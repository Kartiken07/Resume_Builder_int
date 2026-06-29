import 'package:barcode_widget/barcode_widget.dart' as bw;
import 'package:flutter/material.dart';

import '../../../models/Daily_Utility_Tool/barcode_model.dart';
import '../../../theme/app_theme.dart';

class BarcodeResultCard extends StatelessWidget {
  const BarcodeResultCard({
    required this.barcodeData,
    required this.type,
    super.key,
  });

  final String barcodeData;
  final BarcodeType type;

  bw.Barcode _toBarcodeType() {
    switch (type) {
      case BarcodeType.code128:
        return bw.Barcode.code128();
      case BarcodeType.code39:
        return bw.Barcode.code39();
      case BarcodeType.code93:
        return bw.Barcode.code93();
      case BarcodeType.ean13:
        return bw.Barcode.ean13();
      case BarcodeType.ean8:
        return bw.Barcode.ean8();
      case BarcodeType.upcA:
        return bw.Barcode.upcA();
      case BarcodeType.isbn10:
        return bw.Barcode.isbn(); // ISBN10 uses generic ISBN
      case BarcodeType.isbn13:
        return bw.Barcode.isbn(); // ISBN13 uses generic ISBN
      case BarcodeType.issn:
        return bw.Barcode.code128(); // ISSN fallback to Code128
      case BarcodeType.gs1_128:
        return bw.Barcode.code128(); // GS1-128 fallback to Code128
      case BarcodeType.ean:
        return bw.Barcode.ean13(); // Generic EAN uses EAN13
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.cardPaddingH),
      decoration: BoxDecoration(
        color: AppTheme.primaryLight, // white bg needed for barcode readability
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(color: AppTheme.borderLight),
      ),
      child: bw.BarcodeWidget(
        barcode: _toBarcodeType(),
        data: barcodeData,
        width: 280,
        height: 100,
        drawText: true,
        style: AppTheme.bodySmall.copyWith(color: AppTheme.background),
      ),
    );
  }
}
