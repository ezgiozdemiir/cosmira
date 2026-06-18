import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/breathwork_session.dart';

enum BreathPhase { inhale, hold, exhale, holdOut, idle, complete }

class BreathworkState {
  final BreathworkPattern pattern;
  final BreathPhase phase;
  final int currentCycle;
  final int totalCycles;
  final double progress;
  final bool isActive;
  final int phaseSecondsRemaining;

  const BreathworkState({
    required this.pattern,
    this.phase = BreathPhase.idle,
    this.currentCycle = 0,
    this.totalCycles = 10,
    this.progress = 0,
    this.isActive = false,
    this.phaseSecondsRemaining = 0,
  });

  BreathworkState copyWith({
    BreathworkPattern? pattern,
    BreathPhase? phase,
    int? currentCycle,
    int? totalCycles,
    double? progress,
    bool? isActive,
    int? phaseSecondsRemaining,
  }) {
    return BreathworkState(
      pattern: pattern ?? this.pattern,
      phase: phase ?? this.phase,
      currentCycle: currentCycle ?? this.currentCycle,
      totalCycles: totalCycles ?? this.totalCycles,
      progress: progress ?? this.progress,
      isActive: isActive ?? this.isActive,
      phaseSecondsRemaining:
          phaseSecondsRemaining ?? this.phaseSecondsRemaining,
    );
  }
}

final selectedPatternProvider = StateProvider<BreathworkPattern>(
  (ref) => BreathworkPattern.all.first,
);

final breathworkStateProvider =
    StateNotifierProvider<BreathworkNotifier, BreathworkState>((ref) {
  return BreathworkNotifier(ref.watch(selectedPatternProvider));
});

class BreathworkNotifier extends StateNotifier<BreathworkState> {
  Timer? _timer;

  BreathworkNotifier(BreathworkPattern pattern)
      : super(BreathworkState(pattern: pattern));

  void start() => _startPhase(BreathPhase.inhale, 1);

  void stop() {
    _timer?.cancel();
    _timer = null;
    state = state.copyWith(
      isActive: false,
      phase: BreathPhase.idle,
      currentCycle: 0,
      phaseSecondsRemaining: 0,
    );
  }

  void _startPhase(BreathPhase phase, int cycle) {
    _timer?.cancel();
    final seconds = _phaseDuration(phase);

    // Skip zero-duration phases immediately
    if (seconds <= 0) {
      _advanceFrom(phase, cycle);
      return;
    }

    state = state.copyWith(
      isActive: true,
      phase: phase,
      currentCycle: cycle,
      phaseSecondsRemaining: seconds,
    );

    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      final remaining = state.phaseSecondsRemaining - 1;
      if (remaining <= 0) {
        t.cancel();
        _advanceFrom(phase, cycle);
      } else {
        state = state.copyWith(phaseSecondsRemaining: remaining);
      }
    });
  }

  void _advanceFrom(BreathPhase phase, int cycle) {
    switch (phase) {
      case BreathPhase.inhale:
        _startPhase(BreathPhase.hold, cycle);
      case BreathPhase.hold:
        _startPhase(BreathPhase.exhale, cycle);
      case BreathPhase.exhale:
        _startPhase(BreathPhase.holdOut, cycle);
      case BreathPhase.holdOut:
        if (cycle >= state.totalCycles) {
          _complete();
        } else {
          _startPhase(BreathPhase.inhale, cycle + 1);
        }
      default:
        break;
    }
  }

  void _complete() {
    _timer?.cancel();
    _timer = null;
    state = state.copyWith(
      isActive: false,
      phase: BreathPhase.complete,
      phaseSecondsRemaining: 0,
    );
  }

  int _phaseDuration(BreathPhase phase) => switch (phase) {
        BreathPhase.inhale => state.pattern.inhaleSeconds,
        BreathPhase.hold => state.pattern.holdSeconds,
        BreathPhase.exhale => state.pattern.exhaleSeconds,
        BreathPhase.holdOut => state.pattern.holdOutSeconds,
        _ => 0,
      };

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
