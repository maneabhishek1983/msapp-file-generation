import * as fs from 'fs-extra';
import * as path from 'path';
import { IMetadataProcessor } from '../interfaces';
import { AppConfiguration, SolutionMetadata, ValidationResult, ErrorCategory } from '../types';
import { MSAppGeneratorError } from '../errors';

/**
 * Processor for application metadata and configuration
 */
export class MetadataProcessor implements IMetadataProcessor {

  async loadConfiguration(configPath: string): Promise<AppConfiguration> {
    try {
      if (!await fs.pathExists(configPath)) {
        throw new MSAppGeneratorError(
          `Configuration file not found: ${configPath}`,
          ErrorCategory.CONFIGURATION,
          configPath
        );
      }

      const configContent = await fs.readFile(configPath, 'utf-8');
      const config = JSON.parse(configContent) as AppConfiguration;

      // Validate configuration structure
      const validation = this.validateConfiguration(config);
      if (!validation.isValid) {
        throw new MSAppGeneratorError(
          `Invalid configuration: ${validation.errors.map(e => e.message).join(', ')}`,
          ErrorCategory.CONFIGURATION,
          configPath
        );
      }

      return config;
    } catch (error) {
      if (error instanceof MSAppGeneratorError) {
        throw error;
      }
      throw new MSAppGeneratorError(
        `Failed to load configuration: ${error instanceof Error ? error.message : String(error)}`,
        ErrorCategory.CONFIGURATION,
        configPath
      );
    }
  }

  async processMetadata(config: AppConfiguration): Promise<SolutionMetadata> {
    try {
      return {
        uniqueName: this.generateUniqueName(config.app.name),
        displayName: config.app.displayName,
        description: config.app.description,
        version: config.app.version,
        publisher: config.app.publisher
      };
    } catch (error) {
      throw new MSAppGeneratorError(
        `Failed to process metadata: ${error instanceof Error ? error.message : String(error)}`,
        ErrorCategory.CONFIGURATION
      );
    }
  }

  validateConfiguration(config: AppConfiguration): ValidationResult {
    const errors: any[] = [];
    const warnings: any[] = [];

    try {
      // Validate app info
      if (!config.app) {
        errors.push({
          message: 'App configuration is required',
          category: ErrorCategory.CONFIGURATION
        });
      } else {
        this.validateAppInfo(config.app, errors, warnings);
      }

      // Validate publisher info
      if (!config.app?.publisher) {
        errors.push({
          message: 'Publisher information is required',
          category: ErrorCategory.CONFIGURATION
        });
      } else {
        this.validatePublisherInfo(config.app.publisher, errors, warnings);
      }

      // Validate screens and components
      this.validateScreensAndComponents(config, errors, warnings);

      // Validate connections
      this.validateConnections(config.connections || [], errors, warnings);

      // Validate resources
      this.validateResources(config.resources || [], errors, warnings);

      // Validate settings
      this.validateSettings(config.settings || {}, errors, warnings);

      return {
        isValid: errors.length === 0,
        errors,
        warnings
      };
    } catch (error) {
      errors.push({
        message: `Configuration validation failed: ${error instanceof Error ? error.message : String(error)}`,
        category: ErrorCategory.CONFIGURATION
      });

      return {
        isValid: false,
        errors,
        warnings
      };
    }
  }

  substituteParameters(config: AppConfiguration, environment: string): AppConfiguration {
    try {
      // Deep clone the configuration
      const substitutedConfig = JSON.parse(JSON.stringify(config));

      // Define environment-specific parameter mappings
      const parameterMappings = this.getParameterMappings(environment);

      // Recursively substitute parameters
      this.substituteInObject(substitutedConfig, parameterMappings);

      return substitutedConfig;
    } catch (error) {
      throw new MSAppGeneratorError(
        `Failed to substitute parameters: ${error instanceof Error ? error.message : String(error)}`,
        ErrorCategory.CONFIGURATION
      );
    }
  }

  createDefaultConfiguration(): AppConfiguration {
    return {
      app: {
        name: 'MyPowerApp',
        displayName: 'My Power App',
        description: 'A Power Apps application generated from source code',
        version: '1.0.0.0',
        publisher: {
          name: 'DefaultPublisher',
          displayName: 'Default Publisher',
          prefix: 'def',
          uniqueName: 'DefaultPublisher'
        }
      },
      screens: [],
      components: [],
      connections: [],
      resources: [],
      settings: {
        enableFormulas: true,
        enableComponents: true,
        theme: 'default'
      }
    };
  }

