/**
 * Web Search Tools Module
 *
 * Provides web search capabilities for the Cipher AI system using various search engines.
 * Currently supports DuckDuckGo with Puppeteer-based scraping.
 *
 * @module WebSearch
 */

// Configuration and factory
export { WebSearchConfig, WebSearchConfigSchema } from './config.js';
// Constants
export {
	CONTENT_TYPES,
	ERROR_MESSAGES,
	EXTRACTION_LIMITS,
	LOG_PREFIXES,
	SEARCH_ENGINES,
	TIMEOUTS,
} from './constants.js';
export { BaseProvider } from './engine/base.js';
export { DuckDuckGoPuppeteerProvider } from './engine/duckduckgo.js';
export {
	createWebSearchProvider,
	createWebSearchProviderFromEnv,
	getWebSearchConfigFromEnv,
} from './factory.js';
// Core components
export { WebSearchManager } from './manager.js';

// Types
export type {
	ExtractedContent,
	InternalSearchResult,
	ProviderConfig,
	SearchOptions,
	SearchResponse,
	SearchResult,
} from './types.js';

// Tool integration
export { cleanupWebSearch, getWebSearchTools, webSearchTool } from './web-search-tool.js';

/**
 * Check if web search is available based on environment configuration
 */
export function isWebSearchAvailable(): boolean {
	try {
		// Check if required environment variables or configs are available
		const searchEngine = process.env.WEB_SEARCH_ENGINE || 'duckduckgo';
		return searchEngine === 'duckduckgo'; // Currently only DuckDuckGo is supported
	} catch {
		return false;
	}
}

/**
 * Get web search configuration summary for debugging
 */
export function getWebSearchInfo() {
	return {
		availableEngines: ['duckduckgo'],
		defaultEngine: process.env.WEB_SEARCH_ENGINE || 'duckduckgo',
		isAvailable: isWebSearchAvailable(),
		version: '1.0.0',
	};
}

import type { InternalToolSet } from '../../types.js';
import { getWebSearchTools } from './web-search-tool.js';

/**
 * Get all system tools
 */
export function getSystemTools(): InternalToolSet {
	const webSearchTools = getWebSearchTools();

	return {
		...webSearchTools,
	};
}
