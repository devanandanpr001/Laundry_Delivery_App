import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:ziya_laundry_deliveryapp/features/AuthSection/View/LogIn_screen.dart';
import 'package:ziya_laundry_deliveryapp/features/AuthSection/viewmodel/login_viewmodel.dart';
import 'package:ziya_laundry_deliveryapp/features/AuthSection/viewmodel/SignUp_viewmodel.dart';
import 'package:ziya_laundry_deliveryapp/features/onBoarding/splash_screen.dart';
import 'package:ziya_laundry_deliveryapp/features/Orders/data/repository/service_repository.dart';
import 'package:ziya_laundry_deliveryapp/features/Home/viewmodel/home_viewmodel.dart';
import 'package:ziya_laundry_deliveryapp/features/Home/data/repository/home_repository.dart';
import 'package:ziya_laundry_deliveryapp/features/Home/data/service/home_service.dart';
import 'package:ziya_laundry_deliveryapp/features/Orders/data/repository/order_repository.dart';
import 'package:ziya_laundry_deliveryapp/features/Orders/data/service/order_service.dart';
import 'package:ziya_laundry_deliveryapp/features/Orders/viewmodel/order_viewmodel.dart';
import 'package:ziya_laundry_deliveryapp/features/Notification/data/repository/notification_repository.dart';
import 'package:ziya_laundry_deliveryapp/features/Notification/data/Service/notification_service.dart';
import 'package:ziya_laundry_deliveryapp/features/Notification/viewmodel/notification_viewmodel.dart';
import 'package:ziya_laundry_deliveryapp/features/Orders/data/service/service_service.dart';
import 'package:ziya_laundry_deliveryapp/features/Orders/viewmodel/service_viewmodel.dart';
import 'package:ziya_laundry_deliveryapp/features/Profile/data/repository/profile_repository.dart';
import 'package:ziya_laundry_deliveryapp/core/services/connectivity_service.dart';
import 'package:ziya_laundry_deliveryapp/core/connectivity_viewmodel.dart';
import 'package:ziya_laundry_deliveryapp/core/widgets/no_internet_connection_screen.dart';
import 'package:ziya_laundry_deliveryapp/features/Profile/data/service/help_support_service.dart';
import 'package:ziya_laundry_deliveryapp/features/Profile/data/service/profile_service.dart';
import 'package:ziya_laundry_deliveryapp/features/Profile/viewmodel/profile_viewmodel.dart';
import 'package:ziya_laundry_deliveryapp/features/Profile/data/repository/help_support_repository.dart';
import 'package:ziya_laundry_deliveryapp/features/Profile/viewmodel/help_support_controller.dart';
import 'package:ziya_laundry_deliveryapp/core/network/dio_client.dart';
import 'package:quick_popup_manager/quick_popup_manager.dart';
import 'package:ziya_laundry_deliveryapp/core/services/network_service.dart';
import 'package:ziya_laundry_deliveryapp/core/widgets/offline_indicator.dart';

class AppRouteObserver extends NavigatorObserver {
  final ValueNotifier<String?> currentRoute = ValueNotifier<String?>(null);

  void _updateRoute(Route<dynamic>? route) {
    if (route == null) {
      currentRoute.value = null;
      return;
    }

    final routeName = route.settings.name?.isNotEmpty == true
        ? route.settings.name!
        : route.runtimeType.toString();
    currentRoute.value = routeName;
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _updateRoute(route);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    _updateRoute(newRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    _updateRoute(previousRoute);
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NetworkService.instance.startMonitoring();
  await dotenv.load(fileName: ".env");
  runApp(riverpod.ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final AppRouteObserver _appRouteObserver = AppRouteObserver();

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
             
             // Profile Section Dependencies
             Provider(create: (_) => ProfileService()),
             ProxyProvider<ProfileService, ProfileRepository>(
               update: (_, service, previous) => previous ?? ProfileRepository(service),
             ),
             ChangeNotifierProxyProvider<ProfileRepository, ProfileViewModel>(
               create: (context) => ProfileViewModel(context.read<ProfileRepository>()),
               update: (context, repository, previous) => previous ?? ProfileViewModel(repository), // Fixed: Removed .updateRepository and simplified
             ),
             // Help & Support Dependencies
             Provider(create: (_) => HelpSupportService(DioClient())),
             ProxyProvider<HelpSupportService, HelpSupportRepository>(
               update: (_, service, previous) => previous ?? HelpSupportRepository(service),
             ),
             ChangeNotifierProxyProvider<HelpSupportRepository, HelpSupportController>(
               create: (context) => HelpSupportController(context.read<HelpSupportRepository>()),
               update: (_, repository, previous) => previous ?? HelpSupportController(repository),
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
             // Connectivity management
             Provider(create: (_) => ConnectivityService.instance),
             ChangeNotifierProxyProvider<ConnectivityService, ConnectivityViewModel>(
               create: (context) => ConnectivityViewModel(context.read<ConnectivityService>()),
               update: (_, service, previous) => previous ?? ConnectivityViewModel(service),
             ),
             // Service Section Dependencies (Moved from Orders to Services)
             Provider(create: (_) => ServiceService()),
             ProxyProvider<ServiceService, ServiceRepository>(
               update: (_, service, previous) => previous ?? ServiceRepository(service),
             ),

             // Adding dependencies for HomeViewModel
             Provider(create: (_) => HomeService()),
             ProxyProvider<HomeService, HomeRepository>(
               update: (_, service, previous) => previous ?? HomeRepository(service),
             ),
             ChangeNotifierProxyProvider3<HomeRepository, ProfileRepository, ServiceRepository, HomeViewModel>(
               create: (context) => HomeViewModel(context.read<HomeRepository>(), context.read<ProfileRepository>(), context.read<ServiceRepository>()),
               update: (context, homeRepo, profileRepo, serviceRepo, previous) => 
                   previous ?? HomeViewModel(homeRepo, profileRepo, serviceRepo),
             ),
             ChangeNotifierProxyProvider<ServiceRepository, ServiceViewModel>(
               create: (context) => ServiceViewModel(context.read<ServiceRepository>()),
               update: (_, repository, previous) => previous ?? ServiceViewModel(repository),
             ),

            Provider<NotificationService>(create: (_) => NotificationService.instance),
            ProxyProvider<NotificationService, NotificationRepository>(
              update: (_, service, previous) => previous ?? NotificationRepository(service),
            ),
            ChangeNotifierProxyProvider<NotificationRepository, NotificationViewModel>(
              create: (context) => NotificationViewModel(context.read<NotificationRepository>()),
              update: (_, repository, previous) => previous ?? NotificationViewModel(repository),
            ),
             ],
          child: OfflineIndicatorWrapper(
            navigatorKey: DioClient.navigatorKey,
            child: MaterialApp(
              navigatorKey: DioClient.navigatorKey,
              navigatorObservers: [QuickPopupNavigatorObserver(), _appRouteObserver],
              debugShowCheckedModeBanner: false,
              title: 'Ziya Laundry DeliveryApp',
              initialRoute: '/',
              routes: {
                '/': (context) => const SplashScreen(),
                '/login': (context) => const LoginScreen(),
              },
              builder: (context, child) => child!,
            ),
          ),
        );
      },
    );
  }
}