  private validateAppInfo(appInfo: any, errors: any[], warnings: any[]): void {
    const requiredFields = ['name', 'displayName', 'description', 'version'];
    
    for (const field of requiredFields) {
      if (!appInfo[field] || typeof appInfo[field] !== 'string' || appInfo[field].trim() === '') {
        errors.push({
          message: `App ${field} is required and must be a non-empty string`,
          category: ErrorCategory.CONFIGURATION
        });
      }
    }

    // Validate version format
    if (appInfo.version && !this.isValidVersion(appInfo.version)) {
      errors.push({
        message: 'App version must be in format x.x.x.x (e.g., 1.0.0.0)',
        category: ErrorCategory.CONFIGURATION
      });
    }

    // Validate name format (no spaces, special characters)
    if (appInfo.name && !/^[a-zA-Z][a-zA-Z0-9_]*$/.test(appInfo.name)) {
      errors.push({
        message: 'App name must start with a letter and contain only letters, numbers, and underscores',
        category: ErrorCategory.CONFIGURATION
      });
    }

    // Check for reasonable length limits
    if (appInfo.displayName && appInfo.displayName.length > 100) {
      warnings.push({
        message: 'App display name is longer than 100 characters',
        category: ErrorCategory.CONFIGURATION
      });
    }

    if (appInfo.description && appInfo.description.length > 500) {
      warnings.push({
        message: 'App description is longer than 500 characters',
        category: ErrorCategory.CONFIGURATION
      });
    }
  }

  private validatePublisherInfo(publisher: any, errors: any[], warnings: any[]): void {
    const requiredFields = ['name', 'displayName', 'prefix', 'uniqueName'];
    
    for (const field of requiredFields) {
      if (!publisher[field] || typeof publisher[field] !== 'string' || publisher[field].trim() === '') {
        errors.push({
          message: `Publisher ${field} is required and must be a non-empty string`,
          category: ErrorCategory.CONFIGURATION
        });
      }
    }

    // Validate prefix format (3-8 lowercase letters)
    if (publisher.prefix && !/^[a-z]{3,8}$/.test(publisher.prefix)) {
      errors.push({
        message: 'Publisher prefix must be 3-8 lowercase letters',
        category: ErrorCategory.CONFIGURATION
      });
    }

    // Validate unique name format
    if (publisher.uniqueName && !/^[a-zA-Z][a-zA-Z0-9_]*$/.test(publisher.uniqueName)) {
      errors.push({
        message: 'Publisher unique name must start with a letter and contain only letters, numbers, and underscores',
        category: ErrorCategory.CONFIGURATION
      });
    }
  }

  private validateScreensAndComponents(config: AppConfiguration, errors: any[], warnings: any[]): void {
    // Validate screens array
    if (!Array.isArray(config.screens)) {
      errors.push({
        message: 'Screens must be an array',
        category: ErrorCategory.CONFIGURATION
      });
    } else if (config.screens.length === 0) {
      warnings.push({
        message: 'No screens defined in configuration',
        category: ErrorCategory.CONFIGURATION
      });
    }

    // Validate components array
    if (!Array.isArray(config.components)) {
      errors.push({
        message: 'Components must be an array',
        category: ErrorCategory.CONFIGURATION
      });
    }

    // Check for duplicate screen/component names
    const allNames = [...(config.screens || []), ...(config.components || [])];
    const duplicates = allNames.filter((name, index) => allNames.indexOf(name) !== index);
    
    if (duplicates.length > 0) {
      errors.push({
        message: `Duplicate screen/component names found: ${duplicates.join(', ')}`,
        category: ErrorCategory.CONFIGURATION
      });
    }
  }

  private validateConnections(connections: any[], errors: any[], warnings: any[]): void {
    for (let i = 0; i < connections.length; i++) {
      const connection = connections[i];
      
      if (!connection.name || typeof connection.name !== 'string') {
        errors.push({
          message: `Connection ${i}: name is required and must be a string`,
          category: ErrorCategory.CONFIGURATION
        });
      }

      if (!connection.type || typeof connection.type !== 'string') {
        errors.push({
          message: `Connection ${i}: type is required and must be a string`,
          category: ErrorCategory.CONFIGURATION
        });
      }

      if (!connection.displayName || typeof connection.displayName !== 'string') {
        errors.push({
          message: `Connection ${i}: displayName is required and must be a string`,
          category: ErrorCategory.CONFIGURATION
        });
      }

      // Validate connection type
      const validConnectionTypes = [
        'sharepoint', 'sql', 'dataverse', 'excel', 'onedrive',
        'outlook', 'teams', 'powerapps', 'flow', 'custom'
      ];

      if (connection.type && !validConnectionTypes.includes(connection.type.toLowerCase())) {
        warnings.push({
          message: `Connection ${i}: unknown connection type '${connection.type}'`,
          category: ErrorCategory.CONFIGURATION
        });
      }
    }
  }

