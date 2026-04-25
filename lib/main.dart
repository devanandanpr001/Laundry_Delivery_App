import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:ziya_laundry_deliveryapp/AuthSection/View/LogIn_screen.dart';
import 'package:ziya_laundry_deliveryapp/AuthSection/viewmodel/login_viewmodel.dart';
import 'package:ziya_laundry_deliveryapp/AuthSection/viewmodel/SignUp_viewmodel.dart';
import 'package:ziya_laundry_deliveryapp/AuthSection/viewmodel/forgot_password_viewmodel.dart';
import 'package:ziya_laundry_deliveryapp/Home/viewmodel/home_viewmodel.dart';
import 'package:ziya_laundry_deliveryapp/Home/data/repository/home_repository.dart';
import 'package:ziya_laundry_deliveryapp/Home/data/service/home_service.dart';
import 'package:ziya_laundry_deliveryapp/Orders/data/service/order_service.dart';
import 'package:ziya_laundry_deliveryapp/Orders/data/repository/order_repository.dart';
import 'package:ziya_laundry_deliveryapp/Orders/viewmodel/order_viewmodel.dart';
import 'package:ziya_laundry_deliveryapp/Notification/data/repository/notification_repository.dart';
import 'package:ziya_laundry_deliveryapp/Notification/data/Service/notification_service.dart';
import 'package:ziya_laundry_deliveryapp/Notification/viewmodel/notification_viewmodel.dart';
import 'package:ziya_laundry_deliveryapp/Profile/data/repository/profile_repository.dart';
import 'package:ziya_laundry_deliveryapp/Profile/data/service/help_support_service.dart';
import 'package:ziya_laundry_deliveryapp/Profile/data/service/profile_service.dart';
import 'package:ziya_laundry_deliveryapp/Profile/viewmodel/profile_viewmodel.dart';
import 'package:ziya_laundry_deliveryapp/Profile/data/repository/help_support_repository.dart';
import 'package:ziya_laundry_deliveryapp/Profile/viewmodel/help_support_viewmodel.dart';
import 'package:ziya_laundry_deliveryapp/common_widgets/BottomNavigation/bottom_navigation_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812), 
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MultiProvider(
           providers: [
             ChangeNotifierProvider(create: (_) => LoginViewModel()),
             ChangeNotifierProvider(create: (_) => SignupViewModel()),
             ChangeNotifierProvider(create: (_) => ForgotPasswordViewModel()),
             
             // Profile Section Dependencies
             Provider(create: (_) => ProfileService()),
             ProxyProvider<ProfileService, ProfileRepository>(
               update: (_, service, previous) => previous ?? ProfileRepository(service),
             ),
             ChangeNotifierProxyProvider<ProfileRepository, ProfileViewModel>(
               create: (context) => ProfileViewModel(context.read<ProfileRepository>()),
               update: (_, repository, previous) => (previous ?? ProfileViewModel(repository))..updateRepository(repository),
             ),
             // Help & Support Dependencies
             Provider(create: (_) => HelpSupportService()),
             ProxyProvider<HelpSupportService, HelpSupportRepository>(
               update: (_, service, previous) => previous ?? HelpSupportRepository(service),
             ),
             ChangeNotifierProxyProvider<HelpSupportRepository, HelpSupportViewModel>(
               create: (context) => HelpSupportViewModel(context.read<HelpSupportRepository>()),
               update: (_, repository, previous) => previous ?? HelpSupportViewModel(repository),
             ),
             
             // Order Section Dependencies
             Provider(create: (_) => OrderService()),
             ProxyProvider<OrderService, OrderRepository>(
               update: (_, service, previous) => previous ?? OrderRepository(service),
             ),
             ChangeNotifierProxyProvider<OrderRepository, OrderViewModel>(
               create: (context) => OrderViewModel(context.read<OrderRepository>()),
               update: (_, repository, previous) => previous ?? OrderViewModel(repository),
             ),

             // Adding dependencies for HomeViewModel
             Provider(create: (_) => HomeService()),
             ProxyProvider<HomeService, HomeRepository>(
               update: (_, service, previous) => previous ?? HomeRepository(),
             ),
             ChangeNotifierProxyProvider<HomeRepository, HomeViewModel>(
               create: (context) => HomeViewModel(context.read<HomeRepository>()),
               update: (_, repository, previous) => previous ?? HomeViewModel(repository),
             ),

            Provider(create: (_) => NotificationService()),
            ProxyProvider<NotificationService, NotificationRepository>(
              update: (_, service, previous) => previous ?? NotificationRepository(service),
            ),
            ChangeNotifierProxyProvider<NotificationRepository, NotificationViewModel>(
              create: (context) => NotificationViewModel(context.read<NotificationRepository>()),
              update: (_, repository, previous) => previous ?? NotificationViewModel(repository),
            ),
             ],
          child: const MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Ziya Laundry DeliveryApp',
            home:  LoginScreen(),
          ),
        );
      },
    );
  }
}
