import 'package:flutter_test/flutter_test.dart';
import 'package:sfa/features/ai/data/ai_models.dart';
import 'package:sfa/features/ai/data/ai_stream_events.dart';

/// The `ai:stream:*` payloads are the only place the chat thread comes from,
/// so a silently-dropped field renders as an empty bubble rather than an
/// error — these lock the shapes the gateway actually sends.
void main() {
  group('AiStreamStart', () {
    test('parses the documented payload', () {
      final event = AiStreamStart.fromJson(const {
        'conversationId': 'conv_123',
        'userMessageId': 'msg_456',
      });

      expect(event.conversationId, 'conv_123');
      expect(event.userMessageId, 'msg_456');
    });

    test('tolerates a start without a user message id', () {
      final event = AiStreamStart.fromJson(const {'conversationId': 'conv_123'});

      expect(event.conversationId, 'conv_123');
      expect(event.userMessageId, isNull);
    });
  });

  group('AiStreamChunk', () {
    test('parses a delta, preserving leading whitespace', () {
      // Token boundaries carry the spaces between words; trimming here
      // would run the reply together.
      final event = AiStreamChunk.fromJson(const {
        'conversationId': 'conv_123',
        'delta': ' abaya',
      });

      expect(event.delta, ' abaya');
    });

    test('falls back to content/text spellings', () {
      expect(
        AiStreamChunk.fromJson(const {'conversationId': 'c', 'content': 'hi'}).delta,
        'hi',
      );
      expect(
        AiStreamChunk.fromJson(const {'conversationId': 'c', 'text': 'hi'}).delta,
        'hi',
      );
    });
  });

  group('AiStreamProducts', () {
    test('parses the documented product shape', () {
      final event = AiStreamProducts.fromJson(const {
        'conversationId': 'conv_123',
        'products': [
          {
            'id': 'p1',
            'name': {'ar': 'عباية', 'en': 'Abaya'},
            'priceFils': 24900,
            'image': 'https://cdn.example.com/p1.jpg',
          },
        ],
      });

      expect(event.products, hasLength(1));
      final product = event.products.single;
      expect(product.id, 'p1');
      expect(product.name.resolve(true), 'عباية');
      expect(product.name.resolve(false), 'Abaya');
      expect(product.priceFils, 24900);
      expect(product.image, 'https://cdn.example.com/p1.jpg');
    });

    test('parses a re-emitted Mongo document', () {
      final event = AiStreamProducts.fromJson(const {
        'conversationId': 'conv_123',
        'recommendedProducts': [
          {
            '_id': 'p2',
            'title': 'Kaftan',
            'price': 15000,
            'images': ['https://cdn.example.com/p2.jpg'],
          },
        ],
      });

      final product = event.products.single;
      expect(product.id, 'p2');
      // A plain-string name is used for both locales rather than crashing.
      expect(product.name.resolve(true), 'Kaftan');
      expect(product.priceFils, 15000);
      expect(product.image, 'https://cdn.example.com/p2.jpg');
    });

    test('yields an empty list when products is missing or malformed', () {
      expect(AiStreamProducts.fromJson(const {'conversationId': 'c'}).products, isEmpty);
      expect(
        AiStreamProducts.fromJson(const {'conversationId': 'c', 'products': 'nope'}).products,
        isEmpty,
      );
    });
  });

  group('AiStreamDone', () {
    test('parses the terminal payload', () {
      final event = AiStreamDone.fromJson(const {
        'conversationId': 'conv_123',
        'messageId': 'msg_789',
        'fullReply': 'Here are three options.',
        'products': [
          {'id': 'p1', 'name': {'ar': 'عباية', 'en': 'Abaya'}, 'priceFils': 1000, 'image': ''},
        ],
      });

      expect(event.messageId, 'msg_789');
      expect(event.fullReply, 'Here are three options.');
      expect(event.products, hasLength(1));
    });

    test('leaves fullReply empty when the gateway omits it', () {
      // The notifier keeps the accumulated chunks in this case.
      final event = AiStreamDone.fromJson(const {
        'conversationId': 'conv_123',
        'messageId': 'msg_789',
      });

      expect(event.fullReply, isEmpty);
      expect(event.products, isEmpty);
    });
  });

  group('AiStreamError', () {
    test('parses a string error', () {
      final event = AiStreamError.fromJson(const {
        'conversationId': 'conv_123',
        'error': 'Upstream timeout',
      });

      expect(event.message, 'Upstream timeout');
    });

    test('parses an object error and an error with no conversation', () {
      final event = AiStreamError.fromJson(const {
        'error': {'message': 'Rate limited', 'code': 429},
      });

      expect(event.message, 'Rate limited');
      // Empty means "belongs to whichever turn is open" — the notifier
      // accepts it rather than dropping the failure.
      expect(event.conversationId, isEmpty);
    });
  });

  group('AiChatMessage', () {
    test('parses a stored history message as finished', () {
      final message = AiChatMessage.fromJson(const {
        '_id': 'm1',
        'role': 'assistant',
        'content': 'Welcome back.',
        'products': [
          {'id': 'p1', 'name': {'ar': 'عباية', 'en': 'Abaya'}, 'priceFils': 1000, 'image': ''},
        ],
      });

      expect(message.id, 'm1');
      expect(message.role, ChatRole.assistant);
      expect(message.text, 'Welcome back.');
      expect(message.recommendedProducts, hasLength(1));
      expect(message.isStreaming, isFalse);
      expect(message.isError, isFalse);
    });

    test('treats an unknown role as the assistant', () {
      expect(
        AiChatMessage.fromJson(const {'role': 'system', 'content': 'x'}).role,
        ChatRole.assistant,
      );
      expect(
        AiChatMessage.fromJson(const {'sender': 'user', 'text': 'x'}).role,
        ChatRole.user,
      );
    });
  });

  group('AiConversationHistory', () {
    test('parses a bare list of messages, keeping the requested id', () {
      final history = AiConversationHistory.fromResponse(
        const [
          {'role': 'user', 'content': 'hi'},
          {'role': 'assistant', 'content': 'hello'},
        ],
        'conv_123',
      );

      expect(history.conversationId, 'conv_123');
      expect(history.messages, hasLength(2));
      expect(history.messages.first.role, ChatRole.user);
    });

    test('parses a wrapped thread', () {
      final history = AiConversationHistory.fromResponse(
        const {
          'conversationId': 'conv_999',
          'messages': [
            {'role': 'assistant', 'content': 'hello'},
          ],
        },
        'conv_123',
      );

      expect(history.conversationId, 'conv_999');
      expect(history.messages, hasLength(1));
    });

    test('falls back to the requested id for an unrecognised body', () {
      final history = AiConversationHistory.fromResponse('nope', 'conv_123');

      expect(history.conversationId, 'conv_123');
      expect(history.messages, isEmpty);
    });
  });
}
