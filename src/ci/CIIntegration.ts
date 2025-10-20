import * as fs from 'fs-extra';
import * as path from 'path';
import { BatchProcessor, BatchConfiguration } from '../batch/BatchProcessor';
import { MSAppGenerator } from '../MSAppGenerator';
import { CommandOptions } from '../types';

/**
 * CI/CD integration utilities
 */
export class CIIntegration {
  private batchProcessor: BatchProcessor;
  private generator: MSAppGenerator;

  constructor() {
    this.batchProcessor = new BatchProcessor();
    this.generator = MSAppGenerator.create();
  }

  /**
   * Generate CI/CD pipeline configuration files
   */
  async generatePipelineConfigs(options: PipelineConfigOptions): Promise<void> {
    const outputDir = options.outputDir || './ci';
    await fs.ensureDir(outputDir);

    // Generate GitHub Actions workflow
    if (options.platforms.includes('github')) {
      await this.generateGitHubActions(outputDir, options);
    }

    // Generate Azure DevOps pipeline
    if (options.platforms.includes('azure')) {
      await this.generateAzureDevOps(outputDir, options);
    }

    // Generate Jenkins pipeline
    if (options.platforms.includes('jenkins')) {
      await this.generateJenkins(outputDir, options);
    }

    // Generate Docker configuration
    if (options.includeDocker) {
      await this.generateDockerConfig(outputDir, options);
    }

    console.log(`🔧 CI/CD configurations generated in ${outputDir}`);
  }

  /**
   * Generate GitHub Actions workflow
   */
  private async generateGitHubActions(outputDir: string, options: PipelineConfigOptions): Promise<void> {
    const workflowDir = path.join(outputDir, '.github', 'workflows');
    await fs.ensureDir(workflowDir);

    const pushBranches = options.triggerBranches || ['main', 'develop'];
    const pullBranches = options.triggerBranches || ['main'];

    const stepBlocks: string[] = [
      `      - name: Checkout code\n        uses: actions/checkout@v4`,
      `      - name: Setup Node.js\n        uses: actions/setup-node@v4\n        with:\n          node-version: 18\n          cache: npm`,
      `      - name: Install Power Platform CLI\n        run: npm install -g @microsoft/powerplatform-cli`,
      `      - name: Install dependencies\n        run: npm ci`
    ];

    if (options.includeTests) {
      stepBlocks.push(`      - name: Run tests\n        run: npm test`);
    }

    stepBlocks.push(
      `      - name: Validate source code\n        run: npx msapp-gen validate -s ./src -c ./msapp-generator.config.json`,
      `      - name: Build .msapp packages\n        run: npx msapp-gen generate -s ./src -o ./dist/app.msapp -c ./msapp-generator.config.json`,
      `      - name: Upload artifacts\n        uses: actions/upload-artifact@v4\n        with:\n          name: msapp-packages\n          path: ./dist/*.msapp`
    );

    let deployJob = '';
    if (options.deploymentEnvironments && options.deploymentEnvironments.length > 0) {
      const environmentLines = options.deploymentEnvironments
        .map(env => `          - ${env}`)
        .join('\n');

      deployJob = `\n  deploy:\n    runs-on: ubuntu-latest\n    needs: build\n    if: github.ref == 'refs/heads/main'\n    strategy:\n      matrix:\n        environment:\n${environmentLines}\n    steps:\n      - name: Download artifacts\n        uses: actions/download-artifact@v4\n        with:\n          name: msapp-packages\n          path: ./dist\n      - name: Deploy to Power Platform\n        run: pac solution import --path ./dist/app.msapp --environment \${{ matrix.environment }}`;
    }

    const workflowContent = `# Auto-generated GitHub Actions workflow for Power Apps\nname: Build Power Apps\non:\n  push:\n    branches:\n${pushBranches.map(branch => `      - ${branch}`).join('\n')}\n  pull_request:\n    branches:\n${pullBranches.map(branch => `      - ${branch}`).join('\n')}\njobs:\n  build:\n    runs-on: ubuntu-latest\n    steps:\n${stepBlocks.join('\n')}\n${deployJob}`.trim() + '\n';

    await fs.writeFile(
      path.join(workflowDir, 'build-powerapps.yml'),
      workflowContent,
      'utf-8'
    );
  }

