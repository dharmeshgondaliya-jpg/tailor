import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:statekit/statekit.dart';
import '../../customers_page/model/customer_model.dart';
import '../../orders_page/model/order_model.dart';
import '../../orders_page/repository/orders_page_repository.dart';
import '../binding/bill_preview_screen_binding.dart';

class BillPreviewScreenController extends StateController<BillPreviewScreenBinding> {
  late CustomerModel customer;
  List<OrderModel> unpaidOrders = [];
  double subtotal = 0.0;
  double advancePaid = 0.0;
  double balanceDue = 0.0;

  void initData(CustomerModel customer) {
    this.customer = customer;
    final allOrders = OrdersPageRepository().getOrders().where((o) => o.customerName == customer.name).toList();
    unpaidOrders = allOrders.where((o) => o.paymentStatus.toLowerCase() != 'paid').toList();
    
    subtotal = 0.0;
    advancePaid = 0.0;
    for (final order in unpaidOrders) {
      subtotal += order.laborCost * order.quantity;
      advancePaid += order.advanceAmount;
    }
    balanceDue = subtotal - advancePaid;
    update();
  }

  void printBill() async {
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => generatePdf(format),
      name: 'Bill_${customer.name.replaceAll(' ', '_')}.pdf',
    );
  }

  Future<Uint8List> generatePdf(PdfPageFormat format) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: format,
        build: (pw.Context context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(24),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header / Shop Name
                pw.Center(
                  child: pw.Text(
                    "TAILOR STITCH & STYLE STUDIO",
                    style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
                  ),
                ),
                pw.Center(
                  child: pw.Text(
                    "High Quality Bespoke Tailoring & Alterations",
                    style: pw.TextStyle(fontSize: 10, fontStyle: pw.FontStyle.italic),
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Divider(thickness: 1),
                pw.SizedBox(height: 10),

                // Invoice Info / Customer details
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text("BILL TO:", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                        pw.Text(customer.name, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 13)),
                        pw.Text(customer.phone, style: pw.TextStyle(fontSize: 10)),
                        pw.Text(customer.address, style: pw.TextStyle(fontSize: 10)),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text("INVOICE DATE:", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                        pw.Text(DateFormat('dd/MM/yyyy').format(DateTime.now()), style: pw.TextStyle(fontSize: 11)),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: 20),

                // Table of Orders
                pw.TableHelper.fromTextArray(
                  headers: ['Order #', 'Clothes/Pairs', 'Qty', 'Labor Cost (Rate)', 'Total'],
                  data: unpaidOrders.map((order) {
                    return [
                      order.orderNumber,
                      order.clothesName,
                      order.quantity.toString(),
                      "₹${order.laborCost.toStringAsFixed(0)}",
                      "₹${(order.laborCost * order.quantity).toStringAsFixed(0)}",
                    ];
                  }).toList(),
                  headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                  headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey700),
                  cellHeight: 25,
                  cellAlignments: {
                    0: pw.Alignment.centerLeft,
                    1: pw.Alignment.centerLeft,
                    2: pw.Alignment.center,
                    3: pw.Alignment.centerRight,
                    4: pw.Alignment.centerRight,
                  },
                ),
                pw.SizedBox(height: 20),

                // Summary
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.end,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Row(
                          children: [
                            pw.Text("Subtotal:  ", style: pw.TextStyle(fontSize: 12)),
                            pw.Text("₹${subtotal.toStringAsFixed(0)}", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
                          ],
                        ),
                        pw.SizedBox(height: 5),
                        pw.Row(
                          children: [
                            pw.Text("Advance Paid:  ", style: pw.TextStyle(fontSize: 12)),
                            pw.Text("₹${advancePaid.toStringAsFixed(0)}", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
                          ],
                        ),
                        pw.SizedBox(height: 5),
                        pw.Divider(thickness: 1),
                        pw.SizedBox(height: 5),
                        pw.Row(
                          children: [
                            pw.Text("Balance Due:  ", style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                            pw.Text("₹${balanceDue.toStringAsFixed(0)}", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 15, color: PdfColors.red700)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                pw.Spacer(),
                pw.Center(
                  child: pw.Text("Thank you for your business!", style: pw.TextStyle(fontSize: 12, fontStyle: pw.FontStyle.italic)),
                ),
              ],
            ),
          );
        },
      ),
    );

    return pdf.save();
  }
}