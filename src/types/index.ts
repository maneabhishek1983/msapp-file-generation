/**
 * Core types and interfaces for the MSAPP Generator
 */

// Command line options
export interface CommandOptions {
  sourceDir: string;
  outputPath: string;
  configFile?: string;
  validate?: boolean;
  dryRun?: boolean;
  verbose?: boolean;
}

// Application configuration
export interface AppConfiguration {
  app: AppInfo;
  screens: string[];
  components: string[];
  connections: ConnectionReference[];
  resources: ResourceReference[];
  settings: AppSettings;
}

export interface AppInfo {
  name: string;
  displayName: string;
  description: string;
  version: string;
  publisher: PublisherInfo;
}

export interface PublisherInfo {
  name: string;
  displayName: string;
  prefix: string;
  uniqueName: string;
}

export interface AppSettings {
  enableFormulas?: boolean;
  enableComponents?: boolean;
  theme?: string;
  [key: string]: unknown;
}

// Screen and component definitions
export interface ScreenDefinition {
  name: string;
  file: string;
  controls: ControlDefinition[];
  properties: PropertyMap;
  formulas: FormulaMap;
}

export interface ComponentDefinition {
  name: string;
  file: string;
  type: string;
  properties: PropertyMap;
  customProperties?: CustomProperty[];
  children?: ControlDefinition[];
}

export interface ControlDefinition {
  name: string;
  type: string;
  properties: PropertyMap;
  children?: ControlDefinition[];
}

export interface CustomProperty {
  name: string;
  type: string;
  defaultValue?: unknown;
  description?: string;
}

// Property and formula maps
export type PropertyMap = Record<string, unknown>;
export type FormulaMap = Record<string, string>;

// Connection and resource references
export interface ConnectionReference {
  name: string;
  type: string;
  displayName: string;
  connectionId?: string;
  parameters?: Record<string, unknown>;
}

export interface ResourceReference {
  name: string;
  type: 'image' | 'icon' | 'file';
  path: string;
  mimeType?: string;
}

// Solution package structure
export interface SolutionPackage {
  metadata: SolutionMetadata;
  canvasApp: CanvasAppDefinition;
  connections: ConnectionReference[];
  resources: ResourceFile[];
}

export interface SolutionMetadata {
  uniqueName: string;
  displayName: string;
  description: string;
  version: string;
  publisher: PublisherInfo;
}

export interface CanvasAppDefinition {
  name: string;
  displayName: string;
  description: string;
  screens: ScreenDefinition[];
  components: ComponentDefinition[];
  properties: PropertyMap;
}

export interface ResourceFile {
  name: string;
  content: Buffer;
  mimeType: string;
}

// Validation results
export interface ValidationResult {
  isValid: boolean;
  errors: ValidationError[];
  warnings: ValidationWarning[];
}

export interface ValidationError {
  message: string;
  file?: string;
  line?: number;
  column?: number;
  category: ErrorCategory;
}

export interface ValidationWarning {
  message: string;
  file?: string;
  line?: number;
  column?: number;
}

export interface DependencyResult {
  satisfied: boolean;
  missing: string[];
  conflicts: string[];
}

// Error categories
export enum ErrorCategory {
  SYNTAX = 'SYNTAX',
  CONFIGURATION = 'CONFIGURATION',
  DEPENDENCY = 'DEPENDENCY',
  PACKAGE = 'PACKAGE',
  VALIDATION = 'VALIDATION'
}

// Progress reporting
export interface ProgressInfo {
  stage: string;
  progress: number;
  message?: string;
}

// Solution project structure
export interface SolutionProject {
  path: string;
  metadata: SolutionMetadata;
  canvasApps: CanvasAppDefinition[];
  connections: ConnectionReference[];
}