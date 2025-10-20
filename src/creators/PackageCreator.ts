import * as fs from 'fs-extra';
import * as path from 'path';
import archiver from 'archiver';
import { execSync } from 'child_process';
import { IPackageCreator } from '../interfaces';
import { SolutionPackage, ResourceReference } from '../types';
import { MSAppGeneratorError } from '../errors';
import { ErrorCategory } from '../types';

/**
 * Creator for .msapp packages
 */
export class PackageCreator implements IPackageCreator {
  private tempDir: string;

  constructor() {
    this.tempDir = path.join(process.cwd(), '.temp', 'packages');
  }

  async createPackage(solutionPackage: SolutionPackage): Promise<Buffer> {
    try {
      await fs.ensureDir(this.tempDir);
      
      const packagePath = path.join(this.tempDir, `${solutionPackage.metadata.uniqueName}.msapp`);
      
      // Create the .msapp package structure
      const packageDir = path.join(this.tempDir, solutionPackage.metadata.uniqueName);
      await fs.ensureDir(packageDir);

      // Generate package manifest
      await this.generatePackageManifest(packageDir, solutionPackage);

      // Generate app definition
      await this.generateAppDefinition(packageDir, solutionPackage);

      // Generate connection references
      await this.generateConnectionReferences(packageDir, solutionPackage);

      // Create the .msapp archive
      const packageBuffer = await this.createArchive(packageDir, packagePath);

      // Cleanup temporary directory
      await fs.remove(packageDir);

      return packageBuffer;
    } catch (error) {
      throw new MSAppGeneratorError(
        `Failed to create package: ${error instanceof Error ? error.message : String(error)}`,
        ErrorCategory.PACKAGE
      );
    }
  }

  async addResources(packageBuffer: Buffer, resources: ResourceReference[]): Promise<Buffer> {
    try {
      if (resources.length === 0) {
        return packageBuffer;
      }

      // Extract existing package to temporary directory
      const extractDir = path.join(this.tempDir, 'extract_' + Date.now());
      const packageRoot = path.join(extractDir, 'package');
      await fs.ensureDir(packageRoot);

      // Write buffer to temporary file for extraction
      const tempPackagePath = path.join(extractDir, 'temp.msapp');
      await fs.writeFile(tempPackagePath, packageBuffer);

      // Extract package (assuming it's a ZIP file)
      await this.extractArchive(tempPackagePath, packageRoot);

      // Temporary archive is no longer needed after extraction
      await fs.remove(tempPackagePath);

      // Add resources to the package
      const resourcesDir = path.join(packageRoot, 'Resources');
      await fs.ensureDir(resourcesDir);

      for (const resource of resources) {
        const resourcePath = path.resolve(resource.path);

        if (!await fs.pathExists(resourcePath)) {
          throw new MSAppGeneratorError(
            `Resource file not found: ${resourcePath}`,
            ErrorCategory.PACKAGE,
            resource.path
          );
        }

        const resourceContent = await fs.readFile(resourcePath);
        const resourceFileName = `${resource.name}${path.extname(resource.path)}`;
        
        await fs.writeFile(
          path.join(resourcesDir, resourceFileName),
          resourceContent
        );

        // Update resource manifest
        await this.updateResourceManifest(packageRoot, resource, resourceFileName);
      }

      // Recreate the package with resources
      const newPackagePath = path.join(this.tempDir, `updated_${Date.now()}.msapp`);
      const updatedBuffer = await this.createArchive(packageRoot, newPackagePath);

      // Remove the regenerated package file from the temp directory
      await fs.remove(newPackagePath);

      // Cleanup
      await fs.remove(extractDir);

      return updatedBuffer;
    } catch (error) {
      if (error instanceof MSAppGeneratorError) {
        throw error;
      }
      throw new MSAppGeneratorError(
        `Failed to add resources: ${error instanceof Error ? error.message : String(error)}`,
        ErrorCategory.PACKAGE
      );
    }
  }

  async signPackage(packageBuffer: Buffer): Promise<Buffer> {
    try {
      // Note: Package signing would require enterprise certificates
      // For now, return the package as-is
      console.warn('Package signing is not implemented. Enterprise deployment may require signed packages.');
      return packageBuffer;
    } catch (error) {
      throw new MSAppGeneratorError(
        `Failed to sign package: ${error instanceof Error ? error.message : String(error)}`,
        ErrorCategory.PACKAGE
      );
    }
  }

