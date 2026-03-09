import 'package:openclaw_gateway/openclaw_gateway.dart';
import 'package:test/test.dart';

void main() {
  test('parses chat history payloads into typed transcript messages', () {
    final history = GatewayChatHistoryResult.fromJson({
      'sessionKey': 'main',
      'sessionId': 'session-1',
      'thinkingLevel': 'medium',
      'verboseLevel': 'default',
      'messages': [
        {
          'role': 'user',
          'timestamp': 1000,
          'content': 'hello',
        },
        {
          'role': 'assistant',
          'timestamp': 1200.5,
          'content': [
            {
              'type': 'text',
              'text': '# Heading\n\nHello **world**',
            },
            {
              'type': 'tool_call',
              'id': 'tool-1',
              'name': 'shell',
              'arguments': {'cmd': 'pwd'},
            },
          ],
          'usage': {
            'input': 10,
            'output': 20,
            'totalTokens': 30,
            'cost': {
              'total': 0.03,
            },
          },
        },
      ],
    });

    expect(history.sessionKey, 'main');
    expect(history.sessionId, 'session-1');
    expect(history.thinkingLevel, 'medium');
    expect(history.messages, hasLength(2));
    expect(history.messages.first.primaryText, 'hello');
    expect(history.messages.last.primaryText, '# Heading\n\nHello **world**');
    expect(history.messages.last.content.last.isToolCall, isTrue);
    expect(history.messages.last.usage?.total, 30);
    expect(history.messages.last.usage?.cost?.total, 0.03);
  });

  test('parses chat send and abort acknowledgements', () {
    final send = GatewayChatSendResult.fromJson({
      'runId': 'run-1',
      'status': 'started',
    });
    expect(send.runId, 'run-1');
    expect(send.isInFlight, isFalse);

    final abort = GatewayChatAbortResult.fromJson({
      'ok': true,
      'aborted': true,
      'runIds': ['run-1'],
    });
    expect(abort.ok, isTrue);
    expect(abort.aborted, isTrue);
    expect(abort.runIds, ['run-1']);
  });

  test('matches common operator session aliases', () {
    expect(
      gatewayChatSessionKeysMatch(
        incoming: 'agent:main:main',
        current: 'main',
      ),
      isTrue,
    );
    expect(
      gatewayChatSessionKeysMatch(
        incoming: 'main',
        current: 'agent:main:main',
      ),
      isTrue,
    );
    expect(
      gatewayChatSessionKeysMatch(
        incoming: 'session-a',
        current: 'session-b',
      ),
      isFalse,
    );
  });
}
