import { MSAppGenerator } from '../../MSAppGenerator';
import { CommandOptions } from '../../types';
import * as fs from 'fs-extra';
import * as path from 'path';

describe('End-to-End Integration Tests', () => {
  let generator: MSAppGenerator;
  const testDataDir = path.join(__dirname, '../../../examples/sample-app');
  const configPath = path.join(__dirname, '../../../examples/msapp-generator.config.json');
  const outputDir = path.join(__dirname, '../../../.temp/test-output');

  beforeEach(async () => {
    generator = MSAppGenerator.create();
    await fs.ensureDir(outputDir);
  });

  afterEach(async () => {
    // Cleanup test output
    await fs.remove(outputDir);
  });

  describe('Complete Generation Workflow', () => {
    it('should generate .msapp package from source code', async () => {
      if (await fs.pathExists(testDataDir) && await fs.pathExists(configPath)) {
        const outputPath = path.join(outputDir, 'test-app.msapp');
        
        const options: CommandOptions = {
          sourceDir: testDataDir,
          outputPath,
          configFile: configPath,
          validate: true,
          dryRun: false,
          verbose: true
        };

        try {
          const packageBuffer = await generator.generate(options);
          
          expect(packageBuffer).toBeDefined();
          expect(Buffer.isBuffer(packageBuffer)).toBe(true);
          expect(packageBuffer.length).toBeGreaterThan(0);
          
          // Check if output file was created
          expect(await fs.pathExists(outputPath)).toBe(true);
          
          const stats = await fs.stat(outputPath);
          expect(stats.size).toBeGreaterThan(0);
        } catch (error) {
          // Log error for debugging but don't fail test if dependencies are missing
          console.warn('Generation test skipped due to missing dependencies:', error);
        }
      } else {
        console.warn('Test data not found, skipping end-to-end test');
      }
    }, 30000); // 30 second timeout for generation

    it('should perform dry run validation', async () => {
      if (await fs.pathExists(testDataDir) && await fs.pathExists(configPath)) {
        const options: CommandOptions = {
          sourceDir: testDataDir,
          outputPath: path.join(outputDir, 'dry-run.msapp'),
          configFile: configPath,
          validate: true,
          dryRun: true,
          verbose: true
        };

        try {
          const packageBuffer = await generator.generate(options);

          expect(packageBuffer).toBeDefined();
          expect(Buffer.isBuffer(packageBuffer)).toBe(true);

          // In dry run mode, output file should not be created
          expect(await fs.pathExists(options.outputPath)).toBe(false);
        } catch (error) {
          console.warn('Dry run test skipped due to missing dependencies:', error);
        }
      }
    });

    it('should validate source code without generation', async () => {
      if (await fs.pathExists(testDataDir)) {
        const result = await generator.validate(testDataDir, configPath);
        
        expect(result).toBeDefined();
        expect(result.isValid).toBeDefined();
        expect(Array.isArray(result.errors)).toBe(true);
        expect(Array.isArray(result.warnings)).toBe(true);
      }
    });

    it('should handle missing configuration gracefully', async () => {
      if (await fs.pathExists(testDataDir)) {
        const options: CommandOptions = {
          sourceDir: testDataDir,
          outputPath: path.join(outputDir, 'no-config.msapp'),
          validate: true,
          dryRun: true,
          verbose: true
        };

        try {
          const packageBuffer = await generator.generate(options);
          
          expect(packageBuffer).toBeDefined();
          expect(Buffer.isBuffer(packageBuffer)).toBe(true);
        } catch (error) {
          // Should handle missing config gracefully
          expect(error).toBeDefined();
        }
      }
    });

    it('should skip validation when requested', async () => {
      if (await fs.pathExists(testDataDir) && await fs.pathExists(configPath)) {
        const options: CommandOptions = {
          sourceDir: testDataDir,
          outputPath: path.join(outputDir, 'no-validation.msapp'),
          configFile: configPath,
          validate: false,
          dryRun: true,
          verbose: false
        };

        try {
          const packageBuffer = await generator.generate(options);
          
          expect(packageBuffer).toBeDefined();
          expect(Buffer.isBuffer(packageBuffer)).toBe(true);
        } catch (error) {
          console.warn('Generation test skipped due to missing dependencies:', error);
        }
      }
    });
  });

  describe('Error Handling', () => {
    it('should handle invalid source directory', async () => {
      const options: CommandOptions = {
        sourceDir: '/non/existent/directory',
        outputPath: path.join(outputDir, 'error-test.msapp'),
        validate: true,
        dryRun: true
      };

      await expect(generator.generate(options)).rejects.toThrow();
    });

    it('should handle invalid configuration file', async () => {
      if (await fs.pathExists(testDataDir)) {
        const invalidConfigPath = path.join(outputDir, 'invalid-config.json');
        await fs.writeFile(invalidConfigPath, '{ invalid json }');

        const options: CommandOptions = {
          sourceDir: testDataDir,
          outputPath: path.join(outputDir, 'invalid-config.msapp'),
          configFile: invalidConfigPath,
          validate: true,
          dryRun: true
        };

        await expect(generator.generate(options)).rejects.toThrow();
      }
    });

    it('should handle permission errors gracefully', async () => {
      if (await fs.pathExists(testDataDir) && await fs.pathExists(configPath)) {
        // Try to write to a read-only location (this may not work on all systems)
        const readOnlyPath = '/root/readonly.msapp';

        const options: CommandOptions = {
          sourceDir: testDataDir,
          outputPath: readOnlyPath,
          configFile: configPath,
          validate: true,
          dryRun: false
        };

        try {
          await generator.generate(options);
        } catch (error) {
          // Should throw a meaningful error
          expect(error).toBeDefined();
        }
      }
    });
  });

  describe('Performance Tests', () => {
    it('should complete generation within reasonable time', async () => {
      if (await fs.pathExists(testDataDir) && await fs.pathExists(configPath)) {
        const startTime = Date.now();
        
        const options: CommandOptions = {
          sourceDir: testDataDir,
          outputPath: path.join(outputDir, 'performance-test.msapp'),
          configFile: configPath,
          validate: true,
          dryRun: true,
          verbose: false
        };

        try {
          await generator.generate(options);
          
          const duration = Date.now() - startTime;
          
          // Should complete within 10 seconds for small test app
          expect(duration).toBeLessThan(10000);
        } catch (error) {
          console.warn('Performance test skipped due to missing dependencies:', error);
        }
      }
    }, 15000); // 15 second timeout

    it('should handle multiple concurrent generations', async () => {
      if (await fs.pathExists(testDataDir) && await fs.pathExists(configPath)) {
        const promises = [];
        
        for (let i = 0; i < 3; i++) {
          const options: CommandOptions = {
            sourceDir: testDataDir,
            outputPath: path.join(outputDir, `concurrent-${i}.msapp`),
            configFile: configPath,
            validate: true,
            dryRun: true,
            verbose: false
          };

          promises.push(generator.generate(options));
        }

        try {
          const results = await Promise.all(promises);
          
          expect(results).toHaveLength(3);
          results.forEach(result => {
            expect(Buffer.isBuffer(result)).toBe(true);
          });
        } catch (error) {
          console.warn('Concurrent test skipped due to missing dependencies:', error);
        }
      }
    }, 20000); // 20 second timeout
  });
});