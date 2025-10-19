import * as fs from 'fs-extra';
import * as path from 'path';
import { MSAppGenerator } from '../MSAppGenerator';
import { CommandOptions, ValidationResult } from '../types';
import { MSAppGeneratorError } from '../errors';
import { ErrorCategory } from '../types';

/**
 * Batch processing functionality for multiple applications
 */
export class BatchProcessor {
  private generator: MSAppGenerator;

  constructor() {
    this.generator = MSAppGenerator.create();
  }

  /**
   * Process multiple applications in batch
   */
  async processBatch(batchConfig: BatchConfiguration): Promise<BatchResult> {
    const results: ApplicationResult[] = [];
    const startTime = Date.now();

    console.log(`🚀 Starting batch processing of ${batchConfig.applications.length} applications...`);

    try {
      if (batchConfig.parallel) {
        // Process applications in parallel
        const promises = batchConfig.applications.map(app => 
          this.processApplication(app, batchConfig.globalOptions)
        );
        
        const parallelResults = await Promise.allSettled(promises);
        
        parallelResults.forEach((result, index) => {
          const app = batchConfig.applications[index];
          if (result.status === 'fulfilled') {
            results.push(result.value);
          } else {
            results.push({
              applicationName: app.name,
              success: false,
              error: result.reason instanceof Error ? result.reason.message : String(result.reason),
              duration: 0,
              outputPath: app.outputPath
            });
          }
        });
      } else {
        // Process applications sequentially
        for (const app of batchConfig.applications) {
          try {
            const result = await this.processApplication(app, batchConfig.globalOptions);
            results.push(result);
          } catch (error) {
            results.push({
              applicationName: app.name,
              success: false,
              error: error instanceof Error ? error.message : String(error),
              duration: 0,
              outputPath: app.outputPath
            });
          }
        }
      }

      const totalDuration = Date.now() - startTime;
      const successCount = results.filter(r => r.success).length;
      const failureCount = results.length - successCount;

      console.log(`✅ Batch processing completed: ${successCount} successful, ${failureCount} failed`);
      console.log(`⏱️  Total duration: ${totalDuration}ms`);

      // Generate batch report if requested
      if (batchConfig.generateReport) {
        await this.generateBatchReport(results, totalDuration, batchConfig.reportPath);
      }

      return {
        success: failureCount === 0,
        totalApplications: results.length,
        successfulApplications: successCount,
        failedApplications: failureCount,
        totalDuration,
        results,
        reportPath: batchConfig.generateReport ? batchConfig.reportPath : undefined
      };
    } catch (error) {
      throw new MSAppGeneratorError(
        `Batch processing failed: ${error instanceof Error ? error.message : String(error)}`,
        ErrorCategory.PACKAGE
      );
    }
  }

  /**
   * Process a single application
   */
  private async processApplication(app: ApplicationConfig, globalOptions?: Partial<CommandOptions>): Promise<ApplicationResult> {
    const startTime = Date.now();
    
    try {
      console.log(`📱 Processing application: ${app.name}`);

      const options: CommandOptions = {
        sourceDir: app.sourceDir,
        outputPath: app.outputPath,
        configFile: app.configFile,
        validate: app.validate ?? globalOptions?.validate ?? true,
        dryRun: app.dryRun ?? globalOptions?.dryRun ?? false,
        verbose: app.verbose ?? globalOptions?.verbose ?? false
      };

      const packageBuffer = await this.generator.generate(options);
      const duration = Date.now() - startTime;

      console.log(`✅ Application ${app.name} processed successfully in ${duration}ms`);

      return {
        applicationName: app.name,
        success: true,
        duration,
        outputPath: app.outputPath,
        packageSize: packageBuffer.length
      };
    } catch (error) {
      const duration = Date.now() - startTime;
      
      console.error(`❌ Application ${app.name} failed: ${error instanceof Error ? error.message : String(error)}`);

      return {
        applicationName: app.name,
        success: false,
        error: error instanceof Error ? error.message : String(error),
        duration,
        outputPath: app.outputPath
      };
    }
  }

