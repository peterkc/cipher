#!/usr/bin/env bun

/**
 * Fix Mixed Type/Value Imports
 *
 * This script handles imports that need to be split into separate
 * type-only and value imports when using verbatimModuleSyntax.
 *
 * It fixes two error types:
 * - TS1484: Must be imported using type-only import
 * - TS1361: Cannot be used as a value because it was imported using 'import type'
 */

import { execSync } from 'node:child_process';
import * as fs from 'node:fs';
import * as path from 'node:path';

interface ErrorInfo {
	file: string;
	line: number;
	name: string;
	type: 'needs-type' | 'needs-value';
}

let totalFixes = 0;

/**
 * Parse errors from TypeScript compiler
 */
function parseErrors(): ErrorInfo[] {
	let output: string;
	try {
		execSync('bun run typecheck', { encoding: 'utf-8', stdio: 'pipe' });
		return [];
	} catch (error: any) {
		output = error.stdout || error.stderr || '';
	}

	const errors: ErrorInfo[] = [];

	// TS1484: 'Name' is a type and must be imported using a type-only import
	const needsTypePattern =
		/^(.+?)\((\d+),\d+\): error TS1484: '([^']+)' is a type and must be imported using a type-only import/gm;

	let match;
	while ((match = needsTypePattern.exec(output)) !== null) {
		errors.push({
			file: match[1]!,
			line: parseInt(match[2]!, 10),
			name: match[3]!,
			type: 'needs-type',
		});
	}

	// TS1361: 'Name' cannot be used as a value because it was imported using 'import type'
	const needsValuePattern =
		/^(.+?)\((\d+),\d+\): error TS1361: '([^']+)' cannot be used as a value/gm;

	while ((match = needsValuePattern.exec(output)) !== null) {
		errors.push({
			file: match[1]!,
			line: parseInt(match[2]!,  10),
			name: match[3]!,
			type: 'needs-value',
		});
	}

	return errors;
}

/**
 * Fix imports in a file based on error analysis
 */
function fixFile(filePath: string, errors: ErrorInfo[]): number {
	const content = fs.readFileSync(filePath, 'utf-8');
	const lines = content.split('\n');
	let modified = false;

	// Group errors by line and type
	const errorsByLine = new Map<number, ErrorInfo[]>();
	for (const error of errors) {
		if (!errorsByLine.has(error.line)) {
			errorsByLine.set(error.line, []);
		}
		errorsByLine.get(error.line)!.push(error);
	}

	for (const [lineNum, lineErrors] of errorsByLine.entries()) {
		const lineIndex = lineNum - 1;
		if (lineIndex < 0 || lineIndex >= lines.length) continue;

		const line = lines[lineIndex]!;

		// Check if we have errors requiring opposite actions (needs-type AND needs-value)
		const needsType = lineErrors.some((e) => e.type === 'needs-type');
		const needsValue = lineErrors.some((e) => e.type === 'needs-value');

		if (needsValue && line.includes('import type')) {
			// Split the import: some names need type, others need value
			const match = line.match(/^(\s*)import type \{ ([^}]+) \} from (['"][^'"]+['"])/);
			if (match) {
				const [, indent, imports, from] = match;
				const importNames = imports!.split(',').map((n) => n.trim());

				// Names that caused TS1361 errors (used as values)
				const valueNames = lineErrors.filter((e) => e.type === 'needs-value').map((e) => e.name);
				const typeNames = importNames.filter((n) => !valueNames.includes(n));

				// Create two import statements if needed
				const newLines: string[] = [];
				if (valueNames.length > 0) {
					newLines.push(`${indent}import { ${valueNames.join(', ')} } from ${from}`);
				}
				if (typeNames.length > 0) {
					newLines.push(`${indent}import type { ${typeNames.join(', ')} } from ${from}`);
				}

				if (newLines.length > 0) {
					lines[lineIndex] = newLines.join('\n');
					modified = true;
					totalFixes++;
				}
			}
		} else if (needsType && !line.includes('import type')) {
			// Convert to type-only import
			const match = line.match(/^(\s*)import \{ ([^}]+) \} from/);
			if (match) {
				lines[lineIndex] = line.replace(/^(\s*)import \{/, '$1import type {');
				modified = true;
				totalFixes++;
			}
		}
	}

	if (modified) {
		fs.writeFileSync(filePath, lines.join('\n'), 'utf-8');
		return 1;
	}
	return 0;
}

async function main() {
	console.log('🔧 Mixed Import Fixer\n');

	const errors = parseErrors();

	if (errors.length === 0) {
		console.log('✅ No import errors found!\n');
		return;
	}

	console.log(`Found ${errors.length} import errors\n`);

	// Group by file
	const fileErrors = new Map<string, ErrorInfo[]>();
	for (const error of errors) {
		if (!fileErrors.has(error.file)) {
			fileErrors.set(error.file, []);
		}
		fileErrors.get(error.file)!.push(error);
	}

	console.log('Fixing imports...\n');

	for (const [file, errs] of fileErrors.entries()) {
		const fixed = fixFile(file, errs);
		if (fixed > 0) {
			console.log(`✓ ${path.relative(process.cwd(), file)}`);
		}
	}

	console.log(`\n✅ Applied ${totalFixes} fixes\n`);

	console.log('🔍 Re-checking...\n');
	try {
		execSync('bun run typecheck', { stdio: 'inherit' });
		console.log('\n✅ All errors fixed!\n');
	} catch {
		console.log('\n⚠️  Some errors remain - may need manual fixes\n');
	}
}

main().catch(console.error);