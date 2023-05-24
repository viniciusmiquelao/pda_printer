String formatToReal(double n) {
  return 'R\$ ${n.toStringAsFixed(2).replaceAll('.', ',')}';
}
