import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  IO.Socket? _socket;
  final List<IO.Socket> _sockets = [];

  IO.Socket initSocket({
    required String baseUrl,
    Map<String, dynamic>? query,
    List<String> transports = const ['websocket'],
    bool autoConnect = true,
    int reconnectionAttempts = 3,
    int reconnectionDelayMs = 2000,
    int? timeoutMs,
    String? path,
    Map<String, dynamic>? extraHeaders,
  }) {
    // Close any previous socket to avoid leaks
    try {
      _socket?.dispose();
      _socket?.disconnect();
    } catch (_) {}

    final optionsBuilder = IO.OptionBuilder()
        .setTransports(transports)
        .setQuery(query ?? {})
        .setReconnectionAttempts(reconnectionAttempts)
        .setReconnectionDelay(reconnectionDelayMs);

    if (timeoutMs != null && timeoutMs > 0) {
      optionsBuilder.setTimeout(timeoutMs);
    }

    if (path != null && path.isNotEmpty) {
      optionsBuilder.setPath(path);
    }

    if (extraHeaders != null && extraHeaders.isNotEmpty) {
      optionsBuilder.setExtraHeaders(extraHeaders);
    }

    if (autoConnect) {
      optionsBuilder.enableAutoConnect();
    } else {
      optionsBuilder.disableAutoConnect();
    }

    final options = optionsBuilder.build();

    final socket = IO.io(baseUrl, options);
    if (autoConnect) {
      socket.connect();
    }

    socket.onError((data) {
      if (kDebugMode) {
        print('Socket error: $data');
      }
    });

    _socket = socket;
    _sockets.add(socket);
    return socket;
  }

  IO.Socket? get socket => _socket;
  List<IO.Socket> get sockets => List.unmodifiable(_sockets);

  void dispose() {
    try {
      for (final s in _sockets) {
        try {
          s.dispose();
          s.disconnect();
        } catch (_) {}
      }
    } catch (_) {}
    _socket = null;
    _sockets.clear();
  }
}

