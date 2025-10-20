import { AppConfiguration, SolutionMetadata, ValidationResult } from '../types';

/**
 * Interface for processing application metadata and configuration
 */
export interface IMetadataProcessor {
  /**
   * Load configuration from file
   */
  loadConfiguration(configPath: string): Promise<AppConfiguration>;

  /**
   * Process metadata and convert to solution metadata
   */
  processMetadata(config: AppConfiguration): Promise<SolutionMetadata>;

  /**
   * Validate configuration structure and values
   */
  validateConfiguration(config: AppConfiguration): ValidationResult;

  /**
   * Apply environment-specific parameter substitution
   */
  substituteParameters(config: AppConfiguration, environment: string): AppConfiguration;

  /**
   * Create default configuration template
   */
  createDefaultConfiguration(): AppConfiguration;
}