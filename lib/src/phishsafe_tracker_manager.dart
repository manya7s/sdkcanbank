import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import 'trackers/interaction/tap_tracker.dart';
import 'trackers/interaction/swipe_tracker.dart';
import 'trackers/location_tracker.dart';
import 'trackers/navigation_logger.dart';
import 'analytics/session_tracker.dart';
import 'device/device_info_logger.dart';
import '../storage/export_manager.dart';
import 'detectors/screen_recording_detector.dart';

class PhishSafeTrackerManager {
  final TapTracker _tapTracker = TapTracker();
  final SwipeTracker _swipeTracker = SwipeTracker();
  final NavigationLogger _navLogger = NavigationLogger();
  final LocationTracker _locationTracker = LocationTracker();
  final SessionTracker _sessionTracker = SessionTracker();
  final DeviceInfoLogger _deviceLogger = DeviceInfoLogger();
  final ExportManager _exportManager = ExportManager();

  final Map<String, int> _screenDurations = {};

  Timer? _screenRecordingTimer;
  bool _screenRecordingDetected = false;

  BuildContext? _context; // for showing dialogs

  void setContext(BuildContext context) {
    _context = context;
  }

  void recordScreenDuration(String screen, int seconds) {
    _screenDurations[screen] = (_screenDurations[screen] ?? 0) + seconds;
    print("🧠 Screen duration logged: $screen → $seconds seconds");
  }

  void startSession() {
    _tapTracker.reset();
    _swipeTracker.reset();
    _navLogger.reset();
    _sessionTracker.startSession();
    _screenDurations.clear();
    _screenRecordingDetected = false;

    print("✅ PhishSafe session started.");

    // 🚨 Start screen recording detection every 5 seconds
    _screenRecordingTimer = Timer.periodic(Duration(seconds: 5), (_) async {
      final isRecording = await ScreenRecordingDetector().isScreenRecording();
      if (isRecording && !_screenRecordingDetected) {
        _screenRecordingDetected = true;
        print("🚨 Screen recording detected during session!");

        // ✅ Show warning popup
        if (_context != null) {
          showDialog(
            context: _context!,
            builder: (ctx) => AlertDialog(
              title: Text("⚠️ Security Warning"),
              content: Text(
                "Screen recording is active. Please disable it to protect your banking session.",
              ),
              actions: [
                TextButton(
                  child: Text("OK"),
                  onPressed: () => Navigator.of(ctx).pop(),
                ),
              ],
            ),
          );
        }
      }
    });
  }

  Future<void> endSessionAndExport() async {
    _sessionTracker.endSession();
    _screenRecordingTimer?.cancel();
    _screenRecordingTimer = null;

    final Position? location = await _locationTracker.getCurrentLocation();
    final deviceInfo = await _deviceLogger.getDeviceInfo();
    final sessionDuration = _sessionTracker.sessionDuration?.inSeconds ?? 0;

    final sessionData = {
      'session': {
        'start': _sessionTracker.startTimestamp,
        'end': _sessionTracker.endTimestamp,
        'duration_seconds': sessionDuration,
      },
      'device': deviceInfo,
      'location': location != null
          ? {
        'latitude': location.latitude,
        'longitude': location.longitude,
      }
          : 'Location unavailable',
      'tap_durations_ms': _tapTracker.getTapDurations(),
      'last_swipe': _swipeTracker.getLastSwipeData(),
      'screens_visited': _navLogger.logs,
      'screen_durations': _screenDurations,
      'screen_recording_detected': _screenRecordingDetected,
    };

    await _exportManager.exportToJson(sessionData, 'session_log');
    print("📁 PhishSafe session exported.");
  }

  void onTapEvent() => _tapTracker.recordTap();
  void onSwipeStart(double pos) => _swipeTracker.startSwipe(pos);
  void onSwipeEnd(double pos) => _swipeTracker.endSwipe(pos);
  void onScreenVisited(String screenName) => _navLogger.logVisit(screenName);
}
