import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../api_services/Minima/api_client.dart';

final apiProvider = Provider((ref) => ApiClient());
