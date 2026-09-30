import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/student/student_state.dart';
import '../domain/student/student_models.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _name = TextEditingController();
  final _university = TextEditingController(text: 'جامعة صنعاء');
  final _college = TextEditingController(text: 'كلية الحاسوب وتكنولوجيا المعلومات');
  final _specialization = TextEditingController(text: 'الذكاء الاصطناعي');

  @override
  void dispose() {
    _name.dispose();
    _university.dispose();
    _college.dispose();
    _specialization.dispose();
    super.dispose();
  }

  void _save() {
    final name = _name.text.trim();
    if (name.isEmpty) return;

    ref.read(studentProfileProvider.notifier).state = StudentProfile(
      name: name,
      university: _university.text.trim(),
      college: _college.text.trim(),
      specialization: _specialization.text.trim(),
      currentYear: 1,
      currentSemester: 1,
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('الملف الأكاديمي')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('تعريف المستخدم', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            const Text('هذه البيانات تصبح جزءاً من السياق الذي يستخدمه العبقري طوفان لمساندة رحلة التعلم.'),
            const SizedBox(height: 20),
            TextField(controller: _name, decoration: const InputDecoration(labelText: 'الاسم')),
            const SizedBox(height: 12),
            TextField(controller: _university, decoration: const InputDecoration(labelText: 'الجامعة')),
            const SizedBox(height: 12),
            TextField(controller: _college, decoration: const InputDecoration(labelText: 'الكلية / المركز')),
            const SizedBox(height: 12),
            TextField(controller: _specialization, decoration: const InputDecoration(labelText: 'التخصص')),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.check),
              label: const Text('حفظ الملف'),
            ),
          ],
        ),
      ),
    );
  }
}