  async writePackage(packageBuffer: Buffer, outputPath: string): Promise<void> {
    try {
      // Ensure output directory exists
      const outputDir = path.dirname(outputPath);
      await fs.ensureDir(outputDir);

      // Write package to file
      await fs.writeFile(outputPath, packageBuffer);

      console.log(`Package written to: ${outputPath}`);
    } catch (error) {
      throw new MSAppGeneratorError(
        `Failed to write package: ${error instanceof Error ? error.message : String(error)}`,
        ErrorCategory.PACKAGE,
        outputPath
      );
    }
  }

  async extractPackage(packagePath: string): Promise<SolutionPackage> {
    const extractDir = path.join(this.tempDir, 'extract_' + Date.now());
    try {
      if (!await fs.pathExists(packagePath)) {
        throw new MSAppGeneratorError(
          `Package file not found: ${packagePath}`,
          ErrorCategory.PACKAGE,
          packagePath
        );
      }

      await fs.ensureDir(extractDir);

      // Extract the .msapp package
      await this.extractArchive(packagePath, extractDir);

      // Read package manifest
      const manifestPath = path.join(extractDir, 'Manifest.json');
      if (!await fs.pathExists(manifestPath)) {
        throw new MSAppGeneratorError(
          'Invalid package: Manifest.json not found',
          ErrorCategory.PACKAGE,
          packagePath
        );
      }

      const manifest = await fs.readJSON(manifestPath);

      // Reconstruct solution package from extracted files
      const solutionPackage: SolutionPackage = {
        metadata: {
          uniqueName: manifest.uniqueName,
          displayName: manifest.displayName,
          description: manifest.description,
          version: manifest.version,
          publisher: manifest.publisher
        },
        canvasApp: manifest.canvasApp,
        connections: manifest.connections || [],
        resources: []
      };

      // Load resources if they exist
      const resourcesDir = path.join(extractDir, 'Resources');
      if (await fs.pathExists(resourcesDir)) {
        const resourceFiles = await fs.readdir(resourcesDir);
        
        for (const fileName of resourceFiles) {
          const filePath = path.join(resourcesDir, fileName);
          const content = await fs.readFile(filePath);
          
          solutionPackage.resources.push({
            name: path.parse(fileName).name,
            content,
            mimeType: this.getMimeType(fileName)
          });
        }
      }

      return solutionPackage;
    } catch (error) {
      if (error instanceof MSAppGeneratorError) {
        throw error;
      }
      throw new MSAppGeneratorError(
        `Failed to extract package: ${error instanceof Error ? error.message : String(error)}`,
        ErrorCategory.PACKAGE,
        packagePath
      );
    } finally {
      // Cleanup extraction directory
      try {
        await fs.remove(extractDir);
      } catch (cleanupError) {
        console.warn(`Warning: Failed to cleanup extraction directory: ${cleanupError}`);
      }
    }
  }

  private async generatePackageManifest(packageDir: string, solutionPackage: SolutionPackage): Promise<void> {
    const manifest = {
      uniqueName: solutionPackage.metadata.uniqueName,
      displayName: solutionPackage.metadata.displayName,
      description: solutionPackage.metadata.description,
      version: solutionPackage.metadata.version,
      publisher: solutionPackage.metadata.publisher,
      canvasApp: {
        name: solutionPackage.canvasApp.name,
        displayName: solutionPackage.canvasApp.displayName,
        description: solutionPackage.canvasApp.description,
        screenCount: solutionPackage.canvasApp.screens.length,
        componentCount: solutionPackage.canvasApp.components.length
      },
      connections: solutionPackage.connections.map(conn => ({
        name: conn.name,
        type: conn.type,
        displayName: conn.displayName
      })),
      resources: solutionPackage.resources.map(res => ({
        name: res.name,
        mimeType: res.mimeType
      })),
      createdOn: new Date().toISOString(),
      fileFormat: '1.333',
      minClientVersion: '3.22103.17'
    };

    await fs.writeJSON(
      path.join(packageDir, 'Manifest.json'),
      manifest,
      { spaces: 2 }
    );
  }

