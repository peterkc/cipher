/**
 * System Prompt Architecture - Main Exports
 *
 * This module provides a complete plugin-based system prompt management solution
 * with backward compatibility for existing code.
 */

// Built-in generators
export * from './built-in-generators.js';
export { SystemPromptConfigManager } from './config-manager.js';
export * from './config-schemas.js';
// Enhanced manager
export { EnhancedPromptManager } from './enhanced-manager.js';
// Core interfaces and types
export * from './interfaces.js';
// Provider implementations
export * from './providers/index.js';
// Registry and configuration
export { DefaultProviderRegistry, providerRegistry } from './registry.js';
