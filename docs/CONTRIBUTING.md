# Contributing to MSAPP Generator

Thank you for your interest in contributing to the MSAPP Generator! This document provides guidelines and information for contributors.

## Table of Contents

- [Getting Started](#getting-started)
- [Development Setup](#development-setup)
- [Project Structure](#project-structure)
- [Development Workflow](#development-workflow)
- [Testing](#testing)
- [Code Style](#code-style)
- [Submitting Changes](#submitting-changes)
- [Issue Reporting](#issue-reporting)

## Getting Started

### Prerequisites

- Node.js 16.0.0 or higher
- npm or yarn
- Git
- Power Platform CLI (for testing)
- TypeScript knowledge

### Fork and Clone

1. Fork the repository on GitHub
2. Clone your fork locally:
   ```bash
   git clone https://github.com/your-username/msapp-generator.git
   cd msapp-generator
   ```

3. Add the upstream remote:
   ```bash
   git remote add upstream https://github.com/original-org/msapp-generator.git
   ```

## Development Setup

1. **Install dependencies:**
   ```bash
   npm install
   ```

2. **Build the project:**
   ```bash
   npm run build
   ```

3. **Run tests:**
   ```bash
   npm test
   ```

4. **Run in development mode:**
   ```bash
   npm run dev
   ```

5. **Link for local testing:**
   ```bash
   npm link
   ```

## Project Structure

```
msapp-generator/
├── src/                          # Source code
│   ├── parsers/                  # FX file parsers
│   ├── processors/               # Metadata processors
│   ├── builders/                 # Solution builders
│   ├── creators/                 # Package creators
│   ├── validators/               # Validation engines
│   ├── batch/                    # Batch processing
│   ├── ci/                       # CI/CD integration
│   ├── interfaces/               # TypeScript interfaces
│   ├── types/                    # Type definitions
│   ├── errors/                   # Error classes
│   ├── implementations/          # Concrete implementations
│   ├── __tests__/               # Unit tests
│   ├── cli.ts                   # CLI entry point
│   ├── index.ts                 # Main export
│   └── MSAppGenerator.ts        # Main generator class
├── examples/                     # Example configurations
├── docs/                        # Documentation
├── dist/                        # Compiled output
├── .temp/                       # Temporary files
├── package.json
├── tsconfig.json
├── jest.config.js
└── README.md
```

## Development Workflow

### 1. Create a Feature Branch

```bash
git checkout -b feature/your-feature-name
```

### 2. Make Changes

- Follow the existing code style
- Add tests for new functionality
- Update documentation as needed
- Ensure all tests pass

### 3. Commit Changes

Use conventional commit messages:

```bash
git commit -m "feat: add batch processing support"
git commit -m "fix: resolve parsing error for nested controls"
git commit -m "docs: update API documentation"
```

Commit types:
- `feat`: New features
- `fix`: Bug fixes
- `docs`: Documentation changes
- `style`: Code style changes
- `refactor`: Code refactoring
- `test`: Test additions or modifications
- `chore`: Build process or auxiliary tool changes

### 4. Push and Create Pull Request

```bash
git push origin feature/your-feature-name
```

Then create a pull request on GitHub.

## Testing

### Running Tests

```bash
# Run all tests
npm test

# Run tests in watch mode
npm run test:watch

# Run tests with coverage
npm run test:coverage

# Run specific test file
npm test -- FXParser.test.ts

# Run integration tests
npm test -- --testPathPattern=integration
```

### Writing Tests

1. **Unit Tests**: Test individual functions and classes
2. **Integration Tests**: Test component interactions
3. **End-to-End Tests**: Test complete workflows

#### Test Structure

```typescript
describe('ComponentName', () => {
  let component: ComponentName;

  beforeEach(() => {
    component = new ComponentName();
  });

  describe('methodName', () => {
    it('should do something specific', () => {
      // Arrange
      const input = 'test input';
      
      // Act
      const result = component.methodName(input);
      
      // Assert
      expect(result).toBe('expected output');
    });

    it('should handle error cases', () => {
      expect(() => component.methodName(null)).toThrow();
    });
  });
});
```

#### Test Guidelines

- Write descriptive test names
- Test both success and error cases
- Use meaningful assertions
- Mock external dependencies
- Keep tests focused and isolated

### Test Coverage

Maintain high test coverage:
- Aim for >90% line coverage
- Ensure all public methods are tested
- Test error handling paths
- Include edge cases

## Code Style

### TypeScript Guidelines

1. **Use strict TypeScript:**
   ```typescript
   // Good
   function processData(data: string[]): ProcessedData {
     return data.map(item => ({ value: item }));
   }

   // Bad
   function processData(data: any): any {
     return data.map((item: any) => ({ value: item }));
   }
   ```

2. **Prefer interfaces over types for object shapes:**
   ```typescript
   // Good
   interface UserConfig {
     name: string;
     email: string;
   }

   // Acceptable for unions
   type Status = 'pending' | 'completed' | 'failed';
   ```

3. **Use meaningful names:**
   ```typescript
   // Good
   const validationResult = validateConfiguration(config);
   
   // Bad
   const result = validate(cfg);
   ```

### Error Handling

1. **Use custom error classes:**
   ```typescript
   throw new MSAppGeneratorError(
     'Configuration validation failed',
     ErrorCategory.CONFIGURATION,
     configFile
   );
   ```

2. **Provide helpful error messages:**
   ```typescript
   // Good
   throw new Error(`Screen file not found: ${screenPath}. Please check the file path and ensure the file exists.`);
   
   // Bad
   throw new Error('File not found');
   ```

### Async/Await

Prefer async/await over Promises:

```typescript
// Good
async function processFile(filePath: string): Promise<ProcessedFile> {
  try {
    const content = await fs.readFile(filePath, 'utf-8');
    return await processContent(content);
  } catch (error) {
    throw new MSAppGeneratorError(`Failed to process file: ${error.message}`);
  }
}

// Avoid
function processFile(filePath: string): Promise<ProcessedFile> {
  return fs.readFile(filePath, 'utf-8')
    .then(content => processContent(content))
    .catch(error => {
      throw new MSAppGeneratorError(`Failed to process file: ${error.message}`);
    });
}
```

### Documentation

1. **Use JSDoc for public APIs:**
   ```typescript
   /**
    * Parse Power Apps .fx file and extract screen definition
    * @param filePath - Path to the .fx file
    * @returns Promise resolving to screen definition
    * @throws MSAppGeneratorError when file cannot be parsed
    */
   async parseScreenFile(filePath: string): Promise<ScreenDefinition> {
     // Implementation
   }
   ```

2. **Add inline comments for complex logic:**
   ```typescript
   // Extract property formulas (Property: Formula)
   const propertyRegex = /(\w+):\s*([^,\n}]+)/g;
   let match;
   
   while ((match = propertyRegex.exec(content)) !== null) {
     const [, property, formula] = match;
     // Only include actual formulas, not literal values
     if (this.isFormula(formula.trim())) {
       formulas[property] = formula.trim();
     }
   }
   ```

## Submitting Changes

### Pull Request Process

1. **Ensure your branch is up to date:**
   ```bash
   git fetch upstream
   git rebase upstream/main
   ```

2. **Run the full test suite:**
   ```bash
   npm test
   npm run lint
   npm run build
   ```

3. **Create a detailed pull request:**
   - Clear title describing the change
   - Detailed description of what was changed and why
   - Link to related issues
   - Screenshots for UI changes
   - Breaking change notes if applicable

### Pull Request Template

```markdown
## Description
Brief description of the changes made.

## Type of Change
- [ ] Bug fix (non-breaking change which fixes an issue)
- [ ] New feature (non-breaking change which adds functionality)
- [ ] Breaking change (fix or feature that would cause existing functionality to not work as expected)
- [ ] Documentation update

## Testing
- [ ] Unit tests pass
- [ ] Integration tests pass
- [ ] Manual testing completed

## Checklist
- [ ] Code follows the project's style guidelines
- [ ] Self-review of code completed
- [ ] Code is commented, particularly in hard-to-understand areas
- [ ] Documentation has been updated
- [ ] No new warnings introduced
```

### Review Process

1. **Automated checks must pass:**
   - All tests pass
   - Linting passes
   - Build succeeds
   - Coverage requirements met

2. **Code review:**
   - At least one maintainer approval required
   - Address all review comments
   - Update based on feedback

3. **Merge:**
   - Squash commits for clean history
   - Update changelog if needed
   - Tag releases appropriately

## Issue Reporting

### Bug Reports

Use the bug report template:

```markdown
**Describe the bug**
A clear and concise description of what the bug is.

**To Reproduce**
Steps to reproduce the behavior:
1. Go to '...'
2. Click on '....'
3. Scroll down to '....'
4. See error

**Expected behavior**
A clear and concise description of what you expected to happen.

**Environment:**
- OS: [e.g. Windows 10, macOS 12.0]
- Node.js version: [e.g. 18.0.0]
- MSAPP Generator version: [e.g. 1.0.0]
- Power Platform CLI version: [e.g. 1.0.0]

**Additional context**
Add any other context about the problem here.
```

### Feature Requests

Use the feature request template:

```markdown
**Is your feature request related to a problem? Please describe.**
A clear and concise description of what the problem is.

**Describe the solution you'd like**
A clear and concise description of what you want to happen.

**Describe alternatives you've considered**
A clear and concise description of any alternative solutions or features you've considered.

**Additional context**
Add any other context or screenshots about the feature request here.
```

## Development Tips

### Debugging

1. **Use VS Code debugger:**
   - Set breakpoints in TypeScript files
   - Use launch configurations for testing

2. **Enable verbose logging:**
   ```bash
   DEBUG=msapp-generator:* npm test
   ```

3. **Use temporary test files:**
   ```typescript
   // Create test files in .temp directory
   const testFile = path.join(__dirname, '../.temp/test-file.fx');
   ```

### Performance

1. **Profile performance:**
   ```bash
   npm run build:profile
   ```

2. **Monitor memory usage:**
   ```typescript
   console.log('Memory usage:', process.memoryUsage());
   ```

3. **Use async operations:**
   - Prefer streaming for large files
   - Use parallel processing where appropriate
   - Implement caching for expensive operations

### Best Practices

1. **Keep functions small and focused**
2. **Use dependency injection for testability**
3. **Implement proper error boundaries**
4. **Log important operations**
5. **Validate inputs early**
6. **Use TypeScript strict mode**
7. **Write self-documenting code**

## Getting Help

- **Discord/Slack**: Join our community chat
- **GitHub Discussions**: Ask questions and share ideas
- **Stack Overflow**: Tag questions with `msapp-generator`
- **Email**: Contact maintainers directly for sensitive issues

## Recognition

Contributors will be recognized in:
- README.md contributors section
- Release notes
- Annual contributor highlights
- Conference presentations (with permission)

Thank you for contributing to MSAPP Generator!