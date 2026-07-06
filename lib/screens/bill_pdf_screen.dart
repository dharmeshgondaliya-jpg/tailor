import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/order.dart';
import '../models/cloth_field.dart';

class BillPdfScreen extends StatelessWidget {
  final Order order;

  const BillPdfScreen({super.key, required this.order});

  Future<Uint8List> _generatePdf(PdfPageFormat format) async {
    final pdf = pw.Document(title: 'Invoice - ${order.billNumber}');

    pdf.addPage(
      pw.Page(
        pageFormat: format,
        build: (pw.Context context) {
          final totalAmount = order.price * order.quantity;
          final orderDateStr = '${order.orderDate.day}/${order.orderDate.month}/${order.orderDate.year}';
          final deliveryDateStr = '${order.completionDate.day}/${order.completionDate.month}/${order.completionDate.year}';

          return pw.Padding(
            padding: const pw.EdgeInsets.all(12),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header (Boutique Info)
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'GOLDEN STITCH',
                          style: pw.TextStyle(
                            fontSize: 22,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColor.fromHex('#D4AF37'), // Gold
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          'Premium Men\'s Tailors & Designers',
                          style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
                        ),
                        pw.Text(
                          '101, Fashion Plaza, Linking Road, Mumbai',
                          style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
                        ),
                        pw.Text(
                          'Phone: +91 98989 89898',
                          style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
                        ),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(
                          'INVOICE',
                          style: pw.TextStyle(
                            fontSize: 24,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.indigo900,
                          ),
                        ),
                        pw.SizedBox(height: 6),
                        pw.Container(
                          padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: pw.BoxDecoration(
                            color: PdfColors.grey100,
                            borderRadius: pw.BorderRadius.circular(4),
                          ),
                          child: pw.Text(
                            order.billNumber,
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: 20),
                pw.Divider(thickness: 1.5, color: PdfColors.grey300),
                pw.SizedBox(height: 16),

                // Customer Info and Invoice Info
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // Client detail
                    pw.Expanded(
                      flex: 3,
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'BILLED TO:',
                            style: pw.TextStyle(
                              fontSize: 10,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.grey700,
                            ),
                          ),
                          pw.SizedBox(height: 6),
                          pw.Text(
                            order.customer.name,
                            style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold),
                          ),
                          pw.SizedBox(height: 2),
                          pw.Text(
                            'Mobile: +91 ${order.customer.mobile}',
                            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey800),
                          ),
                          if (order.customer.address.isNotEmpty) ...[
                            pw.SizedBox(height: 2),
                            pw.Text(
                              order.customer.address,
                              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
                            ),
                          ],
                        ],
                      ),
                    ),
                    pw.Spacer(flex: 1),
                    // Invoice Dates & Details
                    pw.Expanded(
                      flex: 3,
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          _buildPdfInfoRow('Invoice Date:', orderDateStr),
                          _buildPdfInfoRow('Delivery Target:', deliveryDateStr),
                          _buildPdfInfoRow('Order Status:', order.status.label),
                          _buildPdfInfoRow('Job Quantity:', '${order.quantity}'),
                        ],
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 24),

                // Table of Items
                pw.Text(
                  'GARMENT DETAILS & SPECIFICATIONS',
                  style: pw.TextStyle(
                    fontSize: 11,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.indigo900,
                  ),
                ),
                pw.SizedBox(height: 8),

