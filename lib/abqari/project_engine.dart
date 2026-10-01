import '../data/academic/academic_catalog.dart';
import '../domain/academic/academic_models.dart';
import 'academic_knowledge_engine.dart';
import 'abqari_models.dart';
import 'knowledge_graph.dart';
import 'learning_gap_engine.dart';

class AbqariProjectEngine {
  const AbqariProjectEngine({this.knowledgeEngine = const AcademicKnowledgeEngine(), this.knowledgeGraph = const AbqariKnowledgeGraph(), this.learningGapEngine = const AbqariLearningGapEngine()});
  final AcademicKnowledgeEngine knowledgeEngine;
  final AbqariKnowledgeGraph knowledgeGraph;
  final AbqariLearningGapEngine learningGapEngine;

  AbqariProjectPlan plan(AbqariProjectRequest request) {
    final knowledge = knowledgeEngine.search(request.idea);
    final gap = learningGapEngine.analyze(request.idea);
    final disciplines = _disciplines(request.idea, knowledge);
    final skills = <String>{for (final item in knowledge) ...item.skillIds}.toList();
    final sourceCourseIds = knowledge.map((item) => item.courseId).where((id) => id.isNotEmpty).toSet().toList(growable: false);
    final sourceProjectTitles = <String>{for (final item in knowledge) ...item.projectTitles}.toList(growable: false);
    final sourceLessonIds = knowledge.map((item) => item.lessonId).where((id) => id.isNotEmpty).toSet().toList(growable: false);
    final sourceKnowledgeUnitIds = <String>{for (final item in knowledge) ...item.knowledgeUnitIds}.toList(growable: false);
    final matchedProjects = _matchedProjects(sourceCourseIds, sourceProjectTitles);
    return AbqariProjectPlan(
      idea: request.idea,
      requirements: ['تحديد الهدف ومعيار النجاح: ' + request.idea, 'تحديد المدخلات والمخرجات والقيود.', 'تحديد المخاطر وحالات الفشل قبل التنفيذ.'],
      disciplines: disciplines,
      knowledge: knowledge,
      skills: skills,
      knowledgeGaps: gap.missing ? ['لا توجد معرفة مطابقة في المكتبة بعد؛ يجب التعلم أو إضافة محتوى أكاديمي قبل التنفيذ.'] : const [],
      phases: const ['تحليل المتطلبات', 'تصميم المعمارية', 'تحديد المكونات والواجهات', 'التنفيذ البرمجي', 'المحاكاة داخل الحاسوب', 'الاختبار وتحليل الأخطاء', 'التصحيح وإعادة الاختبار', 'توثيق المشروع وتحديث الخبرة'],
      softwareOutputs: const ['مخطط معماري', 'هيكل مشروع برمجي', 'كود قابل للاختبار', 'اختبارات آلية ومحاكاة عند توفر نموذج برمجي', 'تقرير نتائج وأخطاء'],
      physicalComponents: _physicalComponents(request.idea),
      sourceCourseIds: sourceCourseIds,
      sourceProjectTitles: sourceProjectTitles,
      sourceLessonIds: sourceLessonIds,
      sourceKnowledgeUnitIds: sourceKnowledgeUnitIds,
      sourceProjectRequirements: _flattenProjects(matchedProjects, (project) => project.requirements),
      sourceImplementationTasks: _flattenProjects(matchedProjects, (project) => project.implementationTasks),
      sourceTestCases: _flattenProjects(matchedProjects, (project) => project.testCases),
      sourceEvidenceRequirements: _flattenProjects(matchedProjects, (project) => project.evidenceRequirements),
    );
  }


  List<AcademicProject> _matchedProjects(
    List<String> courseIds,
    List<String> projectTitles,
  ) {
    final projects = <AcademicProject>[];
    final wantedCourses = courseIds.toSet();
    final wantedTitles = projectTitles.toSet();
    for (final university in AcademicCatalog.universities) {
      for (final college in university.colleges) {
        for (final specialization in college.specializations) {
          for (final year in specialization.years) {
            for (final semester in year.semesters) {
              for (final course in semester.courses) {
                if (!wantedCourses.contains(course.id)) continue;
                for (final project in [
                  ...course.projects,
                  ...course.lessons.expand((lesson) => lesson.projects),
                ]) {
                  if (wantedTitles.contains(project.title) || wantedTitles.isEmpty) {
                    projects.add(project);
                  }
                }
              }
            }
          }
        }
      }
    }
    final seen = <String>{};
    return projects.where((project) => seen.add(project.id)).toList(growable: false);
  }

  List<String> _flattenProjects(
    List<AcademicProject> projects,
    List<String> Function(AcademicProject project) select,
  ) =>
      {
        for (final project in projects) ...select(project),
      }.toList(growable: false);

  List<String> _disciplines(String idea, List<AbqariKnowledgeItem> knowledge) {
    final text = idea + ' ' + knowledge.map((e) => e.title).join(' ');
    final result = <String>['هندسة البرمجيات'];
    void add(String value, List<String> terms) { if (terms.any(text.contains)) result.add(value); }
    add('الذكاء الاصطناعي', ['ذكاء اصطناعي', 'تعلم آلي', 'رؤية حاسوبية', 'وكيل']);
    add('إنترنت الأشياء والأنظمة المضمنة', ['iot', 'إنترنت الأشياء', 'مضمنة', 'embedded', 'حساس']);
    add('الشبكات', ['شبكة', 'network', 'اتصال']);
    add('قواعد البيانات', ['قاعدة بيانات', 'database', 'بيانات']);
    add('الأمن السيبراني', ['أمن', 'تشفير', 'security', 'مصادقة']);
    add('الروبوتات والتحكم', ['روبوت', 'مركبة', 'تحكم', 'actuator']);
    return result.toSet().toList(growable: false);
  }

  List<String> _physicalComponents(String idea) {
    final text = idea.toLowerCase();
    final result = <String>[];
    if (['باب', 'نافذة', 'حريق', 'حساس', 'منزل'].any(text.contains)) result.addAll(['حساسات مناسبة', 'وحدة تحكم', 'مشغلات كهربائية', 'مصدر طاقة', 'وسائل اتصال']);
    if (['مركبة', 'سيارة', 'روبوت'].any(text.contains)) result.addAll(['حساسات موقع/مسافة حسب التصميم', 'وحدة معالجة', 'مشغلات الحركة', 'مصدر طاقة', 'وسائل اتصال']);
    return result.toSet().toList(growable: false);
  }
}