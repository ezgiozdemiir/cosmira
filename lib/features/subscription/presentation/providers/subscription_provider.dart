import 'package:flutter_riverpod/flutter_riverpod.dart';

final subscriptionLoadingProvider = StateProvider<bool>((ref) => false);

final selectedPlanProvider = StateProvider<String>((ref) => 'yearly');
