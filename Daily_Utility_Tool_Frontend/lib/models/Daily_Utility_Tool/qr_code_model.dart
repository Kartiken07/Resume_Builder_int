enum QRShape { square, circle }

extension QRShapeX on QRShape {
  String get value {
    switch (this) {
      case QRShape.square:
        return 'square';
      case QRShape.circle:
        return 'circle';
    }
  }

  String get label {
    switch (this) {
      case QRShape.square:
        return 'Square';
      case QRShape.circle:
        return 'Circle';
    }
  }
}

enum ErrorCorrectionLevel { L, M, Q, H }

extension ErrorCorrectionLevelX on ErrorCorrectionLevel {
  String get value {
    switch (this) {
      case ErrorCorrectionLevel.L:
        return 'L';
      case ErrorCorrectionLevel.M:
        return 'M';
      case ErrorCorrectionLevel.Q:
        return 'Q';
      case ErrorCorrectionLevel.H:
        return 'H';
    }
  }

  String get label {
    switch (this) {
      case ErrorCorrectionLevel.L:
        return 'Low (7%)';
      case ErrorCorrectionLevel.M:
        return 'Medium (15%)';
      case ErrorCorrectionLevel.Q:
        return 'Quartile (25%)';
      case ErrorCorrectionLevel.H:
        return 'High (30%)';
    }
  }
}

class QRRequest {
  const QRRequest({
    required this.data,
    this.qrType,
    this.size = 300,
    this.fillColor = '#000000',
    this.backColor = '#ffffff',
    this.errorCorrection = 'M',
    this.shape = 'square',
    this.frame = false,
    this.outputFormat = 'png',
  });

  final String data;
  final String? qrType;
  final int size;
  final String fillColor;
  final String backColor;
  final String errorCorrection;
  final String shape;
  final bool frame;
  final String outputFormat;

  Map<String, dynamic> toJson() {
    return {
      'data': data,
      if (qrType != null) 'qr_type': qrType,
      'size': size,
      'fill_color': fillColor,
      'back_color': backColor,
      'error_correction': errorCorrection,
      'shape': shape,
      'frame': frame,
      'output_format': outputFormat,
    };
  }
}

class QRResponse {
  const QRResponse({
    required this.message,
    required this.qrType,
    required this.image,
    required this.dataUri,
  });

  final String message;
  final String qrType;
  final String image;
  final String dataUri;

  factory QRResponse.fromJson(Map<String, dynamic> json) {
    return QRResponse(
      message: json['message']?.toString() ?? 'QR Code generated',
      qrType: json['qr_type']?.toString() ?? 'text',
      image: json['image']?.toString() ?? '',
      dataUri: json['data_uri']?.toString() ?? '',
    );
  }
}

class QRGeneratorState {
  const QRGeneratorState({
    required this.data,
    required this.size,
    required this.fillColor,
    required this.backColor,
    required this.errorCorrection,
    required this.shape,
    required this.frame,
    required this.isLoading,
    required this.result,
    required this.errorMessage,
  });

  final String data;
  final int size;
  final String fillColor;
  final String backColor;
  final ErrorCorrectionLevel errorCorrection;
  final QRShape shape;
  final bool frame;
  final bool isLoading;
  final QRResponse? result;
  final String? errorMessage;

  QRGeneratorState copyWith({
    String? data,
    int? size,
    String? fillColor,
    String? backColor,
    ErrorCorrectionLevel? errorCorrection,
    QRShape? shape,
    bool? frame,
    bool? isLoading,
    QRResponse? result,
    String? errorMessage,
    bool clearError = false,
    bool clearResult = false,
  }) {
    return QRGeneratorState(
      data: data ?? this.data,
      size: size ?? this.size,
      fillColor: fillColor ?? this.fillColor,
      backColor: backColor ?? this.backColor,
      errorCorrection: errorCorrection ?? this.errorCorrection,
      shape: shape ?? this.shape,
      frame: frame ?? this.frame,
      isLoading: isLoading ?? this.isLoading,
      result: clearResult ? null : (result ?? this.result),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
