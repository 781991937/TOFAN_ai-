import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/learning/assessment_state.dart';
import '../application/learning/learning_state.dart';
import '../domain/learning/analysis_models.dart';

class AssessmentResultScreen extends ConsumerWidget {
  const AssessmentResultScreen({super.key});

  void _continueLifecycle(BuildContext context, WidgetRef ref) {
    final controller = ref.read(learningSessionProvider.notifier);
    if (!ref.read(assessmentResultProvider)!.passed) {
      controller.retryAssessment();
      Navigator.pop(context);
      return;
    }
    controller.completeAnalysis();
    controller.completeSkillUpdate();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = ref.watch(assessmentResultProvider);
    final analysis = ref.watch(learningAnalysisProvider);
    final theme = Theme.of(context);

    if (result == null || analysis == null) {
      return Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          appBar: AppBar(title: const Text('نتيجة التقييم')),
          body: const Center(child: Text('لا توجد نتيجة متاحة.')),
        ),
      );
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('تحليل النتيجة')),
        body: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  children: [
                    Text(
                      result.percentage.toStringAsFixed(0) + '%',
                      style: theme.textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      result.passed ? 'تم اجتياز التقييم' : 'يحتاج إلى مراجعة',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            Card(
              child: ListTile(
                leading: Icon(Icons.insights_outlined,
                    color: theme.colorScheme.primary),
                title: Text(_label(analysis.performance),
                    style: const TextStyle(fontWeight: FontWeight.w800)),
                subtitle: Text(analysis.message),
              ),
            ),
            if (analysis.errorAnalysis.isNotEmpty) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('تحليل الأخطاء',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                          )),
                      const SizedBox(height: 8),
                      for (final item in analysis.errorAnalysis)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text('• $item'),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
            ],
            Card(
              child: Column(
                children: [
                  _DeltaRow('المعرفة', analysis.knowledgeDelta),
                  _DeltaRow('المهارات', analysis.skillDelta),
                  _DeltaRow('القدرات', analysis.capabilityDelta),
                ],
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () => _continueLifecycle(context, ref),
              icon: const Icon(Icons.arrow_back),
              label: Text(result.passed ? 'متابعة إلى مرحلة المشروع' : 'إعادة التدريب والتقييم'),
            ),
          ],
        ),
      ),
    );
  }

  String _label(LearningPerformance performance) {
    switch (performance) {
      case LearningPerformance.needsSupport:
        return 'يحتاج دعمًا';
      case LearningPerformance.developing:
        return 'في طور التطور';
      case LearningPerformance.proficient:
        return 'متقن';
      case LearningPerformance.advanced:
        return 'متقدم';
    }
  }
}

class _DeltaRow extends StatelessWidget {
  const _DeltaRow(this.title, this.value);
  final String title;
  final double value;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      trailing: Text(
        value == 0 ? 'بدون زيادة' : '+' + value.toStringAsFixed(0),
        style: TextStyle(
          fontWeight: FontWeight.w900,
          color: value == 0
              ? Theme.of(context).colorScheme.onSurfaceVariant
              : Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
