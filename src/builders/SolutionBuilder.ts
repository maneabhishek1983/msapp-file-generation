import * as fs from 'fs-extra';
import * as path from 'path';
import { execSync } from 'child_process';
import { ISolutionBuilder } from '../interfaces';
import { SolutionMetadata, SolutionProject, CanvasAppDefinition, ScreenDefinition, ComponentDefinition, ConnectionReference, SolutionPackage } from '../types';
import { MSAppGeneratorError } from '../errors';
import { ErrorCategory } from '../types';

/**
 * Builder for Power Platform solutions using Power Platform CLI
 */
export class SolutionBuilder implements ISolutionBuilder {
  private tempDir: string;

  constructor() {
    this.tempDir = path.join(process.cwd(), '.temp', 'solutions');
  }

  async initializeSolution(metadata: SolutionMetadata): Promise<SolutionProject> {
    try {
      // Create temporary directory for solution
      const solutionPath = path.join(this.tempDir, metadata.uniqueName);
      await fs.ensureDir(solutionPath);

      // Check if Power Platform CLI is available
      try {
        execSync('pac --version', { stdio: 'pipe' });
      } catch (error) {
        throw new MSAppGeneratorError(
          'Power Platform CLI (pac) is not installed or not in PATH. Please install it from https://aka.ms/PowerPlatformCLI',
          ErrorCategory.DEPENDENCY
        );
      }

      // Initialize solution using Power Platform CLI
      const initCommand = [
        'pac solution init',
        `--publisher-name "${metadata.publisher.name}"`,
        `--publisher-prefix ${metadata.publisher.prefix}`,
        `--name ${metadata.uniqueName}`,
        `--display-name "${metadata.displayName}"`
      ].join(' ');

      execSync(initCommand, { 
        cwd: solutionPath,
        stdio: 'pipe'
      });

      // Create solution project structure
      const solutionProject: SolutionProject = {
        path: solutionPath,
        metadata,
        canvasApps: [],
        connections: []
      };

      // Create additional directories
      await fs.ensureDir(path.join(solutionPath, 'src', 'CanvasApps'));
      await fs.ensureDir(path.join(solutionPath, 'src', 'ConnectionReferences'));
      await fs.ensureDir(path.join(solutionPath, 'src', 'EnvironmentVariables'));

      return solutionProject;
    } catch (error) {
      if (error instanceof MSAppGeneratorError) {
        throw error;
      }
      throw new MSAppGeneratorError(
        `Failed to initialize solution: ${error instanceof Error ? error.message : String(error)}`,
        ErrorCategory.PACKAGE
      );
    }
  }

  async addCanvasApp(project: SolutionProject, screens: ScreenDefinition[], components: ComponentDefinition[]): Promise<void> {
    try {
      const appName = `${project.metadata.publisher.prefix}_${project.metadata.uniqueName}`;
      const appPath = path.join(project.path, 'src', 'CanvasApps', appName);
      
      // Create canvas app definition
      const canvasApp: CanvasAppDefinition = {
        name: appName,
        displayName: project.metadata.displayName,
        description: project.metadata.description,
        screens,
        components,
        properties: {
          documentLayoutWidth: 1366,
          documentLayoutHeight: 768,
          documentLayoutOrientation: 'landscape',
          documentType: 'App',
          fileFormat: '1.333',
          enableInstrumentation: true
        }
      };

      // Create app directory structure
      await fs.ensureDir(appPath);
      await fs.ensureDir(path.join(appPath, 'Src'));
      await fs.ensureDir(path.join(appPath, 'DataSources'));
      await fs.ensureDir(path.join(appPath, 'Assets'));

      // Generate app manifest
      await this.generateAppManifest(appPath, canvasApp);

      // Generate screen files
      await this.generateScreenFiles(appPath, screens);

      // Generate component files
      await this.generateComponentFiles(appPath, components);

      // Generate app properties
      await this.generateAppProperties(appPath, canvasApp.properties);

      // Add to project
      project.canvasApps.push(canvasApp);

    } catch (error) {
      throw new MSAppGeneratorError(
        `Failed to add canvas app: ${error instanceof Error ? error.message : String(error)}`,
        ErrorCategory.PACKAGE
      );
    }
  }

