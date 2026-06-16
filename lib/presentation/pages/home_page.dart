// ignore_for_file: unused_element

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'dart:ui';
import '../../core/theme.dart';
import '../../core/styles.dart';
import '../../core/app_utils.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/intention/models/daily_intention.dart';
import '../../features/intention/providers/intention_provider.dart';
import '../../features/prayer/providers/prayer_provider.dart';
import '../widgets/app_logo.dart';
import '../widgets/app_ui.dart';
import 'dashboard/dashboard.dart';
import 'prayer/prayer_page.dart';
import 'profile/profile_page.dart';
import 'report/report_page.dart';
import 'settings/notification_settings_page.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      const DashboardView(),
      const PrayerPage(embedded: true),
      const ReportPage(embedded: true),
      const ProfilePage(),
    ];
    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.access_time_outlined),
            selectedIcon: Icon(Icons.access_time_filled_rounded),
            label: 'Prayers',
          ),
          NavigationDestination(
            icon: Icon(Icons.edit_note_outlined),
            selectedIcon: Icon(Icons.edit_note_rounded),
            label: 'Reflect',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}


