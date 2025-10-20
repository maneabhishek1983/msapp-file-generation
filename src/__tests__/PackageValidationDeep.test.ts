import AdmZip from 'adm-zip';
import * as fs from 'fs-extra';
import * as os from 'os';
import * as path from 'path';

import { ValidationEngine } from '../validators/ValidationEngine';

describe('ValidationEngine package structural validation', () => {
  let tempDir: string;
  let validator: ValidationEngine;

  beforeEach(async () => {
    validator = new ValidationEngine();
    tempDir = await fs.mkdtemp(path.join(os.tmpdir(), 'msapp-package-test-'));
  });

  afterEach(async () => {
    await fs.remove(tempDir);
  });

  const writePackage = async (files: Record<string, string | Buffer>): Promise<string> => {
    const archive = new AdmZip();

    for (const [name, content] of Object.entries(files)) {
      const buffer = Buffer.isBuffer(content) ? content : Buffer.from(content, 'utf8');
      archive.addFile(name, buffer);
    }

    const filePath = path.join(tempDir, 'test.msapp');
    archive.writeZip(filePath);

    return filePath;
  };

  const manifest = (overrides: Record<string, unknown> = {}): string => JSON.stringify({
    AppVersion: '2024.100.0',
    FormatVersion: '2.0',
    Properties: {},
    ScreenOrder: ['HomeScreen'],
    ...overrides
  }, null, 2);

  const appJson = JSON.stringify({
    Properties: {
      StartScreen: 'HomeScreen'
    }
  }, null, 2);

  const propertiesJson = JSON.stringify({ App: { Name: 'Test' } }, null, 2);

  const baseFiles = (): Record<string, string | Buffer> => ({
    'App.json': appJson,
    'Manifest.json': manifest(),
    'Properties.json': propertiesJson,
    'Resources/Resources.json': JSON.stringify({
      Resources: [
        {
          Path: 'Media/logo.png'
        }
      ]
    }, null, 2),
    'Media/logo.png': Buffer.from([0, 1, 2, 3]),
    'Src/HomeScreen.fx': 'ControlId: "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee"'
  });

  it('accepts a well-formed package', async () => {
    const packagePath = await writePackage(baseFiles());
    const result = await validator.validatePackage(packagePath);

    expect(result.errors).toHaveLength(0);
    expect(result.isValid).toBe(true);
  });

  it('detects manifest casing mismatches', async () => {
    const files = baseFiles();
    files['Manifest.json'] = JSON.stringify({
      AppVersion: '2024.100.0',
      formatVersion: '2.0',
      Properties: {},
      ScreenOrder: ['HomeScreen']
    }, null, 2);

    const packagePath = await writePackage(files);
    const result = await validator.validatePackage(packagePath);

    expect(result.isValid).toBe(false);
    expect(result.errors.some(error => error.message.includes('Manifest key'))).toBe(true);
  });

  it('detects nested package archives', async () => {
    const nestedFiles: Record<string, string | Buffer> = {};
    for (const [name, content] of Object.entries(baseFiles())) {
      nestedFiles[`App/${name}`] = content;
    }

    const packagePath = await writePackage(nestedFiles);
    const result = await validator.validatePackage(packagePath);

    expect(result.isValid).toBe(false);
    expect(result.errors.some(error => error.message.includes('nested under'))).toBe(true);
  });

  it('detects duplicate control identifiers', async () => {
    const files = baseFiles();
    files['Src/Another.fx'] = 'ControlId: "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee"';

    const packagePath = await writePackage(files);
    const result = await validator.validatePackage(packagePath);

    expect(result.isValid).toBe(false);
    expect(result.errors.some(error => error.message.includes('Duplicate ControlId'))).toBe(true);
  });
});

