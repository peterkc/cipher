/**
 * Embedding Backend Module
 *
 * Exports all embedding backend types and implementations.
 * Provides a unified interface for different embedding providers.
 *
 * @module embedding/backend
 */

export { AWSBedrockEmbedder } from './aws.js';
export { GeminiEmbedder } from './gemini.js';
export { LMStudioEmbedder } from './lmstudio.js';
export { OllamaEmbedder } from './ollama.js';
// Export backend implementations
export { OpenAIEmbedder } from './openai.js';
export { QwenEmbedder } from './qwen.js';
// Export core types
export type {
	AWSBedrockEmbeddingConfig,
	BackendConfig,
	BatchEmbeddingResult,
	Embedder,
	EmbeddingConfig,
	EmbeddingResult,
	GeminiEmbeddingConfig,
	LMStudioEmbeddingConfig,
	OllamaEmbeddingConfig,
	OpenAIEmbeddingConfig,
	QwenEmbeddingConfig,
	VoyageEmbeddingConfig,
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
export { VoyageEmbedder } from './voyage.js';
