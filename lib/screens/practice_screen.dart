import 'package:flutter/material.dart';
import '../domain/academic/academic_models.dart';

class PracticeScreen extends StatefulWidget {
  const PracticeScreen({super.key, required this.practice});
  final LessonPractice practice;

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  int _index = 0;
  bool _completed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final task = widget.practice.tasks[_index];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: Text(widget.practice.title)),
        body: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            Text(
              'التطبيق ${_index + 1} من ${widget.practice.tasks.length}',
              style: theme.textTheme.labelLarge,
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  task.instruction,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
            if (_completed)
              Card(
                child: ListTile(
                  leading: Icon(Icons.check_circle_outline,
                      color: theme.colorScheme.primary),
                  title: const Text('اكتمل التطبيق',
                      style: TextStyle(fontWeight: FontWeight.w800)),
                  subtitle: const Text(
                    'تم تسجيل إكمال مرحلة التطبيق. لا تُحسب درجة أكاديمية دون وجود تقييم معرفي.',
                  ),
                ),
              )
            else
              FilledButton.icon(
                onPressed: () {
                  if (_index + 1 < widget.practice.tasks.length) {
                    setState(() => _index++);
                  } else {
                    setState(() => _completed = true);
                  }
                },
                icon: Icon(
                  _index + 1 < widget.practice.tasks.length
                      ? Icons.arrow_back
                      : Icons.check,
                ),
                label: Text(
                  _index + 1 < widget.practice.tasks.length
                      ? 'أكملت التطبيق'
                      : 'إنهاء التطبيق',
                ),
              ),
          ],
        ),
      ),
    );
  }
}
