import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/learning/assessment_state.dart';
import '../domain/academic/academic_models.dart';
import 'assessment_result_screen.dart';

class AssessmentScreen extends ConsumerStatefulWidget {
  const AssessmentScreen({super.key, required this.assessment});
  final LessonAssessment assessment;

  @override
  ConsumerState<AssessmentScreen> createState() => _AssessmentScreenState();
}

class _AssessmentScreenState extends ConsumerState<AssessmentScreen> {
  final Map<String, int> answers = {};
  int index = 0;

  @override
  Widget build(BuildContext context) {
    final q = widget.assessment.questions[index];
    final selected = answers[q.id];
    final theme = Theme.of(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.assessment.title),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(4),
            child: LinearProgressIndicator(
              value: (index + 1) / widget.assessment.questions.length,
            ),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            Text(
              'السؤال ' + (index + 1).toString() + ' من ' +
                  widget.assessment.questions.length.toString(),
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 14),
            Text(q.text,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  height: 1.35,
                )),
            const SizedBox(height: 20),
            for (var i = 0; i < q.options.length; i++)
              Card(
                child: RadioListTile<int>(
                  value: i,
                  groupValue: selected,
                  onChanged: (v) => setState(() => answers[q.id] = v ?? 0),
                  title: Text(q.options[i]),
                ),
              ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: selected == null ? null : _next,
              child: Text(index == widget.assessment.questions.length - 1
                  ? 'إنهاء التقييم'
                  : 'التالي'),
            ),
          ],
        ),
      ),
    );
  }

  void _next() {
    if (index < widget.assessment.questions.length - 1) {
      setState(() => index++);
      return;
    }

    var score = 0;
    for (final q in widget.assessment.questions) {
      if (answers[q.id] == q.correctIndex) score++;
    }

    ref.read(assessmentResultProvider.notifier).submit(
      assessmentId: widget.assessment.id,
      score: score,
      total: widget.assessment.questions.length,
    );
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const AssessmentResultScreen()),
    );
  }
}
