import 'package:esc_pos_printer/esc_pos_printer.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart';
import 'package:intl/intl.dart';
import 'package:pda_printer/data/models/product_model.dart';

Future<void> printReceipt(
    {required NetworkPrinter printer,
    required double clientMoney,
    required List<ProductModel> items}) async {
  // Print image
  final ByteData data = await rootBundle.load('assets/logo.png');
  final Uint8List bytes = data.buffer.asUint8List();
  final image = decodeImage(bytes);
  printer.image(image!);

  printer.text(
    'TICKUP',
    styles: const PosStyles(
      align: PosAlign.center,
      height: PosTextSize.size2,
      width: PosTextSize.size2,
    ),
    linesAfter: 1,
  );

  printer.text('Rua José Lourenço, 810',
      styles: const PosStyles(align: PosAlign.center));
  printer.text('Juiz de Fora - MG',
      styles: const PosStyles(align: PosAlign.center));
  printer.text('Tel: (31) 98245-0386',
      styles: const PosStyles(align: PosAlign.center));
  printer.text('www.tickup.com.br',
      styles: const PosStyles(align: PosAlign.center), linesAfter: 1);

  printer.hr();
  printer.row([
    PosColumn(text: 'Qtd', width: 1),
    PosColumn(text: 'Item', width: 7),
    PosColumn(
      text: 'Preço',
      width: 2,
      styles: const PosStyles(align: PosAlign.right),
    ),
    PosColumn(
      text: 'Total',
      width: 2,
      styles: const PosStyles(align: PosAlign.right),
    ),
  ]);

  var totalValue = 0.0;

  for (var item in items) {
    final totalValueItem = item.unitPrice * item.quantity;
    totalValue = totalValue + totalValueItem;
    printer.row([
      PosColumn(text: item.quantity.toString(), width: 1),
      PosColumn(text: item.name, width: 7),
      PosColumn(
        text: item.unitPrice.toString().replaceAll('.', ','),
        width: 2,
        styles: const PosStyles(align: PosAlign.right),
      ),
      PosColumn(
        text: totalValueItem.toString().replaceAll('.', ','),
        width: 2,
        styles: const PosStyles(align: PosAlign.right),
      ),
    ]);
  }
  printer.hr();

  printer.row([
    PosColumn(
      text: 'TOTAL',
      width: 6,
      styles: const PosStyles(
        height: PosTextSize.size2,
        width: PosTextSize.size2,
      ),
    ),
    PosColumn(
      text: totalValue.toString().replaceAll('.', ','),
      width: 6,
      styles: const PosStyles(
        align: PosAlign.right,
        height: PosTextSize.size2,
        width: PosTextSize.size2,
      ),
    ),
  ]);

  printer.hr(ch: '=', linesAfter: 1);

  printer.row([
    PosColumn(
      text: 'Dinheiro',
      width: 8,
      styles: const PosStyles(align: PosAlign.right, width: PosTextSize.size2),
    ),
    PosColumn(
      text: 'R\$ ${clientMoney.toString().replaceAll('.', ',')}',
      width: 4,
      styles: const PosStyles(align: PosAlign.right, width: PosTextSize.size2),
    ),
  ]);
  printer.row([
    PosColumn(
      text: 'Troco',
      width: 8,
      styles: const PosStyles(align: PosAlign.right, width: PosTextSize.size2),
    ),
    PosColumn(
      text: 'R\$ ${(clientMoney - totalValue).toString().replaceAll('.', ',')}',
      width: 4,
      styles: const PosStyles(align: PosAlign.right, width: PosTextSize.size2),
    ),
  ]);

  printer.feed(2);
  printer.text(
    'Obrigado e volte sempre!',
    styles: const PosStyles(align: PosAlign.center, bold: true),
  );

  final now = DateTime.now();
  final formatter = DateFormat('MM/dd/yyyy H:m');
  final String timestamp = formatter.format(now);

  printer.text(
    timestamp,
    styles: const PosStyles(align: PosAlign.center),
    linesAfter: 2,
  );

  printer.qrcode('www.tickup.com.br');

  printer.feed(1);
  printer.cut();
}