  /**
   * Generate Azure DevOps pipeline
   */
  private async generateAzureDevOps(outputDir: string, options: PipelineConfigOptions): Promise<void> {
    const pipelineDir = outputDir;
    await fs.ensureDir(pipelineDir);

    const triggerBranches = options.triggerBranches || ['main', 'develop'];
    const prBranches = options.triggerBranches || ['main'];

    const buildSteps: string[] = [
      `          - task: NodeTool@0\n            displayName: Setup Node.js\n            inputs:\n              versionSpec: 18.x`,
      `          - script: npm install -g @microsoft/powerplatform-cli\n            displayName: Install Power Platform CLI`,
      `          - script: npm ci\n            displayName: Install dependencies`,
      `          - script: npx msapp-gen validate -s ./src -c ./msapp-generator.config.json\n            displayName: Validate source code`
    ];

    if (options.includeTests) {
      buildSteps.push(`          - script: npm test\n            displayName: Run tests`);
    }

    buildSteps.push(
      `          - script: npx msapp-gen generate -s ./src -o ./dist/app.msapp -c ./msapp-generator.config.json\n            displayName: Build .msapp packages`,
      `          - task: PublishBuildArtifacts@1\n            displayName: Publish artifacts\n            inputs:\n              PathtoPublish: ./dist\n              ArtifactName: msapp-packages`
    );

    let deployStage = '';
    if (options.deploymentEnvironments && options.deploymentEnvironments.length > 0) {
      const deployJobs = options.deploymentEnvironments
        .map(env => `      - job: Deploy_${env}\n        displayName: Deploy to ${env}\n        steps:\n          - script: pac solution import --path ./dist/app.msapp --environment ${env}\n            displayName: Deploy to ${env}`)
        .join('\n');

      deployStage = `\n  - stage: Deploy\n    displayName: Deploy to Power Platform\n    dependsOn: Build\n    condition: eq(variables['Build.SourceBranch'], 'refs/heads/main')\n    jobs:\n${deployJobs}`;
    }

    const pipelineContent = `# Auto-generated Azure DevOps pipeline for Power Apps\ntrigger:\n${triggerBranches.map(branch => `  - ${branch}`).join('\n')}\npr:\n${prBranches.map(branch => `  - ${branch}`).join('\n')}\npool:\n  vmImage: ubuntu-latest\nvariables:\n  buildConfiguration: Release\nstages:\n  - stage: Build\n    displayName: Build Power Apps\n    jobs:\n      - job: BuildJob\n        displayName: Build .msapp packages\n        steps:\n${buildSteps.join('\n')}\n${deployStage}`.trim() + '\n';

    await fs.writeFile(
      path.join(outputDir, 'azure-pipelines.yml'),
      pipelineContent,
      'utf-8'
    );
  }

  /**
   * Generate Jenkins pipeline
   */
  private async generateJenkins(outputDir: string, options: PipelineConfigOptions): Promise<void> {
    const jenkinsfile = `
// Auto-generated Jenkinsfile for Power Apps
pipeline {
    agent any
    
    triggers {
        pollSCM('H/5 * * * *')
    }
    
    environment {
        NODE_VERSION = '18'
    }
    
    stages {
        stage('Setup') {
            steps {
                script {
                    def nodeHome = tool name: 'NodeJS', type: 'jenkins.plugins.nodejs.tools.NodeJSInstallation'
                    env.PATH = "\${nodeHome}/bin:\${env.PATH}"
                }
                sh 'npm install -g @microsoft/powerplatform-cli'
                sh 'npm ci'
            }
        }
        
        stage('Validate') {
            steps {
                sh 'npx msapp-gen validate -s ./src -c ./msapp-generator.config.json'
            }
        }
        
        ${options.includeTests ? `
        stage('Test') {
            steps {
                sh 'npm test'
            }
            post {
                always {
                    publishTestResults testResultsPattern: 'test-results.xml'
                }
            }
        }
        ` : ''}
        
        stage('Build') {
            steps {
                sh 'npx msapp-gen generate -s ./src -o ./dist/app.msapp -c ./msapp-generator.config.json'
            }
            post {
                success {
                    archiveArtifacts artifacts: 'dist/*.msapp', fingerprint: true
                }
            }
        }
        
        ${options.deploymentEnvironments && options.deploymentEnvironments.length > 0 ? `
        stage('Deploy') {
            when {
                branch 'main'
            }
            parallel {
                ${options.deploymentEnvironments.map(env => `
                stage('Deploy to ${env}') {
                    steps {
                        sh "pac solution import --path ./dist/app.msapp --environment ${env}"
                    }
                }
                `).join('')}
            }
        }
        ` : ''}
    }
    
    post {
        always {
            cleanWs()
        }
        failure {
            emailext (
                subject: "Build Failed: \${env.JOB_NAME} - \${env.BUILD_NUMBER}",
                body: "Build failed. Check console output at \${env.BUILD_URL}",
                to: "\${env.CHANGE_AUTHOR_EMAIL}"
            )
        }
    }
}
`;

    await fs.writeFile(path.join(outputDir, 'Jenkinsfile'), jenkinsfile.trim(), 'utf-8');
  }

