import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/Daily_Utility_Tool/emi_calculator_model.dart';
import '../../notifiers/Daily_Utility_Tool/emi_calculator_notifier.dart';
import '../../api_services/Daily_Utility_Tool/services/emi_converter_services.dart';

final emiConverterServicesProvider = Provider<EmiConverterServices>((ref) {
  EmiConverterServices.initializeDio();
  return EmiConverterServices();
});

final emiCalculatorProvider =
    StateNotifierProvider<EmiCalculatorNotifier, EmiCalculatorState>((ref) {
      final service = ref.watch(emiConverterServicesProvider);
      return EmiCalculatorNotifier(service);
    });
