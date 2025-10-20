import { ValidationEngine } from '../validators/ValidationEngine';
import { ValidationResult, DependencyResult } from '../types';
import * as fs from 'fs-extra';
import * as path from 'path';

describe('ValidationEngine', () => {
  let validator: ValidationEngine;
  const testDataDir = path.join(__dirname, '../../examples/sample-app');

  beforeEach(() => {
    validator = new ValidationEngine();
  });

  describe('validateSourceCode', () => {
    it('should validate existing source directory', async () => {
      if (await fs.pathExists(testDataDir)) {
        const result: ValidationResult = await validator.validateSourceCode(testDataDir);
        
        expect(result).toBeDefined();
        expect(result.isValid).toBeDefined();
        expect(Array.isArray(result.errors)).toBe(true);
        expect(Array.isArray(result.warnings)).toBe(true);
      }
    });

    it('should fail for non-existent directory', async () => {
      const nonExistentDir = path.join(__dirname, 'non-existent-dir');
      
      const result: ValidationResult = await validator.validateSourceCode(nonExistentDir);
      
      expect(result.isValid).toBe(false);
      expect(result.errors.length).toBeGreaterThan(0);
      expect(result.errors[0].message).toContain('not found');
    });

    it('should validate directory structure', async () => {
      const tempDir = path.join(__dirname, 'temp-test-dir');
      await fs.ensureDir(tempDir);
      
      try {
        const result: ValidationResult = await validator.validateSourceCode(tempDir);
        
        expect(result).toBeDefined();
        // Should have warnings about missing recommended directories
        expect(result.warnings.some(w => w.message.includes('directory'))).toBe(true);
      } finally {
        await fs.remove(tempDir);
      }
    });
  });

  describe('validatePackage', () => {
    it('should fail for non-existent package', async () => {
      const nonExistentPackage = path.join(__dirname, 'non-existent.msapp');
      
      const result: ValidationResult = await validator.validatePackage(nonExistentPackage);
      
      expect(result.isValid).toBe(false);
      expect(result.errors.length).toBeGreaterThan(0);
      expect(result.errors[0].message).toContain('not found');
    });

    it('should validate package file extension', async () => {
      const tempFile = path.join(__dirname, 'test-package.txt');
      await fs.writeFile(tempFile, 'test content');
      
      try {
        const result: ValidationResult = await validator.validatePackage(tempFile);
        
        expect(result.warnings.some(w => w.message.includes('.msapp'))).toBe(true);
      } finally {
        await fs.remove(tempFile);
      }
    });

    it('should detect empty package file', async () => {
      const tempFile = path.join(__dirname, 'empty-package.msapp');
      await fs.writeFile(tempFile, '');
      
      try {
        const result: ValidationResult = await validator.validatePackage(tempFile);
        
        expect(result.isValid).toBe(false);
        expect(result.errors.some(e => e.message.includes('empty'))).toBe(true);
      } finally {
        await fs.remove(tempFile);
      }
    });
  });

  describe('checkDependencies', () => {
    it('should check for required dependencies', async () => {
      const result: DependencyResult = await validator.checkDependencies();
      
      expect(result).toBeDefined();
      expect(typeof result.satisfied).toBe('boolean');
      expect(Array.isArray(result.missing)).toBe(true);
      expect(Array.isArray(result.conflicts)).toBe(true);
    });

    it('should detect Node.js version', async () => {
      const result: DependencyResult = await validator.checkDependencies();
      
      // Node.js should be available since we're running the test
      const nodeVersion = process.version;
      const majorVersion = parseInt(nodeVersion.slice(1).split('.')[0]);
      
      if (majorVersion < 16) {
        expect(result.conflicts.some(c => c.includes('Node.js'))).toBe(true);
      }
    });
  });

  describe('dryRunValidation', () => {
    it('should perform comprehensive validation', async () => {
      if (await fs.pathExists(testDataDir)) {
        const result: ValidationResult = await validator.dryRunValidation(testDataDir);
        
        expect(result).toBeDefined();
        expect(result.isValid).toBeDefined();
        expect(Array.isArray(result.errors)).toBe(true);
        expect(Array.isArray(result.warnings)).toBe(true);
      }
    });

    it('should validate with configuration file', async () => {
      const configPath = path.join(__dirname, '../../examples/msapp-generator.config.json');
      
      if (await fs.pathExists(testDataDir) && await fs.pathExists(configPath)) {
        const result: ValidationResult = await validator.dryRunValidation(testDataDir, configPath);
        
        expect(result).toBeDefined();
        expect(result.isValid).toBeDefined();
      }
    });

    it('should handle invalid configuration file', async () => {
      const invalidConfigPath = path.join(__dirname, 'invalid-config.json');
      await fs.writeFile(invalidConfigPath, '{ invalid json }');
      
      try {
        const result: ValidationResult = await validator.dryRunValidation(testDataDir, invalidConfigPath);
        
        expect(result.isValid).toBe(false);
        expect(result.errors.some(e => e.message.includes('Configuration'))).toBe(true);
      } finally {
        await fs.remove(invalidConfigPath);
      }
    });
  });

  describe('validateImportCompatibility', () => {
    it('should validate package import compatibility', async () => {
      const tempPackage = path.join(__dirname, 'test-package.msapp');
      await fs.writeFile(tempPackage, 'dummy package content');
      
      try {
        const result: ValidationResult = await validator.validateImportCompatibility(tempPackage);
        
        expect(result).toBeDefined();
        expect(result.isValid).toBeDefined();
        expect(Array.isArray(result.errors)).toBe(true);
        expect(Array.isArray(result.warnings)).toBe(true);
      } finally {
        await fs.remove(tempPackage);
      }
    });

    it('should detect problematic file names', async () => {
      const problematicName = path.join(__dirname, 'package with spaces.msapp');
      await fs.writeFile(problematicName, 'dummy content');
      
      try {
        const result: ValidationResult = await validator.validateImportCompatibility(problematicName);
        
        expect(result.warnings.some(w => w.message.includes('spaces'))).toBe(true);
      } finally {
        await fs.remove(problematicName);
      }
    });
  });
});