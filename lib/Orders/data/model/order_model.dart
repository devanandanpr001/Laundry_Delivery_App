import 'package:ziya_laundry_deliveryapp/Orders/data/model/Bundle_Model.dart';
import 'package:ziya_laundry_deliveryapp/Orders/viewmodel/DeliveryStage.dart';

class OrderModel {
  final String orderId;
  final String name;
  final String by;
  final String address;
  final bool isPaid;
  final OrderStatus status;
  final OrderType orderType;
  final DeliveryStage deliveryStage;
  final List<String> pickedImages;
  final List<BundleModel> bundles;
  final List<OrderItem> items;

  OrderModel({
    required this.orderId,
    required this.name,
    required this.by,
    required this.address,
    required this.isPaid,
    required this.status,
    required this.orderType,
    this.deliveryStage = DeliveryStage.startPickup,
    this.pickedImages = const [],
    this.bundles = const [],
    required this.items,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      orderId: json['orderId'] ?? '',
      name: json['name'] ?? '',
      by: json['by'] ?? '',
      address: json['address'] ?? '',
      isPaid: json['isPaid'] ?? false,
      status: parseOrderStatus(json['status']),
      orderType: parseOrderType(json['orderType']),
      deliveryStage: json['deliveryStage'] ?? DeliveryStage.startPickup,
      pickedImages: [],
      bundles: [],
      items: (json['items'] as List? ?? [])
          .map((i) => OrderItem(
                name: i['name'] ?? '',
                qty: i['qty'] ?? '',
              ))
          .toList(),
    );
  }

  OrderModel copyWith({
    String? orderId,
    String? name,
    String? by,
    String? address,
    bool? isPaid,
    OrderStatus? status,
    OrderType? orderType,
    DeliveryStage? deliveryStage,
    List<String>? pickedImages,
    List<BundleModel>? bundles,
    List<OrderItem>? items,
  }) {
    return OrderModel(
      orderId: orderId ?? this.orderId,
      name: name ?? this.name,
      by: by ?? this.by,
      address: address ?? this.address,
      isPaid: isPaid ?? this.isPaid,
      status: status ?? this.status,
      orderType: orderType ?? this.orderType,
      deliveryStage: deliveryStage ?? this.deliveryStage,
      pickedImages: pickedImages ?? this.pickedImages,
      bundles: bundles ?? this.bundles,
      items: items ?? this.items,
    );
  }
}

class OrderItem {
  final String name;
  final String qty;

  OrderItem({
    required this.name,
    required this.qty,
  });
}

enum OrderStatus {
  pending,
  assigned,
  completed
}

enum OrderType { pickup, delivery }

OrderStatus parseOrderStatus(dynamic status) {
  if (status is OrderStatus) return status;
  switch (status?.toString().toUpperCase()) {
    case "ASSIGNED":
      return OrderStatus.assigned;
    case "COMPLETED":
      return OrderStatus.completed;
    default:
      return OrderStatus.pending;
  }
}

OrderType parseOrderType(dynamic type) {
  if (type is OrderType) return type;
  switch (type?.toString().toUpperCase()) {
    case "DELIVERY":
      return OrderType.delivery;
    default:
      return OrderType.pickup;
  }
}