  /**
   * Generate batch processing report
   */
  private async generateBatchReport(results: ApplicationResult[], totalDuration: number, reportPath?: string): Promise<void> {
    const report = {
      timestamp: new Date().toISOString(),
      summary: {
        totalApplications: results.length,
        successfulApplications: results.filter(r => r.success).length,
        failedApplications: results.filter(r => !r.success).length,
        totalDuration,
        averageDuration: Math.round(totalDuration / results.length)
      },
      applications: results.map(result => ({
        name: result.applicationName,
        success: result.success,
        duration: result.duration,
        outputPath: result.outputPath,
        packageSize: result.packageSize,
        error: result.error
      })),
      performance: {
        fastestApplication: results.reduce((fastest, current) => 
          current.success && current.duration < fastest.duration ? current : fastest
        ),
        slowestApplication: results.reduce((slowest, current) => 
          current.success && current.duration > slowest.duration ? current : slowest
        ),
        totalPackageSize: results
          .filter(r => r.success && r.packageSize)
          .reduce((total, r) => total + (r.packageSize || 0), 0)
      }
    };

    const outputPath = reportPath || path.join(process.cwd(), 'batch-report.json');
    await fs.writeJSON(outputPath, report, { spaces: 2 });
    
    console.log(`📊 Batch report generated: ${outputPath}`);
  }

  /**
   * Validate all applications in batch before processing
   */
  async validateBatch(batchConfig: BatchConfiguration): Promise<BatchValidationResult> {
    const validationResults: ApplicationValidationResult[] = [];
    
    console.log(`🔍 Validating ${batchConfig.applications.length} applications...`);

    for (const app of batchConfig.applications) {
      try {
        const result = await this.generator.validate(app.sourceDir, app.configFile);
        
        validationResults.push({
          applicationName: app.name,
          isValid: result.isValid,
          errorCount: result.errors.length,
          warningCount: result.warnings.length,
          errors: result.errors,
          warnings: result.warnings
        });
      } catch (error) {
        validationResults.push({
          applicationName: app.name,
          isValid: false,
          errorCount: 1,
          warningCount: 0,
          errors: [{
            message: error instanceof Error ? error.message : String(error),
            category: ErrorCategory.VALIDATION
          }],
          warnings: []
        });
      }
    }

    const validApplications = validationResults.filter(r => r.isValid).length;
    const invalidApplications = validationResults.length - validApplications;

    console.log(`🔍 Batch validation completed: ${validApplications} valid, ${invalidApplications} invalid`);

    return {
      allValid: invalidApplications === 0,
      validApplications,
      invalidApplications,
      results: validationResults
    };
  }
}

/**
 * Incremental build support
 */
export class IncrementalBuilder {
  private cacheDir: string;
  private generator: MSAppGenerator;

  constructor(cacheDir?: string) {
    this.cacheDir = cacheDir || path.join(process.cwd(), '.msapp-cache');
    this.generator = MSAppGenerator.create();
  }

  /**
   * Build application with incremental support
   */
  async buildIncremental(options: CommandOptions): Promise<Buffer> {
    await fs.ensureDir(this.cacheDir);

    const cacheKey = this.generateCacheKey(options);
    const cacheFile = path.join(this.cacheDir, `${cacheKey}.json`);
    const packageFile = path.join(this.cacheDir, `${cacheKey}.msapp`);

    // Check if incremental build is possible
    const canUseCache = await this.canUseCachedBuild(options, cacheFile);

    if (canUseCache && await fs.pathExists(packageFile)) {
      console.log('📦 Using cached build');
      return await fs.readFile(packageFile);
    }

    console.log('🔨 Performing full build');
    
    // Perform full build
    const packageBuffer = await this.generator.generate(options);

    // Cache the build
    await this.cacheBuild(options, cacheFile, packageFile, packageBuffer);

    return packageBuffer;
  }

