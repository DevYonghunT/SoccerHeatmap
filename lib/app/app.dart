import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import 'routes.dart';

class KickoffApp extends StatelessWidget {
  const KickoffApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'KICKOFF',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: appRouter,
    );
  }
}
