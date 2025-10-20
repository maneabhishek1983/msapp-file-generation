import * as fs from 'fs-extra';
import * as os from 'os';
import * as path from 'path';
import { IValidationEngine } from '../interfaces';
import { ValidationResult, DependencyResult, ErrorCategory } from '../types';
import { MSAppGeneratorError } from '../errors';
import { FXParser } from '../parsers/FXParser';
import { MetadataProcessor } from '../processors/MetadataProcessor';
import { PowerFxHeuristics } from './PowerFxHeuristics';
import AdmZip from 'adm-zip';
import { glob } from 'glob';

/**
 * Comprehensive validation engine for Power Apps source code and packages
 */
export class ValidationEngine implements IValidationEngine {
  private fxParser: FXParser;
  private metadataProcessor: MetadataProcessor;
  private heuristics: PowerFxHeuristics;

  constructor() {
    this.fxParser = new FXParser();
    this.metadataProcessor = new MetadataProcessor();
    this.heuristics = new PowerFxHeuristics();
  }

  async validateSourceCode(sourceDir: string): Promise<ValidationResult> {
    const errors: any[] = [];
    const warnings: any[] = [];

    try {
      // Check if source directory exists
      if (!await fs.pathExists(sourceDir)) {
        errors.push({
          message: `Source directory not found: ${sourceDir}`,
          category: ErrorCategory.VALIDATION,
          file: sourceDir
        });
        return { isValid: false, errors, warnings };
      }

      // Validate directory structure
      await this.validateDirectoryStructure(sourceDir, errors, warnings);

      // Find and validate .fx files
      await this.validateFXFiles(sourceDir, errors, warnings);

      // Validate configuration file if present
      await this.validateConfigurationFile(sourceDir, errors, warnings);

      // Validate resource references
      await this.validateResourceReferences(sourceDir, errors, warnings);

      // Check for common issues
      await this.validateCommonIssues(sourceDir, errors, warnings);

      // Run heuristic guardrails for known Canvas app pitfalls
      await this.heuristics.analyze(sourceDir, errors, warnings);

      return {
        isValid: errors.length === 0,
        errors,
        warnings
      };
    } catch (error) {
      errors.push({
        message: `Source code validation failed: ${error instanceof Error ? error.message : String(error)}`,
        category: ErrorCategory.VALIDATION
      });

      return {
        isValid: false,
        errors,
        warnings
      };
    }
  }

  async validatePackage(packagePath: string): Promise<ValidationResult> {
    const errors: any[] = [];
    const warnings: any[] = [];

    try {
      // Check if package file exists
      if (!await fs.pathExists(packagePath)) {
        errors.push({
          message: `Package file not found: ${packagePath}`,
          category: ErrorCategory.VALIDATION,
          file: packagePath
        });
        return { isValid: false, errors, warnings };
      }

      // Validate file extension
      const hasMsappExtension = packagePath.toLowerCase().endsWith('.msapp');

      if (!hasMsappExtension) {
        warnings.push({
          message: 'Package file should have .msapp extension',
          file: packagePath
        });
      }

      // Validate package size
      const stats = await fs.stat(packagePath);
      if (stats.size === 0) {
        errors.push({
          message: 'Package file is empty',
          category: ErrorCategory.VALIDATION,
          file: packagePath
        });
      } else if (stats.size > 50 * 1024 * 1024) { // 50MB
        warnings.push({
          message: 'Package file is larger than 50MB, which may cause import issues',
          file: packagePath
        });
      }

      // Validate package structure (extract and inspect manifest/resources)
      if (hasMsappExtension) {
        await this.validatePackageStructure(packagePath, errors, warnings);
      }

      return {
        isValid: errors.length === 0,
        errors,
        warnings
      };
    } catch (error) {
      errors.push({
        message: `Package validation failed: ${error instanceof Error ? error.message : String(error)}`,
        category: ErrorCategory.VALIDATION,
        file: packagePath
      });

      return {
        isValid: false,
        errors,
        warnings
      };
    }
  }

