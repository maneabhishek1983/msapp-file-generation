import * as fs from 'fs-extra';
import * as path from 'path';
import { glob } from 'glob';
import { IFXParser } from '../interfaces';
import { ScreenDefinition, ComponentDefinition, FormulaMap, ValidationResult, ControlDefinition, PropertyMap, ErrorCategory } from '../types';
import { MSAppGeneratorError } from '../errors';

/**
 * Parser for Power Apps .fx files
 */
export class FXParser implements IFXParser {
  
  async parseScreenFile(filePath: string): Promise<ScreenDefinition> {
    try {
      const content = await fs.readFile(filePath, 'utf-8');
      const fileName = path.basename(filePath, '.fx');
      
      // Extract screen structure
      const controls = this.parseControls(content);
      const properties = this.extractProperties(content);
      const formulas = this.extractFormulas(content);
      
      return {
        name: fileName,
        file: filePath,
        controls,
        properties,
        formulas
      };
    } catch (error) {
      throw new MSAppGeneratorError(
        `Failed to parse screen file: ${error instanceof Error ? error.message : String(error)}`,
        ErrorCategory.SYNTAX,
        filePath
      );
    }
  }

  async parseComponentFile(filePath: string): Promise<ComponentDefinition> {
    try {
      const content = await fs.readFile(filePath, 'utf-8');
      const fileName = path.basename(filePath, '.fx');
      
      // Extract component structure
      const properties = this.extractProperties(content);
      const customProperties = this.extractCustomProperties(content);
      const children = this.parseControls(content);
      
      return {
        name: fileName,
        file: filePath,
        type: 'Component',
        properties,
        customProperties,
        children
      };
    } catch (error) {
      throw new MSAppGeneratorError(
        `Failed to parse component file: ${error instanceof Error ? error.message : String(error)}`,
        ErrorCategory.SYNTAX,
        filePath
      );
    }
  }

  extractFormulas(content: string): FormulaMap {
    const formulas: FormulaMap = {};
    
    // Extract property formulas (Property: Formula)
    const propertyRegex = /(\w+):\s*([^,\n}]+)/g;
    let match;
    
    while ((match = propertyRegex.exec(content)) !== null) {
      const [, property, formula] = match;
      if (this.isFormula(formula.trim())) {
        formulas[property] = formula.trim();
      }
    }
    
