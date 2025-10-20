#!/usr/bin/env node

/**
 * CLI entry point for MSAPP Generator
 */

import { Command } from 'commander';
import chalk from 'chalk';
import { MSAppGenerator } from './MSAppGenerator';
import { CommandOptions } from './types';
import { MSAppGeneratorError } from './errors';
import { BatchProcessor, BatchConfiguration } from './batch/BatchProcessor';
import { CIIntegration, PipelineConfigOptions } from './ci/CIIntegration';
import * as fs from 'fs-extra';
import * as path from 'path';

const program = new Command();

program
  .name('msapp-gen')
  .description('Generate .msapp packages from Power Apps source code')
  .version('1.0.0');

program
  .command('generate')
  .description('Generate .msapp package from source code')
  .requiredOption('-s, --source <dir>', 'Source directory containing .fx files')
  .requiredOption('-o, --output <file>', 'Output path for .msapp package')
  .option('-c, --config <file>', 'Configuration file path')
  .option('--no-validate', 'Skip validation before generation')
  .option('--dry-run', 'Validate without creating package')
  .option('-v, --verbose', 'Enable verbose logging')
  .action(async (options) => {
    try {
      console.log(chalk.blue('🚀 Starting MSAPP generation...'));
      
      const commandOptions: CommandOptions = {
        sourceDir: options.source,
        outputPath: options.output,
        configFile: options.config,
        validate: options.validate,
        dryRun: options.dryRun,
        verbose: options.verbose
      };

      // Initialize generator with concrete implementations
      const generator = MSAppGenerator.create();
      await generator.generate(commandOptions);
      
      if (options.dryRun) {
        console.log(chalk.green('✅ Dry run completed successfully'));
      } else {
        console.log(chalk.green('✅ Package generation completed successfully'));
      }
    } catch (error) {
      if (error instanceof MSAppGeneratorError) {
        console.error(chalk.red(error.getFormattedMessage()));
      } else {
        console.error(chalk.red(`❌ Error: ${error instanceof Error ? error.message : String(error)}`));
      }
      process.exit(1);
    }
  });

program
  .command('validate')
  .description('Validate source code without generating package')
  .requiredOption('-s, --source <dir>', 'Source directory containing .fx files')
  .option('-c, --config <file>', 'Configuration file path')
  .option('-v, --verbose', 'Enable verbose logging')
  .action(async (options) => {
    try {
      console.log(chalk.blue('🔍 Validating source code...'));
      
      // Initialize validation engine
      const generator = MSAppGenerator.create();
      const result = await generator.validate(options.source, options.config);
      
      if (result.isValid) {
        console.log(chalk.green('✅ Validation completed successfully'));
      } else {
        console.log(chalk.red(`❌ Validation failed with ${result.errors.length} errors`));
        result.errors.forEach(error => {
          console.log(chalk.red(`  • ${error.message}`));
        });
      }
      
      if (result.warnings.length > 0) {
        console.log(chalk.yellow(`⚠️  ${result.warnings.length} warnings:`));
        result.warnings.forEach(warning => {
          console.log(chalk.yellow(`  • ${warning.message}`));
        });
      }
    } catch (error) {
      if (error instanceof MSAppGeneratorError) {
        console.error(chalk.red(error.getFormattedMessage()));
      } else {
        console.error(chalk.red(`❌ Error: ${error instanceof Error ? error.message : String(error)}`));
      }
      process.exit(1);
    }
  });

program
  .command('batch')
  .description('Process multiple applications in batch')
  .requiredOption('-c, --config <file>', 'Batch configuration file')
  .option('--parallel', 'Process applications in parallel')
  .option('--report <file>', 'Generate batch report')
  .option('-v, --verbose', 'Enable verbose logging')
  .action(async (options) => {
    try {
      console.log(chalk.blue('🚀 Starting batch processing...'));
      
      if (!await fs.pathExists(options.config)) {
        throw new Error(`Batch configuration file not found: ${options.config}`);
      }

      const batchConfig: BatchConfiguration = await fs.readJSON(options.config);
      
      // Override options from CLI
      if (options.parallel) batchConfig.parallel = true;
      if (options.report) {
        batchConfig.generateReport = true;
        batchConfig.reportPath = options.report;
      }
      if (options.verbose) {
        batchConfig.globalOptions = { ...batchConfig.globalOptions, verbose: true };
      }

      const batchProcessor = new BatchProcessor();
      const result = await batchProcessor.processBatch(batchConfig);

      if (result.success) {
        console.log(chalk.green(`✅ Batch processing completed successfully`));
        console.log(chalk.green(`📊 ${result.successfulApplications}/${result.totalApplications} applications processed`));
      } else {
        console.log(chalk.red(`❌ Batch processing completed with errors`));
        console.log(chalk.red(`📊 ${result.failedApplications}/${result.totalApplications} applications failed`));
        process.exit(1);
      }
    } catch (error) {
      if (error instanceof MSAppGeneratorError) {
        console.error(chalk.red(error.getFormattedMessage()));
      } else {
        console.error(chalk.red(`❌ Error: ${error instanceof Error ? error.message : String(error)}`));
      }
      process.exit(1);
    }
  });