  async checkDependencies(): Promise<DependencyResult> {
    const missing: string[] = [];
    const conflicts: string[] = [];

    try {
      // Check for Power Platform CLI
      try {
        const { execSync } = require('child_process');
        execSync('pac --version', { stdio: 'pipe' });
      } catch (error) {
        missing.push('Power Platform CLI (pac) - Install from https://aka.ms/PowerPlatformCLI');
      }

      // Check for Node.js version
      const nodeVersion = process.version;
      const majorVersion = parseInt(nodeVersion.slice(1).split('.')[0]);
      
      if (majorVersion < 16) {
        conflicts.push(`Node.js version ${nodeVersion} is not supported. Minimum required: 16.0.0`);
      }

      // Check for required npm packages
      const requiredPackages = [
        'typescript',
        'fs-extra',
        'glob',
        'commander',
        'chalk',
        'ora'
      ];

      for (const pkg of requiredPackages) {
        try {
          require.resolve(pkg);
        } catch (error) {
          missing.push(`npm package: ${pkg}`);
        }
      }

      // Check for system utilities
      const systemUtils = [
        { command: 'git --version', name: 'Git' },
        { command: 'zip --version', name: 'zip utility' }
      ];

      for (const util of systemUtils) {
        try {
          const { execSync } = require('child_process');
          execSync(util.command, { stdio: 'pipe' });
        } catch (error) {
          missing.push(util.name);
        }
      }

      return {
        satisfied: missing.length === 0 && conflicts.length === 0,
        missing,
        conflicts
      };
    } catch (error) {
      return {
        satisfied: false,
        missing: ['Dependency check failed'],
        conflicts: []
      };
    }
  }

  async dryRunValidation(sourceDir: string, configFile?: string): Promise<ValidationResult> {
    const errors: any[] = [];
    const warnings: any[] = [];

    try {
      console.log('🔍 Starting dry run validation...');

      // Validate source code
      const sourceValidation = await this.validateSourceCode(sourceDir);
      errors.push(...sourceValidation.errors);
      warnings.push(...sourceValidation.warnings);

      // Check dependencies
      const dependencyCheck = await this.checkDependencies();
      if (!dependencyCheck.satisfied) {
        dependencyCheck.missing.forEach(dep => {
          errors.push({
            message: `Missing dependency: ${dep}`,
            category: ErrorCategory.DEPENDENCY
          });
        });

        dependencyCheck.conflicts.forEach(conflict => {
          errors.push({
            message: `Dependency conflict: ${conflict}`,
            category: ErrorCategory.DEPENDENCY
          });
        });
      }

      // Validate configuration if provided
      if (configFile) {
        try {
          const config = await this.metadataProcessor.loadConfiguration(configFile);
          const configValidation = this.metadataProcessor.validateConfiguration(config);
          errors.push(...configValidation.errors);
          warnings.push(...configValidation.warnings);
        } catch (error) {
          errors.push({
            message: `Configuration validation failed: ${error instanceof Error ? error.message : String(error)}`,
            category: ErrorCategory.CONFIGURATION,
            file: configFile
          });
        }
      }

      // Simulate parsing process
      try {
        const { screens, components } = await this.fxParser.parseDirectory(sourceDir);
        
        if (screens.length === 0) {
          warnings.push({
            message: 'No screens found in source directory',
            category: ErrorCategory.VALIDATION
          });
        }

        console.log(`✅ Found ${screens.length} screens and ${components.length} components`);
      } catch (error) {
        errors.push({
          message: `Failed to parse source files: ${error instanceof Error ? error.message : String(error)}`,
          category: ErrorCategory.SYNTAX
        });
      }

      console.log(`🔍 Dry run completed: ${errors.length} errors, ${warnings.length} warnings`);

      return {
        isValid: errors.length === 0,
        errors,
        warnings
      };
    } catch (error) {
      errors.push({
        message: `Dry run validation failed: ${error instanceof Error ? error.message : String(error)}`,
        category: ErrorCategory.VALIDATION
      });

      return {
        isValid: false,
        errors,
        warnings
      };
    }
  }

  async validateImportCompatibility(packagePath: string): Promise<ValidationResult> {
    const errors: any[] = [];
    const warnings: any[] = [];

    try {
      // Basic package validation
      const packageValidation = await this.validatePackage(packagePath);
      errors.push(...packageValidation.errors);
      warnings.push(...packageValidation.warnings);

      // Check Power Apps compatibility
      await this.validatePowerAppsCompatibility(packagePath, errors, warnings);

      // Check for known import issues
      await this.validateKnownImportIssues(packagePath, errors, warnings);

      return {
        isValid: errors.length === 0,
        errors,
        warnings
      };
    } catch (error) {
      errors.push({
        message: `Import compatibility validation failed: ${error instanceof Error ? error.message : String(error)}`,
        category: ErrorCategory.VALIDATION,
        file: packagePath
      });

      return {
        isValid: false,
        errors,
        warnings
      };
    }
  }

