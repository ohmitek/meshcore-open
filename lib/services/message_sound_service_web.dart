import 'dart:js_interop';

import 'package:web/web.dart' as web;

class MessageSoundService {
  static const _minInterval = Duration(seconds: 1);

  web.AudioContext? _context;
  DateTime? _lastPlayed;

  void play() {
    final now = DateTime.now();
    final last = _lastPlayed;
    if (last != null && now.difference(last) < _minInterval) return;
    _lastPlayed = now;

    try {
      final ctx = _context ??= web.AudioContext();
      if (ctx.state == 'suspended') {
        ctx.resume().toDart.ignore();
      }

      final start = ctx.currentTime;
      final oscillator = ctx.createOscillator()..type = 'sine';
      oscillator.frequency
        ..setValueAtTime(880, start)
        ..setValueAtTime(1320, start + 0.12);

      final gain = ctx.createGain();
      gain.gain
        ..setValueAtTime(0.0001, start)
        ..exponentialRampToValueAtTime(0.3, start + 0.02)
        ..exponentialRampToValueAtTime(0.0001, start + 0.35);

      oscillator.connect(gain);
      gain.connect(ctx.destination);
      oscillator.start(start);
      oscillator.stop(start + 0.35);
    } catch (_) {
      // Browsers may refuse audio before the user has interacted with the page.
    }
  }
}
