# MSAPP Generator

Automated .msapp generation tool for Power Apps that converts source code files (.fx files) and configuration metadata into deployable Power Apps packages (.msapp files).

## Features

- 🚀 **Automated Package Generation**: Convert .fx files to .msapp packages
- 🔧 **CI/CD Integration**: Command-line interface for automated pipelines
- ✅ **Validation Engine**: Comprehensive error checking and package validation
- ⚙️ **Configuration Management**: Flexible app metadata and settings handling
- 📦 **Batch Processing**: Multi-application and incremental build support

## Installation

```bash
npm install -g msapp-generator
```

## Usage

### Generate .msapp Package

```bash
msapp-gen generate -s ./src -o ./output/MyApp.msapp -c ./config/app.config.json
```

### Validate Source Code

```bash
msapp-gen validate -s ./src -c ./config/app.config.json
```

### Command Options

- `-s, --source <dir>`: Source directory containing .fx files (required)
- `-o, --output <file>`: Output path for .msapp package (required for generate)
- `-c, --config <file>`: Configuration file path (optional)
- `--no-validate`: Skip validation before generation
- `--dry-run`: Validate without creating package
- `-v, --verbose`: Enable verbose logging

## Project Structure

```
project/
├── src/
│   ├── screens/
│   │   ├── HomeScreen.fx
│   │   ├── DetailScreen.fx
│   │   └── ...
│   ├── components/
│   │   ├── HeaderComponent.fx
│   │   └── ...
│   └── App.OnStart.fx
├── config/
│   ├── app.config.json
│   └── connections.json
├── resources/
│   ├── icons/
│   └── images/
└── msapp-generator.config.json
```

## Configuration

Create a `msapp-generator.config.json` file in your project root:

```json
{
  "app": {
    "name": "MyPowerApp",
    "displayName": "My Power App",
    "description": "A sample Power Apps application",
    "version": "1.0.0",
    "publisher": {
      "name": "MyOrganization",
      "displayName": "My Organization",
      "prefix": "myorg",
      "uniqueName": "myorg"
    }
  },
  "screens": ["src/screens/*.fx"],
  "components": ["src/components/*.fx"],
  "connections": [],
  "resources": [],
  "settings": {
    "enableFormulas": true,
    "enableComponents": true
  }
}
```

## Development

### Prerequisites

- Node.js 16.0.0 or higher
- TypeScript 5.2.2 or higher

### Setup

```bash
git clone <repository-url>
cd msapp-generator
npm install
```

### Build

```bash
npm run build
```

### Test

```bash
npm test
npm run test:watch
```

### Lint

```bash
npm run lint
```

## Architecture

The tool consists of six main components:

1. **CLI Interface**: Handles user interaction and command processing
2. **FX Parser**: Parses Power Apps formula files and extracts definitions
3. **Metadata Processor**: Processes application configuration and settings
4. **Solution Builder**: Creates Power Platform solution structure
5. **Package Creator**: Generates the final .msapp package file
6. **Validation Engine**: Validates source code and generated packages

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Run tests and linting
6. Submit a pull request

## License

MIT License - see LICENSE file for details.

## Support

For issues and questions, please create an issue in the GitHub repository.