import '../../domain/academic/academic_models.dart';

/// Reference catalog for the global TOFAN AI STUDENT library.
/// The data model is independent from any single university.
class AcademicCatalog {
  const AcademicCatalog._();

  static const universities = <AcademicUniversity>[
    AcademicUniversity(
      id: 'sanaa',
      name: 'جامعة صنعاء',
      colleges: [
        AcademicCollege(
          id: 'computer',
          name: 'كلية الحاسوب وتكنولوجيا المعلومات',
          specializations: [
            AcademicSpecialization(
              id: 'ai',
              name: 'الذكاء الاصطناعي',
              years: [
                AcademicYear(
                  number: 1,
                  semesters: [
                    AcademicSemester(
                      number: 1,
                      courses: [
                        AcademicCourse(
                          id: 'python',
                          name: 'أساسيات البرمجة — Python',
                          lessons: [
                            AcademicLesson(id: 'python-1', title: 'مقدمة في Python'),
                            AcademicLesson(id: 'python-2', title: 'المتغيرات وأنواع البيانات'),
                            AcademicLesson(id: 'python-3', title: 'الإدخال والعمليات الحسابية'),
                          ],
                        ),
                        AcademicCourse(
                          id: 'discrete-math',
                          name: 'الرياضيات المتقطعة',
                          lessons: [
                            AcademicLesson(id: 'sets', title: 'المجموعات'),
                            AcademicLesson(id: 'relations', title: 'العلاقات'),
                          ],
                        ),
                        AcademicCourse(
                          id: 'ai-intro',
                          name: 'مقدمة في الذكاء الاصطناعي',
                          lessons: [
                            AcademicLesson(id: 'ai-foundations', title: 'مفاهيم الذكاء الاصطناعي'),
                            AcademicLesson(id: 'ai-agents', title: 'الوكلاء الأذكياء'),
                          ],
                        ),
                      ],
                    ),
                    AcademicSemester(
                      number: 2,
                      courses: [
                        AcademicCourse(
                          id: 'data-structures',
                          name: 'هياكل البيانات',
                          lessons: [
                            AcademicLesson(id: 'arrays', title: 'المصفوفات والقوائم'),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  ];

  static AcademicUniversity get referenceUniversity => universities.first;

  static int get courseCount => universities.expand((u) => u.colleges)
      .expand((c) => c.specializations).expand((s) => s.years)
      .expand((y) => y.semesters).expand((s) => s.courses).length;

  static int get lessonCount => universities.expand((u) => u.colleges)
      .expand((c) => c.specializations).expand((s) => s.years)
      .expand((y) => y.semesters).expand((s) => s.courses)
      .expand((c) => c.lessons).length;
}