  private async validateDirectoryStructure(sourceDir: string, errors: any[], warnings: any[]): Promise<void> {
    const expectedDirs = ['screens', 'components', 'assets'];
    const foundDirs: string[] = [];

    try {
      const items = await fs.readdir(sourceDir, { withFileTypes: true });
      
      for (const item of items) {
        if (item.isDirectory()) {
          foundDirs.push(item.name.toLowerCase());
        }
      }

      // Check for expected directories
      for (const expectedDir of expectedDirs) {
        if (!foundDirs.includes(expectedDir)) {
          warnings.push({
            message: `Recommended directory '${expectedDir}' not found`,
            category: ErrorCategory.VALIDATION
          });
        }
      }

      // Check for .fx files in root (should be in subdirectories)
      const rootFiles = await fs.readdir(sourceDir);
      const rootFxFiles = rootFiles.filter(file => file.endsWith('.fx'));
      
      if (rootFxFiles.length > 0) {
        warnings.push({
          message: `Found .fx files in root directory. Consider organizing them in 'screens' or 'components' folders`,
          category: ErrorCategory.VALIDATION
        });
      }
    } catch (error) {
      errors.push({
        message: `Failed to validate directory structure: ${error instanceof Error ? error.message : String(error)}`,
        category: ErrorCategory.VALIDATION
      });
    }
  }

  private async validateFXFiles(sourceDir: string, errors: any[], warnings: any[]): Promise<void> {
    try {
      const { glob } = require('glob');
      const fxFiles = await glob('**/*.fx', { cwd: sourceDir });

      if (fxFiles.length === 0) {
        errors.push({
          message: 'No .fx files found in source directory',
          category: ErrorCategory.VALIDATION
        });
        return;
      }

      for (const fxFile of fxFiles) {
        const filePath = path.join(sourceDir, fxFile);
        
        try {
          // Validate file syntax
          const content = await fs.readFile(filePath, 'utf-8');
          const syntaxValidation = this.fxParser.validateSyntax(content);
          
          syntaxValidation.errors.forEach(error => {
            errors.push({
              ...error,
              file: fxFile
            });
          });

          syntaxValidation.warnings.forEach(warning => {
            warnings.push({
              ...warning,
              file: fxFile
            });
          });

          // Check file size
          const stats = await fs.stat(filePath);
          if (stats.size > 1024 * 1024) { // 1MB
            warnings.push({
              message: 'File is larger than 1MB, which may impact performance',
              file: fxFile
            });
          }

          // Check for empty files
          if (stats.size === 0) {
            warnings.push({
              message: 'File is empty',
              file: fxFile
            });
          }
        } catch (error) {
          errors.push({
            message: `Failed to validate file: ${error instanceof Error ? error.message : String(error)}`,
            category: ErrorCategory.SYNTAX,
            file: fxFile
          });
        }
      }
    } catch (error) {
      errors.push({
        message: `Failed to validate .fx files: ${error instanceof Error ? error.message : String(error)}`,
        category: ErrorCategory.VALIDATION
      });
    }
  }

  private async validateConfigurationFile(sourceDir: string, errors: any[], warnings: any[]): Promise<void> {
    const configPath = path.join(sourceDir, 'msapp-generator.config.json');
    
    if (await fs.pathExists(configPath)) {
      try {
        const config = await this.metadataProcessor.loadConfiguration(configPath);
        const validation = this.metadataProcessor.validateConfiguration(config);
        
        errors.push(...validation.errors);
        warnings.push(...validation.warnings);
      } catch (error) {
        errors.push({
          message: `Configuration file validation failed: ${error instanceof Error ? error.message : String(error)}`,
          category: ErrorCategory.CONFIGURATION,
          file: 'msapp-generator.config.json'
        });
      }
    } else {
      warnings.push({
        message: 'No configuration file found. Using default settings.',
        category: ErrorCategory.CONFIGURATION
      });
    }
  }

