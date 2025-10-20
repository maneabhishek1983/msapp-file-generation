import { CIIntegration, PipelineConfigOptions } from '../ci/CIIntegration';
import * as fs from 'fs-extra';
import * as path from 'path';

describe('CIIntegration', () => {
  let ciIntegration: CIIntegration;
  const testOutputDir = path.join(__dirname, '../../.temp/ci-test');

  beforeEach(async () => {
    ciIntegration = new CIIntegration();
    await fs.ensureDir(testOutputDir);
  });

  afterEach(async () => {
    await fs.remove(testOutputDir);
  });

  describe('generatePipelineConfigs', () => {
    it('should generate GitHub Actions workflow', async () => {
      const options: PipelineConfigOptions = {
        platforms: ['github'],
        outputDir: testOutputDir,
        triggerBranches: ['main', 'develop'],
        includeTests: true,
        includeDocker: false
      };

      await ciIntegration.generatePipelineConfigs(options);

      const workflowFile = path.join(testOutputDir, '.github', 'workflows', 'build-powerapps.yml');
      expect(await fs.pathExists(workflowFile)).toBe(true);

      const content = await fs.readFile(workflowFile, 'utf-8');
      expect(content).toContain('Build Power Apps');
      expect(content).toContain('npm test');
    });

    it('should generate Azure DevOps pipeline', async () => {
      const options: PipelineConfigOptions = {
        platforms: ['azure'],
        outputDir: testOutputDir,
        triggerBranches: ['main'],
        includeTests: false,
        includeDocker: false
      };

      await ciIntegration.generatePipelineConfigs(options);

      const pipelineFile = path.join(testOutputDir, 'azure-pipelines.yml');
      expect(await fs.pathExists(pipelineFile)).toBe(true);

      const content = await fs.readFile(pipelineFile, 'utf-8');
      expect(content).toContain('Build Power Apps');
      expect(content).toContain('trigger:');
    });

    it('should generate Jenkins pipeline', async () => {
      const options: PipelineConfigOptions = {
        platforms: ['jenkins'],
        outputDir: testOutputDir,
        includeTests: true,
        includeDocker: false
      };

      await ciIntegration.generatePipelineConfigs(options);

      const jenkinsFile = path.join(testOutputDir, 'Jenkinsfile');
      expect(await fs.pathExists(jenkinsFile)).toBe(true);

      const content = await fs.readFile(jenkinsFile, 'utf-8');
      expect(content).toContain('pipeline {');
      expect(content).toContain('npm test');
    });

    it('should generate Docker configuration', async () => {
      const options: PipelineConfigOptions = {
        platforms: ['github'],
        outputDir: testOutputDir,
        includeDocker: true
      };

      await ciIntegration.generatePipelineConfigs(options);

      const dockerFile = path.join(testOutputDir, 'Dockerfile');
      const dockerCompose = path.join(testOutputDir, 'docker-compose.yml');
      const dockerIgnore = path.join(testOutputDir, '.dockerignore');

      expect(await fs.pathExists(dockerFile)).toBe(true);
      expect(await fs.pathExists(dockerCompose)).toBe(true);
      expect(await fs.pathExists(dockerIgnore)).toBe(true);

      const dockerContent = await fs.readFile(dockerFile, 'utf-8');
      expect(dockerContent).toContain('FROM node:18-alpine');
      expect(dockerContent).toContain('npm install -g @microsoft/powerplatform-cli');
    });

    it('should generate multiple platform configurations', async () => {
      const options: PipelineConfigOptions = {
        platforms: ['github', 'azure', 'jenkins'],
        outputDir: testOutputDir,
        includeTests: true,
        includeDocker: true
      };

      await ciIntegration.generatePipelineConfigs(options);

      // Check all files are generated
      expect(await fs.pathExists(path.join(testOutputDir, '.github', 'workflows', 'build-powerapps.yml'))).toBe(true);
      expect(await fs.pathExists(path.join(testOutputDir, 'azure-pipelines.yml'))).toBe(true);
      expect(await fs.pathExists(path.join(testOutputDir, 'Jenkinsfile'))).toBe(true);
      expect(await fs.pathExists(path.join(testOutputDir, 'Dockerfile'))).toBe(true);
    });

    it('should include deployment environments when specified', async () => {
      const options: PipelineConfigOptions = {
        platforms: ['github'],
        outputDir: testOutputDir,
        deploymentEnvironments: ['dev', 'staging', 'prod']
      };

      await ciIntegration.generatePipelineConfigs(options);

      const workflowFile = path.join(testOutputDir, '.github', 'workflows', 'build-powerapps.yml');
      const content = await fs.readFile(workflowFile, 'utf-8');
      
      expect(content).toContain('deploy:');
      expect(content).toContain('dev');
      expect(content).toContain('staging');
      expect(content).toContain('prod');
    });
  });

  describe('validateCIEnvironment', () => {
    it('should validate CI environment', async () => {
      const result = await ciIntegration.validateCIEnvironment();

      expect(result).toBeDefined();
      expect(typeof result.passed).toBe('boolean');
      expect(Array.isArray(result.checks)).toBe(true);
      expect(typeof result.summary).toBe('string');

      // Should have at least basic checks
      expect(result.checks.length).toBeGreaterThan(0);
      
      // Check for Node.js version check
      const nodeCheck = result.checks.find(check => check.name.includes('Node.js'));
      expect(nodeCheck).toBeDefined();
    });

    it('should detect Node.js version correctly', async () => {
      const result = await ciIntegration.validateCIEnvironment();
      
      const nodeCheck = result.checks.find(check => check.name.includes('Node.js'));
      expect(nodeCheck).toBeDefined();
      
      // Current Node.js version should be 16+ for our tests
      const nodeVersion = process.version;
      const majorVersion = parseInt(nodeVersion.slice(1).split('.')[0]);
      
      if (majorVersion >= 16) {
        expect(nodeCheck?.passed).toBe(true);
      }
    });

    it('should check for Power Platform CLI', async () => {
      const result = await ciIntegration.validateCIEnvironment();
      
      const pacCheck = result.checks.find(check => check.name.includes('Power Platform CLI'));
      expect(pacCheck).toBeDefined();
      
      // This will likely fail in test environment, which is expected
      expect(typeof pacCheck?.passed).toBe('boolean');
    });

    it('should provide meaningful summary', async () => {
      const result = await ciIntegration.validateCIEnvironment();
      
      expect(result.summary).toMatch(/\d+\/\d+ checks passed/);
    });
  });
});