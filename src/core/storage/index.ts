/**
 * Storage Module Public API
 *
 * This module provides a flexible dual-backend storage system with:
 * - Cache backend for fast, ephemeral storage
 * - Database backend for persistent, reliable storage
 *
 * Features:
 * - Lazy loading of external backends (Redis, SQLite, etc.)
 * - Graceful fallback to in-memory storage
 * - Health monitoring and connection management
 * - Type-safe configuration with runtime validation
 *
 * @module storage
 */

// Backend implementations
export { InMemoryBackend } from './backend/in-memory.js';
// Error exports
export { StorageConnectionError, StorageError, StorageNotFoundError } from './backend/types.js';
export type {
	InMemoryBackendConfig,
	PostgresBackendConfig,
	RedisBackendConfig,
	SqliteBackendConfig,
} from './config.js';

// Configuration exports
export { StorageSchema } from './config.js';
// Constants exports (for external use if needed)
export {
	BACKEND_TYPES,
	DEFAULTS,
	ERROR_MESSAGES,
	HEALTH_CHECK,
	LOG_PREFIXES,
	TIMEOUTS,
} from './constants.js';
export type { HealthCheckResult, StorageInfo } from './manager.js';
// Core exports
export { StorageManager } from './manager.js';
// Type exports
export type {
	BackendConfig,
	CacheBackend,
	DatabaseBackend,
	StorageBackends,
	StorageConfig,
} from './types.js';

// Redis and SQLite backends will be loaded lazily

// Factory functions
export {
	createDefaultStorage,
	createStorageBackends,
	createStorageFromEnv,
	isStorageFactory,
	type StorageFactory,
} from './factory.js';
export type {
	HistoryFilters,
	MemoryHistoryEntry,
	MemoryHistoryService,
	MemoryOperation,
	OperationStats,
	QueryOptions,
} from './memory-history/index.js';
// Memory History Service exports
export {
	createMemoryHistoryEntry,
	createMemoryHistoryService,
	MemoryHistoryStorageService,
} from './memory-history/index.js';