  private async validateResourceReferences(sourceDir: string, errors: any[], warnings: any[]): Promise<void> {
    try {
      const assetsDir = path.join(sourceDir, 'assets');
      
      if (await fs.pathExists(assetsDir)) {
        const assetFiles = await fs.readdir(assetsDir);
        
        // Check for common asset types
        const imageFiles = assetFiles.filter(file => 
          /\.(png|jpg|jpeg|gif|svg|ico)$/i.test(file)
        );

        if (imageFiles.length === 0) {
          warnings.push({
            message: 'No image assets found in assets directory',
            category: ErrorCategory.VALIDATION
          });
        }

        // Validate asset file sizes
        for (const assetFile of assetFiles) {
          const assetPath = path.join(assetsDir, assetFile);
          const stats = await fs.stat(assetPath);
          
          if (stats.size > 5 * 1024 * 1024) { // 5MB
            warnings.push({
              message: `Asset file '${assetFile}' is larger than 5MB, which may cause performance issues`,
              file: `assets/${assetFile}`
            });
          }
        }
      }
    } catch (error) {
      warnings.push({
        message: `Failed to validate resource references: ${error instanceof Error ? error.message : String(error)}`,
        category: ErrorCategory.VALIDATION
      });
    }
  }

  private async validateManifestSchema(extractedDir: string, errors: any[], warnings: any[]): Promise<void> {
    const manifestPath = path.join(extractedDir, 'Manifest.json');
    const manifest = await this.readJsonFile(manifestPath, 'Manifest.json', errors);

    if (!manifest) {
      return;
    }

    const requiredKeys = ['AppVersion', 'FormatVersion', 'Properties', 'ScreenOrder'];

    for (const key of requiredKeys) {
      if (!(key in manifest)) {
        const lowerKey = key.charAt(0).toLowerCase() + key.slice(1);
        if (lowerKey in manifest) {
          errors.push({
            message: `Manifest key '${key}' is missing or mis-cased. Use exact casing '${key}'.`,
            category: ErrorCategory.VALIDATION,
            file: 'Manifest.json'
          });
        } else {
          errors.push({
            message: `Manifest key '${key}' is required.`,
            category: ErrorCategory.VALIDATION,
            file: 'Manifest.json'
          });
        }
      }
    }

    if (manifest.FormatVersion && manifest.FormatVersion !== '2.0') {
      warnings.push({
        message: `Unexpected manifest FormatVersion '${manifest.FormatVersion}'. Expected '2.0'.`,
        category: ErrorCategory.VALIDATION,
        file: 'Manifest.json'
      });
    }

    if (manifest.ScreenOrder && !Array.isArray(manifest.ScreenOrder)) {
      errors.push({
        message: 'Manifest ScreenOrder must be an array of screen identifiers.',
        category: ErrorCategory.VALIDATION,
        file: 'Manifest.json'
      });
    }

    if (manifest.Properties === null || (manifest.Properties && typeof manifest.Properties !== 'object')) {
      errors.push({
        message: 'Manifest Properties section must be an object.',
        category: ErrorCategory.VALIDATION,
        file: 'Manifest.json'
      });
    }

    if (Array.isArray(manifest.ScreenOrder) && manifest.ScreenOrder.length === 0) {
      warnings.push({
        message: 'Manifest ScreenOrder is empty. App may not have a deterministically ordered start screen.',
        category: ErrorCategory.VALIDATION,
        file: 'Manifest.json'
      });
    }
  }

  private async readJsonFile(filePath: string, label: string, errors: any[]): Promise<any | undefined> {
    if (!await fs.pathExists(filePath)) {
      errors.push({
        message: `${label} is missing from the package.`,
        category: ErrorCategory.VALIDATION,
        file: label
      });
      return undefined;
    }

    try {
      const raw = await fs.readFile(filePath, 'utf8');
      return JSON.parse(raw);
    } catch (error) {
      errors.push({
        message: `${label} is not valid JSON: ${error instanceof Error ? error.message : String(error)}`,
        category: ErrorCategory.SYNTAX,
        file: label
      });
      return undefined;
    }
  }

  private async validateExtractedResources(extractedDir: string, errors: any[], warnings: any[]): Promise<void> {
    const candidatePaths = [
      path.join(extractedDir, 'Resources.json'),
      path.join(extractedDir, 'Resources', 'Resources.json'),
      path.join(extractedDir, 'References', 'Resources.json')
    ];

    let resourcesPath: string | undefined;
    for (const candidate of candidatePaths) {
      if (await fs.pathExists(candidate)) {
        resourcesPath = candidate;
        break;
      }
    }

    if (!resourcesPath) {
      warnings.push({
        message: 'Resources.json not found in package. Media references cannot be validated.',
        category: ErrorCategory.VALIDATION
      });
      return;
    }

    const resourcesJson = await this.readJsonFile(resourcesPath, path.basename(resourcesPath), errors);

    if (!resourcesJson) {
      return;
    }

    const resourceEntries = Array.isArray(resourcesJson.Resources)
      ? resourcesJson.Resources
      : Array.isArray(resourcesJson.Media)
        ? resourcesJson.Media
        : [];

    for (const resource of resourceEntries) {
      const relativePath: string | undefined = resource?.Path || resource?.path || resource?.FilePath || resource?.filePath;
      if (!relativePath) {
        continue;
      }

      const normalized = relativePath.replace(/\\/g, '/');
      const absolutePath = path.join(extractedDir, normalized);

      if (!await fs.pathExists(absolutePath)) {
        errors.push({
          message: `Resource entry '${normalized}' is referenced but not present in the package.`,
          category: ErrorCategory.VALIDATION,
          file: path.relative(extractedDir, resourcesPath)
        });
      }
    }
  }

