import 'package:flutter/material.dart';

import '../data/academic/academic_catalog.dart';
import '../utils/constants.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text(AppConstants.appName)),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
            children: [
              Text(
                'مرحباً بك في ' + AppConstants.productName,
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(
                'الطالب البشري والطالب الذكي يعملان كفريق واحد لبناء المعرفة والمهارات والقدرات.',
                style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 18),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    children: [
                      Icon(Icons.auto_awesome, size: 42, color: theme.colorScheme.primary),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('TOFAN AI', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                            const SizedBox(height: 4),
                            const Text('نواة الذكاء التي ستنسق التعلم والتقييم والمهارات والمشاريع عبر وكلاء متخصصين.'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text('مساحة الطالب', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),
              Card(
                child: ListTile(
                  leading: Icon(Icons.menu_book_outlined, size: 32, color: theme.colorScheme.primary),
                  title: const Text('المكتبة الأكاديمية', style: TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: const Text('جامعة ← كلية ← تخصص ← سنة ← فصل ← مقرر ← درس'),
                  trailing: const Icon(Icons.chevron_left),
                ),
              ),
              const SizedBox(height: 10),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(child: _Stat(value: AcademicCatalog.courseCount.toString(), label: 'مقررات')),
                      Expanded(child: _Stat(value: AcademicCatalog.lessonCount.toString(), label: 'دروس')),
                      const Expanded(child: _Stat(value: '1', label: 'تخصص مرجعي')),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text('دورة التعلم', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),
              const _LifecycleCard(),
            ],
          ),
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});
  final String value;
  final String label;
  @override
  Widget build(BuildContext context) => Column(children: [
    Text(value, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
    const SizedBox(height: 2),
    Text(label),
  ]);
}

class _LifecycleCard extends StatelessWidget {
  const _LifecycleCard();
  static const steps = [
    ('1', 'التعريف', Icons.person_outline),
    ('2', 'التشخيص', Icons.analytics_outlined),
    ('3', 'خطة التعلم', Icons.route_outlined),
    ('4', 'الدراسة والتطبيق', Icons.school_outlined),
    ('5', 'التقييم', Icons.assignment_outlined),
    ('6', 'تحديث المهارات', Icons.psychology_outlined),
    ('7', 'المشروع', Icons.rocket_launch_outlined),
  ];
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(children: [
        for (final step in steps) ListTile(
          dense: true,
          leading: CircleAvatar(radius: 15, child: Text(step.$1)),
          title: Text(step.$2),
          trailing: Icon(step.$3),
        ),
      ]),
    ),
  );
}