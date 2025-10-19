import { ErrorCategory } from '../types';

/**
 * Custom error class for MSAPP Generator
 */
export class MSAppGeneratorError extends Error {
  constructor(
    message: string,
    public category: ErrorCategory,
    public file?: string,
    public line?: number,
    public column?: number
  ) {
    super(message);
    this.name = 'MSAppGeneratorError';
    
    // Maintains proper stack trace for where our error was thrown (only available on V8)
    if (Error.captureStackTrace) {
      Error.captureStackTrace(this, MSAppGeneratorError);
    }
  }

  /**
   * Get formatted error message with context
   */
  getFormattedMessage(): string {
    let message = `${this.category}: ${this.message}`;
    
    if (this.file) {
      message += `\n  File: ${this.file}`;
      if (this.line !== undefined) {
        message += `:${this.line}`;
        if (this.column !== undefined) {
          message += `:${this.column}`;
        }
      }
    }
    
    return message;
  }

  /**
   * Convert to JSON for logging
   */
  toJSON(): Record<string, unknown> {
    return {
      name: this.name,
      message: this.message,
      category: this.category,
      file: this.file,
      line: this.line,
      column: this.column,
      stack: this.stack
    };
  }
}