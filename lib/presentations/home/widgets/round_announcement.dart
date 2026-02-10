import 'dart:async';

import 'package:flutter/material.dart';

class RoundAnnouncementManager {
  final BuildContext context;
  final Function() onAllComplete;

  OverlayEntry? overlay1;
  OverlayEntry? overlay2;
  OverlayEntry? overlay3;
  Timer? _sequenceTimer;

  // Track the visibility state using a list of entries for easy removal
  final List<OverlayEntry> _activeOverlays = [];

  RoundAnnouncementManager({
    required this.context,
    required this.onAllComplete,
    required this.overlay1,
    required this.overlay2,
    required this.overlay3,

  });

  /// When [showOverlay2Soon] is true (e.g. drawer earned points), show overlay2 (guess compliments) soon
  /// so it appears while points are still animating (~2s), instead of after 2.5s.
  void startAnnouncementSequence({bool? isTimeUp, bool showOverlay2Soon = false}) {
    clearSequence();
    final isTimeUpVal = isTimeUp == true;
    final firstDelayMs = showOverlay2Soon ? 400 : 2500;

    final overlay = Overlay.of(context);
    if (isTimeUpVal && overlay1 != null) {
      overlay.insert(overlay1!);
      _activeOverlays.add(overlay1!);
    }

    // Safety: clear any stuck overlays after 8s so compliment never blocks (phase_change to interval will still come from server)
    Timer(Duration(milliseconds: 8000), () {
      if (_activeOverlays.isNotEmpty && context.mounted) {
        clearSequence();
      }
    });

    _sequenceTimer = Timer(Duration(milliseconds: firstDelayMs), () {
      if (!context.mounted) {
        clearSequence();
        return;
      }
      if (isTimeUpVal) _removeOverlay(overlay1);

      if (overlay2 != null) {
        overlay.insert(overlay2!);
        _activeOverlays.add(overlay2!);
      }

      _sequenceTimer = Timer(const Duration(milliseconds: 2500), () {
        if (!context.mounted) {
          clearSequence();
          return;
        }
        _removeOverlay(overlay2);

        if (overlay3 != null) {
          overlay.insert(overlay3!);
          _activeOverlays.add(overlay3!);
        }

        _sequenceTimer = Timer(const Duration(milliseconds: 2000), () {
          _removeOverlay(overlay3);
          onAllComplete();
          clearSequence();
        });
      });
    });
  }

  // --- 3. CLEANUP ---

  void _removeOverlay(OverlayEntry? entry) {
    if (entry != null && entry.mounted) {
      entry.remove();
      _activeOverlays.remove(entry);
    }
  }

  void clearSequence() {
    _sequenceTimer?.cancel();
    _sequenceTimer = null;

    // Remove all active overlays immediately
    for (var entry in _activeOverlays) {
      if (entry.mounted) {
        entry.remove();
      }
    }
    _activeOverlays.clear();
    // overlay1 = overlay2 = overlay3 = null;
    print('Round announcement sequence cleared.');
  }
}
