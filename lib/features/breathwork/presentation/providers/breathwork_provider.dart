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

  const BreathworkState({
    required this.pattern,
    this.phase = BreathPhase.idle,
    this.currentCycle = 0,
    this.totalCycles = 10,
    this.progress = 0,
    this.isActive = false,
  });

  BreathworkState copyWith({
    BreathworkPattern? pattern,
    BreathPhase? phase,
    int? currentCycle,
    int? totalCycles,
    double? progress,
    bool? isActive,
  }) {
    return BreathworkState(
      pattern: pattern ?? this.pattern,
      phase: phase ?? this.phase,
      currentCycle: currentCycle ?? this.currentCycle,
      totalCycles: totalCycles ?? this.totalCycles,
      progress: progress ?? this.progress,
      isActive: isActive ?? this.isActive,
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
  BreathworkNotifier(BreathworkPattern pattern)
      : super(BreathworkState(pattern: pattern));

  void start() {
    state = state.copyWith(isActive: true, phase: BreathPhase.inhale, currentCycle: 1);
  }

  void stop() {
    state = state.copyWith(isActive: false, phase: BreathPhase.idle, currentCycle: 0);
  }

  void updatePhase(BreathPhase phase) {
    state = state.copyWith(phase: phase);
  }

  void nextCycle() {
    if (state.currentCycle >= state.totalCycles) {
      state = state.copyWith(phase: BreathPhase.complete, isActive: false);
    } else {
      state = state.copyWith(
        currentCycle: state.currentCycle + 1,
        phase: BreathPhase.inhale,
      );
    }
  }

  void updateProgress(double progress) {
    state = state.copyWith(progress: progress);
  }
}
