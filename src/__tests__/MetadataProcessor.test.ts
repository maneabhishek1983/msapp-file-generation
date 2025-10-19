import { MetadataProcessor } from '../processors/MetadataProcessor';
import { AppConfiguration, ValidationResult } from '../types';
import * as fs from 'fs-extra';
import * as path from 'path';

describe('MetadataProcessor', () => {
  let processor: MetadataProcessor;
  const testConfigPath = path.join(__dirname, '../../examples/msapp-generator.config.json');

  beforeEach(() => {
    processor = new MetadataProcessor();
  });

  describe('loadConfiguration', () => {
    it('should load valid configuration file', async () => {
      if (await fs.pathExists(testConfigPath)) {
        const config = await processor.loadConfiguration(testConfigPath);
        
        expect(config).toBeDefined();
        expect(config.app).toBeDefined();
        expect(config.app.name).toBeDefined();
        expect(config.app.displayName).toBeDefined();
        expect(config.app.version).toBeDefined();
        expect(config.app.publisher).toBeDefined();
      }
    });

    it('should throw error for non-existent file', async () => {
      const nonExistentPath = path.join(__dirname, 'non-existent-config.json');
      
      await expect(processor.loadConfiguration(nonExistentPath)).rejects.toThrow();
    });

    it('should throw error for invalid JSON', async () => {
      const invalidJsonPath = path.join(__dirname, 'invalid-config.json');
      await fs.writeFile(invalidJsonPath, '{ invalid json }');
      
      try {
        await expect(processor.loadConfiguration(invalidJsonPath)).rejects.toThrow();
      } finally {
        await fs.remove(invalidJsonPath);
      }
    });
  });

  describe('validateConfiguration', () => {
    it('should validate correct configuration', () => {
      const validConfig: AppConfiguration = {
        app: {
          name: 'TestApp',
          displayName: 'Test Application',
          description: 'A test application',
          version: '1.0.0.0',
          publisher: {
            name: 'TestPublisher',
            displayName: 'Test Publisher',
            prefix: 'test',
            uniqueName: 'TestPublisher'
          }
        },
        screens: ['HomeScreen', 'DetailScreen'],
        components: ['HeaderComponent'],
        connections: [],
        resources: [],
        settings: {
          enableFormulas: true,
          enableComponents: true,
          theme: 'default'
        }
      };

      const result: ValidationResult = processor.validateConfiguration(validConfig);
      
      expect(result.isValid).toBe(true);
      expect(result.errors).toHaveLength(0);
    });

    it('should detect missing required fields', () => {
      const invalidConfig = {
        app: {
          name: 'TestApp',
          displayName: '',
          description: '',
          version: '',
          publisher: {
            name: '',
            displayName: '',
            prefix: '',
            uniqueName: ''
          }
        },
        screens: [],
        components: [],
        connections: [],
        resources: [],
        settings: {}
      } as AppConfiguration;

      const result: ValidationResult = processor.validateConfiguration(invalidConfig);
      
      expect(result.isValid).toBe(false);
      expect(result.errors.length).toBeGreaterThan(0);
    });

    it('should validate version format', () => {
      const invalidConfig: AppConfiguration = {
        app: {
          name: 'TestApp',
          displayName: 'Test Application',
          description: 'A test application',
          version: '1.0', // Invalid version format
          publisher: {
            name: 'TestPublisher',
            displayName: 'Test Publisher',
            prefix: 'test',
            uniqueName: 'TestPublisher'
          }
        },
        screens: [],
        components: [],
        connections: [],
        resources: [],
        settings: {}
      };

      const result: ValidationResult = processor.validateConfiguration(invalidConfig);
      
      expect(result.isValid).toBe(false);
      expect(result.errors.some(e => e.message.includes('version'))).toBe(true);
    });

    it('should validate publisher prefix format', () => {
      const invalidConfig: AppConfiguration = {
        app: {
          name: 'TestApp',
          displayName: 'Test Application',
          description: 'A test application',
          version: '1.0.0.0',
          publisher: {
            name: 'TestPublisher',
            displayName: 'Test Publisher',
            prefix: 'INVALID_PREFIX', // Invalid prefix format
            uniqueName: 'TestPublisher'
          }
        },
        screens: [],
        components: [],
        connections: [],
        resources: [],
        settings: {}
      };

      const result: ValidationResult = processor.validateConfiguration(invalidConfig);
      
      expect(result.isValid).toBe(false);
      expect(result.errors.some(e => e.message.includes('prefix'))).toBe(true);
    });
  });

  describe('processMetadata', () => {
    it('should process valid configuration to solution metadata', async () => {
      const config: AppConfiguration = {
        app: {
          name: 'TestApp',
          displayName: 'Test Application',
          description: 'A test application',
          version: '1.0.0.0',
          publisher: {
            name: 'TestPublisher',
            displayName: 'Test Publisher',
            prefix: 'test',
            uniqueName: 'TestPublisher'
          }
        },
        screens: [],
        components: [],
        connections: [],
        resources: [],
        settings: {}
      };

      const metadata = await processor.processMetadata(config);
      
      expect(metadata).toBeDefined();
      expect(metadata.uniqueName).toBeDefined();
      expect(metadata.displayName).toBe(config.app.displayName);
      expect(metadata.description).toBe(config.app.description);
      expect(metadata.version).toBe(config.app.version);
      expect(metadata.publisher).toEqual(config.app.publisher);
    });
  });

  describe('substituteParameters', () => {
    it('should substitute environment parameters', () => {
      const config: AppConfiguration = {
        app: {
          name: 'TestApp',
          displayName: 'Test Application - {{ENVIRONMENT}}',
          description: 'A test application for {{ENVIRONMENT}}',
          version: '1.0.0.0',
          publisher: {
            name: 'TestPublisher',
            displayName: 'Test Publisher',
            prefix: 'test',
            uniqueName: 'TestPublisher'
          }
        },
        screens: [],
        components: [],
        connections: [
          {
            name: 'TestConnection',
            type: 'sharepoint',
            displayName: 'SharePoint Connection',
            parameters: {
              siteUrl: '{{API_URL}}/sites/test'
            }
          }
        ],
        resources: [],
        settings: {}
      };

      const substituted = processor.substituteParameters(config, 'development');
      
      expect(substituted.app.displayName).toContain('dev');
      expect(substituted.app.description).toContain('dev');
      expect(substituted.connections[0].parameters?.siteUrl).toContain('api-dev.example.com');
    });

    it('should handle missing environment', () => {
      const config: AppConfiguration = {
        app: {
          name: 'TestApp',
          displayName: 'Test Application - {{ENVIRONMENT}}',
          description: 'A test application',
          version: '1.0.0.0',
          publisher: {
            name: 'TestPublisher',
            displayName: 'Test Publisher',
            prefix: 'test',
            uniqueName: 'TestPublisher'
          }
        },
        screens: [],
        components: [],
        connections: [],
        resources: [],
        settings: {}
      };

      const substituted = processor.substituteParameters(config, 'unknown-env');
      
      // Should fall back to development environment
      expect(substituted.app.displayName).toContain('dev');
    });
  });

  describe('createDefaultConfiguration', () => {
    it('should create valid default configuration', () => {
      const defaultConfig = processor.createDefaultConfiguration();
      
      expect(defaultConfig).toBeDefined();
      expect(defaultConfig.app).toBeDefined();
      expect(defaultConfig.app.name).toBeDefined();
      expect(defaultConfig.app.displayName).toBeDefined();
      expect(defaultConfig.app.version).toBeDefined();
      expect(defaultConfig.app.publisher).toBeDefined();
      expect(Array.isArray(defaultConfig.screens)).toBe(true);
      expect(Array.isArray(defaultConfig.components)).toBe(true);
      expect(Array.isArray(defaultConfig.connections)).toBe(true);
      expect(Array.isArray(defaultConfig.resources)).toBe(true);
      expect(defaultConfig.settings).toBeDefined();

      // Validate the default configuration
      const validation = processor.validateConfiguration(defaultConfig);
      expect(validation.isValid).toBe(true);
    });
  });
});