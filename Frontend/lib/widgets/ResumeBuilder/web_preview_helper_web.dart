import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

Widget createWebPreview(String url) {
  // Each URL needs a unique view ID so multiple previews on screen don't conflict.
  final viewId = 'pdf_preview_${url.hashCode}';

  // Determine the embed URL:
  //  - Localhost / 127.0.0.1: load directly (Google Docs Viewer can't reach private addresses).
  //  - Everything else: route through Google Docs Viewer which bypasses X-Frame-Options / CORS.
  final isLocalhost = url.contains('localhost') || url.contains('127.0.0.1');
  final embedUrl = isLocalhost
      ? url
      : 'https://docs.google.com/viewer?url=${Uri.encodeComponent(url)}&embedded=true';

  // Guard: only register once per viewId (hot-restart safe).
  try {
    ui_web.platformViewRegistry.registerViewFactory(viewId, (int id) {
      final iframe = web.document.createElement('iframe') as web.HTMLIFrameElement
        ..src = embedUrl
        ..allow = 'fullscreen';
      iframe.style
        ..border = 'none'
        ..width = '100%'
        ..height = '100%';
      return iframe;
    });
  } catch (_) {
    // Already registered on a previous build — safe to ignore.
  }

  return HtmlElementView(viewType: viewId);
}