    // Extract OnSelect, OnVisible, etc. event formulas
    const eventRegex = /(On\w+):\s*([^,\n}]+)/g;
    while ((match = eventRegex.exec(content)) !== null) {
      const [, event, formula] = match;
      formulas[event] = formula.trim();
    }
    
    return formulas;
  }

  validateSyntax(content: string): ValidationResult {
    const errors: any[] = [];
    const warnings: any[] = [];
    
    try {
      // Basic syntax validation
      this.validateBrackets(content, errors);
      this.validateQuotes(content, errors);
      this.validateFunctionCalls(content, errors, warnings);
      this.validatePropertySyntax(content, errors);
      
      return {
        isValid: errors.length === 0,
        errors,
        warnings
      };
    } catch (error) {
      errors.push({
        message: `Syntax validation failed: ${error instanceof Error ? error.message : String(error)}`,
        category: ErrorCategory.SYNTAX
      });
      
      return {
        isValid: false,
        errors,
        warnings
      };
    }
  }

  async parseDirectory(directoryPath: string): Promise<{ screens: ScreenDefinition[]; components: ComponentDefinition[]; }> {
    try {
      const screens: ScreenDefinition[] = [];
      const components: ComponentDefinition[] = [];
      
      // Find all .fx files
      const fxFiles = await glob('**/*.fx', { cwd: directoryPath });
      
      for (const file of fxFiles) {
        const fullPath = path.join(directoryPath, file);
        const relativePath = path.dirname(file);
        
        // Determine if it's a screen or component based on path or content
        if (relativePath.includes('screens') || relativePath.includes('Screen')) {
          const screen = await this.parseScreenFile(fullPath);
          screens.push(screen);
        } else if (relativePath.includes('components') || relativePath.includes('Component')) {
          const component = await this.parseComponentFile(fullPath);
          components.push(component);
        } else {
          // Auto-detect based on content
          const content = await fs.readFile(fullPath, 'utf-8');
          if (this.isScreenFile(content)) {
            const screen = await this.parseScreenFile(fullPath);
            screens.push(screen);
          } else {
            const component = await this.parseComponentFile(fullPath);
            components.push(component);
          }
        }
      }
      
      return { screens, components };
    } catch (error) {
      throw new MSAppGeneratorError(
        `Failed to parse directory: ${error instanceof Error ? error.message : String(error)}`,
        ErrorCategory.SYNTAX,
        directoryPath
      );
    }
  }

  private parseControls(content: string): ControlDefinition[] {
    const controls: ControlDefinition[] = [];
    
    // Parse control hierarchy using regex patterns
    const controlRegex = /(\w+)\s*\(\s*([^)]*)\s*\)/g;
    let match;
    
    while ((match = controlRegex.exec(content)) !== null) {
      const [, controlType, propertiesStr] = match;
      
      if (this.isControlType(controlType)) {
        const properties = this.parseProperties(propertiesStr);
        
        controls.push({
          name: this.generateControlName(controlType, controls.length),
          type: controlType,
          properties,
          children: [] // TODO: Parse nested controls
        });
      }
    }
    
    return controls;
  }

  private extractProperties(content: string): PropertyMap {
    const properties: PropertyMap = {};
    
    // Extract top-level properties
    const propertyRegex = /(\w+):\s*([^,\n}]+)/g;
    let match;
    
    while ((match = propertyRegex.exec(content)) !== null) {
      const [, property, value] = match;
      properties[property] = this.parsePropertyValue(value.trim());
    }
    
    return properties;
  }

  private extractCustomProperties(content: string): any[] {
    const customProperties: any[] = [];
    
    // Look for custom property definitions
    const customPropRegex = /CustomProperty\s*\(\s*(\w+),\s*(\w+),\s*([^)]+)\)/g;
    let match;
    
    while ((match = customPropRegex.exec(content)) !== null) {
      const [, name, type, defaultValue] = match;
      customProperties.push({
        name,
        type,
        defaultValue: this.parsePropertyValue(defaultValue.trim())
      });
    }
    
    return customProperties;
  }

  private parseProperties(propertiesStr: string): PropertyMap {
    const properties: PropertyMap = {};
    
    // Split properties by comma, handling nested structures
    const props = this.splitProperties(propertiesStr);
    
    for (const prop of props) {
      const colonIndex = prop.indexOf(':');
      if (colonIndex > 0) {
        const key = prop.substring(0, colonIndex).trim();
        const value = prop.substring(colonIndex + 1).trim();
        properties[key] = this.parsePropertyValue(value);
      }
    }
    
    return properties;
  }

  private splitProperties(str: string): string[] {
    const properties: string[] = [];
    let current = '';
    let depth = 0;
    let inString = false;
    let stringChar = '';
    
    for (let i = 0; i < str.length; i++) {
      const char = str[i];
      
      if (!inString && (char === '"' || char === "'")) {
        inString = true;
        stringChar = char;
      } else if (inString && char === stringChar) {
        inString = false;
        stringChar = '';
      } else if (!inString) {
        if (char === '(' || char === '{' || char === '[') {
          depth++;
        } else if (char === ')' || char === '}' || char === ']') {
          depth--;
        } else if (char === ',' && depth === 0) {
          properties.push(current.trim());
          current = '';
          continue;
        }
      }
      
      current += char;
    }
    
    if (current.trim()) {
      properties.push(current.trim());
    }
    
    return properties;
  }

  private parsePropertyValue(value: string): any {
    value = value.trim();
    
    // Handle different value types
    if (value.startsWith('"') && value.endsWith('"')) {
      return value.slice(1, -1); // String literal
    } else if (value.startsWith("'") && value.endsWith("'")) {
      return value.slice(1, -1); // String literal
    } else if (value === 'true' || value === 'false') {
      return value === 'true'; // Boolean
    } else if (/^\d+(\.\d+)?$/.test(value)) {
      return parseFloat(value); // Number
    } else if (value.startsWith('[') && value.endsWith(']')) {
      return value; // Array (keep as string for now)
    } else if (value.startsWith('{') && value.endsWith('}')) {
      return value; // Object (keep as string for now)
    } else {
      return value; // Formula or reference
    }
  }

  private isFormula(value: string): boolean {
    // Check if value contains Power Apps functions or operators
    const formulaPatterns = [
      /\b(If|Switch|Filter|LookUp|Patch|Collect|Set|Navigate|Notify)\b/,
      /\b(Parent\.|ThisItem\.|varTheme\.|col\w+)/,
      /[+\-*/=<>!&|]/,
      /\b(Color\.|Font\.|Align\.)/
    ];
    
    return formulaPatterns.some(pattern => pattern.test(value));
  }

  private isControlType(type: string): boolean {
    const controlTypes = [
      'Screen', 'Rectangle', 'Label', 'Button', 'Gallery', 'Container',
      'TextInput', 'Dropdown', 'Checkbox', 'Toggle', 'Slider', 'DatePicker',
      'Image', 'Icon', 'Timer', 'Audio', 'Video', 'Camera', 'Microphone',
      'BarcodeScanner', 'PDF', 'PowerBITile', 'Form', 'DataCard'
    ];
    
    return controlTypes.includes(type);
  }

  private isScreenFile(content: string): boolean {
    // Check if content starts with Screen( or contains screen-specific patterns
    return /^\s*Screen\s*\(/.test(content) || content.includes('App.ActiveScreen');
  }

  private generateControlName(type: string, index: number): string {
    return `${type}${index + 1}`;
  }

  private validateBrackets(content: string, errors: any[]): void {
    const brackets = { '(': ')', '[': ']', '{': '}' };
    const stack: string[] = [];
    
    for (let i = 0; i < content.length; i++) {
      const char = content[i];
      
      if (char in brackets) {
        stack.push(char);
      } else if (Object.values(brackets).includes(char)) {
        const last = stack.pop();
        if (!last || brackets[last as keyof typeof brackets] !== char) {
          errors.push({
            message: `Mismatched bracket at position ${i}`,
            line: this.getLineNumber(content, i),
            column: this.getColumnNumber(content, i),
            category: ErrorCategory.SYNTAX
          });
        }
      }
    }
    
    if (stack.length > 0) {
      errors.push({
        message: `Unclosed brackets: ${stack.join(', ')}`,
        category: ErrorCategory.SYNTAX
      });
    }
  }

  private validateQuotes(content: string, errors: any[]): void {
    let inString = false;
    let stringChar = '';
    
    for (let i = 0; i < content.length; i++) {
      const char = content[i];
      
      if (!inString && (char === '"' || char === "'")) {
        inString = true;
        stringChar = char;
      } else if (inString && char === stringChar) {
        inString = false;
        stringChar = '';
      }
    }
    
    if (inString) {
      errors.push({
        message: `Unclosed string literal`,
        category: ErrorCategory.SYNTAX
      });
    }
  }

  private validateFunctionCalls(content: string, errors: any[], warnings: any[]): void {
    const functionRegex = /(\w+)\s*\(/g;
    let match;
    
    const knownFunctions = [
      'If', 'Switch', 'Filter', 'LookUp', 'Patch', 'Collect', 'Set', 'Navigate',
      'Notify', 'Text', 'Value', 'DateAdd', 'DateDiff', 'Now', 'Today',
      'CountRows', 'Sum', 'Average', 'Min', 'Max', 'Concatenate', 'Left', 'Right',
      'Mid', 'Len', 'Upper', 'Lower', 'Trim', 'Replace', 'Substitute'
    ];
    
    while ((match = functionRegex.exec(content)) !== null) {
      const [, functionName] = match;
      
      if (!knownFunctions.includes(functionName) && !this.isControlType(functionName)) {
        warnings.push({
          message: `Unknown function: ${functionName}`,
          line: this.getLineNumber(content, match.index),
          column: this.getColumnNumber(content, match.index),
          category: ErrorCategory.VALIDATION
        });
      }
    }
  }

  private validatePropertySyntax(content: string, errors: any[]): void {
    // Validate property assignment syntax
    const propertyRegex = /(\w+):\s*([^,\n}]+)/g;
    let match;
    
    while ((match = propertyRegex.exec(content)) !== null) {
      const [, property, value] = match;
      
      // Check for common property syntax errors
      if (value.trim() === '') {
        errors.push({
          message: `Empty value for property: ${property}`,
          line: this.getLineNumber(content, match.index),
          column: this.getColumnNumber(content, match.index),
          category: ErrorCategory.SYNTAX
        });
      }
    }
  }

  private getLineNumber(content: string, position: number): number {
    return content.substring(0, position).split('\n').length;
  }

  private getColumnNumber(content: string, position: number): number {
    const lines = content.substring(0, position).split('\n');
    return lines[lines.length - 1].length + 1;
  }
}