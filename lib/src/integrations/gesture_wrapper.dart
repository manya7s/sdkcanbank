import 'package:flutter/material.dart';
import 'package:phishsafe_sdk/phishsafe_sdk.dart';

/// Wrap any screen with this to auto-track taps and screen visits.
class GestureWrapper extends StatefulWidget {
  final Widget child;
  final String screenName;

  const GestureWrapper({
    Key? key,
    required this.child,
    required this.screenName,
  }) : super(key: key);

  @override
  State<GestureWrapper> createState() => _GestureWrapperState();
}

class _GestureWrapperState extends State<GestureWrapper> {
  bool _loggedVisit = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loggedVisit) {
      PhishSafeSDK.onScreenVisit(widget.screenName);
      _loggedVisit = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        PhishSafeSDK.onTap();
      },
      child: widget.child,
    );
  }
}
