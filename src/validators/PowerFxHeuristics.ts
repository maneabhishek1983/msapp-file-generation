import * as fs from 'fs-extra';
import * as path from 'path';
import { glob } from 'glob';
import { ErrorCategory, ValidationError, ValidationWarning } from '../types';

const BEHAVIOR_FUNCTION_PATTERN = /(Collect|ClearCollect|Set|Navigate|Patch|Remove|UpdateContext|Clear)\s*\(/i;

/**
 * Lightweight heuristics that flag common Canvas app issues that frequently
 * block .msapp imports. The goal isn't to perfectly understand an app but to
 * provide actionable guardrails that mirror the manual triage guidance used by
 * makers.
 */
export class PowerFxHeuristics {
  async analyze(
    sourceDir: string,
    errors: ValidationError[],
    warnings: ValidationWarning[]
  ): Promise<void> {
    const fxFiles = await glob('**/*.fx', { cwd: sourceDir, nodir: true });

    if (fxFiles.length === 0) {
      // No formulas to analyse – nothing else to report.
      return;
    }

    const fileContents = await Promise.all(
      fxFiles.map(async relativePath => {
        const absolutePath = path.join(sourceDir, relativePath);
        const content = await fs.readFile(absolutePath, 'utf-8');

        return { relativePath, absolutePath, content };
      })
    );

    this.validateOnStart(fileContents, errors, warnings);
    this.validateStartScreen(fileContents, errors, warnings);
    this.validateMapFallback(fileContents, warnings);
    this.validateReviewPassFail(fileContents, warnings);
    this.validateOutcomeOverride(fileContents, warnings);
    this.validatePublishGuardrails(fileContents, warnings);
    this.validateExports(fileContents, warnings);
    this.validateAuditTrail(fileContents, warnings);
  }

  private validateOnStart(
    fileContents: Array<{ relativePath: string; absolutePath: string; content: string }>,
    errors: ValidationError[],
    warnings: ValidationWarning[]
  ): void {
    const onStartFiles = fileContents.filter(file =>
      path.basename(file.relativePath).toLowerCase() === 'app.onstart.fx'
    );

    if (onStartFiles.length === 0) {
      errors.push({
        message:
          'App.OnStart.fx not found. Move your startup formula into App.OnStart and enable Enhanced App OnStart so collections seed correctly.',
        category: ErrorCategory.VALIDATION
      });

      return;
    }

    const hasSeedData = onStartFiles.some(file => /ClearCollect\s*\(|Collect\s*\(/i.test(file.content));

    if (!hasSeedData) {
      warnings.push({
        message:
          'App.OnStart does not seed data. Add ClearCollect/Collect guards so demo data and KPIs appear when the app loads.',
        file: onStartFiles[0].absolutePath
      });
    }
  }

  private validateStartScreen(
    fileContents: Array<{ relativePath: string; absolutePath: string; content: string }>,
    errors: ValidationError[],
    warnings: ValidationWarning[]
  ): void {
    const appFile = fileContents.find(file => path.basename(file.relativePath).toLowerCase() === 'app.fx');

    if (!appFile) {
      return;
    }

    const startScreenMatch = /StartScreen\s*:\s*([^\r\n,]+)/.exec(appFile.content);

    if (!startScreenMatch) {
      return;
    }

    const formula = startScreenMatch[1].trim();

    if (BEHAVIOR_FUNCTION_PATTERN.test(formula) || formula.includes(';')) {
      errors.push({
        message:
          'StartScreen contains behavior formulas. Keep StartScreen to a single screen name and move Set/Collect/Navigate calls into App.OnStart or button handlers.',
        category: ErrorCategory.VALIDATION,
        file: appFile.absolutePath
      });

      return;
    }

    if (!/^[A-Za-z_][\w]*$/.test(formula)) {
      warnings.push({
        message:
          'StartScreen should resolve to a screen symbol. If dynamic logic is required, compute it in App.OnStart and reference a variable here.',
        file: appFile.absolutePath
      });
    }
  }

  private validateMapFallback(
    fileContents: Array<{ relativePath: string; absolutePath: string; content: string }>,
    warnings: ValidationWarning[]
  ): void {
    const filesWithWebMap = fileContents.filter(file => file.content.includes('txtWebMapId'));

    if (filesWithWebMap.length === 0) {
      return;
    }

    const hasFallback = filesWithWebMap.some(file =>
      /If\s*\(\s*IsBlank\s*\(\s*txtWebMapId\.Text/i.test(file.content) ||
      file.content.includes('varMapImageUrl')
    );

    if (!hasFallback) {
      warnings.push({
        message:
          'Map screen references txtWebMapId without a fallback image. Provide a placeholder via varMapImageUrl so exports do not break.',
        file: filesWithWebMap[0].absolutePath
      });
    }
  }

  private validateReviewPassFail(
    fileContents: Array<{ relativePath: string; absolutePath: string; content: string }>,
    warnings: ValidationWarning[]
  ): void {
    const reviewFiles = fileContents.filter(file =>
      file.content.includes('colObservations') || file.content.includes('colAttributes')
    );

    if (reviewFiles.length === 0) {
      return;
    }

    const hasPassFailLogic = reviewFiles.some(file =>
      /"Pass"/.test(file.content) && /"Fail"/.test(file.content) && /TargetMin|AllowedValues/i.test(file.content)
    );

    if (!hasPassFailLogic) {
      warnings.push({
        message:
          'Review screens should derive Pass/Fail from attribute thresholds. Use LookUp(colAttributes, ...) with TargetMin/TargetMax or AllowedValues.',
        file: reviewFiles[0].absolutePath
      });
    }
  }

  private validateOutcomeOverride(
    fileContents: Array<{ relativePath: string; absolutePath: string; content: string }>,
    warnings: ValidationWarning[]
  ): void {
    const outcomeFiles = fileContents.filter(file =>
      file.content.includes('varSuggested') || file.content.includes('tglOverride')
    );

    if (outcomeFiles.length === 0) {
      return;
    }

    const hasGuardrails = outcomeFiles.some(file =>
      /Notify\s*\(\s*"Justification is required/i.test(file.content) ||
      /tglOverride\.Value/.test(file.content)
    );

    if (!hasGuardrails) {
      warnings.push({
        message:
          'Outcome override lacks justification guardrails. Require tglOverride + justification before Patch/Collect executes.',
        file: outcomeFiles[0].absolutePath
      });
    }
  }

  private validatePublishGuardrails(
    fileContents: Array<{ relativePath: string; absolutePath: string; content: string }>,
    warnings: ValidationWarning[]
  ): void {
    const publishFiles = fileContents.filter(file =>
      /Publish/i.test(file.content) && /OnSelect/i.test(file.content)
    );

    if (publishFiles.length === 0) {
      return;
    }

    const hasValidation = publishFiles.some(file =>
      /Notify\s*\(\s*"Missing required/i.test(file.content) ||
      /IsBlank\s*\(\s*ddSite\.Selected/i.test(file.content)
    );

    if (!hasValidation) {
      warnings.push({
        message:
          'Publish button lacks pre-flight validation. Block the action when Site, Feature, WebMap Id or reviewers are missing and show Notify().',
        file: publishFiles[0].absolutePath
      });
    }
  }

  private validateExports(
    fileContents: Array<{ relativePath: string; absolutePath: string; content: string }>,
    warnings: ValidationWarning[]
  ): void {
    const exportFiles = fileContents.filter(file =>
      /Export/i.test(file.content) && /OnSelect/i.test(file.content)
    );

    if (exportFiles.length === 0) {
      return;
    }

    const hasFeedback = exportFiles.some(file =>
      /Notify\s*\(\s*"Export generated/i.test(file.content) ||
      /Notify\s*\(\s*"Excel exported/i.test(file.content)
    );

    if (!hasFeedback) {
      warnings.push({
        message:
          'Export buttons do not provide feedback. Surface a Notify() with a fake download URL to keep demo flows moving.',
        file: exportFiles[0].absolutePath
      });
    }
  }

  private validateAuditTrail(
    fileContents: Array<{ relativePath: string; absolutePath: string; content: string }>,
    warnings: ValidationWarning[]
  ): void {
    const hasAuditCollection = fileContents.some(file => /colAudit/i.test(file.content));

    if (hasAuditCollection) {
      return;
    }

    warnings.push({
      message:
        'No audit telemetry detected. Create a colAudit collection and log Publish/Outcome actions so Diagnostics can show recent activity.',
      file: fileContents[0].absolutePath
    });
  }
}
