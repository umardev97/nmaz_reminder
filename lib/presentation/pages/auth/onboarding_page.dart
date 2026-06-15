import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import '../../../core/styles.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/app_ui.dart';
import 'login_page.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _controller = PageController();
  int _index = 0;

  static const _pages = [
    (
      Icons.access_time_filled_rounded,
      'Never lose track of prayer',
      'Thoughtful reminders and a focused daily view keep every prayer close at hand.'
    ),
    (
      Icons.auto_graph_rounded,
      'Build a meaningful rhythm',
      'Mark prayers, reflect on your day, and see steady progress without the noise.'
    ),
    (
      Icons.family_restroom_rounded,
      'Grow with intention',
      'A calm private space for daily worship, routines, and family accountability.'
    ),
  ];

  void _continue() {
    if (_index < _pages.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
      return;
    }
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 12, 0),
              child: Row(
                children: [
                  const AppLogo(height: 52, compact: true),
                  const Spacer(),
                  TextButton(
                    onPressed: () => Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const LoginPage()),
                    ),
                    child: const Text('Skip'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (value) => setState(() => _index = value),
                itemBuilder: (context, index) {
                  final item = _pages[index];
                  return AppPage(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 210,
                          height: 210,
                          decoration: BoxDecoration(
                            gradient: AppGradients.premium,
                            borderRadius: BorderRadius.circular(44),
                            boxShadow: AppShadows.soft,
                          ),
                          child:
                              Icon(item.$1, color: AppColors.accent, size: 82),
                        ),
                        const SizedBox(height: 44),
                        Text(
                          item.$2,
                          style: Theme.of(context).textTheme.displaySmall,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          item.$3,
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        width: index == _index ? 26 : 8,
                        height: 8,
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        decoration: BoxDecoration(
                          color: index == _index
                              ? Theme.of(context).colorScheme.primary
                              : AppColors.divider,
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  FullWidthButton(
                    label: _index == _pages.length - 1
                        ? 'Get started'
                        : 'Continue',
                    onPressed: _continue,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
