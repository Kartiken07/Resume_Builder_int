import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/Daily_Utility_Tool/unit_converter_model.dart';
import '../../notifiers/Daily_Utility_Tool/unit_converter_notifier.dart';
import '../../api_services/Daily_Utility_Tool/services/unit_converter_services.dart';

final unitConverterServicesProvider = Provider<UnitConverterServices>((ref) {
  UnitConverterServices.initializeDio();
  return UnitConverterServices();
});

final unitConverterProvider =
    StateNotifierProvider<UnitConverterNotifier, UnitConverterState>((ref) {
  final service = ref.watch(unitConverterServicesProvider);
  return UnitConverterNotifier(service);
});
