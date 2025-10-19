import { ValidationResult, DependencyResult, AppConfiguration } from '../types';

/**
 * Interface for validation engine
 */
export interface IValidationEngine {
  /**
   * Validate source code directory structure and files
   */
  validateSourceCode(sourceDir: string): Promise<ValidationResult>;

  /**
   * Validate generated package integrity
   */
  validatePackage(packagePath: string): Promise<ValidationResult>;

  /**
   * Check for missing dependencies and connections
   */
  checkDependencies(config: AppConfiguration): Promise<DependencyResult>;

  /**
   * Perform dry-run validation without creating package
   */
  dryRunValidation(sourceDir: string, configPath?: string): Promise<ValidationResult>;

  /**
   * Validate Power Apps import compatibility
   */
  validateImportCompatibility(packagePath: string): Promise<ValidationResult>;
}