  private async validateControlIdentifiers(extractedDir: string, errors: any[]): Promise<void> {
    try {
      const fxFiles = await glob('**/*.fx', { cwd: extractedDir, nodir: true });
      const seenIds = new Map<string, string>();

      for (const relativePath of fxFiles) {
        const absolutePath = path.join(extractedDir, relativePath);
        const content = await fs.readFile(absolutePath, 'utf8');
        const regex = /ControlId\s*:\s*"([0-9a-fA-F-]{36})"/g;
        let match: RegExpExecArray | null;

        // eslint-disable-next-line no-cond-assign
        while ((match = regex.exec(content)) !== null) {
          const controlId = match[1].toLowerCase();
          const existing = seenIds.get(controlId);

          if (existing && existing !== relativePath) {
            errors.push({
              message: `Duplicate ControlId '${controlId}' found in ${relativePath} and ${existing}.`,
              category: ErrorCategory.VALIDATION,
              file: relativePath
            });
          } else if (!existing) {
            seenIds.set(controlId, relativePath);
          }
        }
      }
    } catch (error) {
      errors.push({
        message: `Failed to validate control identifiers: ${error instanceof Error ? error.message : String(error)}`,
        category: ErrorCategory.VALIDATION
      });
    }
  }

  private async runPacUnpackSmokeTest(packagePath: string, warnings: any[]): Promise<void> {
    let pacAvailable = false;

    try {
      const { execSync } = require('child_process');
      execSync('pac --version', { stdio: 'pipe' });
      pacAvailable = true;
    } catch (error) {
      warnings.push({
        message: 'Power Platform CLI (pac) not available. Skipping unpack smoke test.',
        category: ErrorCategory.DEPENDENCY,
        file: packagePath
      });
    }

    if (!pacAvailable) {
      return;
    }

    let unpackDir: string | undefined;

    try {
      const { execSync } = require('child_process');
      unpackDir = await fs.mkdtemp(path.join(os.tmpdir(), 'msapp-pac-unpack-'));
      execSync(`pac canvas unpack --msapp "${packagePath}" --sources "${unpackDir}"`, { stdio: 'pipe' });
    } catch (error) {
      warnings.push({
        message: `Power Platform CLI failed to unpack package: ${error instanceof Error ? error.message : String(error)}`,
        category: ErrorCategory.VALIDATION,
        file: packagePath
      });
    } finally {
      if (unpackDir) {
        await fs.remove(unpackDir);
      }
    }
  }