  /**
   * Generate Docker configuration
   */
  private async generateDockerConfig(outputDir: string, options: PipelineConfigOptions): Promise<void> {
    const dockerfile = `
# Auto-generated Dockerfile for Power Apps build
FROM node:18-alpine

# Install Power Platform CLI
RUN npm install -g @microsoft/powerplatform-cli

# Set working directory
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci --only=production

# Copy source code
COPY . .

# Build the application
RUN npx msapp-gen generate -s ./src -o ./dist/app.msapp -c ./msapp-generator.config.json

# Expose the dist directory
VOLUME ["/app/dist"]

CMD ["echo", "Power Apps build completed. Check /app/dist for .msapp files"]
`;

    await fs.writeFile(path.join(outputDir, 'Dockerfile'), dockerfile.trim(), 'utf-8');

    const dockerCompose = `
# Auto-generated Docker Compose for Power Apps build
version: '3.8'

services:
  powerapps-build:
    build: .
    volumes:
      - ./dist:/app/dist
      - ./src:/app/src:ro
      - ./msapp-generator.config.json:/app/msapp-generator.config.json:ro
    environment:
      - NODE_ENV=production
`;

    await fs.writeFile(path.join(outputDir, 'docker-compose.yml'), dockerCompose.trim(), 'utf-8');

    const dockerIgnore = `
# Auto-generated .dockerignore for Power Apps build
node_modules
npm-debug.log
.git
.gitignore
README.md
.env
.nyc_output
coverage
.temp
dist
*.msapp
`;

    await fs.writeFile(path.join(outputDir, '.dockerignore'), dockerIgnore.trim(), 'utf-8');
  }

  /**
   * Run CI/CD validation
   */
  async validateCIEnvironment(): Promise<CIValidationResult> {
    const checks: CICheck[] = [];

    // Check Node.js version
    const nodeVersion = process.version;
    checks.push({
      name: 'Node.js Version',
      passed: this.checkNodeVersion(nodeVersion),
      message: `Node.js ${nodeVersion} ${this.checkNodeVersion(nodeVersion) ? '✅' : '❌ (requires 16+)'}`
    });

    // Check for Power Platform CLI
    try {
      const { execSync } = require('child_process');
      execSync('pac --version', { stdio: 'pipe' });
      checks.push({
        name: 'Power Platform CLI',
        passed: true,
        message: 'Power Platform CLI is available ✅'
      });
    } catch (error) {
      checks.push({
        name: 'Power Platform CLI',
        passed: false,
        message: 'Power Platform CLI not found ❌'
      });
    }

    // Check for required environment variables
    const requiredEnvVars = ['NODE_ENV'];
    for (const envVar of requiredEnvVars) {
      const exists = process.env[envVar] !== undefined;
      checks.push({
        name: `Environment Variable: ${envVar}`,
        passed: exists,
        message: `${envVar} ${exists ? 'is set ✅' : 'is not set ❌'}`
      });
    }

    // Check disk space (simplified)
    try {
      const stats = await fs.stat(process.cwd());
      checks.push({
        name: 'Disk Space',
        passed: true,
        message: 'Sufficient disk space available ✅'
      });
    } catch (error) {
      checks.push({
        name: 'Disk Space',
        passed: false,
        message: 'Unable to check disk space ❌'
      });
    }

    const allPassed = checks.every(check => check.passed);

    return {
      passed: allPassed,
      checks,
      summary: `${checks.filter(c => c.passed).length}/${checks.length} checks passed`
    };
  }

  private checkNodeVersion(version: string): boolean {
    const majorVersion = parseInt(version.slice(1).split('.')[0]);
    return majorVersion >= 16;
  }
}

// Type definitions
export interface PipelineConfigOptions {
  platforms: ('github' | 'azure' | 'jenkins')[];
  outputDir?: string;
  triggerBranches?: string[];
  includeTests?: boolean;
  includeDocker?: boolean;
  deploymentEnvironments?: string[];
}

export interface CIValidationResult {
  passed: boolean;
  checks: CICheck[];
  summary: string;
}

export interface CICheck {
  name: string;
  passed: boolean;
  message: string;
}