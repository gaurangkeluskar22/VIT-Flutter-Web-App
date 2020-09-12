import 'package:advance_pdf_viewer/advance_pdf_viewer.dart';
import 'package:flutter/material.dart';

class PdfViewer extends StatelessWidget {
  final PDFDocument document;

  const PdfViewer({@required this.document});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PDFViewer(document: document),
    );
  }
}
