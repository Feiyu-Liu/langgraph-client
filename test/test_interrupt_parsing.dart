import 'package:langgraph_client/langgraph_client.dart';

/// 测试脚本：验证 Task 事件中的 Interrupt 字段解析
///
/// 使用 "向我问一些问题" 作为 prompt，这个场景可能会触发
/// Agent 返回需要用户回答的问题，从而产生 interrupt 事件
void main() async {
  print('=== 开始测试 Interrupt 字段解析 ===\n');

  var client = LangGraphClient(
    baseUrl: 'http://localhost:2024',
  );

  Thread thread = await client.createThread();
  print('✓ 创建 Thread: ${thread.threadId}\n');

  var statefulRequest = RunCreateStateful(
    assistantId: '72a076d3-4298-402e-a7c6-2006d36c9b93',
    input: {
      'messages': [
        {
          'content': '向我问一些问题',
          'role': 'user',
        },
      ]
    },
    streamMode: ['messages-tuple', 'tasks']
  );

  print('--- 开始流式处理 ---\n');

  int messageEventCount = 0;
  int taskEventCount = 0;
  int interruptCount = 0;
  int toolCallCount = 0;

  // Store pending tool calls to match with results
  final Map<String, ToolCall> pendingToolCalls = {};

  await for (final sseEvent
      in client.streamStatefulRun(thread.threadId, statefulRequest)) {
    // 打印原始事件类型（用于调试）
    print('📨 收到事件: ${sseEvent.name}');

    // Try parsing as a message event first
    final messageParsed = parseStreamEventData(sseEvent);
    if (messageParsed != null) {
      messageEventCount++;
      final message = messageParsed.message;

      // Stage 1: AI declares tool calls - print tool names
      if (message.isAiMessage && message.allToolCalls.isNotEmpty) {
        print('  ├─ 类型: AI 消息 (包含工具调用)');
        for (final toolCall in message.allToolCalls) {
          toolCallCount++;
          print('  │  🔧 工具调用 #${toolCallCount}: ${toolCall.name}');
          print('  │     ID: ${toolCall.id}');
          print('  │     参数: ${toolCall.args}');
          // Store for matching with results later
          pendingToolCalls[toolCall.id] = toolCall;
        }
      }

      // Stage 2: Tool execution results - print tool results
      if (message.isToolMessage) {
        print('  ├─ 类型: 工具消息');
        final toolCallId = message.toolCallId;
        if (toolCallId != null && pendingToolCalls.containsKey(toolCallId)) {
          final originalCall = pendingToolCalls[toolCallId]!;
          // Extract tool result from content
          final result = message.content
              .where((c) => c.text != null)
              .map((c) => c.text!)
              .join('');
          print('  │  ✅ 工具结果: ${originalCall.name}');
          if (result.isNotEmpty) {
            print('  │     结果: $result');
          }

          // Remove completed call
          pendingToolCalls.remove(toolCallId);
        } else {
          print('  │  ⚠️  未找到匹配的工具调用');
        }
      }

      // 检查普通 AI 消息（有文本内容）
      if (message.isAiMessage && message.firstText != null) {
        print('  ├─ 类型: AI 消息 (文本)');
        print('  │  💬 文本: ${message.firstText!.substring(0, message.firstText!.length > 50 ? 50 : message.firstText!.length)}...');
      }

      print('  └─ 元数据: runId=${messageParsed.metadata.runId}, node=${messageParsed.metadata.langgraphNode}\n');
      continue;
    }

    // If not a message event, try parsing as a task event
    final taskParsed = parseTaskEventData(sseEvent);
    if (taskParsed != null) {
      taskEventCount++;
      final task = taskParsed.task;

      print('  ├─ Task ID: ${task.id}');
      print('  ├─ Task 名称: ${task.name}');
      print('  ├─ Task 类型: ${task.isInputTask ? "输入任务" : "结果任务"}');

      // 打印任务输入详情（如果有）
      if (task.isInputTask && task.input != null) {
        print('  ├─ 输入详情:');
        print('  │  - 消息数: ${task.input!.messages.length}');
        print('  │  - 待办数: ${task.input!.todos.length}');
        print('  │  - 文件数: ${task.input!.files.length}');
      }

      // 打印任务结果详情（如果有）
      if (task.isResultTask && task.result != null) {
        print('  ├─ 结果详情:');
        print('  │  - 消息数: ${task.result!.messages.length}');
      }

      // 打印触发器
      if (task.triggers.isNotEmpty) {
        print('  ├─ 触发器: ${task.triggers.join(', ')}');
      }

      // *** 重点：检查并打印 Interrupt 信息 ***
      if (task.hasInterrupts) {
        interruptCount += task.interrupts.length;
        print('  ├─ ⚠️  Interrupts 数量: ${task.interrupts.length}');
        for (int i = 0; i < task.interrupts.length; i++) {
          final interrupt = task.interrupts[i];
          print('  │  Interrupt #${i + 1}:');
          print('  │     ID: ${interrupt.id}');
          print('  │     Value 类型: ${interrupt.value.keys.join(', ')}');
          print('  │     Value 内容:');
          interrupt.value.forEach((key, value) {
            print('  │        $key: $value');
          });
        }
      } else {
        print('  ├─ Interrupts: 无');
      }

      print('  └─\n');
      continue;
    }

    // 如果既不是 message 也不是 task，打印原始数据（调试用）
    if (sseEvent.data != null && sseEvent.data!.isNotEmpty) {
      print('  ⚠️  未知事件类型，原始数据:');
      print('  ${sseEvent.data}\n');
    }
  }

  print('=== 流式处理完成 ===\n');
  print('📊 统计信息:');
  print('  - Message 事件数量: $messageEventCount');
  print('  - Task 事件数量: $taskEventCount');
  print('  - Interrupt 总数: $interruptCount');
  print('  - 工具调用数量: $toolCallCount');

  if (interruptCount > 0) {
    print('\n✅ 成功解析到 $interruptCount 个 Interrupt ！');
  } else {
    print('\n⚠️  未解析到任何 Interrupt');
    print('   可能原因:');
    print('   1. 该 Assistant 在处理 "向我问一些问题" 时没有产生 Interrupt');
    print('   2. Interrupt 可能以不同的形式返回');
    print('   3. 需要检查 Assistant 的图配置');
  }
}
