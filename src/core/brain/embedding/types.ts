/**
 * Embedding Module Public API Types
 *
 * This module re-exports all the necessary types and interfaces for the embedding system.
 * It provides a simplified, clean API surface for consumers of the embedding module.
 *
 * The embedding system architecture:
 * - Multiple provider support (OpenAI, future: Anthropic, Cohere, etc.)
 * - Consistent API across different providers
 * - Strong type safety with TypeScript and runtime validation with Zod
 * - Factory pattern for creating embedders
 * - Manager pattern for lifecycle management
 *
 * @module embedding/types
 *
 * @example
 * ```typescript
 * import type { Embedder, EmbeddingConfig } from './embedding/types.js';
 *
 * // Configure embedder
 * const config: EmbeddingConfig = {
 *   type: 'openai',
 *   apiKey: process.env.OPENAI_API_KEY,
 *   model: 'text-embedding-3-small'
 * };
 *
 * // Use embedder
 * const embedder = await createEmbedder(config);
 * const embedding = await embedder.embed('Hello world');
 * ```
 */

/**
 * Re-export core embedding types
 *
 * These exports provide the complete type system needed to work with
 * the embedding module without exposing internal implementation details.
 */
export type {
	BackendConfig, // Union type for all provider configurations
	BatchEmbeddingResult, // Batch embedding result with metadata
	// Core interfaces
	Embedder, // Interface for embedding providers
	EmbeddingConfig, // Base configuration interface
	// Result types
	EmbeddingResult, // Single embedding result with metadata
	OpenAIEmbeddingConfig, // OpenAI-specific configuration
} from './backend/types.js';

/**
 * Re-export error classes
 *
 * Comprehensive error hierarchy for embedding operations.
 */
export {
	EmbeddingConnectionError, // Connection-related errors
	EmbeddingDimensionError, // Dimension mismatch errors
	EmbeddingError, // Base error class
	EmbeddingQuotaError, // Quota exceeded errors
	EmbeddingRateLimitError, // Rate limiting errors
	EmbeddingValidationError, // Input validation errors
} from './backend/types.js';
/**
 * Re-export configuration types and utilities
 *
 * Configuration validation and parsing utilities.
 */
export type {
	EmbeddingEnvConfig, // Environment-based configuration
} from './config.js';
/**
 * Re-export factory types
 *
 * Types related to embedding factory functionality.
 */
export type {
	EmbeddingFactory, // Factory interface for creating embedders
} from './factory.js';
/**
 * Re-export manager types
 *
 * Types related to embedding lifecycle management.
 */
export type {
	EmbedderInfo, // Information about embedder instances
	EmbeddingStats, // Statistics about embedding operations
	HealthCheckResult, // Health check result structure
} from './manager.js';
