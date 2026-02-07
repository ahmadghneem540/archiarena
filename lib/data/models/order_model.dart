class OrderModel {
  final String id;
  final String date;
  final String status;
  final String from;
  final String to;

  final String? customsNumber;
  final String? cargoType;
  final double? weight;
  final double? goodsValue;
  final double? transportCost;
  final bool? hasReturn;
  OrderModel({
    required this.id,
    required this.date,
    required this.status,
    required this.from,
    required this.to,
    this.customsNumber,
    this.cargoType,
    this.weight,
    this.goodsValue,
    this.transportCost,
    this.hasReturn,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'],
      date: json['date'],
      status: json['status'],
      from: json['from'],
      to: json['to'],

      customsNumber: json['customsNumber'],
      cargoType: json['cargoType'],
      weight: json['weight'] != null
          ? (json['weight'] as num).toDouble()
          : null,
      goodsValue: json['goodsValue'] != null
          ? (json['goodsValue'] as num).toDouble()
          : null,
      transportCost: json['transportCost'] != null
          ? (json['transportCost'] as num).toDouble()
          : null,
      hasReturn: json['hasReturn'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "date": date,
      "status": status,
      "from": from,
      "to": to,
      "customsNumber": customsNumber,
      "cargoType": cargoType,
      "weight": weight,
      "goodsValue": goodsValue,
      "transportCost": transportCost,
      "hasReturn": hasReturn,
    };
  }
}
