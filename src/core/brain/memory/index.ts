/**
 * Memory System with Lazy Loading Optimizations
 *
 * Memory-related functionality for the Cipher agent with performance optimizations.
 * Phase 3: Memory operations lazy loading - properly integrated into the application.
 */

// Export enhanced service initializer
export {
	createEnhancedAgentServices,
	type EnhancedServiceOptions,
	getEmbeddingManager,
	getLLMService,
	getVectorStoreManager,
	shouldEnableLazyLoading,
} from './enhanced-service-initializer.js';
// Export lazy memory tool
export { lazyExtractAndOperateMemoryTool } from './lazy-extract-and-operate.js';
// Export lazy loading service wrappers
export {
	getDefaultLazyConfig,
	type LazyAgentServices,
	LazyEmbeddingManager,
	LazyLLMService,
	type LazyServiceConfig,
	LazyVectorStoreManager,
} from './lazy-service-wrapper.js';
