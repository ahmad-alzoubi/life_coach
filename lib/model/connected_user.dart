// lib/model/connected_user.dart
class ConnectedUser {
  final String id; // uid as string
  String type; // 'coach' | 'user' | custom label
  bool audioEnabled;
  bool videoEnabled;
  DateTime joinedAt;
  DateTime lastSeen;

  ConnectedUser({
    required this.id,
    required this.type,
    this.audioEnabled = true,
    this.videoEnabled = true,
    DateTime? joinedAt,
    DateTime? lastSeen,
  })  : joinedAt = joinedAt ?? DateTime.now(),
        lastSeen = lastSeen ?? DateTime.now();

  void update({
    bool? audioEnabled,
    bool? videoEnabled,
    DateTime? lastSeen,
    String? type,
  }) {
    if (audioEnabled != null) this.audioEnabled = audioEnabled;
    if (videoEnabled != null) this.videoEnabled = videoEnabled;
    if (lastSeen != null) this.lastSeen = lastSeen;
    if (type != null) this.type = type;
  }
}
