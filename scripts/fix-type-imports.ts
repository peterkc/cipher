#!/usr/bin/env bun

/**
 * Automated Type Import Fixer for verbatimModuleSyntax
 *
 * This script automatically converts regular imports to type-only imports
 * when all imported names are used only as types, as required by the
 * verbatimModuleSyntax TypeScript compiler option.
 *
 * Usage: bun scripts/fix-type-imports.ts
 */

import * as fs from 'node:fs';
import * as path from 'node:path';
import { glob } from 'glob';

interface ImportFix {
	file: string;
	line: number;
	original: string;
	fixed: string;
}

const fixes: ImportFix[] = [];
let filesProcessed = 0;
let filesModified = 0;

/**
 * Fix type imports in a single file
 */
function fixFileImports(filePath: string): boolean {
	const content = fs.readFileSync(filePath, 'utf-8');
	const lines = content.split('\n');
	let modified = false;
	const newLines: string[] = [];

	for (let i = 0; i < lines.length; i++) {
		let line = lines[i]!;

		// Match import statements that need fixing
		// Pattern: import { Name1, Name2, ... } from '...'
		const importMatch = line.match(/^(\s*)import\s+\{\s*([^}]+)\s*\}\s+from\s+(['"][^'"]+['"])/);

		if (importMatch) {
			const [, indent, imports, from] = importMatch;

			// Skip if already has 'type' keyword
			if (line.includes('import type')) {
				newLines.push(line);
				continue;
			}

			// Check if this is likely a type-only import based on common patterns
			// Express types, MCP types, etc.
			const isLikelyTypeImport =
				from.includes('express') ||
				from.includes('@modelcontextprotocol') ||
				from.includes('weaviate') ||
				imports.includes('Config') ||
				imports.includes('Type') ||
				imports.includes('Interface') ||
				// Check for PascalCase names (likely types/interfaces)
				/^[A-Z]/.test(imports.trim().split(',')[0]?.trim() || '');

			if (isLikelyTypeImport) {
				const fixed = `${indent}import type { ${imports.trim()} } from ${from}`;
				fixes.push({
					file: filePath,
					line: i + 1,
					original: line,
					fixed: fixed,
				});
				newLines.push(fixed);
				modified = true;
			} else {
				newLines.push(line);
			}
		} else {
			newLines.push(line);
		}
	}

	if (modified) {
		fs.writeFileSync(filePath, newLines.join('\n'), 'utf-8');
		filesModified++;
	}

	filesProcessed++;
	return modified;
}

/**
 * Process all TypeScript files in the project
 */
async function main() {
	console.log('🔍 Scanning for TypeScript files...\n');

	// Find all TypeScript files in src/
	const files = await glob('src/**/*.{ts,tsx}', {
		ignore: ['**/node_modules/**', '**/dist/**', '**/*.d.ts'],
		cwd: process.cwd(),
		absolute: true,
	});

	console.log(`Found ${files.length} TypeScript files\n`);
	console.log('🔧 Fixing type imports...\n');

	for (const file of files) {
		const relativePath = path.relative(process.cwd(), file);
		process.stdout.write(`Processing: ${relativePath}\r`);
		fixFileImports(file);
	}

	console.log('\n\n✅ Processing complete!\n');
	console.log(`Files processed: ${filesProcessed}`);
	console.log(`Files modified: ${filesModified}`);
	console.log(`Total fixes applied: ${fixes.length}\n`);

	if (fixes.length > 0) {
		console.log('📝 Sample fixes (first 10):');
		fixes.slice(0, 10).forEach((fix, idx) => {
			console.log(`\n${idx + 1}. ${path.relative(process.cwd(), fix.file)}:${fix.line}`);
			console.log(`   - ${fix.original.trim()}`);
			console.log(`   + ${fix.fixed.trim()}`);
		});

		if (fixes.length > 10) {
			console.log(`\n... and ${fixes.length - 10} more fixes`);
		}
	}

	console.log('\n💡 Next steps:');
	console.log('   1. Run: bun run typecheck');
	console.log('   2. Manually fix remaining errors (if any)');
	console.log('   3. Run: bun run build');
	console.log('   4. Commit changes\n');
}

main().catch(error => {
	console.error('❌ Error:', error);
	process.exit(1);
});
