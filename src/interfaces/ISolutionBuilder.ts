import { SolutionMetadata, SolutionProject, SolutionPackage, ScreenDefinition, ComponentDefinition, ConnectionReference } from '../types';

/**
 * Interface for building Power Platform solutions
 */
export interface ISolutionBuilder {
  /**
   * Initialize a new solution project
   */
  initializeSolution(metadata: SolutionMetadata): Promise<SolutionProject>;

  /**
   * Add canvas app to solution
   */
  addCanvasApp(project: SolutionProject, screens: ScreenDefinition[], components: ComponentDefinition[]): Promise<void>;

  /**
   * Add connection references to solution
   */
  addConnections(project: SolutionProject, connections: ConnectionReference[]): Promise<void>;

  /**
   * Build the complete solution package
   */
  buildSolution(project: SolutionProject): Promise<SolutionPackage>;

  /**
   * Clean up temporary solution files
   */
  cleanup(project: SolutionProject): Promise<void>;
}