  async addConnections(project: SolutionProject, connections: ConnectionReference[]): Promise<void> {
    try {
      for (const connection of connections) {
        const connectionPath = path.join(project.path, 'src', 'ConnectionReferences', connection.name);
        await fs.ensureDir(connectionPath);

        // Generate connection reference manifest
        const connectionManifest = {
          connectionReferenceLogicalName: connection.name,
          connectorId: this.getConnectorId(connection.type),
          displayName: connection.displayName,
          description: `Connection reference for ${connection.displayName}`,
          connectionParameters: connection.parameters || {}
        };

        await fs.writeJSON(
          path.join(connectionPath, 'connectionreference.json'),
          connectionManifest,
          { spaces: 2 }
        );

        project.connections.push(connection);
      }
    } catch (error) {
      throw new MSAppGeneratorError(
        `Failed to add connections: ${error instanceof Error ? error.message : String(error)}`,
        ErrorCategory.PACKAGE
      );
    }
  }

  async buildSolution(project: SolutionProject): Promise<SolutionPackage> {
    try {
      // Build solution using Power Platform CLI
      const buildCommand = 'pac solution pack --zipfile solution.zip --folder .';
      
      execSync(buildCommand, {
        cwd: project.path,
        stdio: 'pipe'
      });

      // Read the generated solution package
      const solutionZipPath = path.join(project.path, 'solution.zip');
      const solutionBuffer = await fs.readFile(solutionZipPath);

      // Create solution package structure
      const solutionPackage: SolutionPackage = {
        metadata: project.metadata,
        canvasApp: project.canvasApps[0], // Assuming single app for now
        connections: project.connections,
        resources: [] // Will be populated by PackageCreator
      };

      return solutionPackage;
    } catch (error) {
      throw new MSAppGeneratorError(
        `Failed to build solution: ${error instanceof Error ? error.message : String(error)}`,
        ErrorCategory.PACKAGE
      );
    }
  }

  async cleanup(project: SolutionProject): Promise<void> {
    try {
      // Remove temporary solution directory
      await fs.remove(project.path);
    } catch (error) {
      // Log warning but don't fail the process
      console.warn(`Warning: Failed to cleanup solution directory: ${error instanceof Error ? error.message : String(error)}`);
    }
  }

  private async generateAppManifest(appPath: string, canvasApp: CanvasAppDefinition): Promise<void> {
    const manifest = {
      name: canvasApp.name,
      displayName: canvasApp.displayName,
      description: canvasApp.description,
      documentLayoutWidth: canvasApp.properties.documentLayoutWidth,
      documentLayoutHeight: canvasApp.properties.documentLayoutHeight,
      documentLayoutOrientation: canvasApp.properties.documentLayoutOrientation,
      documentType: canvasApp.properties.documentType,
      fileFormat: canvasApp.properties.fileFormat,
      enableInstrumentation: canvasApp.properties.enableInstrumentation,
      screens: canvasApp.screens.map(screen => ({
        name: screen.name,
        template: 'screen'
      })),
      components: canvasApp.components.map(component => ({
        name: component.name,
        template: 'component'
      }))
    };

    await fs.writeJSON(
      path.join(appPath, 'CanvasManifest.json'),
      manifest,
      { spaces: 2 }
    );
  }

  private async generateScreenFiles(appPath: string, screens: ScreenDefinition[]): Promise<void> {
    const srcPath = path.join(appPath, 'Src');

    for (const screen of screens) {
      // Generate screen JSON structure
      const screenData = {
        TopParent: {
          Name: screen.name,
          Template: 'screen',
          Type: 'ControlInfo',
          Properties: this.convertPropertiesToPowerAppsFormat(screen.properties),
          Children: this.convertControlsToPowerAppsFormat(screen.controls)
        }
      };

      await fs.writeJSON(
        path.join(srcPath, `${screen.name}.json`),
        screenData,
        { spaces: 2 }
      );

      // Generate screen formulas file
      if (Object.keys(screen.formulas).length > 0) {
        const formulasContent = Object.entries(screen.formulas)
          .map(([property, formula]) => `${screen.name}.${property} = ${formula}`)
          .join('\n\n');

        await fs.writeFile(
          path.join(srcPath, `${screen.name}.fx`),
          formulasContent,
          'utf-8'
        );
      }
    }
  }

