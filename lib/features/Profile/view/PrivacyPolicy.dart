import 'package:flutter/material.dart';
import 'package:ziya_laundry_deliveryapp/features/Profile/widgets/CmsPageWidget.dart';

class Privacypolicy extends StatelessWidget {
  const Privacypolicy({super.key});

  @override
  Widget build(BuildContext context) {
    return const CmsPageScreen(
      type: 'PRIVACY',
      title: 'Privacy Policy',
    );
  }
}
