import 'dart:convert';

import '../enums/device_role.dart';

/// Universal WebSocket message envelope.
/// Every message sent between devices uses this wrapper.
class WsMessage {
  final String type;
  final String senderId;
  final DeviceRole senderRole;
  final int timestampMs;
  final Map<String, dynamic> payload;

  const WsMessage({
    required this.type,
    required this.senderId,
    required this.senderRole,
    required this.timestampMs,
    required this.payload,
  });

  factory WsMessage.create({
    required String type,
    required String senderId,
    required DeviceRole senderRole,
    required Map<String, dynamic> payload,
  }) {
    return WsMessage(
      type: type,
      senderId: senderId,
      senderRole: senderRole,
      timestampMs: DateTime.now().millisecondsSinceEpoch,
      payload: payload,
    );
  }

  String toJsonString() => jsonEncode({
        'type': type,
        'senderId': senderId,
        'senderRole': senderRole.name,
        'timestampMs': timestampMs,
        'payload': payload,
      });

  factory WsMessage.fromJsonString(String raw) {
    final json = jsonDecode(raw) as Map<String, dynamic>;
    return WsMessage(
      type: json['type'],
      senderId: json['senderId'],
      senderRole: DeviceRole.values.byName(json['senderRole']),
      timestampMs: json['timestampMs'],
      payload: json['payload'] as Map<String, dynamic>,
    );
  }
}