import 'package:ziya_laundry_deliveryapp/Home/data/service/home_service.dart';
import 'package:ziya_laundry_deliveryapp/Home/data/model/home_models.dart';
import 'package:ziya_laundry_deliveryapp/Orders/data/model/Bundle_Model.dart';
import 'package:ziya_laundry_deliveryapp/Orders/viewmodel/DeliveryStage.dart';
import 'package:ziya_laundry_deliveryapp/Constants/app_images.dart';

class HomeRepository {
  final HomeService _service;

  HomeRepository(this._service);

  Future<List<OrderModel>> getOrders() async {
    await _service.fetchOrdersFromApi();
    
    return [
      // --- 4 PICK UP ORDERS ---
      OrderModel(
        orderId: "#ORD-5001",
        name: "Rahul Sharma",
        by: "By Weight",
        address: "Apt 4B, Skyview Residency, Kochi",
        isPaid: false,
        status: OrderStatus.pending,
        orderType: OrderType.pickup,
        pickedImages: [
          AppImages.signupBg,
          AppImages.loginBg,
        ],
        items: [OrderItem(name: 'General Wash', qty: '5kg')],
      ),
      OrderModel(
        orderId: "#ORD-5002",
        name: "Sneha Kapoor",
        by: "Per Piece",
        address: "Flat 102, Green Valley, Sector 15",
        isPaid: false,
        status: OrderStatus.pending,
        orderType: OrderType.pickup,
        items: [OrderItem(name: 'Silk Saree', qty: '2')],
      ),
      OrderModel(
        orderId: "#ORD-5003",
        name: "Amit Patel",
        by: "By Weight",
        address: "House No 23, Rose Gardens, MG Road",
        isPaid: true,
        status: OrderStatus.pending,
        orderType: OrderType.pickup,
        pickedImages: [
          AppImages.defaultProfile,
          AppImages.signupBg,
        ],
        items: [],
      ),
      OrderModel(
        orderId: "#ORD-5004",
        name: "Priya Das",
        by: "Per Piece",
        address: "Lakeview Apartments, Block C, Room 405",
        isPaid: false,
        status: OrderStatus.pending,
        orderType: OrderType.pickup,
        items: [OrderItem(name: 'Bedsheet', qty: '4')],
      ),

      // --- 4 DELIVERY ORDERS ---
      OrderModel(
        orderId: "#ORD-4001",
        name: "Vikram Singh",
        by: "By Weight",
        address: "Villa 9, Palm Meadows, Outer Ring Road",
        isPaid: true,
        status: OrderStatus.pending,
        orderType: OrderType.delivery,
        deliveryStage: DeliveryStage.startDelivery,
        bundles: [
          BundleModel(id: 1, price: 450.0, services: ["Wash & Fold", "Ironing"]),
        ],
        pickedImages: [
          AppImages.loginBg,
          AppImages.signupBg,
        ],
        items: [],
      ),
      OrderModel(
        orderId: "#ORD-4002",
        name: "Anjali Menon",
        by: "Per Piece",
        address: "Harmony Heights, 12th Floor, Hebbal",
        isPaid: true,
        status: OrderStatus.pending,
        orderType: OrderType.delivery,
        deliveryStage: DeliveryStage.startDelivery,
        items: [OrderItem(name: 'Jeans', qty: '6')],
      ),
      OrderModel(
        orderId: "#ORD-4003",
        name: "Suresh Kumar",
        by: "By Weight",
        address: "No 14, 5th Cross, Indiranagar",
        isPaid: false,
        status: OrderStatus.pending,
        orderType: OrderType.delivery,
        deliveryStage: DeliveryStage.startDelivery,
        bundles: [
          BundleModel(id: 2, price: 320.0, services: ["Premium ironing"]),
        ],
        pickedImages: [
          AppImages.signupBg,
          AppImages.defaultProfile,
        ],
        items: [],
      ),
      OrderModel(
        orderId: "#ORD-4004",
        name: "Megha Rao",
        by: "Per Piece",
        address: "Sun City Layout, Plot 88, Sarjapur",
        isPaid: true,
        status: OrderStatus.pending,
        orderType: OrderType.delivery,
        deliveryStage: DeliveryStage.startDelivery,
        items: [OrderItem(name: 'Curtains', qty: '2')],
      ),
    ];
  }

  Future<bool> updateStatus(String id, OrderStatus status) async {
    return await _service.updateOrderStatusOnApi(id, status.name);
  }

  Future<bool> getInitialOnlineStatus() async => await _service.getOnlineStatusFromApi();
}