import { CommandOptions, ProgressInfo } from '../types';

/**
 * Interface for command-line interface
 */
export interface ICLIInterface {
  /**
   * Parse command line arguments
   */
  parseArguments(args: string[]): CommandOptions;

  /**
   * Display progress information
   */
  displayProgress(progress: ProgressInfo): void;

  /**
   * Handle and display errors
   */
  handleError(error: Error): void;

  /**
   * Display help information
   */
  displayHelp(): void;

  /**
   * Display version information
   */
  displayVersion(): void;

  /**
   * Prompt user for input
   */
  promptUser(message: string, defaultValue?: string): Promise<string>;
}