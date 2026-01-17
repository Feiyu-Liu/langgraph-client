# LangGraph Client API 用法指南

本文档详细介绍 `langgraph_client` package 中所有 API 的用法。

---

## 目录

- [初始化客户端](#初始化客户端)
- [Assistants API](#assistants-api)
- [Threads API](#threads-api)
- [Thread Runs API](#thread-runs-api)
- [Stateless Runs API](#stateless-runs-api)
- [Crons API](#crons-api)
- [Store API](#store-api)
- [错误处理](#错误处理)

---

## 初始化客户端

```dart
import 'package:langgraph_client/langgraph_client.dart';

// 基本初始化
final client = LangGraphClient(
  baseUrl: 'https://your-langgraph-server.com',
);

// 带认证的初始化
final client = LangGraphClient(
  baseUrl: 'https://your-langgraph-server.com',
  apiKey: 'your-api-key',
);

// 使用自定义 HTTP 客户端（用于测试）
final client = LangGraphClient(
  baseUrl: 'https://your-langgraph-server.com',
  apiKey: 'your-api-key',
  client: myCustomHttpClient,
);
```

---

## Assistants API

Assistant 是图的可配置实例，用于处理线程中的消息。

### 创建 Assistant

```dart
final assistant = await client.createAssistant(
  graphId: 'my-graph-id',
  assistantId: 'my-assistant',  // 可选
  name: 'My Assistant',          // 可选
  metadata: {'env': 'production'}, // 可选
  config: AssistantConfig(
    configurable: {'temperature': 0.7},
  ),
  ifExists: 'raise', // 'raise' | 'update' | 'ignore'
);
```

### 搜索 Assistants

```dart
final assistants = await client.searchAssistants(
  graphId: 'my-graph-id',  // 可选过滤条件
  metadata: {'env': 'production'}, // 可选过滤条件
  limit: 10,
  offset: 0,
);
```

### 获取 Assistant

```dart
final assistant = await client.getAssistant('assistant-id');
```

### 更新 Assistant

```dart
final updated = await client.updateAssistant(
  'assistant-id',
  name: 'Updated Name',
  metadata: {'version': '2.0'},
);
```

### 删除 Assistant

```dart
await client.deleteAssistant('assistant-id');
```

### 获取 Assistant 图定义

```dart
final graph = await client.getAssistantGraph('assistant-id');
```

### 获取 Assistant Schemas

```dart
final schemas = await client.getAssistantSchemas('assistant-id');
```

### 列出 Assistant 版本

```dart
final versions = await client.listAssistantVersions('assistant-id');
```

### 获取最新版本

```dart
final latest = await client.getLatestAssistantVersion('assistant-id');
```

### 列出子图

```dart
final namespaces = await client.listAssistantSubgraphs('assistant-id');
```

### 获取特定子图

```dart
final subgraph = await client.getAssistantSubgraph(
  'assistant-id',
  'namespace',
);
```

---

## Threads API

Thread 是状态和消息历史的容器。

### 创建 Thread

```dart
final thread = await client.createThread(
  threadId: 'custom-thread-id', // 可选
  metadata: {'session': '123'},  // 可选
  ifExists: 'raise',             // 'raise' | 'error' | 'return_existing'
);
```

### 获取 Thread

```dart
final thread = await client.getThread('thread-id');
```

### 删除 Thread

```dart
await client.deleteThread('thread-id');
```

### 搜索 Threads

```dart
final threads = await client.searchThreads(
  metadata: {'status': 'active'}, // 可选
  values: {'key': 'value'},       // 可选
  status: 'active',               // 可选
  limit: 10,
  offset: 0,
);
```

### 复制 Thread

```dart
final copied = await client.copyThread('thread-id');
```

### 获取 Thread 状态

```dart
final state = await client.getThreadState('thread-id');
```

### 更新 Thread 状态

```dart
final updatedState = await client.updateThreadState(
  'thread-id',
  values: {'messages': [...], 'count': 5},
  checkpoint: CheckpointConfig(
    threadId: 'thread-id',
    checkpointNs: '',
    checkpointId: 'checkpoint-123',
  ),
  asNode: 'my_node', // 可选
);
```

### 批量更新 Thread 状态

```dart
final results = await client.bulkUpdateThreadState({
  'thread-1': {'key': 'value1'},
  'thread-2': {'key': 'value2'},
});
```

### 获取 Thread 状态检查点

```dart
final checkpointState = await client.getThreadStateCheckpoint(
  'thread-id',
  'checkpoint-id',
);
```

### 获取 Thread 历史

```dart
final history = await client.getThreadHistory(
  'thread-id',
  limit: 10,       // 默认 10
  before: '2025-01-01T00:00:00Z', // 可选
);
```

---

## Thread Runs API

Run 是在 Thread 上调用图/助手的执行实例。

### 列出 Runs

```dart
final runs = await client.listStatefulRuns(
  'thread-id',
  limit: 10,
  offset: 0,
);
```

### 创建后台 Run（立即返回）

```dart
final run = await client.createStatefulBackgroundRun(
  'thread-id',
  RunCreateStateful(
    assistantId: 'assistant-id',
    input: {
      'messages': [
        {'role': 'user', 'content': 'Hello!'},
      ],
    },
    streamMode: 'messages', // 'messages' | 'updates' | 'debug'
    metadata: {'session': '123'},
  ),
);
```

### 流式 Run

```dart
await for (final event in client.streamStatefulRun(
  'thread-id',
  RunCreateStateful(
    assistantId: 'assistant-id',
    input: {'messages': [{'role': 'user', 'content': 'Hello'}]},
  ),
)) {
  print('Event: ${event.data}');
  // 处理每个 SSE 事件
}
```

### 解析流式事件数据

LangGraph SSE 流返回的数据是 JSON 数组格式。使用 `parseStreamEventData()` 函数可以轻松解析事件并提取消息内容和元数据。

```dart
await for (final event in client.streamStatefulRun(
  'thread-id',
  RunCreateStateful(
    assistantId: 'assistant-id',
    input: {'messages': [{'role': 'user', 'content': 'Hello'}]},
  ),
)) {
  // 解析 SSE 事件
  final parsed = parseStreamEventData(event);
  if (parsed != null) {
    // 提取文本内容
    final text = parsed.message.firstText;
    if (text != null) {
      print('Text: $text');
    }

    // 访问元数据
    print('Run ID: ${parsed.metadata.runId}');
    print('Node: ${parsed.metadata.langgraphNode}');
    print('Step: ${parsed.metadata.langgraphStep}');
    print('Model: ${parsed.metadata.lsModelName}');
  } else {
    // 解析失败时的回退处理
    print('Raw event: ${event.data}');
  }
}
```

#### 流式事件数据模型

| 类型 | 说明 |
|------|------|
| `ParsedStreamEvent` | 解析后的流式事件，包含 message 和 metadata |
| `StreamMessage` | SSE 消息对象，包含 content、id、type、toolCalls 等字段 |
| `MessageContent` | 消息内容块，包含 index、type、text、id、name、input 等字段 |
| `StreamMetadata` | SSE 元数据对象，包含 runId、langgraphNode、name 等字段 |
| `ResponseMetadata` | 响应元数据，包含 modelProvider、usage 等字段 |
| `ToolCall` | 工具调用对象，包含 name、args、id、type |
| `ToolCallChunk` | 流式工具调用片段，包含 id、index、name、args |
| `InvalidToolCall` | 错误的工具调用，包含 name、args、error、type |
| `UsageMetadata` | Token 使用元数据，包含 inputTokens、outputTokens、totalTokens |
| `ToolUseContent` | 工具使用内容辅助类，包含 index、id、name、input |

#### StreamMessage 便捷方法

```dart
// 获取第一个文本内容
final text = parsed.message.firstText;
if (text != null) {
  print('First text: $text');
}

// 消息类型判断
if (parsed.message.isAiMessage) {
  print('This is an AI message');
}
if (parsed.message.isToolMessage) {
  print('This is a tool message');
}
if (parsed.message.isRemoveMessage) {
  print('This is a remove message');
}

// 访问工具调用
final toolCalls = parsed.message.allToolCalls;
for (final toolCall in toolCalls) {
  print('Tool: ${toolCall.name}, Args: ${toolCall.args}');
}

// 访问工具调用片段（流式）
final toolCallChunks = parsed.message.allToolCallChunks;
for (final chunk in toolCallChunks) {
  print('Chunk ${chunk.index}: ${chunk.name} - ${chunk.args}');
}

// 访问使用元数据
if (parsed.message.usageMetadata != null) {
  print('Input tokens: ${parsed.message.usageMetadata!.inputTokens}');
  print('Output tokens: ${parsed.message.usageMetadata!.outputTokens}');
  print('Total tokens: ${parsed.message.usageMetadata!.totalTokens}');
}
```

### 等待 Run 完成

```dart
final result = await client.waitForStatefulRun(
  'thread-id',
  RunCreateStateful(
    assistantId: 'assistant-id',
    input: {'messages': [{'role': 'user', 'content': 'Hello'}]},
  ),
);
```

### 获取 Run

```dart
final run = await client.getStatefulRun('thread-id', 'run-id');
```

### 取消 Run

```dart
await client.cancelStatefulRun(
  'thread-id',
  'run-id',
  wait: false,          // 是否等待取消完成
  action: 'interrupt',  // 'interrupt' | 'rollback'
);
```

### 删除 Run

```dart
await client.deleteStatefulRun('thread-id', 'run-id');
```

### 加入现有 Run 流

```dart
await for (final event in client.joinStatefulRunStream(
  'thread-id',
  'run-id',
)) {
  print('Joined event: ${event.data}');
}
```

### 流式现有 Run

```dart
await for (final event in client.streamExistingStatefulRun(
  'thread-id',
  'run-id',
)) {
  print('Replayed event: ${event.data}');
}
```

---

## Stateless Runs API

Stateless Run 不保留状态或内存持久化。

### 创建后台 Run（无状态）

```dart
final result = await client.createBackgroundRun(
  RunCreateStateless(
    assistantId: 'assistant-id',
    input: {
      'messages': [
        {'role': 'user', 'content': 'Hello!'},
      ],
    },
  ),
);
```

### 流式 Run（无状态）

```dart
await for (final event in client.streamRun(
  RunCreateStateless(
    assistantId: 'assistant-id',
    input: {'messages': [{'role': 'user', 'content': 'Hello'}]},
  ),
)) {
  print('Event: ${event.data}');
}
```

### 等待 Run 完成（无状态）

```dart
final result = await client.waitForRun(
  RunCreateStateless(
    assistantId: 'assistant-id',
    input: {'messages': [{'role': 'user', 'content': 'Hello'}]},
  ),
);
```

### 批量创建 Runs

```dart
final requests = [
  RunCreateStateless(assistantId: 'asst-1', input: {...}),
  RunCreateStateless(assistantId: 'asst-2', input: {...}),
];

final results = await client.createRunBatch(requests);
```

### 取消 Run（无状态）

```dart
await client.cancelRun(
  'run-id',
  wait: false,
  action: 'interrupt',
);
```

---

## Crons API

Cron 是按计划定期运行的周期性任务。

### 创建 Cron

```dart
final cron = await client.createCron(
  CronCreate(
    assistantId: 'assistant-id',
    graphId: 'graph-id',
    schedule: '0 9 * * *', // cron 表达式
    input: {'messages': [{'role': 'user', 'content': 'Daily report'}]},
    timezone: 'UTC',
  ),
);
```

### 创建 Thread Cron

```dart
final cron = await client.createThreadCron(
  'thread-id',
  CronCreate(
    assistantId: 'assistant-id',
    schedule: '0 */6 * * *', // 每 6 小时
    input: {'task': 'sync'},
  ),
);
```

### 搜索 Crons

```dart
final crons = await client.searchCrons(
  CronSearch(
    assistantId: 'assistant-id', // 可选
    limit: 10,
    offset: 0,
  ),
);
```

### 删除 Cron

```dart
await client.deleteCron('cron-id');
```

---

## Store API

Store 是一个按命名空间组织的键值数据存储。

### 创建存储项目

```dart
final item = await client.createStoreItem(
  StoreItemCreate(
    namespace: 'my-namespace',
    key: 'user-123',
    value: {'name': 'John', 'age': 30},
    metadata: {'created_by': 'admin'},
  ),
);
```

### 获取存储项目

```dart
final item = await client.getStoreItem('my-namespace', 'user-123');
```

### 搜索存储项目

```dart
final items = await client.searchStoreItems(
  StoreItemSearch(
    namespace: 'my-namespace',
    filter: {'age': 30}, // 可选的元数据过滤
    limit: 10,
    offset: 0,
  ),
);
```

### 删除存储项目

```dart
await client.deleteStoreItem('my-namespace', 'user-123');
```

### 列出所有命名空间

```dart
final namespaces = await client.listStoreNamespaces();
```

---

## 错误处理

所有 API 调用都可能抛出 `LangGraphApiException`：

```dart
try {
  final thread = await client.createThread();
  print('Created: ${thread.threadId}');
} on LangGraphApiException catch (e) {
  print('Error: ${e.message}');
  print('Status Code: ${e.statusCode}');
  // 处理错误
} catch (e) {
  print('Unexpected error: $e');
}
```

---

## 数据模型

### 主要数据类型

| 类型 | 说明 |
|------|------|
| `Assistant` | 助手实例 |
| `Thread` | 线程容器 |
| `Run` | 执行实例 |
| `Cron` | 定时任务 |
| `StoreItem` | 存储项目 |
| `ThreadState` | 线程状态 |
| `AssistantVersion` | 助手版本 |
| `AssistantSchema` | 助手输入/输出模式 |

### 流式事件数据类型

| 类型 | 说明 |
|------|------|
| `ParsedStreamEvent` | 解析后的 SSE 流式事件，包含 message 和 metadata |
| `StreamMessage` | SSE 流式消息对象，包含 content、id、type、toolCalls 等字段 |
| `MessageContent` | 消息内容块，包含 index、type、text、id、name、input 等字段 |
| `StreamMetadata` | SSE 流式元数据对象，包含 runId、langgraphNode、name 等字段 |
| `ResponseMetadata` | 响应元数据，包含 modelProvider、usage 等字段 |
| `ToolCall` | 工具调用对象，包含 name、args、id、type |
| `ToolCallChunk` | 流式工具调用片段，包含 id、index、name、args |
| `InvalidToolCall` | 错误的工具调用，包含 name、args、error、type |
| `UsageMetadata` | Token 使用元数据，包含 inputTokens、outputTokens、totalTokens |
| `ToolUseContent` | 工具使用内容辅助类，包含 index、id、name、input |

### 请求模型

| 类型 | 说明 |
|------|------|
| `RunCreateStateful` | 创建有状态 Run 的请求 |
| `RunCreateStateless` | 创建无状态 Run 的请求 |
| `CronCreate` | 创建 Cron 的请求 |
| `CronSearch` | 搜索 Cron 的请求 |
| `StoreItemCreate` | 创建存储项目的请求 |
| `StoreItemSearch` | 搜索存储项目的请求 |

---

## 最佳实践

1. **使用流式处理**：对于长时间运行的 AI 任务，使用 `streamStatefulRun` 或 `streamRun` 获取实时更新

2. **批量操作**：使用 `createRunBatch` 提高效率

3. **错误重试**：实现适当的重试逻辑处理网络错误

4. **资源清理**：及时删除不需要的 threads 和 runs

5. **元数据使用**：使用 metadata 字段存储业务标识，便于后续搜索和过滤

---

## 相关资源

- [LangGraph API 官方文档](https://langchain-ai.github.io/langgraph/cloud/reference/api/api_ref.html)
- [Stream Modes 文档](https://langchain-ai.github.io/langgraph/concepts/streaming/)
