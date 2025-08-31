/**
 * Internal Tools Module
 *
 * This module provides internal tools for the Cipher agent, including
 * memory management, session control, and system operations.
 *
 * @example
 * ```typescript
 * import { InternalToolManager, InternalToolRegistry } from '@core/brain/tools';
 *
 * const manager = new InternalToolManager();
 * await manager.initialize();
 *
 * // Register a tool
 * const result = manager.registerTool(myTool);
 *
 * // Execute a tool
 * const output = await manager.executeTool('cipher_my_tool', args);
 * ```
 */

export { InternalToolManager } from './manager.js';
// Core classes
export { InternalToolRegistry } from './registry.js';
// Core types
export type {
	IInternalToolManager,
	InternalTool,
	InternalToolCategory,
	InternalToolContext,
	InternalToolHandler,
	InternalToolManagerConfig,
	InternalToolSet,
	ToolExecutionStats,
	ToolRegistrationResult,
} from './types.js';
// Constants and utilities
export { createInternalToolName, INTERNAL_TOOL_PREFIX, isInternalToolName } from './types.js';
export type { CombinedToolSet, UnifiedToolManagerConfig } from './unified-tool-manager.js';
export { UnifiedToolManager } from './unified-tool-manager.js';

import { InternalToolManager } from './manager.js';
import { InternalToolRegistry } from './registry.js';
// Import types for use in functions
import type { InternalToolCategory, InternalToolManagerConfig } from './types.js';

// Version and metadata
export const INTERNAL_TOOLS_VERSION = '1.0.0';
export const SUPPORTED_CATEGORIES: InternalToolCategory[] = ['memory', 'session', 'system'];

/**
 * Create a new internal tool manager with optional configuration
 */
export function createInternalToolManager(config?: InternalToolManagerConfig): InternalToolManager {
	return new InternalToolManager(config);
}

/**
 * Get the singleton registry instance
 */
export function getInternalToolRegistry(): InternalToolRegistry {
	return InternalToolRegistry.getInstance();
}
