/**
 * Event System - Main Export
 *
 * Central export point for the two-tier event system infrastructure.
 */

// Vector store integration
export { EventAwareVectorStore } from '../vector_storage/event-aware-store.js';
export * from './event-manager.js';
export * from './event-types.js';
export { EventFilter } from './event-types.js';
// Advanced features
export * from './filtering.js';
export * from './metrics.js';
export * from './persistence.js';
export * from './replay.js';
export * from './service-event-bus.js';
export * from './session-event-bus.js';
// Core event system components
export * from './typed-event-emitter.js';
export * from './webhooks.js';
