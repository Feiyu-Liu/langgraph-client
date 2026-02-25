import 'package:langgraph_client/langgraph_client.dart';

/// 测试脚本：验证 Task 事件中的 Interrupt 字段解析
///
/// 使用 "向我问一些问题" 作为 prompt，这个场景可能会触发
/// Agent 返回需要用户回答的问题，从而产生 interrupt 事件
void main() async {
  print('=== 开始测试 Interrupt 字段解析 ===\n');

  var client = LangGraphClient(baseUrl: 'http://localhost:2024');

  Thread thread = await client.createThread();
  print('✓ 创建 Thread: ${thread.threadId}\n');

  var statefulRequest = RunCreateStateful(
    assistantId: '72a076d3-4298-402e-a7c6-2006d36c9b93',
    input: {
      'messages': [
        {'content': '向我问一些问题', 'role': 'user'},
      ],
    },
    streamMode: ['messages-tuple', 'tasks'],
  );

  print('--- 开始流式处理 ---\n');

  int messageEventCount = 0;
  int taskEventCount = 0;
  int interruptCount = 0;
  int toolCallCount = 0;

  await for (final event in client.runStatefulConversationStream(
    thread.threadId,
    statefulRequest,
  )) {
    if (event is ConversationTextDeltaEvent) {
      messageEventCount++;
      print(
        '📨 文本(${event.origin.isSubagent ? "subagent" : "main"}): ${event.text}',
      );
      continue;
    }

    if (event is ConversationToolCallRequestedEvent) {
      toolCallCount++;
      print('🔧 工具调用 #$toolCallCount: ${event.toolCall.name}');
      print('   参数: ${event.toolCall.args}');
      continue;
    }

    if (event is ConversationToolCallCompletedEvent) {
      print('✅ 工具执行完成: ${event.toolName ?? event.toolCallId}');
      if (event.result != null) {
        print('   结果: ${event.result}');
      }
      continue;
    }

    if (event is ConversationInterruptEvent) {
      taskEventCount++;
      interruptCount++;
      print('⚠️ Interrupt: ${event.interrupt.id}');
      print('   Value: ${event.interrupt.value}');
      continue;
    }

    if (event is ConversationUnknownEvent) {
      print('⚠️ 未知事件: ${event.unknown.eventName}');
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
