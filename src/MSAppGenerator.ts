import { CommandOptions, ValidationResult, SolutionPackage } from './types';
import { IFXParser, IMetadataProcessor, ISolutionBuilder, IPackageCreator, IValidationEngine } from './interfaces';
import { FXParser, MetadataProcessor, SolutionBuilder, PackageCreator, ValidationEngine } from './implementations';

/**
 * Main MSAPP Generator class that orchestrates all components
 */
export class MSAppGenerator {
  constructor(
    private fxParser: IFXParser,
    private metadataProcessor: IMetadataProcessor,
    private solutionBuilder: ISolutionBuilder,
    private packageCreator: IPackageCreator,
    private validationEngine: IValidationEngine
  ) {}

  /**
   * Create a new MSAppGenerator instance with default implementations
   */
  static create(): MSAppGenerator {
    return new MSAppGenerator(
      new FXParser(),
      new MetadataProcessor(),
      new SolutionBuilder(),
      new PackageCreator(),
      new ValidationEngine()
    );
  }

  /**
   * Generate .msapp package from source code
   */
  async generate(options: CommandOptions): Promise<Buffer> {
    // Validate source code first
    if (options.validate !== false) {
      const validation = await this.validationEngine.validateSourceCode(options.sourceDir);
      if (!validation.isValid) {
        throw new Error(`Validation failed: ${validation.errors.map(e => e.message).join(', ')}`);
      }
    }

    // Load configuration
    const config = await this.metadataProcessor.loadConfiguration(
      options.configFile || `${options.sourceDir}/msapp-generator.config.json`
    );

    // Parse source files
    const { screens, components } = await this.fxParser.parseDirectory(options.sourceDir);

    // Process metadata
    const solutionMetadata = await this.metadataProcessor.processMetadata(config);

    // Build solution
    const solutionProject = await this.solutionBuilder.initializeSolution(solutionMetadata);
    await this.solutionBuilder.addCanvasApp(solutionProject, screens, components);
    await this.solutionBuilder.addConnections(solutionProject, config.connections);
    
    const solutionPackage = await this.solutionBuilder.buildSolution(solutionProject);

    // Create package
    let packageBuffer = await this.packageCreator.createPackage(solutionPackage);
    
    if (config.resources.length > 0) {
      packageBuffer = await this.packageCreator.addResources(packageBuffer, config.resources);
    }

    // Write package if not dry run
    if (!options.dryRun) {
      await this.packageCreator.writePackage(packageBuffer, options.outputPath);
    }

    // Cleanup
    await this.solutionBuilder.cleanup(solutionProject);

    return packageBuffer;
  }

  /**
   * Validate source code without generating package
   */
  async validate(sourceDir: string, configFile?: string): Promise<ValidationResult> {
    return this.validationEngine.dryRunValidation(sourceDir, configFile);
  }
}