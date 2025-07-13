class SwipeTracker {
  DateTime? _startTime;
  double? _startPosition;

  Map<String, dynamic>? _lastSwipeData;

  /// Call this when a swipe starts
  void startSwipe(double position) {
    _startTime = DateTime.now();
    _startPosition = position;
  }

  /// Call this when a swipe ends
  void endSwipe(double position) {
    if (_startTime == null || _startPosition == null) return;

    final duration = DateTime.now().difference(_startTime!).inMilliseconds;
    final distance = (position - _startPosition!).abs();
    final speed = distance / duration;

    _lastSwipeData = {
      'duration_ms': duration,
      'distance_px': distance,
      'speed_px_per_ms': speed
    };

    _startTime = null;
    _startPosition = null;
  }

  /// Returns the last recorded swipe
  Map<String, dynamic>? getLastSwipeData() {
    return _lastSwipeData;
  }

  /// Reset swipe data
  void reset() {
    _lastSwipeData = null;
  }
}
