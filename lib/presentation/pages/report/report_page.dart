import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/app_utils.dart';
import '../../../core/theme.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../features/report/models/report_model.dart';
import '../../../features/report/providers/report_provider.dart';
import '../../widgets/app_ui.dart';
import 'reflections_page.dart';

class ReportPage extends ConsumerStatefulWidget {
  const ReportPage({super.key, this.embedded = false});
  final bool embedded;

  @override
  ConsumerState<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends ConsumerState<ReportPage> {
  final _visited = TextEditingController();
  final _work = TextEditingController();
  final _islamic = TextEditingController();
  final _notes = TextEditingController();
  String _mood = 'Good';
  bool _loading = false;

  @override
  void dispose() {
    _visited.dispose();
    _work.dispose();
    _islamic.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(firebaseUserProvider).asData?.value;
    if (user == null) {
      return const Scaffold(
        body: AppStateView(
            title: 'Sign in required',
            message: 'Sign in to save a daily reflection.'),
      );
    }
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: !widget.embedded,
        title: const Text('Daily reflection'),
        actions: [
          IconButton(
            tooltip: 'My reflections',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ReflectionsPage()),
            ),
            icon: const Icon(Icons.history_edu_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: AppPage(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Make space for today',
                  style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 8),
              Text(
                'A short reflection helps turn daily moments into meaningful progress.',
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 26),
              Text('How did today feel?',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ['Excellent', 'Good', 'Average', 'Poor'].map((mood) {
                  return ChoiceChip(
                    label: Text(mood),
                    selected: _mood == mood,
                    onSelected: (_) => setState(() => _mood = mood),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              _ReflectionField(
                  controller: _visited,
                  label: 'Where did you go?',
                  icon: Icons.place_outlined),
              const SizedBox(height: 14),
              _ReflectionField(
                  controller: _work,
                  label: 'What did you accomplish?',
                  icon: Icons.work_outline_rounded),
              const SizedBox(height: 14),
              _ReflectionField(
                  controller: _islamic,
                  label: 'Islamic activities',
                  icon: Icons.mosque_outlined),
              const SizedBox(height: 14),
              _ReflectionField(
                  controller: _notes,
                  label: 'Anything else on your mind?',
                  icon: Icons.notes_rounded,
                  lines: 4),
              const SizedBox(height: 24),
              FullWidthButton(
                label: 'Save reflection',
                icon: Icons.check_rounded,
                loading: _loading,
                onPressed: () => _save(user.uid),
              ),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  'Saved privately to your account',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: AppColors.textSecondary),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ReflectionsPage()),
                  ),
                  icon: const Icon(Icons.history_edu_rounded),
                  label: const Text('View my reflections'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save(String uid) async {
    setState(() => _loading = true);
    final report = DailyReport(
      date: DateFormat('yyyy-MM-dd').format(DateTime.now()),
      visitedPlaces: _visited.text.trim(),
      workDone: _work.text.trim(),
      islamicActivities: _islamic.text.trim(),
      notes: _notes.text.trim(),
      mood: _mood,
    );
    try {
      await ref.read(saveReportProvider)(uid, report);
      ref.invalidate(reportsStreamProvider(uid));
      ref.invalidate(todayReportProvider(uid));
      if (!mounted) return;
      AppSnackBar.showSuccess(context, 'Today’s reflection has been saved');
      if (widget.embedded) {
        _visited.clear();
        _work.clear();
        _islamic.clear();
        _notes.clear();
        FocusScope.of(context).unfocus();
      } else {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (!mounted) return;
      AppSnackBar.showError(
        context,
        e,
        fallback: 'Could not save your reflection. Please try again.',
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}

class _ReflectionField extends StatelessWidget {
  const _ReflectionField(
      {required this.controller,
      required this.label,
      required this.icon,
      this.lines = 2});
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final int lines;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      minLines: lines,
      maxLines: lines,
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(
          labelText: label, alignLabelWithHint: true, prefixIcon: Icon(icon)),
    );
  }
}
