import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/learning/diagnostic_models.dart';
import '../student/student_state.dart';

const diagnosticQuestions = <DiagnosticQuestion>[
  DiagnosticQuestion(
    id: 'knowledge-1',
    text: 'ما مدى فهمك للمفاهيم الأساسية في تخصصك؟',
    dimension: DiagnosticDimension.knowledge,
  ),
  DiagnosticQuestion(
    id: 'knowledge-2',
    text: 'ما مدى قدرتك على شرح مفهوم دراسي بكلماتك الخاصة؟',
    dimension: DiagnosticDimension.knowledge,
  ),
  DiagnosticQuestion(
    id: 'skill-1',
    text: 'ما مدى قدرتك على تطبيق ما تعلمته في تمرين عملي؟',
    dimension: DiagnosticDimension.skill,
  ),
  DiagnosticQuestion(
    id: 'skill-2',
    text: 'ما مدى قدرتك على حل مشكلة جديدة باستخدام ما تعلمته؟',
    dimension: DiagnosticDimension.skill,
  ),
  DiagnosticQuestion(
    id: 'capability-1',
    text: 'ما مدى قدرتك على تنفيذ مهمة أو مشروع صغير بصورة مستقلة؟',
    dimension: DiagnosticDimension.capability,
  ),
  DiagnosticQuestion(
    id: 'capability-2',
    text: 'ما مدى قدرتك على اختيار الأدوات والخطوات المناسبة لإنجاز مهمة؟',
    dimension: DiagnosticDimension.capability,
  ),
];

final diagnosticProvider =
    NotifierProvider<DiagnosticController, DiagnosticResult?>(
  DiagnosticController.new,
);

class DiagnosticController extends Notifier<DiagnosticResult?> {
  @override
  DiagnosticResult? build() => null;

  void submit(Map<String, int> answers) {
    final normalized = <String, int>{
      for (final question in diagnosticQuestions)
        question.id: (answers[question.id] ?? 0).clamp(0, 4),
    };

    final knowledge = _averageFor(DiagnosticDimension.knowledge, normalized);
    final skill = _averageFor(DiagnosticDimension.skill, normalized);
    final capability =
        _averageFor(DiagnosticDimension.capability, normalized);

    state = DiagnosticResult(
      answers: Map.unmodifiable(normalized),
      knowledgeLevel: knowledge,
      skillLevel: skill,
      capabilityLevel: capability,
    );

    ref.read(smartStudentProvider.notifier).recordLearning(
          knowledgeDelta: knowledge,
          skillDelta: skill,
          capabilityDelta: capability,
        );
  }

  double _averageFor(
    DiagnosticDimension dimension,
    Map<String, int> answers,
  ) {
    final questions = diagnosticQuestions
        .where((question) => question.dimension == dimension)
        .toList(growable: false);

    if (questions.isEmpty) return 0;

    final total = questions.fold<int>(
      0,
      (sum, question) => sum + (answers[question.id] ?? 0),
    );

    return (total / (questions.length * 4) * 100)
        .clamp(0.0, 100.0)
        .toDouble();
  }
}