  private async validateCommonIssues(sourceDir: string, errors: any[], warnings: any[]): Promise<void> {
    try {
      // Check for files with special characters in names
      const allFiles = await glob('**/*', { cwd: sourceDir });
      
      for (const file of allFiles) {
        if (/[<>:"|?*]/.test(file)) {
          errors.push({
            message: `File name contains invalid characters: ${file}`,
            category: ErrorCategory.VALIDATION,
            file
          });
        }

        if (file.length > 260) {
          warnings.push({
            message: `File path is longer than 260 characters, which may cause issues on Windows: ${file}`,
            category: ErrorCategory.VALIDATION,
            file
          });
        }
      }

      // Check for circular references (basic check)
      await this.validateCircularReferences(sourceDir, errors, warnings);
    } catch (error) {
      warnings.push({
        message: `Failed to validate common issues: ${error instanceof Error ? error.message : String(error)}`,
        category: ErrorCategory.VALIDATION
      });
    }
  }

  private async validateCircularReferences(sourceDir: string, errors: any[], warnings: any[]): Promise<void> {
    // This is a simplified circular reference check
    // In a full implementation, you would parse the actual dependencies
    try {
      const { screens, components } = await this.fxParser.parseDirectory(sourceDir);
      
      // Check for screens navigating to themselves
      for (const screen of screens) {
        const formulas = Object.values(screen.formulas);
        const navigatePattern = new RegExp(`Navigate\\s*\\(\\s*${screen.name}\\s*[,)]`, 'i');
        
        if (formulas.some(formula => navigatePattern.test(formula))) {
          warnings.push({
            message: `Screen '${screen.name}' may contain circular navigation reference`,
            category: ErrorCategory.VALIDATION,
            file: screen.file
          });
        }
      }
    } catch (error) {
      // Ignore errors in circular reference check as it's not critical
    }
  }

  private async validatePackageStructure(packagePath: string, errors: any[], warnings: any[]): Promise<void> {
    let tempDir: string | undefined;

    try {
      const initialErrorCount = errors.length;
      const stats = await fs.stat(packagePath);

      if (stats.size < 1024) { // Less than 1KB
        warnings.push({
          message: 'Package file seems unusually small',
          file: packagePath
        });
      }

      let zip: AdmZip;

      try {
        zip = new AdmZip(packagePath);
      } catch (zipError) {
        errors.push({
          message: `Failed to read package archive: ${zipError instanceof Error ? zipError.message : String(zipError)}`,
          category: ErrorCategory.VALIDATION,
          file: packagePath
        });
        return;
      }

      const entries = zip.getEntries().filter(entry => !entry.isDirectory);

      if (entries.length === 0) {
        errors.push({
          message: 'Package archive does not contain any files',
          category: ErrorCategory.VALIDATION,
          file: packagePath
        });
        return;
      }

      const hasRootFiles = entries.some(entry => !entry.entryName.includes('/'));
      const firstSegments = new Set(entries.map(entry => entry.entryName.split('/')[0]));

      if (!hasRootFiles && firstSegments.size === 1) {
        errors.push({
          message: `Package archive is nested under '${Array.from(firstSegments)[0]}'. Files must be stored at the root of the .msapp archive`,
          category: ErrorCategory.VALIDATION,
          file: packagePath
        });
        return;
      }

      const requiredFiles = ['App.json', 'Manifest.json', 'Properties.json'];
      for (const required of requiredFiles) {
        if (!entries.some(entry => entry.entryName === required)) {
          const caseMismatch = entries.find(entry => entry.entryName.toLowerCase() === required.toLowerCase());
          const suggestion = caseMismatch ? ` Did you mean '${caseMismatch.entryName}'?` : '';
          errors.push({
            message: `Missing required file '${required}' in package.${suggestion}`,
            category: ErrorCategory.VALIDATION,
            file: packagePath
          });
        }
      }

      if (errors.length > initialErrorCount) {
        return;
      }

      tempDir = await fs.mkdtemp(path.join(os.tmpdir(), 'msapp-validate-'));
      zip.extractAllTo(tempDir, true);

      await this.validateManifestSchema(tempDir, errors, warnings);
      await this.readJsonFile(path.join(tempDir, 'App.json'), 'App.json', errors);
      await this.readJsonFile(path.join(tempDir, 'Properties.json'), 'Properties.json', errors);
      await this.validateExtractedResources(tempDir, errors, warnings);
      await this.validateControlIdentifiers(tempDir, errors);
      await this.runPacUnpackSmokeTest(packagePath, warnings);
    } catch (error) {
      errors.push({
        message: `Failed to validate package structure: ${error instanceof Error ? error.message : String(error)}`,
        category: ErrorCategory.VALIDATION,
        file: packagePath
      });
    } finally {
      if (tempDir) {
        await fs.remove(tempDir);
      }
    }
  }

  private async validatePowerAppsCompatibility(packagePath: string, errors: any[], warnings: any[]): Promise<void> {
    // Check for Power Apps version compatibility
    warnings.push({
      message: 'Package compatibility with specific Power Apps versions cannot be determined without extraction',
      file: packagePath
    });
  }

  private async validateKnownImportIssues(packagePath: string, errors: any[], warnings: any[]): Promise<void> {
    // Check for known issues that cause import failures
    const fileName = path.basename(packagePath);
    
    if (fileName.includes(' ')) {
      warnings.push({
        message: 'Package file name contains spaces, which may cause import issues in some environments',
        file: packagePath
      });
    }

    if (fileName.length > 100) {
      warnings.push({
        message: 'Package file name is longer than 100 characters, which may cause import issues',
        file: packagePath
      });
    }
  }
}