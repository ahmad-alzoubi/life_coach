// audio_player_manager.dart
import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:coach_life/enums/audio_status.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;


class AudioPlayerManager extends GetxController {
  static final AudioPlayerManager _instance = AudioPlayerManager._internal();
  factory AudioPlayerManager() => _instance;
  AudioPlayerManager._internal();

  final _controllers = <String, PlayerController>{};
  final _status = <String, Rx<AudioStatus>>{};
  final _positions = <String, RxInt>{};
  final _durations = <String, RxInt>{};
  final _cache = <String, String>{};
  final _downloadProgress = <String, RxDouble>{}.obs;
  final _playerCache = LRUCache<String, PlayerController>(maxSize: 10);

  static const _maxControllers = 5;
  final _controllerPool = <PlayerController>[];

  final playerWaveStyle = const PlayerWaveStyle(
    fixedWaveColor: Colors.white54,
    liveWaveColor: Colors.white,
    spacing: 6,
  );

  @override
  void onInit() {
    _initControllerPool();
    super.onInit();
  }

  void _initControllerPool() {
    for (int i = 0; i < _maxControllers; i++) {
      _controllerPool.add(PlayerController());
    }
  }

  PlayerController _getControllerFromPool() {
    if (_controllerPool.isEmpty) {
      return PlayerController();
    }
    return _controllerPool.removeLast();
  }

  void initController(String url) async {
    if (!_controllers.containsKey(url)) {
      final controller = _getControllerFromPool();
      _controllers[url] = controller;
      _status[url] = AudioStatus.idle.obs;
      _positions[url] = 0.obs;
      _durations[url] = 0.obs;
      
      try {
        final path = await _getCachedPath(url);
        await controller.preparePlayer(
          path: path,
          shouldExtractWaveform: true,
          noOfSamples: playerWaveStyle.getSamplesForWidth(Get.width * 0.7),
        );
        
        // Get initial duration
        final duration = await controller.getDuration();
        _durations[url]!.value = duration?.toInt() ?? 0;
        
        _setupListeners(url, controller);
      } catch (e) {
        _status[url]!.value = AudioStatus.error;
        Get.snackbar('Error', 'Failed to initialize audio: ${e.toString()}');
      }
    }
  }

  void _setupListeners(String url, PlayerController controller) {
    controller.onPlayerStateChanged.listen((state) {
      if (state == PlayerState.playing) {
        _status[url]!.value = AudioStatus.playing;
      } else if (state == PlayerState.paused) {
        _status[url]!.value = AudioStatus.paused;
      } else if (state == PlayerState.stopped) {
        _status[url]!.value = AudioStatus.idle;
      }
    });

    controller.onCurrentDurationChanged.listen((duration) {
      _positions[url]!.value = duration;
    });

    // controller.on.listen((duration) {
    //   _durations[url]!.value = duration?.toInt() ?? 0;
    // });
  }

  Future<void> togglePlayback(String url) async {
    final status = _status[url]!.value;
    if (status == AudioStatus.loading) return;

    try {
      if (status == AudioStatus.playing) {
        await pause(url);
      } else {
        await play(url);
      }
    } catch (e) {
      _status[url]!.value = AudioStatus.error;
      Get.snackbar('Error', 'Playback failed: ${e.toString()}');
    }
  }

  Future<void> play(String url) async {
    final controller = _controllers[url]!;
    _status[url]!.value = AudioStatus.loading;

    try {
      final path = await _getCachedPath(url);
      
      // Check if player needs preparation
      if (controller.playerState == PlayerState.stopped) {
        await controller.preparePlayer(
          path: path,
          // shouldExtractWaveform: true,
          // noOfSamples: 3000, // Number of waveform points
          noOfSamples: playerWaveStyle.getSamplesForWidth(Get.width * 0.7)
        );
      }

      await controller.startPlayer();
      _status[url]!.value = AudioStatus.playing;
    } catch (e) {
      _status[url]!.value = AudioStatus.error;
      rethrow;
    }
  }

  Future<void> pause(String url) async {
    final controller = _controllers[url]!;
    await controller.pausePlayer();
    _status[url]!.value = AudioStatus.paused;
  }

  void seek(String url, int positionMs) {
    final controller = _controllers[url]!;
    controller.seekTo(positionMs);
    _positions[url]!.value = positionMs;
  }

  void saveSeekPosition(String url) {
    // Implement any final position saving logic
    update();
  }

  void releaseController(String url) {
    final controller = _controllers.remove(url);
    if (controller != null) {
      controller.dispose();
      _controllerPool.add(PlayerController());
    }
  }

  PlayerController getController(String url) => _controllers[url]!;
  AudioStatus getStatus(String url) => _status[url]!.value;
  int getDuration(String url) => _durations[url]!.value;
  int getPosition(String url) => _positions[url]!.value;
  get downloadProgress => _downloadProgress;

  Future<String> _getCachedPath(String url) async {
    if (_cache.containsKey(url)) return _cache[url]!;
    
    final dir = await getTemporaryDirectory();
    final filePath = '${dir.path}/${url.split('/').last}';
    
    if (await File(filePath).exists()) {
      _cache[url] = filePath;
      return filePath;
    }

    _downloadProgress[url] = 0.0.obs;
    
    try {
      final dio = Dio();
      await dio.download(
        url,
        filePath,
        onReceiveProgress: (received, total) {
          _downloadProgress[url]!.value = received / total;
        },
      );
      _cache[url] = filePath;
      _downloadProgress.remove(url);
      return filePath;
    } catch (e) {
      _downloadProgress.remove(url);
      throw Exception('Download failed: ${e.toString()}');
    }
  }

  @override
  void onClose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    _controllerPool.clear();
    super.onClose();
  }
}

class LRUCache<K, V> {
  final int maxSize;
  final LinkedHashMap<K, V> _cache = LinkedHashMap();

  LRUCache({required this.maxSize});

  V? get(K key) => _cache.containsKey(key) ? _cache[key] : null;

  void put(K key, V value) {
    if (_cache.length >= maxSize) {
      _cache.remove(_cache.keys.first);
    }
    _cache[key] = value;
  }
}