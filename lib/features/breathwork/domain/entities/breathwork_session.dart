import 'package:equatable/equatable.dart';

class BreathworkSession extends Equatable {
  final String id;
  final String userId;
  final String pattern;
  final int durationSeconds;
  final int cyclesCompleted;
  final String? mood;
  final DateTime completedAt;

  const BreathworkSession({
    required this.id,
    required this.userId,
    required this.pattern,
    required this.durationSeconds,
    required this.cyclesCompleted,
    this.mood,
    required this.completedAt,
  });

  @override
  List<Object?> get props => [id];
}

class BreathworkPattern {
  final String id;
  final String name;
  final String description;
  final int inhaleSeconds;
  final int holdSeconds;
  final int exhaleSeconds;
  final int holdOutSeconds;
  final int defaultCycles;
  final bool isPremium;

  const BreathworkPattern({
    required this.id,
    required this.name,
    required this.description,
    required this.inhaleSeconds,
    required this.holdSeconds,
    required this.exhaleSeconds,
    this.holdOutSeconds = 0,
    this.defaultCycles = 10,
    this.isPremium = false,
  });

  int get cycleDuration =>
      inhaleSeconds + holdSeconds + exhaleSeconds + holdOutSeconds;

  static const List<BreathworkPattern> all = [
    BreathworkPattern(
      id: 'box',
      name: 'Box Breathing',
      description: 'Calm your nervous system with equal-length phases.',
      inhaleSeconds: 4,
      holdSeconds: 4,
      exhaleSeconds: 4,
      holdOutSeconds: 4,
    ),
    BreathworkPattern(
      id: '478',
      name: '4-7-8 Relaxation',
      description: 'Deep relaxation technique for sleep and anxiety.',
      inhaleSeconds: 4,
      holdSeconds: 7,
      exhaleSeconds: 8,
    ),
    BreathworkPattern(
      id: 'coherent',
      name: 'Coherent Breathing',
      description: 'Balance your heart rate variability.',
      inhaleSeconds: 5,
      holdSeconds: 0,
      exhaleSeconds: 5,
      defaultCycles: 12,
    ),
    BreathworkPattern(
      id: 'energize',
      name: 'Energizing Breath',
      description: 'Boost energy and focus with rapid breathing.',
      inhaleSeconds: 2,
      holdSeconds: 0,
      exhaleSeconds: 2,
      defaultCycles: 20,
      isPremium: true,
    ),
    BreathworkPattern(
      id: 'cosmic',
      name: 'Cosmic Breath',
      description: 'Deep spiritual breathing aligned with lunar energy.',
      inhaleSeconds: 6,
      holdSeconds: 3,
      exhaleSeconds: 9,
      defaultCycles: 8,
      isPremium: true,
    ),
  ];
}