  /**
   * Check if cached build can be used
   */
  private async canUseCachedBuild(options: CommandOptions, cacheFile: string): Promise<boolean> {
    try {
      if (!await fs.pathExists(cacheFile)) {
        return false;
      }

      const cacheData = await fs.readJSON(cacheFile);
      const sourceFiles = await this.getSourceFiles(options.sourceDir);

      // Check if any source files have been modified since cache
      for (const file of sourceFiles) {
        const stats = await fs.stat(file);
        const cachedMtime = cacheData.files[file];
        
        if (!cachedMtime || new Date(stats.mtime) > new Date(cachedMtime)) {
          return false;
        }
      }

      // Check if configuration has changed
      if (options.configFile) {
        const configStats = await fs.stat(options.configFile);
        const cachedConfigMtime = cacheData.configMtime;
        
        if (!cachedConfigMtime || new Date(configStats.mtime) > new Date(cachedConfigMtime)) {
          return false;
        }
      }

      return true;
    } catch (error) {
      return false;
    }
  }

  /**
   * Cache build results
   */
  private async cacheBuild(options: CommandOptions, cacheFile: string, packageFile: string, packageBuffer: Buffer): Promise<void> {
    try {
      const sourceFiles = await this.getSourceFiles(options.sourceDir);
      const files: Record<string, string> = {};

      // Record modification times of all source files
      for (const file of sourceFiles) {
        const stats = await fs.stat(file);
        files[file] = stats.mtime.toISOString();
      }

      const cacheData = {
        timestamp: new Date().toISOString(),
        options: {
          sourceDir: options.sourceDir,
          configFile: options.configFile
        },
        files,
        configMtime: options.configFile ? (await fs.stat(options.configFile)).mtime.toISOString() : null
      };

      await fs.writeJSON(cacheFile, cacheData, { spaces: 2 });
      await fs.writeFile(packageFile, packageBuffer);
    } catch (error) {
      console.warn('Failed to cache build:', error);
    }
  }

  /**
   * Get all source files for change detection
   */
  private async getSourceFiles(sourceDir: string): Promise<string[]> {
    const { glob } = require('glob');
    const files = await glob('**/*.{fx,json}', { cwd: sourceDir });
    return files.map((file: string) => path.join(sourceDir, file));
  }

  /**
   * Generate cache key for build
   */
  private generateCacheKey(options: CommandOptions): string {
    const crypto = require('crypto');
    const key = JSON.stringify({
      sourceDir: options.sourceDir,
      configFile: options.configFile,
      validate: options.validate
    });
    return crypto.createHash('md5').update(key).digest('hex');
  }

  /**
   * Clear build cache
   */
  async clearCache(): Promise<void> {
    if (await fs.pathExists(this.cacheDir)) {
      await fs.remove(this.cacheDir);
      console.log('🗑️  Build cache cleared');
    }
  }
}

// Type definitions
export interface BatchConfiguration {
  applications: ApplicationConfig[];
  parallel?: boolean;
  generateReport?: boolean;
  reportPath?: string;
  globalOptions?: Partial<CommandOptions>;
}

export interface ApplicationConfig {
  name: string;
  sourceDir: string;
  outputPath: string;
  configFile?: string;
  validate?: boolean;
  dryRun?: boolean;
  verbose?: boolean;
}

export interface BatchResult {
  success: boolean;
  totalApplications: number;
  successfulApplications: number;
  failedApplications: number;
  totalDuration: number;
  results: ApplicationResult[];
  reportPath?: string;
}

export interface ApplicationResult {
  applicationName: string;
  success: boolean;
  duration: number;
  outputPath: string;
  packageSize?: number;
  error?: string;
}

export interface BatchValidationResult {
  allValid: boolean;
  validApplications: number;
  invalidApplications: number;
  results: ApplicationValidationResult[];
}

export interface ApplicationValidationResult {
  applicationName: string;
  isValid: boolean;
  errorCount: number;
  warningCount: number;
  errors: any[];
  warnings: any[];
}