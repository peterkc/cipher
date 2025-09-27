/**
 * Mock implementation of bun:sqlite for Vitest testing
 *
 * This mock allows tests to import the SQLite backend without
 * requiring Bun runtime. Tests that need actual SQLite functionality
 * should be run with Bun's test runner or marked as integration tests.
 */

export class Database {
	constructor(_path: string, _options?: any) {
		throw new Error(
			'bun:sqlite mock: This is a stub implementation for type checking only. ' +
				'SQLite tests must be run with Bun runtime or should use describe.skip().'
		);
	}

	prepare(_query: string): Statement {
		throw new Error('bun:sqlite mock: Not implemented');
	}

	query(_query: string): any {
		throw new Error('bun:sqlite mock: Not implemented');
	}

	run(_query: string, ..._params: any[]): void {
		throw new Error('bun:sqlite mock: Not implemented');
	}

	exec(_query: string): void {
		throw new Error('bun:sqlite mock: Not implemented');
	}

	close(): void {
		throw new Error('bun:sqlite mock: Not implemented');
	}

	transaction(_fn: () => void): () => void {
		throw new Error('bun:sqlite mock: Not implemented');
	}
}

export class Statement {
	get(..._params: any[]): any {
		throw new Error('bun:sqlite mock: Not implemented');
	}

	all(..._params: any[]): any[] {
		throw new Error('bun:sqlite mock: Not implemented');
	}

	run(..._params: any[]): void {
		throw new Error('bun:sqlite mock: Not implemented');
	}
}
