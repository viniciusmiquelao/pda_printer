import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pda_printer/data/models/product_model.dart';

import '../../config/formatters/currecy_formatter.dart';

class DialogProduct extends StatefulWidget {
  const DialogProduct({
    Key? key,
    required this.onPressed,
  }) : super(key: key);

  final Function(ProductModel) onPressed;

  @override
  State<DialogProduct> createState() => _DialogProductState();
}

class _DialogProductState extends State<DialogProduct> {
  late TextEditingController nameController;
  late TextEditingController quantityController;
  late TextEditingController priceController;

  @override
  void initState() {
    nameController = TextEditingController();
    quantityController = TextEditingController();
    priceController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    nameController.dispose();
    quantityController.dispose();
    priceController.dispose();
    super.dispose();
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
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
              widget.onPressed(product);
            }
          },
          child: const Text('Adicionar'),
        ),
      ],
    );
  }
}
