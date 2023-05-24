import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:pda_printer/ui/components/base_button.dart';
import 'package:pda_printer/ui/pages/products_page.dart';
import 'package:ping_discover_network_forked/ping_discover_network_forked.dart';
import 'package:flutter_wifi/flutter_wifi.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String localIp = '';
  List<String> devices = [];

  bool isDiscovering = false;
  int found = -1;
  TextEditingController portController = TextEditingController(text: '9100');

  void showCustomSnackBar(String text) {
    final snackBar = SnackBar(content: Text(text, textAlign: TextAlign.center));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void discover(BuildContext ctx) async {
    setState(() {
      isDiscovering = true;
      devices.clear();
      found = -1;
    });

    String ip;
    try {
      ip = await Wifi.ip;
      if (kDebugMode) print('local ip:\t$ip');
    } catch (e) {
      showCustomSnackBar('WiFi is not connected');
      return;
    }
    setState(() {
      localIp = ip;
    });

    final String subnet = ip.substring(0, ip.lastIndexOf('.'));
    int port = 9100;
    try {
      port = int.parse(portController.text);
    } catch (e) {
      portController.text = port.toString();
    }
    if (kDebugMode) {
      print('subnet:\t$subnet, port:\t$port');
    }

    final stream = NetworkAnalyzer.discover2(subnet, port);

    stream.listen((NetworkAddress addr) {
      if (addr.exists) {
        if (kDebugMode) {
          print('Found device: ${addr.ip}');
        }
        setState(() {
          devices.add(addr.ip);
          found = devices.length;
        });
      }
    })
      ..onDone(() {
        setState(() {
          isDiscovering = false;
          found = devices.length;
        });
      })
      ..onError((dynamic e) {
        showCustomSnackBar('Unexpected exception');
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Descobrir impressoras')),
      body: Builder(
        builder: (BuildContext context) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                TextField(
                  controller: portController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Porta',
                    hintText: 'Porta',
                  ),
                ),
                const SizedBox(height: 10),
                Text('Ip Local: $localIp',
                    style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 15),
                BaseButton(
                  text: isDiscovering ? 'Descobrindo...' : 'Descobrir',
                  onPressed: isDiscovering ? null : () => discover(context),
                ),
                const SizedBox(height: 15),
                Visibility(
                  visible: found >= 0,
                  child: Text(
                    'Encontrado: $found dispositivo(s)',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: devices.length,
                    itemBuilder: (BuildContext context, int index) {
                      return InkWell(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const ProductsPage(),
                            settings: RouteSettings(arguments: devices[index]),
                          ),
                        ),
                        child: Column(
                          children: <Widget>[
                            Container(
                              height: 60,
                              padding: const EdgeInsets.only(left: 10),
                              alignment: Alignment.centerLeft,
                              child: Row(
                                children: <Widget>[
                                  const Icon(Icons.print),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        Text(
                                          '${devices[index]}:${portController.text}',
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                        Text(
                                          'Clique para imprimir',
                                          style: TextStyle(
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(Icons.chevron_right),
                                ],
                              ),
                            ),
                            const Divider(),
                          ],
                        ),
                      );
                    },
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
