import 'package:esc_pos_printer/esc_pos_printer.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter/material.dart';
import 'package:pda_printer/config/utils/print_receipt.dart';
import 'package:pda_printer/ui/components/base_button.dart';
import 'package:pda_printer/ui/components/dialog_money.dart';
import 'package:pda_printer/ui/components/dialog_product.dart';
import 'package:pda_printer/ui/components/product_widget.dart';
import '../../data/models/product_model.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({Key? key}) : super(key: key);

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  var items = <ProductModel>[];
  double clientMoney = 0.0;
  late String ipArgument;

  void _receiveMoney(String money) {
    setState(() {
      clientMoney = double.parse(
        money.replaceAll('R\$', '').replaceAll('.', '').replaceAll(',', '.'),
      );
    });
    testPrint(ipArgument);
  }

  void _addItem(ProductModel model) {
    setState(() {
      items.add(model);
    });
  }

  @override
  void didChangeDependencies() {
    ipArgument = ModalRoute.of(context)?.settings.arguments as String;
    super.didChangeDependencies();
  }

  void showCustomSnackBar(String text) {
    final snackBar = SnackBar(content: Text(text, textAlign: TextAlign.center));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<void> _displayDialogMoney() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        var totalValue = 0.0;
        for (var item in items) {
          final totalValueItem = item.unitPrice * item.quantity;
          totalValue = totalValue + totalValueItem;
        }
        return DialogMoney(
          onPressed: _receiveMoney,
          total: totalValue,
        );
      },
    );
  }

  Future<void> _displayDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return DialogProduct(onPressed: _addItem);
      },
    );
  }

  void testPrint(String printerIp) async {
    const PaperSize paper = PaperSize.mm80;
    final profile = await CapabilityProfile.load();
    final printer = NetworkPrinter(paper, profile);

    final PosPrintResult res = await printer.connect(printerIp, port: 9100);

    if (res == PosPrintResult.success) {
      await printReceipt(
        printer: printer,
        items: items,
        clientMoney: clientMoney,
      );

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
        children: items.map((item) => ProductWidget(item: item)).toList(),
      ),
    );
  }
}