program
  .command('ci-setup')
  .description('Generate CI/CD pipeline configurations')
  .option('--platforms <platforms>', 'Target platforms (github,azure,jenkins)', 'github')
  .option('--output <dir>', 'Output directory for configurations', './ci')
  .option('--branches <branches>', 'Trigger branches', 'main,develop')
  .option('--include-tests', 'Include test steps in pipeline')
  .option('--include-docker', 'Include Docker configuration')
  .option('--environments <envs>', 'Deployment environments')
  .action(async (options) => {
    try {
      console.log(chalk.blue('🔧 Generating CI/CD configurations...'));

      const ciIntegration = new CIIntegration();
      
      const pipelineOptions: PipelineConfigOptions = {
        platforms: options.platforms.split(',') as ('github' | 'azure' | 'jenkins')[],
        outputDir: options.output,
        triggerBranches: options.branches.split(','),
        includeTests: options.includeTests,
        includeDocker: options.includeDocker,
        deploymentEnvironments: options.environments ? options.environments.split(',') : undefined
      };

      await ciIntegration.generatePipelineConfigs(pipelineOptions);
      
      console.log(chalk.green('✅ CI/CD configurations generated successfully'));
    } catch (error) {
      console.error(chalk.red(`❌ Error: ${error instanceof Error ? error.message : String(error)}`));
      process.exit(1);
    }
  });

program
  .command('ci-validate')
  .description('Validate CI/CD environment')
  .action(async () => {
    try {
      console.log(chalk.blue('🔍 Validating CI/CD environment...'));

      const ciIntegration = new CIIntegration();
      const result = await ciIntegration.validateCIEnvironment();

      console.log(chalk.blue('\n📋 CI/CD Environment Check Results:'));
      result.checks.forEach(check => {
        console.log(`  ${check.message}`);
      });

      console.log(`\n${result.summary}`);

      if (result.passed) {
        console.log(chalk.green('✅ CI/CD environment is ready'));
      } else {
        console.log(chalk.red('❌ CI/CD environment has issues'));
        process.exit(1);
      }
    } catch (error) {
      console.error(chalk.red(`❌ Error: ${error instanceof Error ? error.message : String(error)}`));
      process.exit(1);
    }
  });

