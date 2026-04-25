import 'package:ziya_laundry_deliveryapp/Orders/data/model/Bundle_Model.dart';
import 'package:ziya_laundry_deliveryapp/Orders/viewmodel/DeliveryStage.dart';

class OrderModel {
  final String orderId;
  final String orderNumber;
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
    required this.orderNumber,
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

  factory OrderModel.fromJson(Map<String, dynamic> json, OrderType type) {
    final user = json['user'] as Map<String, dynamic>?;
    
    // Look for details in either 'Pickup' or 'Delivery' keys based on backend response
    final details = (json['Pickup'] ?? json['Delivery']) as Map<String, dynamic>?;
    final addressData = details?['address'] as Map<String, dynamic>?;
    
    final orderItems = json['OrderItems'] as List?;

    // Determine 'by' field dynamically (Removes static hardcoded reliance)
    // Prioritize root-level 'by' or 'unitType' from backend, fallback to "By Weight"
    String byValue = json['by']?.toString() ?? json['unitType']?.toString() ?? "By Weight";

    if (orderItems != null && orderItems.isNotEmpty) {
      // Use a robust check for 'piece' types to handle singular/plural and variations (e.g., piece, pieces, pcs)
      final hasPiece = orderItems.any((item) => 
        item['unitType']?.toString().toLowerCase().contains('piece') == true || 
        item['unitType']?.toString().toLowerCase() == 'pcs');
        
      if (hasPiece) {
        byValue = "Per Piece";
      }
    }

    // Construct the full address string from multiple fields
    final addressParts = [
      addressData?['addressLine'],
      addressData?['landmark'],
      addressData?['city'],
      addressData?['state'],
      addressData?['pincode'],
    ];
    final fullAddress = addressParts.where((part) => part != null && part.toString().trim().isNotEmpty).join(', ');

    return OrderModel(
      orderId: json['id']?.toString() ?? '', 
      orderNumber: json['orderNumber']?.toString() ?? '',
      name: user?['name'] ?? '',
      by: byValue,
      address: fullAddress.isEmpty ? 'No Address Provided' : fullAddress,
      isPaid: json['paymentStatus'] == 'SUCCESS',
      status: parseOrderStatus(json['status']), // Map new statuses to existing enum
      orderType: type, // Explicitly set based on API call
      deliveryStage: type == OrderType.pickup ? DeliveryStage.startPickup : DeliveryStage.startDelivery, // Default stage based on order type
      pickedImages: [],
      bundles: [],
      items: (orderItems ?? [])
          .map((i) => OrderItem(
                name: i['title'] ?? '',
                qty: i['quantity']?.toString() ?? '', // Quantity is int, convert to string
                unit: i['unitType']?.toString() ?? '',
              ))
          .toList(),
    );
  }

  OrderModel copyWith({
    String? orderId,
    String? orderNumber,
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
      orderNumber: orderNumber ?? this.orderNumber,
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
  final String unit;

  OrderItem({
    required this.name,
    required this.qty,
    this.unit = '',
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
    case "SCHEDULED": // New status for pending pickup orders
    case "OUT_FOR_DELIVERY": // New delivery tasks should appear as 'pending' to be accepted
      return OrderStatus.pending;
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