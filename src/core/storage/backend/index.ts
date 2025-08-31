/**
 * Storage Backend Exports
 *
 * Central export point for all storage backend implementations.
 *
 * @module storage/backend
 */

// Interface exports
export type { CacheBackend } from './cache-backend.js';
export type { DatabaseBackend } from './database-backend.js';

// Implementation exports
export { InMemoryBackend } from './in-memory.js';
export { PostgresBackend } from './postgresql.js';
export { RedisBackend } from './redis-backend.js';
export { SqliteBackend } from './sqlite.js';
export type {
	BackendConfig,
	InMemoryBackendConfig,
	PostgresBackendConfig,
	RedisBackendConfig,
	SqliteBackendConfig,
	StorageBackends,
} from './types.js';
// Type exports
export { StorageConnectionError, StorageError, StorageNotFoundError } from './types.js';
