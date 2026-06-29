// ============================================================================
// BARCODE TYPE ENUM (aligned with backend)
// ============================================================================

enum BarcodeType {
  code128,
  code39,
  code93,
  ean8,
  ean13,
  upcA,  // Backend calls it 'upc', but widget library uses 'upcA'
  isbn10,
  isbn13,
  issn,
  gs1_128,
  ean,
}

extension BarcodeTypeX on BarcodeType {
  String get value {
    switch (this) {
      case BarcodeType.code128:
        return 'code128';
      case BarcodeType.code39:
        return 'code39';
      case BarcodeType.code93:
        return 'code93';
      case BarcodeType.ean8:
        return 'ean8';
      case BarcodeType.ean13:
        return 'ean13';
      case BarcodeType.upcA:
        return 'upc';  // Backend expects 'upc'
      case BarcodeType.isbn10:
        return 'isbn10';
      case BarcodeType.isbn13:
        return 'isbn13';
      case BarcodeType.issn:
        return 'issn';
      case BarcodeType.gs1_128:
        return 'gs1_128';
      case BarcodeType.ean:
        return 'ean';
    }
  }

  String get label {
    switch (this) {
      case BarcodeType.code128:
        return 'Code 128';
      case BarcodeType.code39:
        return 'Code 39';
      case BarcodeType.code93:
        return 'Code 93';
      case BarcodeType.ean8:
        return 'EAN-8';
      case BarcodeType.ean13:
        return 'EAN-13';
      case BarcodeType.upcA:
        return 'UPC-A';
      case BarcodeType.isbn10:
        return 'ISBN-10';
      case BarcodeType.isbn13:
        return 'ISBN-13';
      case BarcodeType.issn:
        return 'ISSN';
      case BarcodeType.gs1_128:
        return 'GS1-128';
      case BarcodeType.ean:
        return 'EAN';
    }
  }
}

BarcodeType barcodeTypeFromString(String value) {
  switch (value.toLowerCase()) {
    case 'code128':
      return BarcodeType.code128;
    case 'code39':
      return BarcodeType.code39;
    case 'code93':
      return BarcodeType.code93;
    case 'ean8':
      return BarcodeType.ean8;
    case 'ean13':
      return BarcodeType.ean13;
    case 'upc':
      return BarcodeType.upcA;
    case 'isbn10':
      return BarcodeType.isbn10;
    case 'isbn13':
      return BarcodeType.isbn13;
    case 'issn':
      return BarcodeType.issn;
    case 'gs1_128':
      return BarcodeType.gs1_128;
    case 'ean':
      return BarcodeType.ean;
    default:
      return BarcodeType.code128;
  }
}

// ============================================================================
// API REQUEST/RESPONSE MODELS (aligned with backend)
// ============================================================================

class BarcodeGenerationRequest {
  const BarcodeGenerationRequest({
    required this.data,
    required this.barcodeType,
  });

  final String data;
  final BarcodeType barcodeType;

  Map<String, dynamic> toJson() {
    return {
      'data': data,
      'barcode_type': barcodeType.value,
    };
  }
}

class BarcodePayload {
  const BarcodePayload({
    required this.barcodeType,
    required this.originalData,
    required this.normalizedData,
    required this.mimeType,
    required this.imageBase64,
    required this.dataUri,
  });

  final BarcodeType barcodeType;
  final String originalData;
  final String normalizedData;
  final String mimeType;
  final String imageBase64;
  final String dataUri;

  factory BarcodePayload.fromJson(Map<String, dynamic> json) {
    return BarcodePayload(
      barcodeType: barcodeTypeFromString(json['barcode_type']?.toString() ?? ''),
      originalData: json['original_data']?.toString() ?? '',
      normalizedData: json['normalized_data']?.toString() ?? '',
      mimeType: json['mime_type']?.toString() ?? '',
      imageBase64: json['image_base64']?.toString() ?? '',
      dataUri: json['data_uri']?.toString() ?? '',
    );
  }
}

class BarcodeGenerationResponse {
  const BarcodeGenerationResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  final bool success;
  final String message;
  final BarcodePayload data;

  factory BarcodeGenerationResponse.fromJson(Map<String, dynamic> json) {
    return BarcodeGenerationResponse(
      success: json['success'] as bool? ?? true,
      message: json['message']?.toString() ?? 'Barcode generated successfully',
      data: BarcodePayload.fromJson(
        Map<String, dynamic>.from(json['data'] as Map? ?? {}),
      ),
    );
  }
}

class BarcodeHistoryItem {
  const BarcodeHistoryItem({
    required this.id,
    required this.data,
    required this.barcodeType,
    required this.createdAt,
  });

  final int id;
  final String data;
  final BarcodeType barcodeType;
  final DateTime createdAt;

  factory BarcodeHistoryItem.fromJson(Map<String, dynamic> json) {
    return BarcodeHistoryItem(
      id: json['id'] as int? ?? 0,
      data: json['data']?.toString() ?? '',
      barcodeType: barcodeTypeFromString(json['barcode_type']?.toString() ?? ''),
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
    );
  }
}

class BarcodeHistoryResponse {
  const BarcodeHistoryResponse({
    required this.items,
    required this.total,
  });

  final List<BarcodeHistoryItem> items;
  final int total;

  factory BarcodeHistoryResponse.fromJson(Map<String, dynamic> json) {
    final itemsJson = (json['items'] as List? ?? []).cast<dynamic>();
    return BarcodeHistoryResponse(
      items: itemsJson
          .map(
            (e) => BarcodeHistoryItem.fromJson(
              Map<String, dynamic>.from(e as Map),
            ),
          )
          .toList(),
      total: json['total'] as int? ?? 0,
    );
  }
}

// ============================================================================
// UI STATE MODELS (for internal state management)
// ============================================================================

class BarcodeData {
  const BarcodeData({
    required this.value,
    required this.createdAt,
  });

  final String value;
  final DateTime createdAt;
}

class BarcodeState {
  const BarcodeState({
    this.input,
    this.barcode,
    this.errorMessage,
  });

  final String? input;
  final BarcodeData? barcode;
  final String? errorMessage;

  bool get hasBarcode => barcode != null;

  BarcodeState copyWith({
    String? input,
    BarcodeData? barcode,
    String? errorMessage,
    bool clearError = false,
    bool clearBarcode = false,
  }) {
    return BarcodeState(
      input: input ?? this.input,
      barcode: clearBarcode ? null : (barcode ?? this.barcode),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}