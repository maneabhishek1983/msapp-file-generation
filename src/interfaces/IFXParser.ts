import { ScreenDefinition, ComponentDefinition, FormulaMap, ValidationResult } from '../types';

/**
 * Interface for parsing Power Apps .fx files
 */
export interface IFXParser {
  /**
   * Parse a screen .fx file and extract screen definition
   */
  parseScreenFile(filePath: string): Promise<ScreenDefinition>;

  /**
   * Parse a component .fx file and extract component definition
   */
  parseComponentFile(filePath: string): Promise<ComponentDefinition>;

  /**
   * Extract formulas from file content
   */
  extractFormulas(content: string): FormulaMap;

  /**
   * Validate Power Apps formula syntax
   */
  validateSyntax(content: string): ValidationResult;

  /**
   * Parse multiple .fx files in a directory
   */
  parseDirectory(directoryPath: string): Promise<{
    screens: ScreenDefinition[];
    components: ComponentDefinition[];
  }>;
}