program
  .command('init')
  .description('Initialize a new Power Apps project')
  .option('-n, --name <name>', 'Project name', 'MyPowerApp')
  .option('-d, --dir <directory>', 'Project directory', '.')
  .option('--template <template>', 'Project template', 'basic')
  .action(async (options) => {
    try {
      console.log(chalk.blue(`🚀 Initializing new Power Apps project: ${options.name}`));

      const projectDir = path.resolve(options.dir, options.name);
      await fs.ensureDir(projectDir);

      // Create project structure
      await fs.ensureDir(path.join(projectDir, 'src', 'screens'));
      await fs.ensureDir(path.join(projectDir, 'src', 'components'));
      await fs.ensureDir(path.join(projectDir, 'src', 'assets'));
      await fs.ensureDir(path.join(projectDir, 'tests'));

      // Create default configuration
      const generator = MSAppGenerator.create();
      const defaultConfig = generator['metadataProcessor'].createDefaultConfiguration();
      defaultConfig.app.name = options.name;
      defaultConfig.app.displayName = options.name;

      await fs.writeJSON(
        path.join(projectDir, 'msapp-generator.config.json'),
        defaultConfig,
        { spaces: 2 }
      );

      // Create sample files based on template
      if (options.template === 'basic') {
        await createBasicTemplate(projectDir, options.name);
      }

      // Create package.json
      const packageJson = {
        name: options.name.toLowerCase().replace(/\s+/g, '-'),
        version: '1.0.0',
        description: `Power Apps project: ${options.name}`,
        scripts: {
          build: 'msapp-gen generate -s ./src -o ./dist/app.msapp -c ./msapp-generator.config.json',
          validate: 'msapp-gen validate -s ./src -c ./msapp-generator.config.json',
          'build:dev': 'msapp-gen generate -s ./src -o ./dist/app-dev.msapp -c ./msapp-generator.config.json --dry-run'
        },
        devDependencies: {
          'msapp-generator': '^1.0.0'
        }
      };

      await fs.writeJSON(path.join(projectDir, 'package.json'), packageJson, { spaces: 2 });

      // Create README
      const readme = `# ${options.name}

A Power Apps application generated with MSAPP Generator.

## Getting Started

1. Install dependencies:
   \`\`\`bash
   npm install
   \`\`\`

2. Validate your source code:
   \`\`\`bash
   npm run validate
   \`\`\`

3. Build the .msapp package:
   \`\`\`bash
   npm run build
   \`\`\`

## Project Structure

- \`src/screens/\` - Screen definitions (.fx files)
- \`src/components/\` - Component definitions (.fx files)
- \`src/assets/\` - Images, icons, and other resources
- \`msapp-generator.config.json\` - Project configuration
- \`dist/\` - Generated .msapp packages

## Commands

- \`npm run build\` - Generate .msapp package
- \`npm run validate\` - Validate source code
- \`npm run build:dev\` - Dry run build for development

## Documentation

For more information, see the [MSAPP Generator documentation](https://github.com/your-org/msapp-generator).
`;

      await fs.writeFile(path.join(projectDir, 'README.md'), readme);

      console.log(chalk.green(`✅ Project ${options.name} initialized successfully`));
      console.log(chalk.blue(`📁 Project created in: ${projectDir}`));
      console.log(chalk.blue(`🚀 Next steps:`));
      console.log(chalk.blue(`   cd ${options.name}`));
      console.log(chalk.blue(`   npm install`));
      console.log(chalk.blue(`   npm run validate`));
    } catch (error) {
      console.error(chalk.red(`❌ Error: ${error instanceof Error ? error.message : String(error)}`));
      process.exit(1);
    }
  });

// Helper function to create basic template
async function createBasicTemplate(projectDir: string, projectName: string): Promise<void> {
  // Create sample home screen
  const homeScreen = `// ${projectName} - Home Screen
Screen(
  Fill: Color.White,
  
  // Header
  Rectangle(
    X: 0, Y: 0, Width: Parent.Width, Height: 80,
    Fill: RGBA(0, 120, 212, 1),
    
    Label(
      Text: "${projectName}",
      X: 20, Y: 20, Width: Parent.Width - 40, Height: 40,
      Color: Color.White,
      Font: Font.'Segoe UI',
      Size: 18,
      FontWeight: FontWeight.Semibold
    )
  ),
  
  // Welcome message
  Label(
    Text: "Welcome to ${projectName}!",
    X: 20, Y: 100, Width: Parent.Width - 40, Height: 50,
    Color: RGBA(50, 50, 50, 1),
    Font: Font.'Segoe UI',
    Size: 16
  ),
  
  // Sample button
  Button(
    Text: "Get Started",
    X: 20, Y: 170, Width: 200, Height: 40,
    Fill: RGBA(0, 120, 212, 1),
    Color: Color.White,
    OnSelect: Notify("Welcome to ${projectName}!", NotificationType.Success)
  )
);`;

  await fs.writeFile(path.join(projectDir, 'src', 'screens', 'HomeScreen.fx'), homeScreen);

  // Create sample component
  const headerComponent = `// ${projectName} - Header Component
Component(
  // Custom properties
  CustomProperty(Title, Text, "${projectName}"),
  CustomProperty(BackgroundColor, Color, RGBA(0, 120, 212, 1)),
  
  // Component layout
  Rectangle(
    Width: Parent.Width,
    Height: 80,
    Fill: BackgroundColor,
    
    Label(
      Text: Title,
      X: 20, Y: 20, Width: Parent.Width - 40, Height: 40,
      Color: Color.White,
      Font: Font.'Segoe UI',
      Size: 18,
      FontWeight: FontWeight.Semibold
    )
  )
);`;

  await fs.writeFile(path.join(projectDir, 'src', 'components', 'HeaderComponent.fx'), headerComponent);

  // Create sample asset placeholder
  await fs.writeFile(
    path.join(projectDir, 'src', 'assets', 'README.md'),
    '# Assets\n\nPlace your images, icons, and other resources in this directory.\n'
  );
}

program.parse();