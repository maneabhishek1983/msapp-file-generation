import * as fs from 'fs-extra';
import * as os from 'os';
import * as path from 'path';
import { PowerFxHeuristics } from '../validators/PowerFxHeuristics';
import { ValidationError, ValidationWarning } from '../types';

describe('PowerFxHeuristics', () => {
  let tempDir: string;
  let heuristics: PowerFxHeuristics;

  beforeEach(async () => {
    heuristics = new PowerFxHeuristics();
    tempDir = await fs.mkdtemp(path.join(os.tmpdir(), 'msapp-heuristics-'));
  });

  afterEach(async () => {
    await fs.remove(tempDir);
  });

  const runHeuristics = async (): Promise<{ errors: ValidationError[]; warnings: ValidationWarning[] }> => {
    const errors: ValidationError[] = [];
    const warnings: ValidationWarning[] = [];

    await heuristics.analyze(tempDir, errors, warnings);

    return { errors, warnings };
  };

  it('flags missing App.OnStart file', async () => {
    await fs.writeFile(path.join(tempDir, 'App.fx'), 'StartScreen: HomeScreen');

    const { errors } = await runHeuristics();

    expect(errors.some(error => error.message.includes('App.OnStart.fx not found'))).toBe(true);
  });

  it('flags behavior formulas on StartScreen', async () => {
    await fs.writeFile(path.join(tempDir, 'App.OnStart.fx'), 'Collect(colSites, { Id: 1 })');
    await fs.writeFile(
      path.join(tempDir, 'App.fx'),
      'StartScreen: Set(varStart, HomeScreen); HomeScreen'
    );

    const { errors } = await runHeuristics();

    expect(errors.some(error => error.message.includes('StartScreen contains behavior'))).toBe(true);
  });

  it('warns when map fallback is missing', async () => {
    await fs.writeFile(path.join(tempDir, 'App.OnStart.fx'), 'Collect(colSites, { Id: 1 })');
    await fs.writeFile(path.join(tempDir, 'App.fx'), 'StartScreen: HomeScreen');
    await fs.writeFile(
      path.join(tempDir, 'MapScreen.fx'),
      'OnVisible: Set(varMapStatus, txtWebMapId.Text)'
    );

    const { warnings } = await runHeuristics();

    expect(warnings.some(warning => warning.message.includes('fallback image'))).toBe(true);
  });
});