  private validateResources(resources: any[], errors: any[], warnings: any[]): void {
    for (let i = 0; i < resources.length; i++) {
      const resource = resources[i];
      
      if (!resource.name || typeof resource.name !== 'string') {
        errors.push({
          message: `Resource ${i}: name is required and must be a string`,
          category: ErrorCategory.CONFIGURATION
        });
      }

      if (!resource.type || !['image', 'icon', 'file'].includes(resource.type)) {
        errors.push({
          message: `Resource ${i}: type must be 'image', 'icon', or 'file'`,
          category: ErrorCategory.CONFIGURATION
        });
      }

      if (!resource.path || typeof resource.path !== 'string') {
        errors.push({
          message: `Resource ${i}: path is required and must be a string`,
          category: ErrorCategory.CONFIGURATION
        });
      }

      // Validate file extensions for resource types
      if (resource.type === 'image' && resource.path) {
        const validImageExts = ['.png', '.jpg', '.jpeg', '.gif', '.svg'];
        const ext = path.extname(resource.path).toLowerCase();
        
        if (!validImageExts.includes(ext)) {
          warnings.push({
            message: `Resource ${i}: image file should have extension: ${validImageExts.join(', ')}`,
            category: ErrorCategory.CONFIGURATION
          });
        }
      }
    }
  }

  private validateSettings(settings: any, errors: any[], warnings: any[]): void {
    if (typeof settings !== 'object' || settings === null) {
      errors.push({
        message: 'Settings must be an object',
        category: ErrorCategory.CONFIGURATION
      });
      return;
    }

    // Validate boolean settings
    const booleanSettings = ['enableFormulas', 'enableComponents'];
    for (const setting of booleanSettings) {
      if (settings[setting] !== undefined && typeof settings[setting] !== 'boolean') {
        errors.push({
          message: `Setting '${setting}' must be a boolean`,
          category: ErrorCategory.CONFIGURATION
        });
      }
    }

    // Validate theme setting
    if (settings.theme !== undefined) {
      if (typeof settings.theme !== 'string') {
        errors.push({
          message: 'Theme setting must be a string',
          category: ErrorCategory.CONFIGURATION
        });
      } else {
        const validThemes = ['default', 'dark', 'light', 'custom'];
        if (!validThemes.includes(settings.theme)) {
          warnings.push({
            message: `Unknown theme '${settings.theme}'. Valid themes: ${validThemes.join(', ')}`,
            category: ErrorCategory.CONFIGURATION
          });
        }
      }
    }
  }

  private isValidVersion(version: string): boolean {
    return /^\d+\.\d+\.\d+\.\d+$/.test(version);
  }

  private generateUniqueName(appName: string): string {
    // Convert to valid unique name format
    return appName.replace(/[^a-zA-Z0-9_]/g, '_').replace(/^[^a-zA-Z]/, 'App_');
  }

  private getParameterMappings(environment: string): Record<string, string> {
    // Define environment-specific parameter mappings
    const mappings: Record<string, Record<string, string>> = {
      development: {
        '{{ENVIRONMENT}}': 'dev',
        '{{API_URL}}': 'https://api-dev.example.com',
        '{{DATABASE_NAME}}': 'MyApp_Dev'
      },
      staging: {
        '{{ENVIRONMENT}}': 'staging',
        '{{API_URL}}': 'https://api-staging.example.com',
        '{{DATABASE_NAME}}': 'MyApp_Staging'
      },
      production: {
        '{{ENVIRONMENT}}': 'prod',
        '{{API_URL}}': 'https://api.example.com',
        '{{DATABASE_NAME}}': 'MyApp_Production'
      }
    };

    return mappings[environment] || mappings.development;
  }

  private substituteInObject(obj: any, mappings: Record<string, string>): void {
    for (const key in obj) {
      if (obj.hasOwnProperty(key)) {
        const value = obj[key];
        
        if (typeof value === 'string') {
          // Substitute parameters in string values
          let substituted = value;
          for (const [param, replacement] of Object.entries(mappings)) {
            substituted = substituted.replace(new RegExp(param.replace(/[.*+?^${}()|[\]\\]/g, '\\$&'), 'g'), replacement);
          }
          obj[key] = substituted;
        } else if (typeof value === 'object' && value !== null) {
          // Recursively substitute in nested objects
          this.substituteInObject(value, mappings);
        }
      }
    }
  }
}