  private async generateAppDefinition(packageDir: string, solutionPackage: SolutionPackage): Promise<void> {
    const appDir = path.join(packageDir, 'App');
    await fs.ensureDir(appDir);

    // Generate app properties
    const appProperties = {
      name: solutionPackage.canvasApp.name,
      displayName: solutionPackage.canvasApp.displayName,
      description: solutionPackage.canvasApp.description,
      properties: solutionPackage.canvasApp.properties,
      documentLayoutWidth: solutionPackage.canvasApp.properties.documentLayoutWidth || 1366,
      documentLayoutHeight: solutionPackage.canvasApp.properties.documentLayoutHeight || 768,
      documentLayoutOrientation: solutionPackage.canvasApp.properties.documentLayoutOrientation || 'landscape'
    };

    await fs.writeJSON(
      path.join(appDir, 'Properties.json'),
      appProperties,
      { spaces: 2 }
    );

    // Generate screens
    const screensDir = path.join(appDir, 'Screens');
    await fs.ensureDir(screensDir);

    for (const screen of solutionPackage.canvasApp.screens) {
      const screenData = {
        name: screen.name,
        controls: screen.controls,
        properties: screen.properties,
        formulas: screen.formulas
      };

      await fs.writeJSON(
        path.join(screensDir, `${screen.name}.json`),
        screenData,
        { spaces: 2 }
      );
    }

    // Generate components
    if (solutionPackage.canvasApp.components.length > 0) {
      const componentsDir = path.join(appDir, 'Components');
      await fs.ensureDir(componentsDir);

      for (const component of solutionPackage.canvasApp.components) {
        const componentData = {
          name: component.name,
          type: component.type,
          properties: component.properties,
          customProperties: component.customProperties,
          children: component.children
        };

        await fs.writeJSON(
          path.join(componentsDir, `${component.name}.json`),
          componentData,
          { spaces: 2 }
        );
      }
    }
  }

  private async generateConnectionReferences(packageDir: string, solutionPackage: SolutionPackage): Promise<void> {
    if (solutionPackage.connections.length === 0) {
      return;
    }

    const connectionsDir = path.join(packageDir, 'Connections');
    await fs.ensureDir(connectionsDir);

    for (const connection of solutionPackage.connections) {
      const connectionData = {
        name: connection.name,
        type: connection.type,
        displayName: connection.displayName,
        connectionId: connection.connectionId,
        parameters: connection.parameters || {}
      };

      await fs.writeJSON(
        path.join(connectionsDir, `${connection.name}.json`),
        connectionData,
        { spaces: 2 }
      );
    }
  }

  private async createArchive(sourceDir: string, outputPath: string): Promise<Buffer> {
    return new Promise((resolve, reject) => {
      const output = fs.createWriteStream(outputPath);
      const archive = archiver('zip', { zlib: { level: 9 } });

      output.on('close', async () => {
        try {
          const buffer = await fs.readFile(outputPath);
          resolve(buffer);
        } catch (error) {
          reject(error);
        }
      });

      archive.on('error', (err: Error) => {
        reject(err);
      });

      archive.pipe(output);
      archive.directory(sourceDir, false);
      archive.finalize();
    });
  }

  private async extractArchive(archivePath: string, extractDir: string): Promise<void> {
    try {
      // Use system unzip command for simplicity
      // In production, you might want to use a proper ZIP library
      execSync(`unzip -q "${archivePath}" -d "${extractDir}"`, { stdio: 'pipe' });
    } catch (error) {
      // Fallback: try using PowerShell on Windows
      try {
        execSync(`powershell -command "Expand-Archive -Path '${archivePath}' -DestinationPath '${extractDir}'"`, { stdio: 'pipe' });
      } catch (fallbackError) {
        throw new MSAppGeneratorError(
          'Failed to extract archive. Please ensure unzip or PowerShell is available.',
          ErrorCategory.PACKAGE
        );
      }
    }
  }

  private async updateResourceManifest(packageDir: string, resource: ResourceReference, fileName: string): Promise<void> {
    const manifestPath = path.join(packageDir, 'Manifest.json');
    
    if (await fs.pathExists(manifestPath)) {
      const manifest = await fs.readJSON(manifestPath);
      
      if (!manifest.resources) {
        manifest.resources = [];
      }

      manifest.resources.push({
        name: resource.name,
        type: resource.type,
        fileName: fileName,
        mimeType: resource.mimeType || this.getMimeType(fileName)
      });

      await fs.writeJSON(manifestPath, manifest, { spaces: 2 });
    }
  }

  private getMimeType(fileName: string): string {
    const ext = path.extname(fileName).toLowerCase();
    const mimeTypes: Record<string, string> = {
      '.png': 'image/png',
      '.jpg': 'image/jpeg',
      '.jpeg': 'image/jpeg',
      '.gif': 'image/gif',
      '.svg': 'image/svg+xml',
      '.ico': 'image/x-icon',
      '.pdf': 'application/pdf',
      '.json': 'application/json',
      '.xml': 'application/xml',
      '.txt': 'text/plain'
    };

    return mimeTypes[ext] || 'application/octet-stream';
  }
}