/**
 * Vector Storage Backend Exports
 *
 * Central export point for all backend types, interfaces, and implementations.
 * This module provides a clean API for accessing backend functionality.
 *
 * @module vector_storage/backend
 */

// Export core types and interfaces
export type { SearchFilters, VectorStore, VectorStoreResult } from './types.js';

// Export error classes
export {
	CollectionNotFoundError,
	VectorDimensionError,
	VectorStoreConnectionError,
	VectorStoreError,
} from './types.js';

// Export backend implementations
// Note: Implementations are lazily loaded by the manager to reduce startup time
// export { QdrantBackend } from './qdrant.js';
// export { InMemoryBackend } from './in-memory.js';
