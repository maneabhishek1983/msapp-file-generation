# MSAPP Generator Documentation

The MSAPP Generator is a comprehensive tool for automating the creation of Power Apps .msapp packages from source code. It enables developers to work with Power Apps using familiar development practices including version control, CI/CD, and automated testing.

## Table of Contents

- [Quick Start](#quick-start)
- [Installation](#installation)
- [Configuration](#configuration)
- [CLI Commands](#cli-commands)
- [Batch Processing](#batch-processing)
- [CI/CD Integration](#cicd-integration)
- [API Reference](#api-reference)
- [Examples](#examples)
- [Troubleshooting](#troubleshooting)

## Quick Start

1. **Initialize a new project:**
   ```bash
   npx msapp-gen init --name MyPowerApp
   cd MyPowerApp
   npm install
   ```

2. **Validate your source code:**
   ```bash
   npm run validate
   ```

3. **Generate .msapp package:**
   ```bash
   npm run build
   ```

## Installation

### Prerequisites

- Node.js 16.0.0 or higher
- Power Platform CLI (pac)
- Git (for version control)

### Install Power Platform CLI

```bash
npm install -g @microsoft/powerplatform-cli
```

### Install MSAPP Generator

```bash
npm install -g msapp-generator
```

Or use it directly with npx:
```bash
npx msapp-gen --help
```

## Configuration

The MSAPP Generator uses a `msapp-generator.config.json` file to configure your Power Apps project:

```json
{
  "app": {
    "name": "MyPowerApp",
    "displayName": "My Power App",
    "description": "A Power Apps application",
    "version": "1.0.0.0",
    "publisher": {
      "name": "MyOrganization",
      "displayName": "My Organization",
      "prefix": "myorg",
      "uniqueName": "MyOrganization"
    }
  },
  "screens": [
    "HomeScreen",
    "DetailScreen"
  ],
  "components": [
    "HeaderComponent"
  ],
  "connections": [
    {
      "name": "SharePointConnection",
      "type": "sharepoint",
      "displayName": "SharePoint Online",
      "parameters": {
        "siteUrl": "{{SHAREPOINT_SITE_URL}}"
      }
    }
  ],
  "resources": [
    {
      "name": "AppIcon",
      "type": "image",
      "path": "./assets/app-icon.png",
      "mimeType": "image/png"
    }
  ],
  "settings": {
    "enableFormulas": true,
    "enableComponents": true,
    "theme": "default"
  }
}
```

### Environment Variables

Use environment variables in your configuration for different deployment targets:

- `{{ENVIRONMENT}}` - Current environment (dev, staging, prod)
- `{{API_URL}}` - API endpoint URL
- `{{DATABASE_NAME}}` - Database name
- `{{SHAREPOINT_SITE_URL}}` - SharePoint site URL

## CLI Commands

### Generate Command

Generate .msapp package from source code:

```bash
msapp-gen generate -s ./src -o ./dist/app.msapp -c ./config.json
```

Options:
- `-s, --source <dir>` - Source directory containing .fx files
- `-o, --output <file>` - Output path for .msapp package
- `-c, --config <file>` - Configuration file path
- `--no-validate` - Skip validation before generation
- `--dry-run` - Validate without creating package
- `-v, --verbose` - Enable verbose logging

### Validate Command

Validate source code without generating package:

```bash
msapp-gen validate -s ./src -c ./config.json
```

### Batch Command

Process multiple applications in batch:

```bash
msapp-gen batch -c ./batch-config.json --parallel --report ./report.json
```

### CI Setup Command

Generate CI/CD pipeline configurations:

```bash
msapp-gen ci-setup --platforms github,azure --include-tests --include-docker
```

### CI Validate Command

Validate CI/CD environment:

```bash
msapp-gen ci-validate
```

### Init Command

Initialize a new Power Apps project:

```bash
msapp-gen init --name MyApp --template basic
```

## Batch Processing

Process multiple Power Apps applications efficiently using batch configuration:

### Batch Configuration File

```json
{
  "applications": [
    {
      "name": "App1",
      "sourceDir": "./apps/app1/src",
      "outputPath": "./dist/app1.msapp",
      "configFile": "./apps/app1/config.json"
    },
    {
      "name": "App2",
      "sourceDir": "./apps/app2/src",
      "outputPath": "./dist/app2.msapp",
      "configFile": "./apps/app2/config.json"
    }
  ],
  "parallel": true,
  "generateReport": true,
  "reportPath": "./batch-report.json",
  "globalOptions": {
    "verbose": true,
    "validate": true
  }
}
```

### Batch Processing Features

- **Parallel Processing**: Process multiple apps simultaneously
- **Progress Reporting**: Real-time progress updates
- **Error Handling**: Continue processing even if some apps fail
- **Batch Reports**: Detailed reports with metrics and results
- **Incremental Builds**: Skip unchanged applications

## CI/CD Integration

### Supported Platforms

- **GitHub Actions**
- **Azure DevOps**
- **Jenkins**
- **Docker**

### GitHub Actions Example

```yaml
name: Build Power Apps
on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '18'
      - run: npm install -g @microsoft/powerplatform-cli
      - run: npm ci
      - run: npx msapp-gen validate -s ./src
      - run: npx msapp-gen generate -s ./src -o ./dist/app.msapp
      - uses: actions/upload-artifact@v4
        with:
          name: msapp-packages
          path: ./dist/*.msapp
```

### Environment Setup

1. **Generate CI configurations:**
   ```bash
   msapp-gen ci-setup --platforms github --include-tests --environments dev,staging,prod
   ```

2. **Validate CI environment:**
   ```bash
   msapp-gen ci-validate
   ```

3. **Set up environment variables:**
   - `POWERPLATFORM_CLIENT_ID`
   - `POWERPLATFORM_CLIENT_SECRET`
   - `POWERPLATFORM_TENANT_ID`

## API Reference

### MSAppGenerator Class

```typescript
import { MSAppGenerator } from 'msapp-generator';

const generator = MSAppGenerator.create();

// Generate package
const packageBuffer = await generator.generate({
  sourceDir: './src',
  outputPath: './dist/app.msapp',
  configFile: './config.json'
});

// Validate source code
const validation = await generator.validate('./src', './config.json');
```

### BatchProcessor Class

```typescript
import { BatchProcessor } from 'msapp-generator';

const batchProcessor = new BatchProcessor();

const result = await batchProcessor.processBatch({
  applications: [...],
  parallel: true,
  generateReport: true
});
```

### IncrementalBuilder Class

```typescript
import { IncrementalBuilder } from 'msapp-generator';

const builder = new IncrementalBuilder('./cache');

const packageBuffer = await builder.buildIncremental({
  sourceDir: './src',
  outputPath: './dist/app.msapp'
});
```

## Examples

### Basic Project Structure

```
my-power-app/
├── src/
│   ├── screens/
│   │   ├── HomeScreen.fx
│   │   └── DetailScreen.fx
│   ├── components/
│   │   └── HeaderComponent.fx
│   └── assets/
│       └── app-icon.png
├── msapp-generator.config.json
├── package.json
└── README.md
```

### Screen Definition (.fx file)

```javascript
// HomeScreen.fx
Screen(
  Fill: Color.White,
  
  Rectangle(
    X: 0, Y: 0, Width: Parent.Width, Height: 80,
    Fill: RGBA(0, 120, 212, 1),
    
    Label(
      Text: "My Power App",
      X: 20, Y: 20, Width: Parent.Width - 40, Height: 40,
      Color: Color.White,
      Font: Font.'Segoe UI',
      Size: 18,
      FontWeight: FontWeight.Semibold
    )
  ),
  
  Button(
    Text: "Click Me",
    X: 20, Y: 100, Width: 200, Height: 40,
    Fill: RGBA(0, 120, 212, 1),
    Color: Color.White,
    OnSelect: Notify("Hello World!", NotificationType.Success)
  )
);
```

### Component Definition (.fx file)

```javascript
// HeaderComponent.fx
Component(
  CustomProperty(Title, Text, "Default Title"),
  CustomProperty(BackgroundColor, Color, RGBA(0, 120, 212, 1)),
  
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
);
```

## Troubleshooting

### Common Issues

#### 1. Power Platform CLI Not Found

**Error:** `Power Platform CLI (pac) is not installed`

**Solution:**
```bash
npm install -g @microsoft/powerplatform-cli
```

#### 2. Validation Errors

**Error:** `Validation failed: Syntax error in screen file`

**Solution:**
- Check .fx file syntax
- Ensure proper bracket matching
- Validate formula syntax
- Use `msapp-gen validate` for detailed error messages

#### 3. Package Generation Fails

**Error:** `Failed to create package`

**Solution:**
- Verify all source files exist
- Check configuration file format
- Ensure output directory is writable
- Run with `--verbose` flag for detailed logs

#### 4. Missing Dependencies

**Error:** `Missing dependency: zip utility`

**Solution:**
- Install zip utility on your system
- On Windows: Use PowerShell or install zip tools
- On macOS: `brew install zip`
- On Linux: `sudo apt-get install zip`

### Debug Mode

Enable verbose logging for troubleshooting:

```bash
msapp-gen generate -s ./src -o ./dist/app.msapp --verbose
```

### Log Files

Check log files for detailed error information:
- Build logs: `./logs/build.log`
- Validation logs: `./logs/validation.log`
- Batch processing logs: `./logs/batch.log`

### Getting Help

1. **Check the documentation:** [GitHub Repository](https://github.com/your-org/msapp-generator)
2. **Search existing issues:** [GitHub Issues](https://github.com/your-org/msapp-generator/issues)
3. **Create a new issue:** Include error messages, configuration, and steps to reproduce
4. **Community support:** Join our Discord/Slack community

### Performance Tips

1. **Use incremental builds** for faster development cycles
2. **Enable parallel processing** for batch operations
3. **Optimize .fx files** by reducing complexity
4. **Use caching** in CI/CD pipelines
5. **Minimize resource file sizes** for faster package generation

## Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details on:

- Setting up the development environment
- Running tests
- Submitting pull requests
- Code style guidelines
- Issue reporting

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.