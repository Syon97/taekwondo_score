// ─── Judge ───────────────────────────────────────────────────────────────────

class Judge {
  final String id; // device UUID
  final int slot; // 1–4 (or 1–5 for poomsae)
  final String? deviceName;
  final bool isConnected;
  final int? clockOffsetMs; // client clock offset from server

  const Judge({
    required this.id,
    required this.slot,
    this.deviceName,
    required this.isConnected,
    this.clockOffsetMs,
  });

  Judge copyWith({bool? isConnected, int? clockOffsetMs}) => Judge(
        id: id,
        slot: slot,
        deviceName: deviceName,
        isConnected: isConnected ?? this.isConnected,
        clockOffsetMs: clockOffsetMs ?? this.clockOffsetMs,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'slot': slot,
        'deviceName': deviceName,
        'isConnected': isConnected,
        'clockOffsetMs': clockOffsetMs,
      };

  factory Judge.fromJson(Map<String, dynamic> json) => Judge(
        id: json['id'],
        slot: json['slot'],
        deviceName: json['deviceName'],
        isConnected: json['isConnected'] ?? false,
        clockOffsetMs: json['clockOffsetMs'],
      );
}