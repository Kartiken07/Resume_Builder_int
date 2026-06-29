import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/Daily_Utility_Tool/qr_code_model.dart';
import '../../notifiers/Daily_Utility_Tool/qr_generator_notifier.dart';
import '../../api_services/Daily_Utility_Tool/services/qr_code_services.dart';

final qrCodeServicesProvider = Provider<QRCodeServices>((ref) {
  QRCodeServices.initializeDio();
  return QRCodeServices();
});

final qrGeneratorProvider =
    StateNotifierProvider<QRGeneratorNotifier, QRGeneratorState>((ref) {
      final service = ref.watch(qrCodeServicesProvider);
      return QRGeneratorNotifier(service);
    });
