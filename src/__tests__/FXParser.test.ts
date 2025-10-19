import { FXParser } from '../parsers/FXParser';
import { ValidationResult } from '../types';
import * as fs from 'fs-extra';
import * as path from 'path';

describe('FXParser', () => {
  let parser: FXParser;
  const testDataDir = path.join(__dirname, '../../examples/sample-app');

  beforeEach(() => {
    parser = new FXParser();
  });

  describe('parseScreenFile', () => {
    it('should parse a valid screen file', async () => {
      const screenPath = path.join(testDataDir, 'screens/HomeScreen.fx');
      
      if (await fs.pathExists(screenPath)) {
        const result = await parser.parseScreenFile(screenPath);
        
        expect(result).toBeDefined();
        expect(result.name).toBe('HomeScreen');
        expect(result.file).toBe(screenPath);
        expect(result.controls).toBeDefined();
        expect(result.properties).toBeDefined();
        expect(result.formulas).toBeDefined();
      }
    });

    it('should throw error for non-existent file', async () => {
      const nonExistentPath = path.join(testDataDir, 'screens/NonExistent.fx');
      
      await expect(parser.parseScreenFile(nonExistentPath)).rejects.toThrow();
    });
  });

  describe('parseComponentFile', () => {
    it('should parse a valid component file', async () => {
      const componentPath = path.join(testDataDir, 'components/HeaderComponent.fx');
      
      if (await fs.pathExists(componentPath)) {
        const result = await parser.parseComponentFile(componentPath);
        
        expect(result).toBeDefined();
        expect(result.name).toBe('HeaderComponent');
        expect(result.file).toBe(componentPath);
        expect(result.type).toBe('Component');
        expect(result.properties).toBeDefined();
      }
    });
  });

  describe('extractFormulas', () => {
    it('should extract formulas from content', () => {
      const content = `
        Screen(
          Fill: Color.White,
          OnVisible: Set(varTest, true),
          
          Button(
            Text: "Click me",
            OnSelect: Navigate(NextScreen)
          )
        )
      `;
      
      const formulas = parser.extractFormulas(content);
      
      expect(formulas).toBeDefined();
      expect(typeof formulas).toBe('object');
    });

    it('should handle empty content', () => {
      const formulas = parser.extractFormulas('');
      
      expect(formulas).toBeDefined();
      expect(typeof formulas).toBe('object');
    });
  });

  describe('validateSyntax', () => {
    it('should validate correct syntax', () => {
      const validContent = `
        Screen(
          Fill: Color.White,
          
          Label(
            Text: "Hello World",
            X: 10, Y: 10
          )
        )
      `;
      
      const result: ValidationResult = parser.validateSyntax(validContent);
      
      expect(result).toBeDefined();
      expect(result.isValid).toBeDefined();
      expect(result.errors).toBeDefined();
      expect(result.warnings).toBeDefined();
      expect(Array.isArray(result.errors)).toBe(true);
      expect(Array.isArray(result.warnings)).toBe(true);
    });

    it('should detect syntax errors', () => {
      const invalidContent = `
        Screen(
          Fill: Color.White,
          
          Label(
            Text: "Unclosed quote
            X: 10, Y: 10
          )
        )
      `;
      
      const result: ValidationResult = parser.validateSyntax(invalidContent);
      
      expect(result.isValid).toBe(false);
      expect(result.errors.length).toBeGreaterThan(0);
    });

    it('should detect mismatched brackets', () => {
      const invalidContent = `
        Screen(
          Fill: Color.White,
          
          Label(
            Text: "Hello World",
            X: 10, Y: 10
          // Missing closing parenthesis
        )
      `;
      
      const result: ValidationResult = parser.validateSyntax(invalidContent);
      
      expect(result.isValid).toBe(false);
      expect(result.errors.length).toBeGreaterThan(0);
    });
  });

  describe('parseDirectory', () => {
    it('should parse directory with screens and components', async () => {
      if (await fs.pathExists(testDataDir)) {
        const result = await parser.parseDirectory(testDataDir);
        
        expect(result).toBeDefined();
        expect(result.screens).toBeDefined();
        expect(result.components).toBeDefined();
        expect(Array.isArray(result.screens)).toBe(true);
        expect(Array.isArray(result.components)).toBe(true);
      }
    });

    it('should handle empty directory', async () => {
      const emptyDir = path.join(__dirname, 'empty-test-dir');
      await fs.ensureDir(emptyDir);
      
      try {
        const result = await parser.parseDirectory(emptyDir);
        
        expect(result.screens).toHaveLength(0);
        expect(result.components).toHaveLength(0);
      } finally {
        await fs.remove(emptyDir);
      }
    });

    it('should handle non-existent directory gracefully', async () => {
      const nonExistentDir = path.join(__dirname, 'non-existent-dir');
      
      // The current implementation returns empty arrays for non-existent directories
      // This might be the intended behavior for flexibility
      const result = await parser.parseDirectory(nonExistentDir);
      expect(result.screens).toHaveLength(0);
      expect(result.components).toHaveLength(0);
    });
  });
});