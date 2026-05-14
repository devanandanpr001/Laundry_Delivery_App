import 'package:flutter/material.dart';
import 'package:ziya_laundry_deliveryapp/Home/data/repository/home_repository.dart';
import '../../Orders/data/model/order_model.dart';
import '../../Orders/viewmodel/DeliveryStage.dart';
import '../../Orders/data/model/Bundle_Model.dart';
import '../../Constants/Api_Constants.dart';
import '../../core/dio_client.dart';
import 'package:dio/dio.dart';

class HomeViewModel extends ChangeNotifier {
  final HomeRepository _repository;

  HomeViewModel(this._repository) {
    _init();
  }

  List<OrderModel> _orders = [];
  bool _isOnline = false;
  List<Map<String, dynamic>> _availableServices = [];
  final Map<String, List<dynamic>> _serviceItemsMap = {};
  final Set<String> _fetchingServiceIds = {}; // Track active fetches to prevent duplicate calls
  bool _isLoading = false;
  bool _isSessionExpired = false;
  bool _isFetchingServices = false;
  String _selectedFilter = "all";
  int _assignedCount = 0;
  int _completedCount = 0;
  String _userName = "";
  String _profileImage = "";
  String _address = "";
  String? _errorMessage;// Getters
  List<OrderModel> get orders => _orders;
  bool get isOnline => _isOnline;
  List<Map<String, dynamic>> get availableServices => _availableServices;
  Map<String, List<dynamic>> get serviceItemsMap => _serviceItemsMap;
  bool get isLoading => _isLoading;
  bool get isSessionExpired => _isSessionExpired;
  bool get isFetchingServices => _isFetchingServices;
  String get selectedFilter => _selectedFilter;
  String? get errorMessage => _errorMessage;
  int get assignedCount => _assignedCount;
  int get completedCount => _completedCount;
  String get userName => _userName;
  String get profileImage => _profileImage;
  String get address => _address;

  /// Getter to provide service names as a simple list for dropdowns
  List<String> get services => _availableServices
      .map((s) => s['name']?.toString() ?? "")
      .where((name) => name.isNotEmpty)
      .toList();

  // Logic Getters for UI
  List<OrderModel> get pendingOrders => _orders.where((o) => o.status == OrderStatus.pending).toList();
  List<OrderModel> get assignedOrders => _orders.where((o) => o.status == OrderStatus.assigned).toList();
  List<OrderModel> get completedOrders => _orders.where((o) => o.status == OrderStatus.completed).toList();

  Future<void> _init() async {
    _isOnline = await _repository.getInitialOnlineStatus();
    _isSessionExpired = false;
    DioClient.onSessionExpired = _handleSessionExpired;
    refreshOrders();
  }

  void _handleSessionExpired() {
    _isSessionExpired = true;
    notifyListeners();
  }

  /// Resets the session expired flag. Call this after showing the popup.
  void resetSessionExpired() {
    _isSessionExpired = false;
    notifyListeners();
  }

