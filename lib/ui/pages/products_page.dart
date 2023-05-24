import 'package:esc_pos_printer/esc_pos_printer.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart';
import 'package:intl/intl.dart';
import 'package:pda_printer/config/currecy_formatter.dart';
import 'package:pda_printer/ui/components/base_button.dart';
import '../../data/models/product_model.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({Key? key}) : super(key: key);

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  var items = <ProductModel>[];
  double clientMoney = 0.0;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late String ipArgument;

  void _receiveMoney() {
    setState(() {
      clientMoney = double.parse(
        receiveController.text
            .replaceAll('R\$', '')
            .replaceAll('.', '')
            .replaceAll(',', '.'),
      );
    });
    receiveController.clear();
  }

  void _addItem() {
    final product = ProductModel(
      name: nameController.text,
      quantity: int.parse(quantityController.text),
      unitPrice: double.parse(
        priceController.text
            .replaceAll('R\$', '')
            .replaceAll('.', '')
            .replaceAll(',', '.'),
      ),
    );
    setState(() {
      items.add(product);
    });
    nameController.clear();
    quantityController.clear();
    priceController.clear();
  }

  @override
  void didChangeDependencies() {
    ipArgument = ModalRoute.of(context)?.settings.arguments as String;
    super.didChangeDependencies();
  }

  double get totalValueDouble {
    var totalValue = 0.0;
    for (var item in items) {
      final totalValueItem = item.unitPrice * item.quantity;
      totalValue = totalValue + totalValueItem;
    }
    return totalValue;
  }

  String formatToReal(double n) {
    return 'R\$ ${n.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  TextEditingController nameController = TextEditingController();
  TextEditingController quantityController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController receiveController = TextEditingController();

  void showCustomSnackBar(String text) {
    final snackBar = SnackBar(content: Text(text, textAlign: TextAlign.center));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<void> _displayDialogMoney() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Dinheiro recebido pelo cliente'),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Container(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: receiveController,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          CurrencyInputFormatter(),
                        ],
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, insira o valor recebido.';
                          }
                          return null;
                        },
                        decoration: const InputDecoration(
                          labelText: 'Dinheiro recebido',
                          hintText: 'Digite o valor',
                        ),
                        onFieldSubmitted: (value) {
                          final numberFormat = NumberFormat.currency(
                            locale: 'pt_BR',
                            symbol: 'R\$',
                          );
                          final double? price = double.tryParse(value);
                          if (price != null) {
                            priceController.text = numberFormat.format(price);
                          }
                        },
                      ),
                      const SizedBox(height: 8.0),
                    ],
                  ),
                ),
              ),
            ),
          ),
          actions: <Widget>[
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                nameController.clear();
                quantityController.clear();
                priceController.clear();
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  Navigator.of(context).pop();
                  _receiveMoney();
                  testPrint(ipArgument);
                }
              },
              child: const Text('Imprimir'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _displayDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Adicionar produto'),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Container(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: nameController,
                        keyboardType: TextInputType.text,
                        decoration: const InputDecoration(
                          labelText: 'Nome do Produto',
                          hintText: 'Nome do Produto',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, insira o nome do produto.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 8.0),
                      TextFormField(
                        controller: quantityController,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, insira a quantidade.';
                          }
                          return null;
                        },
                        decoration: const InputDecoration(
                          labelText: 'Quantidade',
                          hintText: 'Quantidade',
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      TextFormField(
                        controller: priceController,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          CurrencyInputFormatter(),
                        ],
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, insira o preço.';
                          }
                          return null;
                        },
                        decoration: const InputDecoration(
                          labelText: 'Preço',
                          hintText: 'Preço',
                        ),
                        onFieldSubmitted: (value) {
                          final numberFormat = NumberFormat.currency(
                            locale: 'pt_BR',
                            symbol: 'R\$',
                          );
                          final double? price = double.tryParse(value);
                          if (price != null) {
                            priceController.text = numberFormat.format(price);
                          }
                        },
                      ),
                      const SizedBox(height: 8.0),
                    ],
                  ),
                ),
              ),
            ),
          ),
          actions: <Widget>[
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                nameController.clear();
                quantityController.clear();
                priceController.clear();
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  Navigator.of(context).pop();
                  _addItem();
                }
              },
              child: const Text('Adicionar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> printDemoReceipt(NetworkPrinter printer) async {
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
        styles:
            const PosStyles(align: PosAlign.right, width: PosTextSize.size2),
      ),
      PosColumn(
        text: 'R\$ ${clientMoney.toString().replaceAll('.', ',')}',
        width: 4,
        styles:
            const PosStyles(align: PosAlign.right, width: PosTextSize.size2),
      ),
    ]);
    printer.row([
      PosColumn(
        text: 'Troco',
        width: 8,
        styles:
            const PosStyles(align: PosAlign.right, width: PosTextSize.size2),
      ),
      PosColumn(
        text:
            'R\$ ${(clientMoney - totalValueDouble).toString().replaceAll('.', ',')}',
        width: 4,
        styles:
            const PosStyles(align: PosAlign.right, width: PosTextSize.size2),
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

  void testPrint(String printerIp) async {
    const PaperSize paper = PaperSize.mm80;
    final profile = await CapabilityProfile.load();
    final printer = NetworkPrinter(paper, profile);

    final PosPrintResult res = await printer.connect(printerIp, port: 9100);

    if (res == PosPrintResult.success) {
      await printDemoReceipt(printer);

      printer.disconnect();
    }

    showCustomSnackBar(res.msg);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Produtos')),
      bottomNavigationBar: BottomAppBar(
        child: BaseButton(
          text: 'Imprimir',
          onPressed: items.isNotEmpty ? _displayDialogMoney : null,
          radius: 0,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _displayDialog,
        child: const Icon(Icons.add),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: items
            .map(
              (item) => ListTile(
                title: Text(item.name),
                subtitle: Text(
                  'Preço unitário: ${formatToReal(item.unitPrice)}',
                ),
                trailing: Text('Qtd: ${item.quantity}'),
              ),
            )
            .toList(),
      ),
    );
  }
}
