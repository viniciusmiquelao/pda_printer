import 'package:flutter/material.dart';
import 'package:pda_printer/config/utils/format_real.dart';
import 'package:pda_printer/data/models/product_model.dart';

class ProductWidget extends StatelessWidget {
  const ProductWidget({Key? key, required this.item}) : super(key: key);
  final ProductModel item;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(item.name),
      subtitle: Text(
        'Preço unitário: ${formatToReal(item.unitPrice)}',
      ),
      trailing: Text('Qtd: ${item.quantity}'),
    );
  }
}
