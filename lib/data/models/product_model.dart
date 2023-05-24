class ProductModel {
  late String name;
  late int quantity;
  late double unitPrice;

  ProductModel({
    required this.name,
    required this.quantity,
    required this.unitPrice,
  });

  ProductModel.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    quantity = json['quantity'];
    unitPrice = json['unit_price'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['quantity'] = quantity;
    data['unit_price'] = unitPrice;
    return data;
  }
}
