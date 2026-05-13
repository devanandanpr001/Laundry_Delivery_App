import 'package:ziya_laundry_deliveryapp/Orders/data/model/Bundle_Model.dart';
import 'package:ziya_laundry_deliveryapp/Constants/Api_Constants.dart';
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
  final List<String> pickedImageIds;
  final List<BundleModel> bundles;
  final List<OrderItem> items;
  final String totalAmount;
  final bool isVerified;
  final String paymentMethod;
  final String? mismatchReason;
  final String? pickupUserId;
  final String? deliveryUserId;
  final DateTime? updatedAt;

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
    this.pickedImageIds = const [],
    this.bundles = const [],
    required this.items,
    required this.totalAmount,
    this.paymentMethod = '',
    this.isVerified = false,
    this.mismatchReason,
    this.pickupUserId,
    this.deliveryUserId,
    this.updatedAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json, OrderType type, {bool forceAssigned = false, bool forceCompleted = false}) {
    // Process the raw JSON using the static helper first to ensure numeric types are correct
    json = OrderModel.mapOrderData(json);
    
    final user = json['user'] as Map<String, dynamic>?;

    final details = (json['Pickup'] ?? json['Delivery'] ?? json['pickup'] ?? json['delivery']) as Map<String, dynamic>?;

    // Resilient address map detection: Check root 'address' (common in assigned orders) 
    // and nested 'address' (common in new pickup/delivery orders).
    Map<String, dynamic>? addressMap;
    if (json['address'] is Map) {
      addressMap = json['address'] as Map<String, dynamic>;
    } else if (details?['address'] is Map) {
      addressMap = details!['address'] as Map<String, dynamic>;
    }

    final orderItemsList = (json['OrderItems'] ?? json['items'] ?? details?['OrderItems'] ?? details?['items']) as List?;

    final rawImages = (json['pickedImages'] ?? json['images'] ?? details?['pickedImages'] ?? details?['images']) as List?;

    // Determine 'by' field dynamically (Removes static hardcoded reliance)
    // Prioritize root-level 'orderType', 'by', or 'unitType' from backend
    String rawType = (json['orderType'] ?? json['by'] ?? json['unitType'] ?? details?['orderType'] ?? "").toString().toUpperCase();
    
    String byValue = "By Weight"; // Default
    if (rawType.contains("PIECE")) {
      byValue = "Per Piece";
    } else if (rawType.contains("KG") || rawType.contains("WEIGHT")) {
      byValue = "By Weight";
    }

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
      addressMap?['address'], // Support for flattened address key
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
    String fullAddress = constructedAddress.isNotEmpty ? constructedAddress : (json['address'] is String ? json['address'] as String : details?['address'] is String ? details!['address'] as String : '');
    if (fullAddress.isEmpty || fullAddress.toLowerCase() == "null") fullAddress = 'No Address Provided';

    // Refine order type and status based on root status
    OrderType finalType = type;
    // Prioritize root status to avoid delivery orders using nested Pickup status
    final String rootStatus = (json['status'] ?? "").toString().toUpperCase();

    // Safe override: Respect the explicitly set appOrderType from the service layer.
    // This ensures completed pickups with status 'OUT_FOR_DELIVERY' don't get misclassified.
    if (json['appOrderType']?.toString().toLowerCase() == 'pickup') {
      finalType = OrderType.pickup;
    } else if (json['appOrderType']?.toString().toLowerCase() == 'delivery') {
      finalType = OrderType.delivery;
    } else if (rootStatus == "OUT_FOR_DELIVERY" || rootStatus == "DELIVERED") {
      finalType = OrderType.delivery;
    }

    // Determine the human-readable order number. 
    // Backend sends 'orderId' as the formatted string (LDR-xxxxx) in the root.
    // We use this for display while keeping the UUID 'id' for logical operations.
    String displayOrderNumber = json['orderId']?.toString() ?? '';
    if (!displayOrderNumber.startsWith("LDR") || displayOrderNumber.length < 5) {
      final num? numVal = json['orderNumber'] is num ? json['orderNumber'] as num : num.tryParse(json['orderNumber']?.toString() ?? '');
      if (numVal != null) {
        displayOrderNumber = "LDR-${numVal.toInt().toString().padLeft(5, '0')}";
      } else {
        displayOrderNumber = json['orderNumber']?.toString() ?? displayOrderNumber;
      }
    }

    return OrderModel(
      orderId: (json['id'] ?? json['_id'])?.toString() ?? '',
      orderNumber: displayOrderNumber,
      name: _sanitizeString(json['customerName'] ?? user?['name'] ?? details?['customerName'], "Customer"),
      by: byValue,
      address: fullAddress,
      isPaid: (json['paymentStatus'] ?? details?['paymentStatus']) == 'SUCCESS',
      status: forceCompleted ? OrderStatus.completed : (forceAssigned ? OrderStatus.assigned : parseOrderStatus(json['status'] ?? details?['status'])), 
      orderType: finalType, 
      deliveryStage: finalType == OrderType.pickup ? DeliveryStage.startPickup : DeliveryStage.startDelivery, 
      pickedImages: (rawImages ?? []).map<String>((e) {
        if (e is Map) return (e['imageUrl'] ?? e['filePath'] ?? e['path'] ?? '').toString();
        return e.toString();
      }).where((e) => e.isNotEmpty).toList(),
      pickedImageIds: (rawImages ?? []).map<String>((e) {
        if (e is Map) return (e['id'] ?? e['_id'] ?? '').toString();
        return '';
      }).toList(),
      bundles: (orderItemsList ?? [])
          .where((i) {
            final unitType = i['unitType']?.toString().toUpperCase() ?? "";
            return unitType == 'KG' || unitType == 'WEIGHT' || unitType == 'BUNDLE';
          })
          .map((i) => BundleModel(
                id: i['id']?.toString() ?? '',
                name: i['title'] ?? 'Weight Bundle',
                weight: i['quantity']?.toString() ?? '0',
                price: (i['unitPrice'] as num?)?.toDouble() ?? 0.0,
              ))
          .toList(),
      // Professional Fallback: If no items are provided in the delivery response, 
      // show a placeholder so the OrderCard remains visible and descriptive.
      items: (orderItemsList == null || orderItemsList.isEmpty)
          ? [
              OrderItem(
                id: 'placeholder_${json['id']}',
                name: 'Delivery Order',
                qty: '1',
                unit: 'Item',
              )
            ]
          : orderItemsList
              .where((i) {
                final unitType = i['unitType']?.toString().toUpperCase() ?? "";
                return unitType != 'KG' && unitType != 'WEIGHT' && unitType != 'BUNDLE';
              })
              .map((i) => OrderItem(
                    id: i['id']?.toString() ?? '',
                    name: i['title'] ?? '',
                    qty: i['quantity']?.toString() ?? '',
                    unit: i['unitType']?.toString() ?? '',
                  ))
              .toList(),
      totalAmount: (json['totalAmount'] ?? details?['totalAmount'])?.toString() ?? '0',
      isVerified: json['isVerified'] ?? details?['isVerified'] ?? false,
      paymentMethod: (json['paymentMethod'] ?? details?['paymentMethod'])?.toString() ?? '',
      mismatchReason: json['mismatchReason']?.toString() ?? details?['mismatchReason']?.toString(),
      pickupUserId: json['pickupUserId']?.toString(),
      deliveryUserId: json['deliveryUserId']?.toString(),
      updatedAt: (json['updatedAt'] ?? details?['updatedAt']) != null ? DateTime.tryParse((json['updatedAt'] ?? details?['updatedAt']).toString()) : null,
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
    List<String>? pickedImageIds,
    List<BundleModel>? bundles,
    List<OrderItem>? items,
    String? totalAmount,
    bool? isVerified,
    String? paymentMethod,
    String? mismatchReason,
    String? pickupUserId,
    String? deliveryUserId,
    DateTime? updatedAt,
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
      pickedImageIds: pickedImageIds ?? this.pickedImageIds,
      bundles: bundles ?? this.bundles,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      isVerified: isVerified ?? this.isVerified,
      mismatchReason: mismatchReason ?? this.mismatchReason,
      pickupUserId: pickupUserId ?? this.pickupUserId,
      deliveryUserId: deliveryUserId ?? this.deliveryUserId,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static String _sanitizeString(dynamic value, [String defaultValue = '']) {
    if (value == null) return defaultValue;
    final s = value.toString();
    return (s.isEmpty || s.toLowerCase() == "null") ? defaultValue : s;
  }

  // Helper to sanitize and map order data, moved from HomeService
  static Map<String, dynamic> mapOrderData(Map<String, dynamic> json) {
    // 1. Sanitize Numeric Fields (Crucial fix for "type 'String' is not a subtype of type 'num?'")
    // This handles cases where the API sends decimals or counts as Strings.
    final numericFields = [
      'totalAmount', 'paidAmount', 'payableAmount', 'unitPrice', 'payable_amount',
      'totalPrice', 'collectedAmount', 'orderNumber', 'quantity',
      'pricePerKg', 'itemsCount'
    ];
    
    void sanitize(Map<String, dynamic> data) {
      for (var field in numericFields) {
        if (data.containsKey(field) && data[field] != null) {
          if (data[field] is String) {
            if (field == 'orderNumber' || field == 'quantity') {
              data[field] = int.tryParse(data[field]) ?? (double.tryParse(data[field])?.toInt() ?? 0);
            } else {
              data[field] = double.tryParse(data[field]) ?? 0.0;
            }
          }
        }
      }
    }

    sanitize(json);
    
    // Sanitize root-level details map if present (Crucial for Assigned Orders)
    final detailsKeys = ['Pickup', 'Delivery', 'pickup', 'delivery'];
    for (var key in detailsKeys) {
      if (json[key] != null && json[key] is Map) {
        sanitize(json[key] as Map<String, dynamic>);
      }
    }

    // Sanitize nested items (handles both 'OrderItems' and 'items' keys used by different endpoints)
    final nestedKeys = ['OrderItems', 'items'];
    for (var key in nestedKeys) {
      if (json[key] != null && json[key] is List) {
        json[key] = (json[key] as List).map((item) {
          if (item is Map) {
            final itemMap = Map<String, dynamic>.from(item);
            sanitize(itemMap);
            return itemMap;
          }
          return item;
        }).toList();
      }
    }

    // 2. Prepend base URL to image paths
    void mapImages(Map<String, dynamic> data) {
      final imageFields = ['pickedImages', 'images'];
      for (var field in imageFields) {
        if (data.containsKey(field) && data[field] is List) {
          data[field] = (data[field] as List).map((img) {
            if (img is Map) {
              final imgMap = Map<String, dynamic>.from(img);
              final String path = (imgMap['filePath'] ?? imgMap['path'] ?? imgMap['imageUrl'] ?? "").toString();
              if (path.isNotEmpty && !path.startsWith('http')) {
                imgMap['imageUrl'] = '${ApiConstants.mediaBaseUrl}${path.startsWith('/') ? path.substring(1) : path}';
              } else if (path.isNotEmpty) {
                imgMap['imageUrl'] = path;
              }
              return imgMap;
            }
            final String path = img.toString();
            if (path.isNotEmpty && !path.startsWith('http')) {
              return '${ApiConstants.mediaBaseUrl}${path.startsWith('/') ? path.substring(1) : path}';
            }
            return path;
          }).toList();
        }
      }
    }

    mapImages(json);
    for (var key in detailsKeys) {
      if (json[key] != null && json[key] is Map) {
        mapImages(json[key] as Map<String, dynamic>);
      }
    }

    return json;
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

  OrderItem copyWith({
    String? id,
    String? name,
    String? qty,
    String? unit,
    bool? isVerified,
  }) {
    return OrderItem(
      id: id ?? this.id,
      name: name ?? this.name,
      qty: qty ?? this.qty,
      unit: unit ?? this.unit,
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
    case "WASHING":
    case "DRYING":
    case "IRONING":
    case "PICKUP_CONFIRMED":
    case "COMPLETED": // Pickups marked as completed but not yet terminal (delivered)
      return OrderStatus.assigned;
    case "DELIVERED":
      return OrderStatus.completed;
    case "SCHEDULED": // New status for pending pickup orders
    case "PICKUP": // Orders with status "PICKUP" are pending acceptance
    case "OUT_FOR_DELIVERY": // Delivery orders ready for acceptance
      return OrderStatus.pending;
    default:
      return OrderStatus.pending;
  }
}

OrderType parseOrderType(dynamic type) {
  if (type == null) return OrderType.pickup;
  final typeStr = type.toString().toLowerCase();
  switch (typeStr) {
    case 'pickup':
      return OrderType.pickup;
    case 'delivery':
      return OrderType.delivery;
    default:
      return OrderType.pickup;
  }
}