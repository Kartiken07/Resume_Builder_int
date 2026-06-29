import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../api_services/Daily_Utility_Tool/services/age_services.dart';
import '../../models/Daily_Utility_Tool/age_calculator_model.dart';
import '../../notifiers/Daily_Utility_Tool/age_calculator_notifier.dart';

final ageServiceProvider = Provider<AgeServices>((ref) {
  AgeServices.initializeDio();
  return AgeServices();
});

final ageCalculatorProvider =
    StateNotifierProvider<AgeCalculatorNotifier, AgeCalculatorState>((ref) {
  return AgeCalculatorNotifier(ref.read(ageServiceProvider));
});
