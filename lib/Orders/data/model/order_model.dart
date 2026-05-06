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
  final String totalAmount;
  final bool isVerified;
  final String paymentMethod;

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
    required this.totalAmount,
    this.paymentMethod = '',
    this.isVerified = false,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json, OrderType type, {bool forceAssigned = false}) {
    final user = json['user'] as Map<String, dynamic>?;
    
    // Look for details in either 'Pickup' or 'Delivery' keys based on backend response
    final details = (json['Pickup'] ?? json['Delivery']) as Map<String, dynamic>?;

    // Resilient address map detection: Check root 'address' (common in assigned orders) 
    // and nested 'address' (common in new pickup/delivery orders).
    Map<String, dynamic>? addressMap;
    if (json['address'] is Map) {
      addressMap = json['address'] as Map<String, dynamic>;
    } else if (details?['address'] is Map) {
      addressMap = details!['address'] as Map<String, dynamic>;
    }

    final orderItemsList = (json['OrderItems'] ?? json['items']) as List?;

    // Determine 'by' field dynamically (Removes static hardcoded reliance)
    // Prioritize root-level 'by' or 'unitType' from backend, fallback to "By Weight"
    String byValue = json['by']?.toString() ?? json['unitType']?.toString() ?? "By Weight";

    if (orderItemsList != null && orderItemsList.isNotEmpty) {
      // Use a robust check for 'piece' types to handle singular/plural and variations (e.g., piece, pieces, pcs)
      final hasPiece = orderItemsList.any((item) => 
        item['unitType']?.toString().toLowerCase().contains('piece') == true || 
        item['unitType']?.toString().toLowerCase() == 'pcs');
        
      if (hasPiece) {
        byValue = "Per Piece";
      }
    }

    // Construct the full address string from multiple fields
    final addressParts = [
      addressMap?['addressLine'],
      addressMap?['landmark'],
      addressMap?['city'],
      addressMap?['state'],
      addressMap?['pincode'],
    ];
    
    final constructedAddress = addressParts.where((part) => part != null && part.toString().trim().isNotEmpty).join(', ');
    
    // Priority logic for the final address string:
    // 1. Detailed construction from parts
    // 2. Flat string from root 'address' (if it's a String)
    // 3. Flat string from nested 'address' (if it's a String)
    final String fullAddress = constructedAddress.isNotEmpty ? constructedAddress : (json['address'] is String ? json['address'] as String : details?['address'] is String ? details!['address'] as String : '');

    return OrderModel(
      orderId: json['id']?.toString() ?? '', 
      orderNumber: json['orderNumber']?.toString() ?? '',
      name: json['customerName'] ?? user?['name'] ?? '',
      by: byValue,
      address: fullAddress.isEmpty ? 'No Address Provided' : fullAddress,
      isPaid: json['paymentStatus'] == 'SUCCESS',
      status: forceAssigned ? OrderStatus.assigned : parseOrderStatus(json['status']), // Map new statuses to existing enum
      orderType: type, // Explicitly set based on API call
      deliveryStage: type == OrderType.pickup ? DeliveryStage.startPickup : DeliveryStage.startDelivery, // Default stage based on order type
      pickedImages: [],
      bundles: (orderItemsList ?? [])
          .where((i) => i['unitType']?.toString().toUpperCase() == 'KG')
          .map((i) => BundleModel(
                id: i['id']?.toString() ?? '',
                name: i['title'] ?? 'Weight Bundle',
                weight: i['quantity']?.toString() ?? '0',
                price: (i['unitPrice'] as num?)?.toDouble() ?? 0.0,
              ))
          .toList(),
      items: (orderItemsList ?? [])
          .where((i) => i['unitType']?.toString().toUpperCase() != 'KG')
          .map((i) => OrderItem(
                id: i['id']?.toString() ?? '',
                name: i['title'] ?? '',
                qty: i['quantity']?.toString() ?? '', // Quantity is int, convert to string
                unit: i['unitType']?.toString() ?? '',
              ))
          .toList(),
      totalAmount: json['totalAmount']?.toString() ?? '0',
      isVerified: json['isVerified'] ?? false,
      paymentMethod: json['paymentMethod']?.toString() ?? '',
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
    String? totalAmount,
    bool? isVerified,
    String? paymentMethod,
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
      totalAmount: totalAmount ?? this.totalAmount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      isVerified: isVerified ?? this.isVerified,
    );
  }
}

class OrderItem {
  final String id;
  final String name;
  final String qty;
  final String unit;
  final bool isVerified;

  OrderItem({
    required this.id,
    required this.name,
    required this.qty,
    this.unit = '',
    this.isVerified = false,
  });

  OrderItem copyWith({bool? isVerified}) {
    return OrderItem(
      id: id,
      name: name,
      qty: qty,
      unit: unit,
      isVerified: isVerified ?? this.isVerified,
    );
  }
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
    case "PICKUP":
    case "WASHING":
    case "DRYING":
    case "IRONING":
      return OrderStatus.assigned;
    case "COMPLETED":
    case "DELIVERED":
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