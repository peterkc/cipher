/**
 * Vector Storage Module
 *
 * High-performance vector storage and similarity search for embeddings.
 * Supports multiple backends with a unified API.
 *
 * Features:
 * - Multiple backend support (Qdrant, In-Memory, etc.)
 * - Similarity search with metadata filtering
 * - Batch operations for efficient indexing
 * - Type-safe configuration with runtime validation
 * - Graceful fallback to in-memory storage
 *
 * @module vector_storage
 *
 * @example
 * ```typescript
 * import { createVectorStore } from './vector_storage';
 *
 * // Create a vector store
 * const { store, manager } = await createVectorStore({
 *   type: 'qdrant',
 *   host: 'localhost',
 *   port: 6333,
 *   collectionName: 'documents',
 *   dimension: 1536
 * });
 *
 * // Index vectors
 * await store.insert(
 *   [embedding1, embedding2],
 *   ['doc1', 'doc2'],
 *   [{ title: 'Doc 1' }, { title: 'Doc 2' }]
 * );
 *
 * // Search for similar vectors
 * const results = await store.search(queryEmbedding, 5);
 *
 * // Cleanup
 * await manager.disconnect();
 * ```
 */

// Export error classes
export {
	CollectionNotFoundError,
	VectorDimensionError,
	VectorStoreConnectionError,
	VectorStoreError,
} from './backend/types.js';
// Export constants for external use
export { BACKEND_TYPES, DEFAULTS, DISTANCE_METRICS } from './constants.js';
export { type CollectionType, DualCollectionVectorManager } from './dual-collection-manager.js';
// Export factory functions
export {
	createDefaultVectorStore,
	createDualCollectionVectorStoreFromEnv,
	createMultiCollectionVectorStoreFromEnv,
	createVectorStore,
	createVectorStoreFromEnv,
	createWorkspaceVectorStoreFromEnv,
	type DualCollectionVectorFactory,
	getVectorStoreConfigFromEnv,
	getWorkspaceVectorStoreConfigFromEnv,
	isVectorStoreFactory,
	type MultiCollectionVectorFactory,
	type VectorStoreFactory,
} from './factory.js';
// Export managers
export { type HealthCheckResult, type VectorStoreInfo, VectorStoreManager } from './manager.js';
// Export types
export type {
	BackendConfig,
	SearchFilters,
	VectorStore,
	VectorStoreConfig,
	VectorStoreResult,
} from './types.js';
