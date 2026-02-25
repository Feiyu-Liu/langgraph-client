# 1.0.0

* BREAKING: streaming APIs now return typed events instead of raw `SseEvent`:
  * `streamStatefulRun`, `joinStatefulRunStream`, `streamExistingStatefulRun`
  * `streamRun` (stateless)
* Added high-level conversation streaming APIs:
  * `runStatefulConversationStream`
  * `joinStatefulConversationStream`
  * `streamExistingStatefulConversation`
  * `runStatelessConversationStream`
* Added a new streaming abstraction module:
  * `LangGraphStreamEvent` hierarchy
  * `ConversationStreamEvent` hierarchy
  * unified parser, origin classification, and projection helpers
* Updated examples and tests to the new streaming interface.

# 0.2.2

* Added support for additional LangGraph API endpoints:
  * Assistant versioning and graph information endpoints
  * Thread extended operations (get, delete, checkpoints, bulk updates)
  * Store API for persistent key-value storage
  * Additional run streaming and cancellation options



# 0.1.1

* Improved documentation across the entire codebase:
  * Added comprehensive dartdoc comments to public API elements
  * Enhanced library documentation with examples and usage guidance
  * Documented all model classes and their properties
  * Added detailed method documentation with parameter descriptions
* Updated package description in pubspec.yaml
* Added GitHub workflow for automated publishing to pub.dev


# 0.1.0

* Initial development release.
