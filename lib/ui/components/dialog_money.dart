import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pda_printer/config/formatters/currecy_formatter.dart';

class DialogMoney extends StatefulWidget {
  const DialogMoney({
    Key? key,
    required this.total,
    required this.onPressed,
  }) : super(key: key);

  final double total;
  final Function(String) onPressed;

  @override
  State<DialogMoney> createState() => _DialogMoneyState();
}

class _DialogMoneyState extends State<DialogMoney> {
  late TextEditingController receiveController;

  @override
  void initState() {
    receiveController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    receiveController.dispose();

    super.dispose();
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
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
                      final valueDouble = double.parse(
                        value
                            .replaceAll('R\$', '')
                            .replaceAll('.', '')
                            .replaceAll(',', '.'),
                      );
                      if (valueDouble < widget.total) {
                        return 'Insira um valor maior que a compra';
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
                        receiveController.text = numberFormat.format(price);
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
            receiveController.clear();
            Navigator.of(context).pop();
          },
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.of(context).pop();

              widget.onPressed(receiveController.text);
            }
          },
          child: const Text('Imprimir'),
        ),
      ],
    );
  }
}