  private async generateComponentFiles(appPath: string, components: ComponentDefinition[]): Promise<void> {
    const srcPath = path.join(appPath, 'Src');

    for (const component of components) {
      // Generate component JSON structure
      const componentData = {
        TopParent: {
          Name: component.name,
          Template: 'component',
          Type: 'ControlInfo',
          Properties: this.convertPropertiesToPowerAppsFormat(component.properties),
          Children: this.convertControlsToPowerAppsFormat(component.children || []),
          CustomProperties: component.customProperties || []
        }
      };

      await fs.writeJSON(
        path.join(srcPath, `${component.name}.json`),
        componentData,
        { spaces: 2 }
      );
    }
  }

  private async generateAppProperties(appPath: string, properties: any): Promise<void> {
    const propertiesData = {
      DocumentLayoutWidth: properties.documentLayoutWidth,
      DocumentLayoutHeight: properties.documentLayoutHeight,
      DocumentLayoutOrientation: properties.documentLayoutOrientation,
      DocumentType: properties.documentType,
      FileFormat: properties.fileFormat,
      EnableInstrumentation: properties.enableInstrumentation
    };

    await fs.writeJSON(
      path.join(appPath, 'Properties.json'),
      propertiesData,
      { spaces: 2 }
    );
  }

  private convertPropertiesToPowerAppsFormat(properties: any): any {
    const converted: any = {};
    
    for (const [key, value] of Object.entries(properties)) {
      if (typeof value === 'string' && this.isFormula(value as string)) {
        converted[key] = {
          Type: 'Formula',
          Expression: value
        };
      } else {
        converted[key] = {
          Type: 'Literal',
          Value: value
        };
      }
    }
    
    return converted;
  }

  private convertControlsToPowerAppsFormat(controls: any[]): any[] {
    return controls.map(control => ({
      Name: control.name,
      Template: control.type.toLowerCase(),
      Type: 'ControlInfo',
      Properties: this.convertPropertiesToPowerAppsFormat(control.properties),
      Children: control.children ? this.convertControlsToPowerAppsFormat(control.children) : []
    }));
  }

  private isFormula(value: string): boolean {
    // Check if value contains Power Apps functions or operators
    const formulaPatterns = [
      /\b(If|Switch|Filter|LookUp|Patch|Collect|Set|Navigate|Notify)\b/,
      /\b(Parent\.|ThisItem\.|var\w+|col\w+)/,
      /[+\-*/=<>!&|]/,
      /\b(Color\.|Font\.|Align\.)/
    ];
    
    return formulaPatterns.some(pattern => pattern.test(value));
  }

  private getConnectorId(connectionType: string): string {
    const connectorMappings: Record<string, string> = {
      'sharepoint': '/providers/Microsoft.PowerApps/apis/shared_sharepointonline',
      'sql': '/providers/Microsoft.PowerApps/apis/shared_sql',
      'dataverse': '/providers/Microsoft.PowerApps/apis/shared_commondataserviceforapps',
      'excel': '/providers/Microsoft.PowerApps/apis/shared_excelonlinebusiness',
      'onedrive': '/providers/Microsoft.PowerApps/apis/shared_onedriveforbusiness',
      'outlook': '/providers/Microsoft.PowerApps/apis/shared_office365',
      'teams': '/providers/Microsoft.PowerApps/apis/shared_teams',
      'powerapps': '/providers/Microsoft.PowerApps/apis/shared_powerappsforappmakers',
      'flow': '/providers/Microsoft.PowerApps/apis/shared_logicflows'
    };

    return connectorMappings[connectionType.toLowerCase()] || `/providers/Microsoft.PowerApps/apis/shared_${connectionType.toLowerCase()}`;
  }
}