  Future<void> refreshOrders() async {
    if (_isLoading) return; // Performance: Prevent multiple simultaneous refreshes
    _isLoading = true;
    notifyListeners();
    try {
      // Concurrent fetch for efficiency: Fetch all orders, dashboard counts, profile, and available services
      final results = await Future.wait<dynamic>([
        _repository.getAllOrders(), // Now fetches all orders (pending, assigned, completed, pickup, delivery)
        _repository.getDashboardCounts(),
        _repository.getProfile(),
        fetchAvailableServices(), // Fetch services directly via API
      ]);

      final allFetchedOrders = (results[0] as List<OrderModel>?) ?? [];

      // Separate into active (pending/assigned) and completed orders
      final activeOrders = allFetchedOrders.where((o) => o.status != OrderStatus.completed).toList();
      final completedOrders = allFetchedOrders.where((o) => o.status == OrderStatus.completed).toList();
      
      // Deduplicate fetched orders by orderId, preferring completed/assigned state
      final Map<String, OrderModel> uniqueMap = {};
      for (var order in activeOrders) {
        uniqueMap["${order.orderId}_${order.orderType}"] = order;
      }
      for (var order in completedOrders) {
        uniqueMap["${order.orderId}_${order.orderType}"] = order;
      }
      
      final fetchedOrders = uniqueMap.values.toList();
      
      // Professional Merge Logic: Preserve local progress state (deliveryStage)
      // so the UI doesn't "reset" to Start Pickup after adding items/bundles/images.
      _orders = fetchedOrders.map((newOrder) {
        final existingOrder = _orders.cast<OrderModel?>().firstWhere(
          (o) => o?.orderId == newOrder.orderId && o?.orderType == newOrder.orderType,
          orElse: () => null,
        );
        return existingOrder != null 
            ? newOrder.copyWith(deliveryStage: existingOrder.deliveryStage)
            : newOrder;
      }).toList();
      
      final countData = (results[1] as Map<String, dynamic>?) ?? {};
      // The service already returns the 'data' part, so we access keys directly.
      _assignedCount = countData['assignedCount'] ?? 0;
      _completedCount = countData['completedCount'] ?? 0;

      final profileData = results[2] as Map<String, dynamic>?; // Index changed due to removal of getCompletedOrders
      if (profileData != null) {
        _userName = profileData['name']?.toString() ?? "User";
        
        _address = profileData['address']?.toString() ?? "";
        // Ensure a null profileImage from backend doesn't show up as the string "null"
        _profileImage = profileData['profileImage']?.toString() ?? ""; // Use the getter from ProfileViewModel
        _isOnline = profileData['isOnline'] ?? _isOnline;
      }

      _availableServices = (results[3] as List<Map<String, dynamic>>?) ?? []; // Corrected index
    } catch (e) {
      debugPrint("HomeViewModel Error: $e");
      // Ensure safe defaults if data fetching fails
      _orders = [];
      _assignedCount = 0;
      _completedCount = 0;
      _errorMessage = "Failed to sync dashboard data: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Dedicated method to fetch services independently of the main dashboard refresh
  Future<void> fetchServices(String orderId) async {
    if (_isFetchingServices) return;
    
    _isFetchingServices = true;
    notifyListeners();
    
    try {
      _availableServices = await fetchAvailableServices(orderId: orderId);
    } catch (e) {
      debugPrint("HomeViewModel fetchServices Error: $e");
    } finally {
      _isFetchingServices = false;
      notifyListeners();
    }
  }

  Future<List<Map<String, dynamic>>> fetchAvailableServices({String? orderId}) async {
    try {
      // Direct API call to fetch services using the established DioClient pattern
      String url = ApiConstants.serviceAvailability;
      if (orderId != null) {
        // Suffix with /:orderId/verify as per API requirements
        url = "$url/$orderId/verify";
      }
      
      final response = await DioClient().get(url);
      
      if (response != null && response['success'] == true && response['data'] is List) {
        return List<Map<String, dynamic>>.from(response['data']);
      }
    } catch (e) {
      debugPrint("HomeViewModel fetchAvailableServices Error: $e");
    }
    return [];
  }

  Future<void> fetchItemsForService(String serviceId) async {
    if (_serviceItemsMap.containsKey(serviceId)) return;
    debugPrint("HomeViewModel: Fetching items for service: $serviceId");
    try {
      final response = await DioClient().get(
        ApiConstants.selact_Items.replaceAll(':serviceId', serviceId),
      );
      if (response != null && response['success'] == true && response['data'] != null) {
        // Resilient parsing: handle if data is the list or contains the list under 'items'
        final List<dynamic> items = (response['data'] is Map) 
            ? (response['data']['items'] ?? []) 
            : (response['data'] ?? []);
            
        _serviceItemsMap[serviceId] = List<dynamic>.from(items);
        notifyListeners();
      }
    } catch (e) {
      debugPrint("HomeViewModel fetchItemsForService Error: $e");
    }
  }

  Future<void> fetchItemsForMultipleServices(List<String> serviceIds) async {
    // Only fetch if we don't have the data AND aren't already fetching it
    final idsToFetch = serviceIds.where((id) => !_serviceItemsMap.containsKey(id) && !_fetchingServiceIds.contains(id)).toList();
    if (idsToFetch.isEmpty) return;

    _fetchingServiceIds.addAll(idsToFetch);
    try {
      final response = await DioClient().post(
        ApiConstants.multipleServiceItems,
        data: {'serviceIds': idsToFetch},
      );

      if (response != null && response['success'] == true && response['data'] != null) {
        // Resilient parsing: handle if data is the list or contains the list under 'items'
        final List<dynamic> items = (response['data'] is Map) 
            ? (response['data']['items'] ?? []) 
            : (response['data'] is List ? response['data'] : (response['data'] != null ? [response['data']] : []));
        
        // Initialize map for these IDs to mark them as "fetched" to avoid re-fetching
        for (var id in idsToFetch) {
          _serviceItemsMap[id] = [];
        }

        for (var item in items) {
          if (item is! Map) continue;
          final List itemServices = item['services'] as List? ?? [];
          for (var s in itemServices) {
            final String? sId = (s is Map) 
                ? (s['serviceId']?.toString() ?? s['id']?.toString())
                : s?.toString();
            
            if (sId != null) {
              // Robust grouping: Compare IDs to ensure items are added to the correct service lists in cache
              for (var targetId in idsToFetch) {
                if (targetId.trim().toLowerCase() == sId.trim().toLowerCase()) {
                  _serviceItemsMap[targetId]?.add(item);
                }
              }
            }
          }
        }
      } else {
        // Fallback: Ensure keys are added even on empty/failed response to stop UI loading state
        for (var id in idsToFetch) {
          _serviceItemsMap[id] = [];
        }
      }
    } catch (e) {
      debugPrint("HomeViewModel fetchItemsForMultipleServices Error: $e");
      // Safety: Mark as fetched even on error so UI can proceed and stop showing "Loading"
      for (var id in idsToFetch) {
        if (!_serviceItemsMap.containsKey(id)) _serviceItemsMap[id] = [];
      }
    } finally {
      _fetchingServiceIds.removeAll(idsToFetch);
      notifyListeners();
    }
  }

  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    if (_isLoading) return; // Guard against multiple simultaneous status updates
    final index = _orders.indexWhere((o) => o.orderId == orderId);
    if (index != -1) {
      final currentOrder = _orders[index];

      if (status == OrderStatus.assigned && currentOrder.status == OrderStatus.pending) {
        // Optimistic update
        _orders[index] = currentOrder.copyWith(status: OrderStatus.assigned);
        notifyListeners();

        _isLoading = true;
        notifyListeners();
        try {
          bool success = false;
          if (currentOrder.orderType == OrderType.pickup) {
            success = await _repository.acceptPickupOrder(orderId);
            // If pickup is accepted, set initial stage
            if (success) _orders[index] = _orders[index].copyWith(deliveryStage: DeliveryStage.startPickup);
          } else {
            success = await _repository.acceptDeliveryOrder(orderId);
            // If delivery is accepted, set initial stage
            if (success) _orders[index] = _orders[index].copyWith(deliveryStage: DeliveryStage.startDelivery);

          }

          if (success) {
            // Refreshing ensures the UI matches the server state exactly
            await refreshOrders();
          }
        } catch (e) {
          // Revert optimistic update on failure
          _orders[index] = currentOrder;
          debugPrint("Failed to accept order: $e");
        } finally {
          _isLoading = false;
          notifyListeners();
        }
      } else if (status == OrderStatus.completed) {
        // For explicit completion requests, use the correct repo method based on order type
        if (currentOrder.orderType == OrderType.pickup) {
          await confirmPickup(orderId);
        } else {
          // Delivery completion is handled via verifyDeliveryOtp directly
          await refreshOrders();
        }
      }
    }
  }

  void toggleItemVerification(String orderId, String itemId) {
    // Local UI state for ticking off items during pickup
    final orderIndex = _orders.indexWhere((o) => o.orderId == orderId);
    if (orderIndex != -1) {
      final items = List<OrderItem>.from(_orders[orderIndex].items);
      final itemIndex = items.indexWhere((i) => i.id == itemId);
      if (itemIndex != -1) {
        final originalItem = items[itemIndex];
        // Optimistic update
        items[itemIndex] = originalItem.copyWith(isVerified: !originalItem.isVerified);
        _orders[orderIndex] = _orders[orderIndex].copyWith(items: items);
        notifyListeners();
        // No backend call for this as it's a local verification state for pickup
      }
      // If you need to persist this verification, you'd add an API call here.
    }
  }

  Future<void> deleteItemFromOrder(String orderId, String itemId) async {
    debugPrint("--- CONSOLE: DELETE ITEM START ---");
    debugPrint("OrderId: $orderId, ItemId: $itemId");
    
    final orderIndex = _orders.indexWhere((o) => o.orderId == orderId);
    if (orderIndex == -1) return;

    final originalItems = List<OrderItem>.from(_orders[orderIndex].items);
    final itemToRemove = originalItems.firstWhere((item) => item.id == itemId);

    // Optimistic update: Remove item locally
    final updatedItems = originalItems.where((item) => item.id != itemId).toList();
    _orders[orderIndex] = _orders[orderIndex].copyWith(items: updatedItems);
    notifyListeners();

    try {
      final response = await DioClient().delete(
        "${ApiConstants.orderItem}/$orderId/item",
        data: {"itemId": itemId},
      );
      
      // Refresh to sync totals and backend state
      await refreshOrders();
    } catch (e) {
      debugPrint("CONSOLE: Delete Error: $e");
      // Revert optimistic update
      _orders[orderIndex] = _orders[orderIndex].copyWith(items: originalItems);
      rethrow;
    }
  }

  // Clear error message after it's shown in the UI
  void clearErrorMessage() {
    _errorMessage = null;
    notifyListeners();
  }

  // Helper to check if more items can be added (Max 3)
  bool canAddMoreItems(String orderId) {
    final index = _orders.indexWhere((o) => o.orderId == orderId);
    if (index == -1) return false;
    return _orders[index].items.length < 3;
  }

  // Check if a service is already in the order (Useful for Checkbox state)
  bool isServiceSelected(String orderId, String serviceId) {
    final index = _orders.indexWhere((o) => o.orderId == orderId);
    if (index == -1) return false;
    return _orders[index].items.any((item) => item.id == serviceId);
  }

  // Toggle logic: ideal for Checkboxes
  void toggleService(String orderId, OrderItem service) {
    if (isServiceSelected(orderId, service.id)) {
      deleteItemFromOrder(orderId, service.id);
    } else {
      addItemToOrder(orderId, service);
    }
  }

  Future<void> addItemToOrder(String orderId, OrderItem newItem, {double price = 0, String? serviceName, List<String>? serviceNames}) async {
    if (_isLoading) return; // Guard against rapid multi-taps
    _isLoading = true;
    notifyListeners();
    debugPrint("--- CONSOLE: ADD ITEM START ---");
    // Split service and title from the string returned by AddItemDialog
    final nameParts = newItem.name.split(" - ");
    final List<String> services = serviceNames ?? [serviceName ?? (nameParts.isNotEmpty ? nameParts[0] : "General")];
    final title = nameParts.length > 1 ? nameParts[1] : newItem.name;

    final payload = {
      "title": title,
      "serviceType": services,
      "unitType": newItem.unit.toUpperCase(),
      "quantity": int.tryParse(newItem.qty) ?? 1,
      "unitPrice": price,
    };

    debugPrint("Payload: $payload");

    final orderIndex = _orders.indexWhere((o) => o.orderId == orderId);
    if (orderIndex == -1) return;

    // Optimistic update: Add item locally
    final tempId = DateTime.now().millisecondsSinceEpoch.toString(); // Temporary ID for optimistic update
    final optimisticItem = newItem.copyWith(id: tempId, qty: payload['quantity'].toString());
    _orders[orderIndex] = _orders[orderIndex].copyWith(items: [..._orders[orderIndex].items, optimisticItem]);
    notifyListeners();

    try {
      final response = await DioClient().post(
        "${ApiConstants.orderItem}/$orderId/item",
        data: payload,
      );

      debugPrint("CONSOLE: Add Item Success Response: $response");
      if (response['success'] != true) {
        throw Exception("API failed to add item");
      } else {
        // If successful, refresh to get the actual ID and updated order details
        await refreshOrders(); 
      }
    } catch (e) {
      debugPrint("CONSOLE: Add Item Error: $e");
      _errorMessage = "Failed to add item: $e";
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> reportItemMismatch(String orderId, String details) async {
    if (_isLoading) return false;
    _isLoading = true;
    notifyListeners();
    try {
      final orderIndex = _orders.indexWhere((o) => o.orderId == orderId);
      if (orderIndex == -1) return false;
      // Optimistic update
      _orders[orderIndex] = _orders[orderIndex].copyWith(mismatchReason: details);
      notifyListeners();

      // Endpoint: POST /api/delivery-session/session/orders/:orderId/add-mismatch-reason
      final response = await DioClient().put(
        ApiConstants.mismatch.replaceAll(':orderId', orderId),
        data: {"mismatchReason": details},
      );

      debugPrint("CONSOLE: Report Success Response: $response");
      if (response != null && response['success'] == true) {
        return true;
      }
      return false;
    } catch (e) {
      // Revert optimistic update on failure
      final orderIndex = _orders.indexWhere((o) => o.orderId == orderId);
      if (orderIndex != -1) _orders[orderIndex] = _orders[orderIndex].copyWith(mismatchReason: null); // Revert to null or original
      debugPrint("CONSOLE: Report Error: $e");
      _errorMessage = "Failed to report mismatch: $e";
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> confirmPickup(String orderId) async {
    if (_isLoading) return false;
    _isLoading = true;
    notifyListeners();
    try {
      final orderIndex = _orders.indexWhere((o) => o.orderId == orderId);
      if (orderIndex == -1) return false;

      final originalStatus = _orders[orderIndex].status;
      // Optimistic update
      _orders[orderIndex] = _orders[orderIndex].copyWith(status: OrderStatus.completed);
      notifyListeners();

      final success = await _repository.confirmPickupOrder(orderId);
      if (success) {
        await refreshOrders(); // Professional sync: get final OrderStatus.completed from server
        return true;
      } else {
        // Revert optimistic update on failure
        _orders[orderIndex] = _orders[orderIndex].copyWith(status: originalStatus);
        _errorMessage = "Failed to confirm pickup.";
        notifyListeners();
        return false;
      }
    } catch (e) {
      debugPrint("CONSOLE: Confirm Pickup Error: $e");
      _errorMessage = "Failed to confirm pickup: $e";
      // Revert optimistic update on failure
      final orderIndex = _orders.indexWhere((o) => o.orderId == orderId);
      if (orderIndex != -1) _orders[orderIndex] = _orders[orderIndex].copyWith(status: OrderStatus.assigned); // Assuming it was assigned before
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> verifyOrder(String orderId) async {
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();
    try {
      final orderIndex = _orders.indexWhere((o) => o.orderId == orderId);
      if (orderIndex == -1) return;

      final originalIsVerified = _orders[orderIndex].isVerified;
      // Optimistic update
      _orders[orderIndex] = _orders[orderIndex].copyWith(isVerified: true);
      notifyListeners();

      // Endpoint: PATCH /api/delivery-session/session/orders/:orderId/verify
      final response = await DioClient().patch(
        "${ApiConstants.verifyOrder}/$orderId/verify",
      );

      debugPrint("CONSOLE: Verify Success Response: $response");
      if (response['success'] != true) {
        throw Exception("API failed to verify order");
      } // No need to refreshOrders, local state is already updated
    } catch (e) {
      // Revert optimistic update on failure
      final orderIndex = _orders.indexWhere((o) => o.orderId == orderId);
      if (orderIndex != -1) _orders[orderIndex] = _orders[orderIndex].copyWith(isVerified: false);
      debugPrint("CONSOLE: Verify Error: $e");
      
      // If the server says the order is already verified, sync the local state by refreshing.
      if (e.toString().toLowerCase().contains("already verified")) {
        await refreshOrders();
        return;
      }

      _errorMessage = "Failed to verify order: $e";
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateOrderStage(String orderId, DeliveryStage stage) async {
    final index = _orders.indexWhere((o) => o.orderId == orderId);
    if (index != -1) {
      _orders[index] = _orders[index].copyWith(deliveryStage: stage);
      notifyListeners();
    }

    // Placeholder for backend call
    // _isLoading = true; notifyListeners();
    // await _repository.updateStage(orderId, stage);
    // _isLoading = false; notifyListeners();
  }

  Future<void> addOrderImages(String orderId, List<String> images) async {
    debugPrint("--- CONSOLE: UPLOAD IMAGES START ---");
    _isLoading = true;
    notifyListeners();

    final orderIndex = _orders.indexWhere((o) => o.orderId == orderId);
    if (orderIndex == -1) return;

    final originalImages = List<String>.from(_orders[orderIndex].pickedImages);
    final originalImageIds = List<String>.from(_orders[orderIndex].pickedImageIds);

    // Optimistic update: Add local paths to pickedImages
    _orders[orderIndex] = _orders[orderIndex].copyWith(pickedImages: [...originalImages, ...images]);
    notifyListeners();

    final List<Future<void>> uploadFutures = [];
    for (final path in images) {
      uploadFutures.add(() async {
        try {
          String fileName = path.split('/').last;
          FormData formData = FormData.fromMap({
            "image": await MultipartFile.fromFile(path, filename: fileName),
          });

          debugPrint("Uploading Image: $fileName for Order: $orderId");
          final response = await DioClient().post(
            "${ApiConstants.uploadOrderImage}/$orderId/upload-image",
            data: formData,
          );
          debugPrint("CONSOLE: Upload Success: $response");

          if (response['success'] == true && response['data'] != null) {
            // Update the local image path with the actual URL from the server
            final newImageUrl = response['data']['imageUrl']?.toString() ?? path;
            final newImageId = response['data']['id']?.toString() ?? '';

            final currentImages = List<String>.from(_orders[orderIndex].pickedImages);
            final currentImageIds = List<String>.from(_orders[orderIndex].pickedImageIds);
            final indexToUpdate = currentImages.indexOf(path);
            if (indexToUpdate != -1) {
              currentImages[indexToUpdate] = newImageUrl;
              currentImageIds.add(newImageId);
              _orders[orderIndex] = _orders[orderIndex].copyWith(pickedImages: currentImages, pickedImageIds: currentImageIds);
              notifyListeners(); // Notify after each image URL is updated
            }
          }
        } catch (e) {
          debugPrint("CONSOLE: Upload Error for $path: $e");
          // Revert: Remove the failed image from the local list
          _orders[orderIndex] = _orders[orderIndex].copyWith(pickedImages: _orders[orderIndex].pickedImages.where((img) => img != path).toList());
          notifyListeners();
        }
      }());
    }
    await Future.wait(uploadFutures); // Wait for all uploads to complete
    _isLoading = false;
    notifyListeners(); // Final notification after all uploads
  }

  Future<void> removeOrderImage(String orderId, int imageIndex) async {
    final index = _orders.indexWhere((o) => o.orderId == orderId);
    if (index != -1) {
      final order = _orders[index];
      if (imageIndex < order.pickedImages.length) {
        final imageId = (order.pickedImageIds.length > imageIndex) ? order.pickedImageIds[imageIndex] : '';

        if (imageId.isNotEmpty) {
          try {
            // Matches DELETE /api/delivery-session/session/orders/:orderId/upload-image/:imageId
            final url = "${ApiConstants.uploadOrderImage}/$orderId/upload-image/$imageId";
            final response = await DioClient().delete(url);
            if (response != null && response['success'] == true) {
              await refreshOrders();
              return;
            }
          } catch (e) {
            debugPrint("Error deleting image from server: $e");
          }
        }

        // Fallback: Local removal if no ID or API fails
        final currentImages = List<String>.from(order.pickedImages);
        final currentIds = List<String>.from(order.pickedImageIds);
        currentImages.removeAt(imageIndex);
        if (imageIndex < currentIds.length) currentIds.removeAt(imageIndex);

        _orders[index] = order.copyWith(pickedImages: currentImages, pickedImageIds: currentIds);
        notifyListeners();
      }
    }
  }

  Future<void> addOrderBundle(String orderId, dynamic bundle) async {
    debugPrint("--- CONSOLE: ADD BUNDLE (WEIGHT) START ---");
    
    final orderIndex = _orders.indexWhere((o) => o.orderId == orderId);
    if (orderIndex == -1) return;

    // Optimistic update: Add bundle locally
    final tempId = DateTime.now().millisecondsSinceEpoch.toString(); // Temporary ID for optimistic update
    final optimisticBundle = BundleModel(id: tempId, name: bundle.name ?? "Weight Bundle", weight: bundle.weight.toString(), price: bundle.price ?? 0);
    _orders[orderIndex] = _orders[orderIndex].copyWith(bundles: [..._orders[orderIndex].bundles, optimisticBundle]);
    notifyListeners();

    // Map bundle data to the same payload format as Per Piece items
    final payload = {
      "title": bundle.name ?? "Weight Bundle",
      "serviceType": (bundle.services is List && (bundle.services as List).isNotEmpty) ? bundle.services : ["Wash & Fold"],
      "unitType": "KG",
      "quantity": double.tryParse(bundle.weight.toString()) ?? 1,
      "unitPrice": bundle.price ?? 0,
    };

    try {
      final response = await DioClient().post(
        "${ApiConstants.orderItem}/$orderId/item",
        data: payload,
      );

      debugPrint("CONSOLE: Add Bundle Success Response: $response");
      if (response['success'] != true) {
        throw Exception("API failed to add bundle");
      } else {
        // If successful, refresh to get the actual ID and updated order details
        await refreshOrders(); 
      }
    } catch (e) {
      debugPrint("CONSOLE: Add Bundle Error: $e");
      _errorMessage = "Failed to add bundle: $e";
      notifyListeners();
    }
  }

  Future<void> removeOrderBundle(String orderId, int bundleIndex) async {
    debugPrint("--- CONSOLE: REMOVE BUNDLE START ---");
    final index = _orders.indexWhere((o) => o.orderId == orderId);
    if (index != -1) {
      final originalBundles = List<BundleModel>.from(_orders[index].bundles);
      final bundleToRemove = originalBundles[bundleIndex];

      // Optimistic update: Remove bundle locally
      final updatedBundles = List<BundleModel>.from(originalBundles)..removeAt(bundleIndex);
      _orders[index] = _orders[index].copyWith(bundles: updatedBundles);
      notifyListeners();

      try {
        if (bundleToRemove.id.isNotEmpty) {
          await deleteItemFromOrder(orderId, bundleToRemove.id); // Use existing delete item API
          await refreshOrders();
        }
      } catch (e) {
        // Revert optimistic update on failure
        if (index != -1) _orders[index] = _orders[index].copyWith(bundles: originalBundles);
        debugPrint("CONSOLE: Remove Bundle Error: $e");
      }
    }
  }

  void setSelectedFilter(String filter) {
    _selectedFilter = filter;
    notifyListeners();
  }

  Future<void> toggleOnlineStatus() async {
    final newStatus = !_isOnline;
    // Optimistic UI update
    _isOnline = newStatus;
    notifyListeners();

    try {
      // Use PUT to match the backend route defined in users.route.js
      final response = await DioClient().put(
        ApiConstants.onlineStatus,
        data: {"isOnline": newStatus},
      );

      if (response == null || response['success'] != true) {
        throw Exception("Failed to update status");
      }
    } catch (e) {
      _isOnline = !newStatus; // Revert on failure
      notifyListeners();
      debugPrint("Error updating online status: $e");
    }
  }

  Future<bool> sendDeliveryOtp(String orderId) async {
    try {
      final response = await DioClient().post(
        ApiConstants.deliverysendotp.replaceAll(':orderId', orderId),
      );
      return response != null && response['success'] == true;
    } catch (e) {
      debugPrint("sendDeliveryOtp Error: $e");
      return false;
    }
  }

  Future<bool> verifyDeliveryOtp(String orderId, String otp) async {
    try {
      final response = await DioClient().post(
        ApiConstants.deliveryverifyotp.replaceAll(':orderId', orderId),
        data: {"otp": otp},
      );
      if (response != null && response['success'] == true) {
        await refreshOrders();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("verifyDeliveryOtp Error: $e");
      return false;
    }
  }
}