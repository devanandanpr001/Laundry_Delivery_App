import 'package:flutter/material.dart';
import 'package:ziya_laundry_deliveryapp/features/Orders/data/repository/order_repository.dart';
import 'package:ziya_laundry_deliveryapp/features/Orders/data/model/order_model.dart';
import 'package:ziya_laundry_deliveryapp/features/Orders/viewmodel/DeliveryStage.dart';
import 'package:ziya_laundry_deliveryapp/features/Orders/data/model/Bundle_Model.dart';

class OrderViewModel extends ChangeNotifier {
  final OrderRepository _repository;
  OrderViewModel(this._repository);
  List<OrderModel> _orders = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<OrderModel> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Logic Getters for UI
  List<OrderModel> get pendingOrders => _orders.where((o) => o.status == OrderStatus.pending).toList();
  List<OrderModel> get assignedOrders => _orders.where((o) => o.status == OrderStatus.assigned).toList();
  List<OrderModel> get completedOrders => _orders.where((o) => o.status == OrderStatus.completed).toList();
  void clearAllCachedData() {
    _orders.clear();
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> fetchAllOrders() async {
    if (_isLoading) return;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final fetchedOrders = await _repository.getAllOrders();

      // Performance Optimized Merge: Use a Map for O(N) lookup instead of firstWhere.
      final Map<String, DeliveryStage> existingStages = {
        for (var o in _orders) "${o.orderId}_${o.orderType}": o.deliveryStage
      };

      _orders = fetchedOrders.map((newOrder) {
        final stage = existingStages["${newOrder.orderId}_${newOrder.orderType}"];
        return stage != null ? newOrder.copyWith(deliveryStage: stage) : newOrder;
      }).toList();
    } catch (e) {
      debugPrint("OrderViewModel Error fetching all orders: $e");
      _errorMessage = "Failed to load orders: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> acceptOrder(String orderId, OrderType orderType) async {
    if (_isLoading) return false;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final index = _orders.indexWhere((o) => o.orderId == orderId && o.orderType == orderType);
    if (index == -1) {
      _isLoading = false;
      notifyListeners();
      return false;
    }

    final currentOrder = _orders[index];
    final originalStatus = currentOrder.status;

    // Optimistic update
    _orders[index] = currentOrder.copyWith(
      status: OrderStatus.assigned,
      deliveryStage: orderType == OrderType.pickup ? DeliveryStage.startPickup : DeliveryStage.startDelivery,
    );
    notifyListeners();

    try {
      bool success = false;
      if (orderType == OrderType.pickup) {
        success = await _repository.acceptPickupOrder(orderId);
      } else {
        success = await _repository.acceptDeliveryOrder(orderId);
      }

      if (success) {
        await fetchAllOrders(); // Refresh to sync with server
        return true;
      } else {
        throw Exception("API failed to accept order");
      }
    } catch (e) {
      debugPrint("OrderViewModel: Failed to accept order: $e");
      _errorMessage = "Failed to accept order: $e";
      // Revert optimistic update on failure
      _orders[index] = currentOrder.copyWith(status: originalStatus, deliveryStage: currentOrder.deliveryStage);
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void toggleItemVerification(String orderId, String itemId) {
    final orderIndex = _orders.indexWhere((o) => o.orderId == orderId);
    if (orderIndex != -1) {
      final items = List<OrderItem>.from(_orders[orderIndex].items);
      final itemIndex = items.indexWhere((i) => i.id == itemId);
      if (itemIndex != -1) {
        final originalItem = items[itemIndex];
        items[itemIndex] = originalItem.copyWith(isVerified: !originalItem.isVerified);
        _orders[orderIndex] = _orders[orderIndex].copyWith(items: items);
        notifyListeners();
      }
    }
  }

  Future<void> deleteItemFromOrder(String orderId, String itemId) async {
    debugPrint("--- CONSOLE: DELETE ITEM START ---");
    debugPrint("OrderId: $orderId, ItemId: $itemId");

    final orderIndex = _orders.indexWhere((o) => o.orderId == orderId);
    if (orderIndex == -1) return;

    final originalItems = List<OrderItem>.from(_orders[orderIndex].items);
    // Optimistic update: Remove item locally
    final updatedItems = originalItems.where((item) => item.id != itemId).toList();
    _orders[orderIndex] = _orders[orderIndex].copyWith(items: updatedItems);
    notifyListeners();

    try {
      await _repository.deleteItemFromOrder(orderId, itemId);
      await fetchAllOrders(); // Refresh to sync totals and backend state
    } catch (e) {
      debugPrint("CONSOLE: Delete Error: $e");
      _errorMessage = "Failed to remove item: $e";
      // Revert optimistic update
      _orders[orderIndex] = _orders[orderIndex].copyWith(items: originalItems);
      notifyListeners();
      rethrow;
    }
  }

  Future<void> addItemToOrder(String orderId, OrderItem newItem, {double price = 0, String? serviceName, List<String>? serviceNames}) async {
    if (_isLoading) return;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    debugPrint("--- CONSOLE: ADD ITEM START ---");

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

    final orderIndex = _orders.indexWhere((o) => o.orderId == orderId);
    if (orderIndex == -1) {
      _isLoading = false;
      notifyListeners();
      return;
    }

    // Optimistic update
    final tempId = DateTime.now().millisecondsSinceEpoch.toString();
    final optimisticItem = newItem.copyWith(id: tempId, qty: payload['quantity'].toString());
    _orders[orderIndex] = _orders[orderIndex].copyWith(items: [..._orders[orderIndex].items, optimisticItem]);
    notifyListeners();

    try {
      await _repository.addItemToOrder(orderId, payload);
      await fetchAllOrders();
    } catch (e) {
      debugPrint("CONSOLE: Add Item Error: $e");
      _errorMessage = "Failed to add item: $e";
      // Revert optimistic update
      _orders[orderIndex] = _orders[orderIndex].copyWith(items: _orders[orderIndex].items.where((item) => item.id != tempId).toList());
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> reportItemMismatch(String orderId, String details) async {
    if (_isLoading) return false;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final orderIndex = _orders.indexWhere((o) => o.orderId == orderId);
      if (orderIndex == -1) {
        _isLoading = false;
        notifyListeners();
        return false;
      }
      // Optimistic update
      _orders[orderIndex] = _orders[orderIndex].copyWith(mismatchReason: details);
      notifyListeners();

      final success = await _repository.reportItemMismatch(orderId, details);
      if (success) {
        return true;
      }
      throw Exception("API failed to report mismatch");
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
    _errorMessage = null;
    notifyListeners();
    try {
      final orderIndex = _orders.indexWhere((o) => o.orderId == orderId);
      if (orderIndex == -1) {
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final originalStatus = _orders[orderIndex].status;
      // Optimistic update
      _orders[orderIndex] = _orders[orderIndex].copyWith(status: OrderStatus.completed);
      notifyListeners();

      final success = await _repository.confirmPickupOrder(orderId);
      if (success) {
        await fetchAllOrders(); // Professional sync: get final OrderStatus.completed from server
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
    _errorMessage = null;
    notifyListeners();
    try {
      final orderIndex = _orders.indexWhere((o) => o.orderId == orderId);
      if (orderIndex == -1) {
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Optimistic update
      _orders[orderIndex] = _orders[orderIndex].copyWith(isVerified: true);
      notifyListeners();

      await _repository.verifyOrder(orderId);
      // No need to refreshOrders, local state is already updated
    } catch (e) {
      // Revert optimistic update on failure
      final orderIndex = _orders.indexWhere((o) => o.orderId == orderId);
      if (orderIndex != -1) _orders[orderIndex] = _orders[orderIndex].copyWith(isVerified: false);
      debugPrint("CONSOLE: Verify Error: $e");

      // If the server says the order is already verified, sync the local state by refreshing.
      if (e.toString().toLowerCase().contains("already verified")) {
        await fetchAllOrders();
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
  }

  Future<void> addOrderImages(String orderId, List<String> images) async {
    debugPrint("--- CONSOLE: UPLOAD IMAGES START ---");
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final orderIndex = _orders.indexWhere((o) => o.orderId == orderId);
    if (orderIndex == -1) {
      _isLoading = false;
      notifyListeners();
      return;
    }

    final originalImages = List<String>.from(_orders[orderIndex].pickedImages);
    final originalImageIds = List<String>.from(_orders[orderIndex].pickedImageIds);

    // Optimistic update: Add local paths to pickedImages
    _orders[orderIndex] = _orders[orderIndex].copyWith(pickedImages: [...originalImages, ...images]);
    notifyListeners();

    try {
      final List<String> newImageUrls = [];
      final List<String> newImageIds = [];

      for (final path in images) {
        final result = await _repository.uploadOrderImage(orderId, path);
        if (result != null) {
          newImageUrls.add(result['imageUrl']!);
          newImageIds.add(result['id']!);
        } else {
          throw Exception("Failed to upload image: $path");
        }
      }

      // Update local state with actual URLs and IDs
      final currentImages = List<String>.from(_orders[orderIndex].pickedImages);
      final currentImageIds = List<String>.from(_orders[orderIndex].pickedImageIds);

      // Replace temporary local paths with actual URLs
      for (int i = 0; i < images.length; i++) {
        final indexToUpdate = currentImages.indexOf(images[i]);
        if (indexToUpdate != -1 && i < newImageUrls.length) {
          currentImages[indexToUpdate] = newImageUrls[i];
        }
      }
      _orders[orderIndex] = _orders[orderIndex].copyWith(
        pickedImages: currentImages,
        pickedImageIds: [...currentImageIds, ...newImageIds],
      );
      notifyListeners();
    } catch (e) {
      debugPrint("CONSOLE: Upload Error: $e");
      _errorMessage = "Failed to upload images: $e";
      // Revert optimistic update
      _orders[orderIndex] = _orders[orderIndex].copyWith(pickedImages: originalImages, pickedImageIds: originalImageIds);
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> removeOrderImage(String orderId, int imageIndex) async {
    final index = _orders.indexWhere((o) => o.orderId == orderId);
    if (index != -1) {
      final order = _orders[index];
      if (imageIndex < order.pickedImages.length) {
        final imageId = (order.pickedImageIds.length > imageIndex) ? order.pickedImageIds[imageIndex] : '';

        final currentImages = List<String>.from(order.pickedImages);
        final currentIds = List<String>.from(order.pickedImageIds);

        // Optimistic update
        currentImages.removeAt(imageIndex);
        if (imageIndex < currentIds.length) currentIds.removeAt(imageIndex);
        _orders[index] = order.copyWith(pickedImages: currentImages, pickedImageIds: currentIds);
        notifyListeners();

        if (imageId.isNotEmpty) {
          try {
            await _repository.deleteOrderImage(orderId, imageId);
            await fetchAllOrders(); // Refresh to ensure full sync
          } catch (e) {
            debugPrint("Error deleting image from server: $e");
            _errorMessage = "Failed to delete image: $e";
            // Revert optimistic update
            _orders[index] = order;
            notifyListeners();
          }
        }
      }
    }
  }

  Future<void> addOrderBundle(String orderId, dynamic bundle) async {
    debugPrint("--- CONSOLE: ADD BUNDLE (WEIGHT) START ---");
    if (_isLoading) return;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final orderIndex = _orders.indexWhere((o) => o.orderId == orderId);
    if (orderIndex == -1) {
      _isLoading = false;
      notifyListeners();
      return;
    }

    // Optimistic update
    final tempId = DateTime.now().millisecondsSinceEpoch.toString();
    final optimisticBundle = BundleModel(id: tempId, name: bundle.name ?? "Weight Bundle", weight: bundle.weight.toString(), price: bundle.price ?? 0);
    _orders[orderIndex] = _orders[orderIndex].copyWith(bundles: [..._orders[orderIndex].bundles, optimisticBundle]);
    notifyListeners();

    final payload = {
      "title": bundle.name ?? "Weight Bundle",
      "serviceType": (bundle.services is List && (bundle.services as List).isNotEmpty) ? bundle.services : ["Wash & Fold"],
      "unitType": "KG",
      "quantity": double.tryParse(bundle.weight.toString()) ?? 1,
      "unitPrice": bundle.price ?? 0,
    };

    try {
      await _repository.addOrderBundle(orderId, payload);
      await fetchAllOrders();
    } catch (e) {
      debugPrint("CONSOLE: Add Bundle Error: $e");
      _errorMessage = "Failed to add bundle: $e";
      // Revert optimistic update
      _orders[orderIndex] = _orders[orderIndex].copyWith(bundles: _orders[orderIndex].bundles.where((b) => b.id != tempId).toList());
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> removeOrderBundle(String orderId, int bundleIndex) async {
    debugPrint("--- CONSOLE: REMOVE BUNDLE START ---");
    final index = _orders.indexWhere((o) => o.orderId == orderId);
    if (index != -1) {
      final originalBundles = List<BundleModel>.from(_orders[index].bundles);
      final bundleToRemove = originalBundles[bundleIndex];

      // Optimistic update
      final updatedBundles = List<BundleModel>.from(originalBundles)..removeAt(bundleIndex);
      _orders[index] = _orders[index].copyWith(bundles: updatedBundles);
      notifyListeners();

      try {
        if (bundleToRemove.id.isNotEmpty) {
          await _repository.deleteItemFromOrder(orderId, bundleToRemove.id); // Use existing delete item API
          await fetchAllOrders();
        }
      } catch (e) {
        // Revert optimistic update on failure
        if (index != -1) _orders[index] = _orders[index].copyWith(bundles: originalBundles);
        debugPrint("CONSOLE: Remove Bundle Error: $e");
        _errorMessage = "Failed to remove bundle: $e";
        notifyListeners();
      }
    }
  }

  Future<bool> sendDeliveryOtp(String orderId) async {
    _errorMessage = null;
    notifyListeners();
    try {
      final success = await _repository.sendDeliveryOtp(orderId);
      if (!success) throw Exception("API failed to send OTP");
      return true;
    } catch (e) {
      debugPrint("sendDeliveryOtp Error: $e");
      _errorMessage = "Failed to send OTP: $e";
      notifyListeners();
      return false;
    }
  }

  Future<bool> verifyDeliveryOtp(String orderId, String otp) async {
    _errorMessage = null;
    notifyListeners();
    try {
      final success = await _repository.verifyDeliveryOtp(orderId, otp);
      if (success) {
        await fetchAllOrders(); // Refresh to get the updated status
        return true;
      }
      throw Exception("API failed to verify OTP");
    } catch (e) {
      debugPrint("verifyDeliveryOtp Error: $e");
      _errorMessage = "Failed to verify OTP: $e";
      notifyListeners();
      return false;
    }
  }

  // Clear error message after it's shown in the UI
  void clearErrorMessage() {
    _errorMessage = null;
    notifyListeners();
  }
}