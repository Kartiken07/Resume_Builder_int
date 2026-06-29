import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../api_services/Daily_Utility_Tool/services/barcode_services.dart';
import '../../notifiers/Daily_Utility_Tool/barcode_generator_notifier.dart';

final barcodeServiceProvider = Provider<BarcodeServices>((ref) {
  BarcodeServices.initializeDio();
  return BarcodeServices();
});

final barcodeGeneratorProvider =
    StateNotifierProvider<BarcodeGeneratorNotifier, BarcodeGeneratorState>((ref) {
  return BarcodeGeneratorNotifier(ref.read(barcodeServiceProvider));
});