                pw.Table(
                  border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.8),
                  columnWidths: {
                    0: const pw.FlexColumnWidth(3),
                    1: const pw.FlexColumnWidth(5),
                    2: const pw.FlexColumnWidth(1.5),
                    3: const pw.FlexColumnWidth(2),
                  },
                  children: [
                    // Header Row
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(color: PdfColors.indigo50),
                      children: [
                        _buildTableHeaderCell('Garment Item'),
                        _buildTableHeaderCell('Recorded Sizes / Custom Specs'),
                        _buildTableHeaderCell('Price'),
                        _buildTableHeaderCell('Total'),
                      ],
                    ),
                    // Data Rows
                    ...order.items.map((item) {
                      // Compile measurements list
                      final specStrings = item.clothType.fields.map((field) {
                        final val = item.measurements[field.id] ?? '—';
                        final suffix = field.type == ClothFieldType.inches ? '"' : '';
                        return '${field.name}: $val$suffix';
                      }).join('  |  ');

                      return pw.TableRow(
                        children: [
                          _buildTableDataCell(item.clothType.name, bold: true),
                          _buildTableDataCell(specStrings, fontSize: 8),
                          _buildTableDataCell('₹${order.price.toStringAsFixed(0)}', alignRight: true),
                          _buildTableDataCell('₹${(order.price * order.quantity).toStringAsFixed(0)}', alignRight: true),
                        ],
                      );
                    }),
                  ],
                ),
                pw.SizedBox(height: 20),

                // Summary Calculation section
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.end,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        _buildSummaryCalcRow('Sub-total Stitching:', '₹${(order.price * order.quantity).toStringAsFixed(2)}'),
                        _buildSummaryCalcRow('Tax / GST (0%):', '₹0.00'),
                        pw.SizedBox(height: 4),
                        pw.Container(
                          height: 1,
                          width: 180,
                          color: PdfColors.grey300,
                        ),
                        pw.SizedBox(height: 4),
                        _buildSummaryCalcRow(
                          'Total Invoice Amount:',
                          '₹${totalAmount.toStringAsFixed(2)}',
                          bold: true,
                          fontSize: 13,
                          color: PdfColors.indigo900,
                        ),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: 36),

                // Instructions and Signature Section
                pw.Spacer(),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    // Notes column
                    pw.Expanded(
                      flex: 4,
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'TERMS & CONDITIONS:',
                            style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: PdfColors.grey700),
                          ),
                          pw.SizedBox(height: 4),
                          _buildBulletPoint('Goods once cut or stitched cannot be returned or refunded.'),
                          _buildBulletPoint('Fittings must be verified within 7 days of delivery.'),
                          _buildBulletPoint('Stitched items will be held for maximum 30 days after due date.'),
                          if (order.notes.isNotEmpty) ...[
                            pw.SizedBox(height: 8),
                            pw.Text(
                              'SPECIAL NOTES:',
                              style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: PdfColors.grey700),
                            ),
                            pw.Text(
                              order.notes,
                              style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey800),
                            ),
                          ],
                        ],
                      ),
                    ),
                    pw.Spacer(flex: 1),
                    // Signature column
                    pw.Expanded(
                      flex: 3,
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.center,
                        children: [
                          pw.Container(
                            height: 36,
                            alignment: pw.Alignment.bottomCenter,
                            child: pw.Text(
                              'GS',
                              style: pw.TextStyle(
                                fontSize: 18,
                                fontStyle: pw.FontStyle.italic,
                                color: PdfColors.indigo700,
                              ),
                            ),
                          ),
                          pw.Divider(thickness: 1, color: PdfColors.grey400),
                          pw.SizedBox(height: 4),
                          pw.Text(
                            'Authorized Signature',
                            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );

    return pdf.save();
  }

  pw.Widget _buildBulletPoint(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 2),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('• ', style: const pw.TextStyle(fontSize: 7)),
          pw.Expanded(
            child: pw.Text(text, style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey600)),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildPdfInfoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
          pw.Text(value, style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
        ],
      ),
    );
  }

  pw.Widget _buildTableHeaderCell(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9, color: PdfColors.indigo900),
      ),
    );
  }

  pw.Widget _buildTableDataCell(String text, {bool bold = false, double fontSize = 9, bool alignRight = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Container(
        alignment: alignRight ? pw.Alignment.centerRight : pw.Alignment.centerLeft,
        child: pw.Text(
          text,
          style: pw.TextStyle(
            fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
            fontSize: fontSize,
          ),
        ),
      ),
    );
  }

  pw.Widget _buildSummaryCalcRow(String label, String value, {bool bold = false, double fontSize = 10, PdfColor? color}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 3),
      child: pw.Row(
        mainAxisSize: pw.MainAxisSize.min,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(fontSize: fontSize, color: color ?? PdfColors.grey700),
          ),
          pw.SizedBox(width: 20),
          pw.Container(
            width: 80,
            alignment: pw.Alignment.centerRight,
            child: pw.Text(
              value,
              style: pw.TextStyle(fontSize: fontSize, fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal, color: color),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Invoice - ${order.billNumber}'),
      ),
      body: PdfPreview(
        build: (format) => _generatePdf(format),
        allowPrinting: true,
        allowSharing: true,
        canChangePageFormat: false,
        pdfFileName: 'Invoice_${order.billNumber}.pdf',
        loadingWidget: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Compiling PDF Bill Layout...'),
            ],
          ),
        ),
      ),
    );
  }
}
