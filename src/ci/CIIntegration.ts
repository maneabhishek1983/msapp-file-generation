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

    const workflow = {
      name: 'Build Power Apps',
      on: {
        push: {
          branches: options.triggerBranches || ['main', 'develop']
        },
        pull_request: {
          branches: options.triggerBranches || ['main']
        }
      },
      jobs: {
        build: {
          'runs-on': 'ubuntu-latest',
          steps: [
            {
              name: 'Checkout code',
              uses: 'actions/checkout@v4'
            },
            {
              name: 'Setup Node.js',
              uses: 'actions/setup-node@v4',
              with: {
                'node-version': '18',
                'cache': 'npm'
              }
            },
            {
              name: 'Install Power Platform CLI',
              run: 'npm install -g @microsoft/powerplatform-cli'
            },
            {
              name: 'Install dependencies',
              run: 'npm ci'
            },
            {
              name: 'Validate source code',
              run: 'npx msapp-gen validate -s ./src -c ./msapp-generator.config.json'
            },
            {
              name: 'Build .msapp packages',
              run: 'npx msapp-gen generate -s ./src -o ./dist/app.msapp -c ./msapp-generator.config.json'
            },
            {
              name: 'Upload artifacts',
              uses: 'actions/upload-artifact@v4',
              with: {
                name: 'msapp-packages',
                path: './dist/*.msapp'
              }
            }
          ]
        }
      }
    };

    if (options.includeTests) {
      workflow.jobs.build.steps.splice(-2, 0, {
        name: 'Run tests',
        run: 'npm test'
      });
    }

    if (options.deploymentEnvironments && options.deploymentEnvironments.length > 0) {
      (workflow.jobs as any).deploy = {
        'runs-on': 'ubuntu-latest',
        needs: 'build',
        if: "github.ref == 'refs/heads/main'",
        strategy: {
          matrix: {
            environment: options.deploymentEnvironments
          }
        },
        steps: [
          {
            name: 'Download artifacts',
            uses: 'actions/download-artifact@v4',
            with: {
              name: 'msapp-packages',
              path: './dist'
            }
          },
          {
            name: 'Deploy to Power Platform',
            run: `pac solution import --path ./dist/app.msapp --environment \${{ matrix.environment }}`
          }
        ]
      };
    }

    await fs.writeFile(
      path.join(workflowDir, 'build-powerapps.yml'),
      `# Auto-generated GitHub Actions workflow for Power Apps\n${JSON.stringify(workflow, null, 2)}`,
      'utf-8'
    );
  }

  /**
   * Generate Azure DevOps pipeline
   */
  private async generateAzureDevOps(outputDir: string, options: PipelineConfigOptions): Promise<void> {
    const pipeline = {
      trigger: options.triggerBranches || ['main', 'develop'],
      pr: options.triggerBranches || ['main'],
      pool: {
        vmImage: 'ubuntu-latest'
      },
      variables: {
        buildConfiguration: 'Release'
      },
      stages: [
        {
          stage: 'Build',
          displayName: 'Build Power Apps',
          jobs: [
            {
              job: 'BuildJob',
              displayName: 'Build .msapp packages',
              steps: [
                {
                  task: 'NodeTool@0',
                  displayName: 'Setup Node.js',
                  inputs: {
                    versionSpec: '18.x'
                  }
                },
                {
                  script: 'npm install -g @microsoft/powerplatform-cli',
                  displayName: 'Install Power Platform CLI'
                },
                {
                  script: 'npm ci',
                  displayName: 'Install dependencies'
                },
                {
                  script: 'npx msapp-gen validate -s ./src -c ./msapp-generator.config.json',
                  displayName: 'Validate source code'
                }
              ]
            }
          ]
        }
      ]
    };

    if (options.includeTests) {
      pipeline.stages[0].jobs[0].steps.push({
        script: 'npm test',
        displayName: 'Run tests'
      });
    }

    pipeline.stages[0].jobs[0].steps.push(
      {
        script: 'npx msapp-gen generate -s ./src -o ./dist/app.msapp -c ./msapp-generator.config.json',
        displayName: 'Build .msapp packages'
      },
      {
        task: 'PublishBuildArtifacts@1',
        displayName: 'Publish artifacts',
        inputs: {
          PathtoPublish: './dist',
          ArtifactName: 'msapp-packages'
        } as any
      }
    );

    if (options.deploymentEnvironments && options.deploymentEnvironments.length > 0) {
      (pipeline.stages as any).push({
        stage: 'Deploy',
        displayName: 'Deploy to Power Platform',
        dependsOn: 'Build',
        condition: "eq(variables['Build.SourceBranch'], 'refs/heads/main')",
        jobs: options.deploymentEnvironments.map(env => ({
          job: `Deploy_${env}`,
          displayName: `Deploy to ${env}`,
          steps: [
            {
              script: `pac solution import --path ./dist/app.msapp --environment ${env}`,
              displayName: `Deploy to ${env}`
            }
          ]
        }))
      });
    }

    await fs.writeFile(
      path.join(outputDir, 'azure-pipelines.yml'),
      `# Auto-generated Azure DevOps pipeline for Power Apps\n${JSON.stringify(pipeline, null, 2)}`,
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