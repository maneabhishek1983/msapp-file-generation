import { SolutionPackage, ResourceReference } from '../types';

/**
 * Interface for creating .msapp packages
 */
export interface IPackageCreator {
  /**
   * Create .msapp package from solution
   */
  createPackage(solution: SolutionPackage): Promise<Buffer>;

  /**
   * Add resource files to package
   */
  addResources(packageBuffer: Buffer, resources: ResourceReference[]): Promise<Buffer>;

  /**
   * Sign package for enterprise deployment
   */
  signPackage(packageBuffer: Buffer, certificatePath?: string): Promise<Buffer>;

  /**
   * Write package to file system
   */
  writePackage(packageBuffer: Buffer, outputPath: string): Promise<void>;

  /**
   * Extract package contents for inspection
   */
  extractPackage(packagePath: string): Promise<SolutionPackage>;
}