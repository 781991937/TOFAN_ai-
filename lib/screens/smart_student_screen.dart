import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/learning/diagnostic_state.dart';
import '../application/learning/learning_state.dart';
import '../application/learning/progress_state.dart';
import '../application/student/student_state.dart';
import '../data/academic/academic_catalog.dart';

class SmartStudentScreen extends ConsumerWidget {
  const SmartStudentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(studentProfileProvider);
    final smart = ref.watch(smartStudentProvider);
    final plan = ref.watch(learningPlanProvider);
    final progress = ref.watch(learningProgressProvider);
    final overallProgress = ref.watch(learningProgressProvider.notifier).overallProgress();
    final diagnostic = ref.watch(diagnosticProvider);
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    if (profile == null) {
      return Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          appBar: AppBar(title: const Text('العبقري طوفان')),
          body: const Center(child: Text('أكمل ملفك الأكاديمي أولاً.')),
        ),
      );
    }

    final courses = AcademicCatalog.referenceUniversity.colleges
        .expand((college) => college.specializations)
        .expand((specialization) => specialization.years)
        .expand((year) => year.semesters)
        .expand((semester) => semester.courses)
        .where((course) => plan?.courseIds.contains(course.id) ?? false)
        .toList(growable: false);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('العبقري طوفان')),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: [
                    Container(
                      width: 52, height: 52,
                      decoration: BoxDecoration(
                        color: primary.withValues(alpha: .12),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(Icons.auto_awesome, color: primary, size: 28),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('حالة العبقري طوفان',
                              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
                          const SizedBox(height: 4),
                          Text('ملف يتطور مع التعلم والتقييم والتطبيق.',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('المعرفة والمهارات والقدرات',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: _Metric(title: 'المعرفة', value: smart.knowledgeLevel)),
                const SizedBox(width: 8),
                Expanded(child: _Metric(title: 'المهارات', value: smart.skillLevel)),
                const SizedBox(width: 8),
                Expanded(child: _Metric(title: 'القدرات', value: smart.capabilityLevel)),
              ],
            ),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: Icon(Icons.analytics_outlined, color: primary),
                title: Text(diagnostic == null ? 'التشخيص الأولي' : 'نتيجة التشخيص',
                    style: const TextStyle(fontWeight: FontWeight.w800)),
                subtitle: diagnostic == null
                    ? const Text('قياس أولي لبناء مسار تعلم مناسب.')
                    : Text('تم تحديث مؤشرات العبقري طوفان بعد التشخيص.'),
                trailing: TextButton(
                  onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const DiagnosticScreen())),
                  child: Text(diagnostic == null ? 'ابدأ' : 'إعادة'),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.timeline_outlined, color: primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('التقدم في التعلم',
                              style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w900)),
                          const SizedBox(height: 6),
                          LinearProgressIndicator(
                              value: overallProgress),
                          const SizedBox(height: 6),
                          Text(
                            (overallProgress * 100).toStringAsFixed(0) +
                                '% من دروس المكتبة المرجعية',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('خطة التعلم',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
            const SizedBox(height: 10),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: plan == null || courses.isEmpty
                    ? const Text('لا توجد مقررات مرتبطة بالملف الحالي بعد.')
                    : Column(
                        children: [
                          for (var i = 0; i < courses.length; i++)
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: CircleAvatar(
                                radius: 17,
                                child: Text((i + 1).toString()),
                              ),
                              title: Text(courses[i].name,
                                  style: const TextStyle(fontWeight: FontWeight.w800)),
                              subtitle: Text(courses[i].lessons.length.toString() + ' دروس'),
                              trailing: i == plan.currentCourseIndex
                                  ? Icon(Icons.play_circle_outline, color: primary)
                                  : const Icon(Icons.chevron_left),
                            ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.title, required this.value});
  final String title;
  final double value;

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
          child: Column(
            children: [
              Text(value.toStringAsFixed(0) + '%',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
              const SizedBox(height: 4),
              Text(title, style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 8),
              LinearProgressIndicator(value: value / 100, minHeight: 4),
            ],
          ),
        ),
      );
}

class DiagnosticScreen extends ConsumerStatefulWidget {
  const DiagnosticScreen({super.key});

  @override
  ConsumerState<DiagnosticScreen> createState() => _DiagnosticScreenState();
}

class _DiagnosticScreenState extends ConsumerState<DiagnosticScreen> {
  final Map<String, int> _answers = {};
  int _index = 0;
  static const options = [
    'لا أعرف / أحتاج البدء من الصفر',
    'محدود',
    'متوسط',
    'جيد',
    'متقدم',
  ];

  @override
  Widget build(BuildContext context) {
    final question = diagnosticQuestions[_index];
    final selected = _answers[question.id] ?? -1;
    final theme = Theme.of(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('التشخيص الذكي'),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(4),
            child: LinearProgressIndicator(
              value: (_index + 1) / diagnosticQuestions.length,
            ),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(18, 24, 18, 28),
          children: [
            Text('السؤال ' + (_index + 1).toString() + ' من ' +
                diagnosticQuestions.length.toString(),
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.primary, fontWeight: FontWeight.w800)),
            const SizedBox(height: 14),
            Text(question.text,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900, height: 1.35)),
            const SizedBox(height: 24),
            for (var value = 0; value < options.length; value++)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Card(
                  child: RadioListTile<int>(
                    value: value,
                    groupValue: selected,
                    onChanged: (answer) =>
                        setState(() => _answers[question.id] = answer ?? 0),
                    title: Text(options[value]),
                    activeColor: theme.colorScheme.primary,
                  ),
                ),
              ),
            const SizedBox(height: 10),
            FilledButton.icon(
              onPressed: selected < 0 ? null : _next,
              icon: Icon(_index == diagnosticQuestions.length - 1
                  ? Icons.check : Icons.arrow_back),
              label: Text(_index == diagnosticQuestions.length - 1
                  ? 'حفظ التشخيص' : 'التالي'),
            ),
          ],
        ),
      ),
    );
  }

  void _next() {
    if (_index < diagnosticQuestions.length - 1) {
      setState(() => _index++);
      return;
    }
    ref.read(diagnosticProvider.notifier).submit(_answers);
    Navigator.pop(context);
  }
}
