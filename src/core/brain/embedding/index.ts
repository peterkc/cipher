/**
 * Embedding Module
 *
 * High-performance text embedding system supporting multiple providers.
 * Provides a unified API for generating embeddings with comprehensive
 * error handling, retry logic, and lifecycle management.
 *
 * Features:
 * - Multiple provider support (OpenAI, future: Anthropic, Cohere, etc.)
 * - Batch operations for efficient processing
 * - Type-safe configuration with runtime validation
 * - Comprehensive error handling and retry logic
 * - Health monitoring and statistics collection
 * - Graceful fallback and connection management
 *
 * @module embedding
 *
 * @example
 * ```typescript
 * import { createEmbedder, EmbeddingManager } from './embedding';
 *
 * // Create a single embedder
 * const embedder = await createEmbedder({
 *   type: 'openai',
 *   apiKey: process.env.OPENAI_API_KEY,
 *   model: 'text-embedding-3-small'
 * });
 *
 * // Generate embeddings
 * const embedding = await embedder.embed('Hello world');
 * const embeddings = await embedder.embedBatch(['Hello', 'World']);
 *
 * // Use embedding manager for multiple embedders
 * const manager = new EmbeddingManager();
 * const { embedder: managedEmbedder } = await manager.createEmbedder({
 *   type: 'openai',
 *   apiKey: process.env.OPENAI_API_KEY
 * });
 *
 * // Health monitoring
 * manager.startHealthChecks();
 * const healthResults = await manager.checkAllHealth();
 *
 * // Cleanup
 * await manager.disconnect();
 * ```
 */

// Export configuration utilities
export {
	EmbeddingConfigSchema,
	parseEmbeddingConfig,
	parseEmbeddingConfigFromEnv,
	validateEmbeddingConfig,
} from './config.js';
// Export constants for external use
export {
	DEFAULTS,
	MODEL_DIMENSIONS,
	OPENAI_MODELS,
	PROVIDER_TYPES,
	VALIDATION_LIMITS,
} from './constants.js';

// Export factory functions
export {
	createEmbedder,
	createEmbedderFromEnv,
	EMBEDDING_FACTORIES,
	type EmbeddingFactory,
	getSupportedProviders,
	isProviderSupported,
	validateEmbeddingConfiguration,
} from './factory.js';

// Export manager
export { EmbeddingManager, SessionEmbeddingState } from './manager.js';
// Export types
export type {
	BackendConfig,
	BatchEmbeddingResult,
	Embedder,
	EmbedderInfo,
	EmbeddingConfig,
	EmbeddingEnvConfig,
	EmbeddingResult,
	EmbeddingStats,
	HealthCheckResult,
	OpenAIEmbeddingConfig,
} from './types.js';
// Export error classes
export {
	EmbeddingConnectionError,
	EmbeddingDimensionError,
	EmbeddingError,
	EmbeddingQuotaError,
	EmbeddingRateLimitError,
	EmbeddingValidationError,
} from './types.js';

// Export utilities
export {
	analyzeProviderConfiguration,
	getEmbeddingConfigFromEnv,
	getEmbeddingConfigSummary,
	isEmbeddingConfigAvailable,
	validateEmbeddingEnv,
} from './utils.js';
