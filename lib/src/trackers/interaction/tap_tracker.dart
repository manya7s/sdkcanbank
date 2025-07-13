class TapTracker {
  DateTime? _lastTap;
  final List<int> _tapDurations = [];

  /// Call this method every time a user taps.
  /// It will calculate and store the time gap since the last tap.
  void recordTap() {
    final now = DateTime.now();
    if (_lastTap != null) {
      final diff = now.difference(_lastTap!).inMilliseconds;
      _tapDurations.add(diff);
    }
    _lastTap = now;
  }

  /// Get all recorded tap durations (in ms)
  List<int> getTapDurations() {
    return List.unmodifiable(_tapDurations);
  }

  /// Clear recorded taps (for new session)
  void reset() {
    _lastTap = null;
    _tapDurations.clear();
  }
}
