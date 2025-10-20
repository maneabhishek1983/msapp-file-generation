import * as fs from 'fs-extra';
import * as os from 'os';
import * as path from 'path';

import { PackageCreator } from '../creators/PackageCreator';
import { SolutionPackage } from '../types';

describe('PackageCreator resource handling', () => {
  let packageCreator: PackageCreator;
  let tempDir: string;

  beforeEach(async () => {
    packageCreator = new PackageCreator();
    tempDir = await fs.mkdtemp(path.join(os.tmpdir(), 'msapp-generator-test-'));
  });

  afterEach(async () => {
    await fs.remove(tempDir);
  });

  const createMinimalSolution = (): SolutionPackage => ({
    metadata: {
      uniqueName: 'test-app',
      displayName: 'Test App',
      description: 'Test application',
      version: '1.0.0',
      publisher: {
        name: 'Test Publisher',
        displayName: 'Test Publisher',
        prefix: 'test',
        uniqueName: 'test'
      }
    },
    canvasApp: {
      name: 'test-app',
      displayName: 'Test App',
      description: 'Test application',
      screens: [],
      components: [],
      properties: {}
    },
    connections: [],
    resources: []
  });

  it('does not embed temporary artifacts when adding resources', async () => {
    const basePackage = createMinimalSolution();
    const initialBuffer = await packageCreator.createPackage(basePackage);

    const resourceFile = path.join(tempDir, 'logo.png');
    await fs.writeFile(resourceFile, Buffer.from([0, 1, 2, 3]));

    const updatedBuffer = await packageCreator.addResources(initialBuffer, [
      {
        name: 'Logo',
        type: 'image',
        path: resourceFile,
        mimeType: 'image/png'
      }
    ]);

    expect(updatedBuffer.equals(initialBuffer)).toBe(false);

    // Ensure the regenerated package does not include staging artifacts
    expect(updatedBuffer.includes(Buffer.from('temp.msapp'))).toBe(false);
    expect(updatedBuffer.includes(Buffer.from('extract_'))).toBe(false);

    const outputPath = path.join(tempDir, 'output.msapp');
    await fs.writeFile(outputPath, updatedBuffer);

    const extracted = await packageCreator.extractPackage(outputPath);
    expect(extracted.resources.some(resource => resource.name === 'Logo')).toBe(true);
  });
});
