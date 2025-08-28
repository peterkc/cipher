#!/usr/bin/env bun

/**
 * Precise Type Import Fixer using TypeScript Compiler Diagnostics
 *
 * This script uses the TypeScript compiler's diagnostic messages (error TS1484)
 * to precisely identify and fix imports that must be type-only imports when
 * using verbatimModuleSyntax.
 *
 * Usage: bun scripts/fix-type-imports-precise.ts
 */

import { execSync } from 'node:child_process';
import * as fs from 'node:fs';
import * as path from 'node:path';

interface TypeImportError {
	file: string;
	line: number;
	column: number;
	importName: string;
}

interface FileFixes {
	[filePath: string]: Set<number>; // file -> set of line numbers
}

let totalFixes = 0;
let filesModified = 0;

/**
 * Parse TypeScript compiler output to extract type import errors
 */
function parseTypescriptErrors(): TypeImportError[] {
	console.log('🔍 Running TypeScript compiler to identify errors...\n');

	let output: string;
	try {
		execSync('bun run typecheck', { encoding: 'utf-8', stdio: 'pipe' });
		return []; // No errors
	} catch (error: any) {
		output = error.stdout || error.stderr || '';
	}

	const errors: TypeImportError[] = [];
	const errorPattern =
		/^(.+?)\((\d+),(\d+)\): error TS1484: '([^']+)' is a type and must be imported using a type-only import/gm;

	let match;
	while ((match = errorPattern.exec(output)) !== null) {
		const [, file, line, column, importName] = match;
		errors.push({
			file: file!,
			line: parseInt(line!, 10),
			column: parseInt(column!, 10),
			importName: importName!,
		});
	}

	return errors;
}

/**
 * Group errors by file and line number
 */
function groupErrorsByFile(errors: TypeImportError[]): FileFixes {
	const fileFixes: FileFixes = {};

	for (const error of errors) {
		if (!fileFixes[error.file]) {
			fileFixes[error.file] = new Set();
		}
		fileFixes[error.file]!.add(error.line);
	}

	return fileFixes;
}

/**
 * Fix imports in a specific file
 */
function fixFileImports(filePath: string, lineNumbers: Set<number>): number {
	const content = fs.readFileSync(filePath, 'utf-8');
	const lines = content.split('\n');
	let fixCount = 0;

	for (const lineNum of lineNumbers) {
		const lineIndex = lineNum - 1; // Convert to 0-based index
		if (lineIndex < 0 || lineIndex >= lines.length) continue;

		let line = lines[lineIndex]!;

		// Pattern 1: import { ... } from '...'
		if (line.match(/^\s*import\s+\{/) && !line.includes('import type')) {
			line = line.replace(/^(\s*)import\s+/, '$1import type ');
			lines[lineIndex] = line;
			fixCount++;
			continue;
		}

		// Pattern 2: import Name from '...' (default import)
		if (line.match(/^\s*import\s+[A-Za-z]/) && !line.includes('import type') && !line.includes('{')) {
			line = line.replace(/^(\s*)import\s+/, '$1import type ');
			lines[lineIndex] = line;
			fixCount++;
			continue;
		}
	}

	if (fixCount > 0) {
		fs.writeFileSync(filePath, lines.join('\n'), 'utf-8');
		filesModified++;
	}

	return fixCount;
}

/**
 * Main execution
 */
async function main() {
	console.log('🚀 Precise Type Import Fixer\n');
	console.log('This tool uses TypeScript diagnostics to fix type imports.\n');

	// Step 1: Parse errors
	const errors = parseTypescriptErrors();

	if (errors.length === 0) {
		console.log('✅ No type import errors found! Your code is already compliant.\n');
		return;
	}

	console.log(`Found ${errors.length} type import errors across ${new Set(errors.map((e) => e.file)).size} files\n`);

	// Step 2: Group by file
	const fileFixes = groupErrorsByFile(errors);

	// Step 3: Fix each file
	console.log('🔧 Applying fixes...\n');

	for (const [filePath, lineNumbers] of Object.entries(fileFixes)) {
		const relativePath = path.relative(process.cwd(), filePath);
		const fixCount = fixFileImports(filePath, lineNumbers);
		totalFixes += fixCount;
		console.log(`✓ ${relativePath}: ${fixCount} fixes`);
	}

	console.log(`\n✅ Processing complete!\n`);
	console.log(`Files modified: ${filesModified}`);
	console.log(`Total fixes applied: ${totalFixes}\n`);

	// Step 4: Re-run typecheck to verify
	console.log('🔍 Re-running typecheck to verify fixes...\n');

	try {
		execSync('bun run typecheck', { encoding: 'utf-8', stdio: 'inherit' });
		console.log('\n✅ All type import errors fixed! Typecheck passes.\n');
	} catch (error) {
		console.log('\n⚠️  Some errors remain. You may need to fix them manually.\n');
		console.log('Run "bun run typecheck" to see remaining errors.\n');
	}

	console.log('💡 Next steps:');
	console.log('   1. Review the changes: git diff');
	console.log('   2. Run build: bun run build');
	console.log('   3. Commit changes: git commit -am "fix: convert to type-only imports for verbatimModuleSyntax"\n');
}

main().catch((error) => {
	console.error('❌ Error:', error);
	process.exit(1);
});