import '../../domain/academic/academic_models.dart';
import 'academic_knowledge_unit_catalog.dart';
import 'academic_lesson_blueprints.dart';
import 'academic_source_catalog.dart';

/// Reference catalog for the global TOFAN AI STUDENT library.
/// The structure is independent from any single university.
/// Learning content is aligned with internationally published computing
/// curriculum guidance and is written as original TOFAN academic content.
class AcademicCatalog {
  const AcademicCatalog._();

  static const _libraryProvenance = AcademicContentProvenance(
    status: AcademicPublicationStatus.draft,
    sourceReferences: [AcademicSourceCatalog.cs2023],
    author: 'TOFAN',
    version: '0.2.0',
  );

  /// Single global academic field containing the reference university catalog.
  /// The university is organizational reference data; the library remains global.
  static List<AcademicField> get fields => [
        AcademicField(
          id: 'computing',
          name: 'علوم الحاسوب وتقنية المعلومات',
          universities: universities,
        ),
      ];

  static AcademicUniversity get referenceUniversity => universities.first;

  static final _baseUniversities = <AcademicUniversity>[
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
                          knowledgeAreaIds: ['SDF','FPL'],
                          knowledgeUnitIds: ['sdf-01','fpl-01'],
                          lessons: [
                            AcademicLesson(
                              id: 'python-1',
                              definition: 'Python لغة برمجة تُستخدم لكتابة تعليمات قابلة للتنفيذ لحل المشكلات.',
content: 'تبدأ البرمجة بكتابة تعليمات واضحة. في Python ينفذ المفسر التعليمات بالترتيب ويعرض البرنامج مخرجات يمكن فحصها.',
learningOutcomes: ['يشرح الطالب معنى البرنامج والتعليمات والمخرجات.', 'يكتب برنامج Python قصيرًا قابلًا للتنفيذ.', 'يفسر العلاقة بين الكود والمخرجات.'],
keyTerms: ['Python', 'برنامج', 'تعليمة', 'مفسر', 'مخرجات'],
examples: ['برنامج يطبع رسالة ترحيب.', 'تعديل النص المطبوع ومقارنة المخرجات قبل التعديل وبعده.'],
applications: ['كتابة أدوات صغيرة لأتمتة مهام متكررة.'],
errorAnalysisGuidance: 'إذا لم تظهر المخرجات المتوقعة، راجع صياغة التعليمة، ترتيبها، ورسالة الخطأ قبل تعديل الكود عشوائيًا.',
skillEvidence: ['يكتب ويشغل برنامجًا قصيرًا.', 'يشرح وظيفة كل تعليمة أساسية.'],
                              conceptIds: ['concept-python-1'],
                              skillIds: ['skill-python-1'],
                              title: 'مقدمة في Python',
                              practices: [
                                LessonPractice(
                                  id: 'python-1-practice',
                                  title: 'تطبيق: أول برنامج',
                                  tasks: [
                                    PracticeTask(id: 'p1', instruction: 'اكتب برنامجًا يطبع رسالة ترحيب ثم عدّل الرسالة إلى نص من اختيارك.'),
                                    PracticeTask(id: 'p2', instruction: 'شغّل البرنامج، لاحظ المخرجات، ثم اشرح باختصار الفرق بين الكود والمخرجات.'),
                                    PracticeTask(id: 'p3', instruction: 'غيّر الرسالة إلى مدخل من المستخدم ثم تحقق من أن المخرجات تطابق المدخل.'),
                                  ],
                                ),
                              ],
                              assessments: [
                                LessonAssessment(
                                  id: 'python-1-assessment',
                                  title: 'تقييم: مقدمة في Python',
                                  questions: [
                                    AssessmentQuestion(id: 'q1', text: 'ما وظيفة البرنامج في Python؟', options: ['تنفيذ تعليمات مكتوبة', 'تصميم العتاد فقط', 'تخزين الصور فقط', 'إدارة الشبكات فقط'], correctIndex: 0, learningOutcomeIndexes: [0], conceptIds: ['concept-python-1'], skillIds: ['skill-python-1']),
                                    AssessmentQuestion(id: 'q2', text: 'ما الذي ينتج عادةً عن تنفيذ print؟', options: ['إنشاء قاعدة بيانات', 'إخراج نص أو قيمة', 'تثبيت نظام تشغيل', 'حذف المترجم'], correctIndex: 1, learningOutcomeIndexes: [1], conceptIds: ['concept-python-1'], skillIds: ['skill-python-1']),
                                    AssessmentQuestion(id: 'q3', text: 'ما المقصود بالتعليمات البرمجية؟', options: ['اسم جهاز', 'صورة ثابتة', 'أوامر يفهمها المفسر أو المترجم لتنفيذ مهمة', 'ملف صوتي'], correctIndex: 2, learningOutcomeIndexes: [2], conceptIds: ['concept-python-1'], skillIds: ['skill-python-1']),
                                  ],
                                ),
                              ],
                              projects: [
                                AcademicProject(
                                  id: 'python-1-project',
                                  conceptIds: ['concept-python-1'],
                                  skillIds: ['skill-python-1'],
                                  title: 'مشروع: برنامج ترحيب بسيط',
                                  description: 'أنشئ برنامجًا قصيرًا يستخدم مخرجات نصية واضحة، ثم وثّق وظيفة كل سطر بكلماتك.',
                                ),
                              ],
                            ),
                            AcademicLesson(
                              id: 'python-2',
                              definition: 'المتغير اسم يُستخدم للإشارة إلى قيمة، ونوع البيانات يصف طبيعة تلك القيمة والعمليات المناسبة لها.',
content: 'تخزن المتغيرات قيمًا يمكن للبرنامج استخدامها. يختلف التعامل مع النصوص والأعداد والقيم المنطقية، ولذلك يجب معرفة النوع قبل إجراء العمليات.',
learningOutcomes: ['يعرّف المتغير ونوع البيانات.', 'ينشئ متغيرات ويقرأ قيمها.', 'يفسر سبب اختلاف العمليات بحسب النوع.'],
keyTerms: ['متغير', 'str', 'int', 'float', 'bool', 'type'],
examples: ['متغير لاسم طالب وآخر لعمره.', 'استخدام type للتحقق من نوع قيمة.'],
applications: ['تمثيل بيانات المستخدم داخل برنامج صغير.'],
errorAnalysisGuidance: 'عند حدوث نتيجة غير متوقعة، افحص القيمة ونوعها قبل افتراض أن العملية الحسابية أو النصية صحيحة.',
skillEvidence: ['ينشئ متغيرات مناسبة للبيانات.', 'يتحقق من الأنواع ويبرر اختيارها.'],
                              conceptIds: ['concept-python-2'],
                              skillIds: ['skill-python-2'],
                              title: 'المتغيرات وأنواع البيانات',
                              practices: [
                                LessonPractice(
                                  id: 'python-2-practice',
                                  title: 'تطبيق: بيانات الطالب',
                                  tasks: [
                                    PracticeTask(id: 'p1', instruction: 'أنشئ متغيرات لاسم طالب وعمره، ثم اطبع القيمتين.'),
                                    PracticeTask(id: 'p2', instruction: 'استخدم type لفحص نوع كل قيمة، ثم اشرح لماذا يختلف النوع بين النص والعدد.'),
                                    PracticeTask(id: 'p3', instruction: 'أنشئ قيمة من نوع جديد، افحص نوعها، ثم برر اختيار النوع المناسب للبيانات.'),
                                  ],
                                ),
                              ],
                              assessments: [
                                LessonAssessment(
                                  id: 'python-2-assessment',
                                  title: 'تقييم: المتغيرات والأنواع',
                                  questions: [
                                    AssessmentQuestion(id: 'q1', text: 'ما المتغير؟', options: ['اسم يشير إلى قيمة يمكن استخدامها في البرنامج', 'جهاز إدخال', 'مجلد نظام', 'شبكة'], correctIndex: 0, learningOutcomeIndexes: [0], conceptIds: ['concept-python-2'], skillIds: ['skill-python-2']),
                                    AssessmentQuestion(id: 'q2', text: 'أي نوع يمثل نصًا في Python؟', options: ['int', 'str', 'bool فقط', 'float فقط'], correctIndex: 1, learningOutcomeIndexes: [1], conceptIds: ['concept-python-2'], skillIds: ['skill-python-2']),
                                    AssessmentQuestion(id: 'q3', text: 'ما وظيفة type؟', options: ['إغلاق البرنامج', 'قراءة لوحة المفاتيح فقط', 'معرفة نوع قيمة', 'حذف متغير'], correctIndex: 2, learningOutcomeIndexes: [2], conceptIds: ['concept-python-2'], skillIds: ['skill-python-2']),
                                  ],
                                ),
                              ],
                              projects: [
                                AcademicProject(
                                  id: 'python-2-project',
                                  conceptIds: ['concept-python-2'],
                                  skillIds: ['skill-python-2'],
                                  title: 'مشروع: بطاقة بيانات طالب',
                                  description: 'أنشئ برنامجًا يخزن عدة بيانات أساسية في متغيرات ويعرضها بصورة منظمة.',
                                ),
                              ],
                            ),
                            AcademicLesson(
                              id: 'python-3',
                              definition: 'الإدخال هو استقبال بيانات من المستخدم، وتسمح العمليات الحسابية بتحويل هذه البيانات إلى نتائج قابلة للاستخدام.',
content: 'تُرجع input قيمة نصية، ويمكن تحويلها إلى عدد عند الحاجة. تستخدم العمليات الحسابية لبناء نتائج، مع الانتباه إلى القسمة الصحيحة وباقي القسمة والأس.',
learningOutcomes: ['يقرأ إدخال المستخدم.', 'يحوّل الإدخال إلى النوع المناسب.', 'يطبق العمليات الحسابية ويفسر نتائجها.'],
keyTerms: ['input', 'int', 'float', '//', '%', '**'],
examples: ['قراءة عددين وحساب مجموعهما.', 'استخدام % لمعرفة باقي القسمة.'],
applications: ['بناء حاسبات وأدوات إدخال بسيطة.'],
errorAnalysisGuidance: 'إذا فشل التحويل أو ظهرت نتيجة خاطئة، افحص نوع الإدخال والقيم المدخلة والعامل الحسابي المستخدم.',
skillEvidence: ['يبني برنامجًا تفاعليًا بسيطًا.', 'يختار التحويل والعامل المناسبين.'],
                              conceptIds: ['concept-python-3'],
                              skillIds: ['skill-python-3'],
                              title: 'الإدخال والعمليات الحسابية',
                              practices: [
                                LessonPractice(
                                  id: 'python-3-practice',
                                  title: 'تطبيق: حساب بسيط',
                                  tasks: [
                                    PracticeTask(id: 'p1', instruction: 'اقرأ عددين باستخدام input وحولهما إلى أعداد صحيحة باستخدام int.'),
                                    PracticeTask(id: 'p2', instruction: 'احسب الجمع والطرح والضرب والقسمة الصحيحة وباقي القسمة، ثم اعرض النتائج.'),
                                    PracticeTask(id: 'p3', instruction: 'اختبر البرنامج بقيم حدية أو غير متوقعة، ثم فسّر أي خطأ وكيف يمكن منعه.'),
                                  ],
                                ),
                              ],
                              assessments: [
                                LessonAssessment(
                                  id: 'python-3-assessment',
                                  title: 'تقييم: الإدخال والعمليات',
                                  questions: [
                                    AssessmentQuestion(id: 'q1', text: 'ما وظيفة input؟', options: ['قراءة إدخال من المستخدم كنص', 'طباعة ملف', 'إنشاء متغير تلقائيًا من دون قيمة', 'إغلاق المفسر'], correctIndex: 0, learningOutcomeIndexes: [0], conceptIds: ['concept-python-3'], skillIds: ['skill-python-3']),
                                    AssessmentQuestion(id: 'q2', text: 'لماذا نستخدم int(input(...)) عند الحاجة إلى عدد صحيح؟', options: ['لتحويل العدد إلى صورة', 'لتحويل الإدخال النصي إلى عدد صحيح', 'لإخفاء الإدخال', 'لإنشاء قائمة'], correctIndex: 1, learningOutcomeIndexes: [1], conceptIds: ['concept-python-3'], skillIds: ['skill-python-3']),
                                    AssessmentQuestion(id: 'q3', text: 'ما العامل % في Python؟', options: ['القسمة الصحيحة', 'الأس', 'باقي القسمة', 'الجمع'], correctIndex: 2, learningOutcomeIndexes: [2], conceptIds: ['concept-python-3'], skillIds: ['skill-python-3']),
                                  ],
                                ),
                              ],
                              projects: [
                                AcademicProject(
                                  id: 'python-3-project',
                                  conceptIds: ['concept-python-3'],
                                  skillIds: ['skill-python-3'],
                                  title: 'مشروع: حاسبة طالب',
                                  description: 'أنشئ حاسبة تفاعلية تقرأ قيمًا من المستخدم وتعرض نتائج عمليات حسابية أساسية بصورة واضحة.',
                                ),
                              ],
                            ),
                          ],
                        ),
                        AcademicCourse(
                          id: 'discrete-math',
                          name: 'الرياضيات المتقطعة',
                          knowledgeAreaIds: ['MSF','AL'],
                          knowledgeUnitIds: ['msf-01','msf-02','al-01'],
                          prerequisiteCourseIds: const [],
                          lessons: [
                            AcademicLesson(
                              id: 'sets',
                              definition: 'المجموعة تجميع محدد من عناصر مميزة يمكن وصفها بدقة.',
content: 'تستخدم المجموعات لتمثيل عناصر مميزة، وتسمح عمليات الاتحاد والتقاطع والفرق ببناء مجموعات جديدة وفق قواعد واضحة.',
learningOutcomes: ['يعرّف المجموعة وعنصرها.', 'يحسب الاتحاد والتقاطع والفرق.', 'يتحقق من النتيجة عنصرًا عنصرًا.'],
keyTerms: ['مجموعة', 'عنصر', 'اتحاد', 'تقاطع', 'فرق', 'احتواء'],
examples: ['مجموعتان تمثلان طلاب مقررين مختلفين.', 'استخراج الطلاب المشتركين باستخدام التقاطع.'],
applications: ['تحليل مجموعات البيانات والعلاقات بين التصنيفات.'],
errorAnalysisGuidance: 'عند خطأ في عملية مجموعة، اكتب العناصر صراحة ثم تحقق من شرط الانتماء لكل عملية.',
skillEvidence: ['ينفذ عمليات المجموعات بدقة.', 'يبرر النتيجة باستخدام تعريف العملية.'],
                              conceptIds: ['concept-sets'],
                              skillIds: ['skill-sets'],
                              title: 'المجموعات',
                              practices: [
                                LessonPractice(
                                  id: 'sets-practice',
                                  title: 'تطبيق: عمليات المجموعات',
                                  tasks: [
                                    PracticeTask(id: 'p1', instruction: 'كوّن مجموعتين صغيرتين وحدد عناصر الاتحاد والتقاطع بينهما.'),
                                    PracticeTask(id: 'p2', instruction: 'أنشئ مثالًا على الفرق بين مجموعتين، ثم تحقق من النتيجة عنصرًا عنصرًا.'),
                                    PracticeTask(id: 'p3', instruction: 'غيّر عناصر المجموعتين، ثم تحقق من كل عملية باستخدام تعريفها بدل التخمين.'),
                                  ],
                                ),
                              ],
                              assessments: [
                                LessonAssessment(
                                  id: 'sets-assessment',
                                  title: 'تقييم: المجموعات',
                                  questions: [
                                    AssessmentQuestion(id: 'q1', text: 'ما المجموعة؟', options: ['تجميع محدد من عناصر مميزة', 'عدد عشري فقط', 'برنامج', 'شبكة'], correctIndex: 0, learningOutcomeIndexes: [0], conceptIds: ['concept-sets'], skillIds: ['skill-sets']),
                                    AssessmentQuestion(id: 'q2', text: 'ماذا يمثل تقاطع مجموعتين؟', options: ['كل العناصر من دون تكرار', 'العناصر المشتركة بينهما', 'عناصر المجموعة الأولى فقط', 'عناصر خارج المجموعتين'], correctIndex: 1, learningOutcomeIndexes: [1], conceptIds: ['concept-sets'], skillIds: ['skill-sets']),
                                    AssessmentQuestion(id: 'q3', text: 'ماذا يمثل اتحاد مجموعتين؟', options: ['العناصر في المجموعة الأولى فقط', 'العناصر المشتركة فقط', 'عناصر المجموعتين معًا دون تكرار', 'العناصر في المجموعة الثانية فقط'], correctIndex: 2, learningOutcomeIndexes: [2], conceptIds: ['concept-sets'], skillIds: ['skill-sets']),
                                  ],
                                ),
                              ],
                              projects: [
                                AcademicProject(
                                  id: 'sets-project',
                                  conceptIds: ['concept-sets'],
                                  skillIds: ['skill-sets'],
                                  title: 'مشروع: نموذج مجموعات بيانات',
                                  description: 'مثّل مجموعات لطلاب أو مقررات، ثم استخدم الاتحاد والتقاطع والفرق لتحليل العلاقة بينها.',
                                ),
                              ],
                            ),
                            AcademicLesson(
                              id: 'relations',
                              definition: 'العلاقة بين مجموعتين تمثيل لارتباطات محددة يمكن وصفها بمجموعة من الأزواج المرتبة.',
content: 'تصف العلاقات ارتباط عنصر من مجال بعنصر من مدى. ترتيب الزوج مهم، ويمكن استخدام العلاقات لتمثيل متطلبات أو ارتباطات بين كيانات.',
learningOutcomes: ['يعرّف العلاقة والزوج المرتب.', 'يمثل علاقة بين مجموعتين.', 'يفسر معنى الارتباطات الناتجة.'],
keyTerms: ['علاقة', 'زوج مرتب', 'مجال', 'مدى', 'ارتباط'],
examples: ['علاقة بين الطلاب والمقررات المسجلين فيها.', 'قراءة زوج مرتب وتفسيره في سياق عملي.'],
applications: ['تمثيل العلاقات بين كيانات في نظم المعلومات وقواعد البيانات.'],
errorAnalysisGuidance: 'إذا اختلط معنى العلاقة، حدد المجال والمدى واتجاه الزوج المرتب قبل تفسيره.',
skillEvidence: ['يمثل علاقة صحيحة.', 'يفسر كل زوج مرتب في سياقه.'],
                              conceptIds: ['concept-relations'],
                              skillIds: ['skill-relations'],
                              title: 'العلاقات',
                              practices: [
                                LessonPractice(
                                  id: 'relations-practice',
                                  title: 'تطبيق: تمثيل علاقة',
                                  tasks: [
                                    PracticeTask(id: 'p1', instruction: 'كوّن علاقة بين عناصر مجموعتين باستخدام أزواج مرتبة.'),
                                    PracticeTask(id: 'p2', instruction: 'حدد من المثال ما إذا كانت العلاقة تمثل شرطًا محددًا بين عناصر المجال والمدى.'),
                                    PracticeTask(id: 'p3', instruction: 'غيّر زوجًا مرتبًا واحدًا وفسّر كيف تتغير العلاقة والمعنى في المثال.'),
                                  ],
                                ),
                              ],
                              assessments: [
                                LessonAssessment(
                                  id: 'relations-assessment',
                                  title: 'تقييم: العلاقات',
                                  questions: [
                                    AssessmentQuestion(id: 'q1', text: 'كيف يمكن تمثيل علاقة بين مجموعتين؟', options: ['بمجموعة من الأزواج المرتبة', 'بصورة فقط', 'بملف صوتي فقط', 'بمتغير واحد فقط'], correctIndex: 0, learningOutcomeIndexes: [0], conceptIds: ['concept-relations'], skillIds: ['skill-relations']),
                                    AssessmentQuestion(id: 'q2', text: 'ما الزوج المرتب؟', options: ['مجموعة غير مرتبة فقط', 'عنصران بترتيب محدد', 'عدد صحيح', 'تعليمة Python'], correctIndex: 1, learningOutcomeIndexes: [1], conceptIds: ['concept-relations'], skillIds: ['skill-relations']),
                                    AssessmentQuestion(id: 'q3', text: 'لماذا تُستخدم العلاقات في علوم الحاسوب؟', options: ['لضغط الصور فقط', 'لزيادة سرعة المعالج فقط', 'لتمثيل ارتباطات بين عناصر وكيانات', 'لتثبيت البرامج'], correctIndex: 2, learningOutcomeIndexes: [2], conceptIds: ['concept-relations'], skillIds: ['skill-relations']),
                                  ],
                                ),
                              ],
                              projects: [
                                AcademicProject(
                                  id: 'relations-project',
                                  conceptIds: ['concept-relations'],
                                  skillIds: ['skill-relations'],
                                  title: 'مشروع: علاقة المقررات والمتطلبات',
                                  description: 'مثّل علاقة بسيطة بين مقررات ومتطلبات سابقة باستخدام الأزواج المرتبة وفسّر ما تمثله.',
                                ),
                              ],
                            ),
                          ],
                        ),
                        AcademicCourse(
                          id: 'ai-intro',
                          name: 'مقدمة في الذكاء الاصطناعي',
                          knowledgeAreaIds: ['AI','MSF'],
                          knowledgeUnitIds: ['ai-01','ai-03','msf-02'],
                          lessons: [
                            AcademicLesson(
                              id: 'ai-foundations',
                              definition: 'الذكاء الاصطناعي مجال من علوم الحاسوب يهتم ببناء أنظمة تنفذ مهامًا تتطلب الاستدلال أو التعلم أو التخطيط أو الإدراك.',
content: 'يدرس الذكاء الاصطناعي طرق تمثيل المعرفة والتعلم والاستدلال واتخاذ القرار. يجب وصف النظام وفق هدفه ومدخلاته ومخرجاته ومعيار تقييمه بدل الاكتفاء بوصفه بأنه ذكي.',
learningOutcomes: ['يعرّف الذكاء الاصطناعي ويحدد حدوده.', 'يميز بين التعلم الآلي ومجالات الذكاء الاصطناعي الأوسع.', 'يحلل نظامًا ذكيًا من حيث المهمة والمدخلات والمخرجات.'],
keyTerms: ['ذكاء اصطناعي', 'تعلم آلي', 'تمثيل معرفي', 'استدلال', 'تخطيط'],
examples: ['نظام تعليمي يقترح تدريبًا بناءً على أداء الطالب.', 'مقارنة نظام قواعد ثابتة مع نظام يتعلم من البيانات.'],
applications: ['تحليل الأنظمة الذكية وتحديد متطلبات استخدامها المسؤول.'],
errorAnalysisGuidance: 'إذا اعتبرت كل برنامج ذكاءً اصطناعيًا، ارجع إلى تعريف المجال وحدد المهمة التي تتطلب استدلالًا أو تعلمًا أو تخطيطًا.',
skillEvidence: ['يحلل نظامًا ذكيًا بمصطلحات دقيقة.', 'يميز بين أنواع القدرات الذكية.'],
                              conceptIds: ['concept-ai-foundations'],
                              skillIds: ['skill-ai-foundations'],
                              title: 'مفاهيم الذكاء الاصطناعي',
                              practices: [
                                LessonPractice(
                                  id: 'ai-foundations-practice',
                                  title: 'تطبيق: تحليل نظام ذكي',
                                  tasks: [
                                    PracticeTask(id: 'p1', instruction: 'اختر نظامًا يستخدم الذكاء الاصطناعي وحدد المدخلات والمخرجات والمهمة التي يؤديها.'),
                                    PracticeTask(id: 'p2', instruction: 'ميّز في المثال بين النظام الذي يعتمد على قواعد ثابتة والنظام الذي يتعلم من البيانات إن أمكن.'),
                                    PracticeTask(id: 'p3', instruction: 'حلّل نظامًا جديدًا، ثم اقترح معيارًا واحدًا لقياس نجاحه ومصدرًا محتملًا للتحيز.'),
                                  ],
                                ),
                              ],
                              assessments: [
                                LessonAssessment(
                                  id: 'ai-foundations-assessment',
                                  title: 'تقييم: مفاهيم الذكاء الاصطناعي',
                                  questions: [
                                    AssessmentQuestion(id: 'q1', text: 'ما أحد الموضوعات الأساسية في الذكاء الاصطناعي الحديث؟', options: ['التعلم الآلي', 'تنسيق المستندات فقط', 'إدارة الملفات فقط', 'تصميم الشرائح فقط'], correctIndex: 0, learningOutcomeIndexes: [0], conceptIds: ['concept-ai-foundations'], skillIds: ['skill-ai-foundations']),
                                    AssessmentQuestion(id: 'q2', text: 'ما المقصود بالتمثيل المعرفي؟', options: ['نسخ الملفات', 'تمثيل المعلومات بطريقة تسمح للنظام باستخدامها في الاستدلال أو المعالجة', 'تغيير حجم الشاشة', 'تثبيت نظام التشغيل'], correctIndex: 1, learningOutcomeIndexes: [1], conceptIds: ['concept-ai-foundations'], skillIds: ['skill-ai-foundations']),
                                    AssessmentQuestion(id: 'q3', text: 'لماذا تُدرَس آثار الذكاء الاصطناعي المجتمعية؟', options: ['لتسريع لوحة المفاتيح', 'لزيادة حجم الملفات', 'لفهم الاستخدام المسؤول والمخاطر والآثار المحتملة للأنظمة الذكية', 'لإلغاء الاختبارات'], correctIndex: 2, learningOutcomeIndexes: [2], conceptIds: ['concept-ai-foundations'], skillIds: ['skill-ai-foundations']),
                                  ],
                                ),
                              ],
                              projects: [
                                AcademicProject(
                                  id: 'ai-foundations-project',
                                  conceptIds: ['concept-ai-foundations'],
                                  skillIds: ['skill-ai-foundations'],
                                  title: 'مشروع: دراسة حالة لنظام ذكي',
                                  description: 'حلّل نظامًا ذكيًا حقيقيًا من حيث المهمة والمدخلات والمخرجات ونوع المعرفة أو التعلم المستخدم وآثاره المحتملة.',
                                ),
                              ],
                            ),
                            AcademicLesson(
                              id: 'ai-agents',
                              definition: 'الوكيل الذكي نظام يستقبل ملاحظات من البيئة ويختار أفعالًا لتحقيق هدف أو معيار أداء.',
content: 'يتطلب تصميم الوكيل تحديد البيئة والملاحظات والأفعال والهدف ومعيار الأداء. اختيار الفعل يعتمد على ما يلاحظه الوكيل وعلى النموذج أو السياسة المستخدمة.',
learningOutcomes: ['يعرّف الوكيل والبيئة.', 'يحدد الملاحظات والأفعال والهدف.', 'يصمم نموذجًا مفاهيميًا لوكيل بسيط.'],
keyTerms: ['وكيل', 'بيئة', 'ملاحظة', 'فعل', 'هدف', 'معيار أداء'],
examples: ['وكيل تعليمي يراقب نتائج الطالب ويقترح إجراءً تعليميًا.', 'تحديد أفعال وكيل في بيئة تعليمية.'],
applications: ['تصميم أنظمة تعليمية ومساعدة تتخذ قرارات قابلة للتفسير.'],
errorAnalysisGuidance: 'إذا لم تستطع تحديد الفعل المناسب، ابدأ بتحديد ما يستطيع الوكيل ملاحظته والهدف الذي يقيس نجاحه.',
skillEvidence: ['يحدد مكونات نموذج وكيل.', 'يربط الملاحظات بالأفعال والهدف.'],
                              conceptIds: ['concept-ai-agents'],
                              skillIds: ['skill-ai-agents'],
                              title: 'الوكلاء الأذكياء',
                              practices: [
                                LessonPractice(
                                  id: 'ai-agents-practice',
                                  title: 'تطبيق: نموذج وكيل ذكي',
                                  tasks: [
                                    PracticeTask(id: 'p1', instruction: 'اختر مهمة لوكيل ذكي وحدد البيئة والملاحظات والأفعال التي يمكنه تنفيذها.'),
                                    PracticeTask(id: 'p2', instruction: 'اكتب وصفًا مختصرًا لكيفية اختيار الوكيل لفعل مناسب استنادًا إلى الملاحظات والهدف.'),
                                    PracticeTask(id: 'p3', instruction: 'غيّر هدف الوكيل أو ملاحظاته، ثم حلّل كيف يجب أن يتغير الفعل المختار.'),
                                  ],
                                ),
                              ],
                              assessments: [
                                LessonAssessment(
                                  id: 'ai-agents-assessment',
                                  title: 'تقييم: الوكلاء الأذكياء',
                                  questions: [
                                    AssessmentQuestion(id: 'q1', text: 'ما الوكيل الذكي؟', options: ['نظام يستقبل ملاحظات عن بيئته ويختار أفعالًا لتحقيق هدف', 'برنامج طباعة فقط', 'قاعدة بيانات فقط', 'جهاز تخزين'], correctIndex: 0, learningOutcomeIndexes: [0], conceptIds: ['concept-ai-agents'], skillIds: ['skill-ai-agents']),
                                    AssessmentQuestion(id: 'q2', text: 'ما المقصود بالبيئة في نموذج الوكيل؟', options: ['اسم المتغير فقط', 'العالم أو السياق الذي يتفاعل معه الوكيل', 'ذاكرة الحاسوب فقط', 'لغة البرمجة فقط'], correctIndex: 1, learningOutcomeIndexes: [1], conceptIds: ['concept-ai-agents'], skillIds: ['skill-ai-agents']),
                                    AssessmentQuestion(id: 'q3', text: 'ما العلاقة بين الإدراك والفعل في الوكيل؟', options: ['لا توجد علاقة', 'الفعل يحدث قبل أي ملاحظة دائمًا', 'الملاحظات تساعد الوكيل على اختيار أفعاله', 'الملاحظات هي نفسها قاعدة البيانات'], correctIndex: 2, learningOutcomeIndexes: [2], conceptIds: ['concept-ai-agents'], skillIds: ['skill-ai-agents']),
                                  ],
                                ),
                              ],
                              projects: [
                                AcademicProject(
                                  id: 'ai-agents-project',
                                  conceptIds: ['concept-ai-agents'],
                                  skillIds: ['skill-ai-agents'],
                                  title: 'مشروع: تصميم وكيل تعليمي',
                                  description: 'صمّم نموذجًا مفاهيميًا لوكيل تعليمي يراقب تقدم الطالب ويختار إجراءً تعليميًا مناسبًا، مع تحديد البيئة والملاحظات والأفعال والهدف.',
                                ),
                              ],
                            ),
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
                          knowledgeAreaIds: ['AL','SDF'],
                          knowledgeUnitIds: ['al-02','sdf-02'],
                          prerequisiteCourseIds: const ['python', 'discrete-math'],
                          lessons: [
                            AcademicLesson(
                              id: 'arrays',
                              definition: 'القائمة بنية بيانات مرتبة تخزن مجموعة من القيم ويمكن الوصول إلى عناصرها باستخدام الفهارس.',
content: 'تساعد القوائم على تنظيم عدة قيم في بنية واحدة. يمكن إضافة عناصر وقراءتها وتكرارها، ويجب اختيار بنية البيانات وفق العمليات المطلوبة.',
learningOutcomes: ['يعرّف القائمة والفهرس.', 'ينفذ عمليات أساسية على قائمة.', 'يختار استخدام القائمة لمسألة مناسبة.'],
keyTerms: ['قائمة', 'فهرس', 'عنصر', 'تكرار', 'بنية بيانات'],
examples: ['قائمة مهام يمكن إضافة عناصر إليها.', 'المرور على القائمة وعرض عناصرها بالتتابع.'],
applications: ['تنظيم بيانات صغيرة في البرامج والخوارزميات.'],
errorAnalysisGuidance: 'إذا حصلت على عنصر غير صحيح، راجع الفهرس وترتيب العناصر وحدود القائمة.',
skillEvidence: ['ينشئ قائمة ويقرأ ويعدل عناصرها.', 'يشرح لماذا تناسب القائمة المشكلة.'],
                              conceptIds: ['concept-arrays'],
                              skillIds: ['skill-arrays'],
                              title: 'المصفوفات والقوائم',
                              practices: [
                                LessonPractice(
                                  id: 'arrays-practice',
                                  title: 'تطبيق: التعامل مع قائمة',
                                  tasks: [
                                    PracticeTask(id: 'p1', instruction: 'أنشئ قائمة قيم وأضف إليها عنصرًا ثم اقرأ عنصرًا منها باستخدام الفهرس.'),
                                    PracticeTask(id: 'p2', instruction: 'احسب عدد العناصر وجرّب المرور عليها لعرض القيم بالتتابع.'),
                                    PracticeTask(id: 'p3', instruction: 'غيّر ترتيب العناصر وأضف عنصرًا جديدًا، ثم تحقق من الفهارس والنتيجة.'),
                                  ],
                                ),
                              ],
                              assessments: [
                                LessonAssessment(
                                  id: 'arrays-assessment',
                                  title: 'تقييم: القوائم',
                                  questions: [
                                    AssessmentQuestion(id: 'q1', text: 'ما القائمة في Python؟', options: ['بنية بيانات مرتبة يمكن أن تحتوي عدة قيم', 'عدد واحد فقط', 'دالة طباعة', 'ملف نظام'], correctIndex: 0, learningOutcomeIndexes: [0], conceptIds: ['concept-arrays'], skillIds: ['skill-arrays']),
                                    AssessmentQuestion(id: 'q2', text: 'كيف نصل عادةً إلى عنصر في قائمة؟', options: ['بتغيير اسم الملف', 'باستخدام الفهرس', 'بتثبيت مكتبة', 'بإغلاق البرنامج'], correctIndex: 1, learningOutcomeIndexes: [1], conceptIds: ['concept-arrays'], skillIds: ['skill-arrays']),
                                    AssessmentQuestion(id: 'q3', text: 'ما فائدة بنية البيانات؟', options: ['إدارة الكهرباء', 'تغيير دقة الشاشة فقط', 'تنظيم البيانات ومعالجتها بكفاءة مناسبة للمهمة', 'تشغيل لوحة المفاتيح'], correctIndex: 2, learningOutcomeIndexes: [2], conceptIds: ['concept-arrays'], skillIds: ['skill-arrays']),
                                  ],
                                ),
                              ],
                              projects: [
                                AcademicProject(
                                  id: 'arrays-project',
                                  conceptIds: ['concept-arrays'],
                                  skillIds: ['skill-arrays'],
                                  title: 'مشروع: قائمة مهام برمجية',
                                  description: 'أنشئ نموذجًا بسيطًا لقائمة مهام باستخدام بنية قائمة، مع إضافة عناصر وعرضها وتنظيمها.',
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
            ..._globalSpecializations,
          ],
        ),
      ],
    ),
  ];

  /// Public catalog view. Every specialization is normalized through the same
  /// depth layer so hand-authored reference courses and generated global courses
  /// expose the same deep lesson structure.
  static List<AcademicUniversity> get universities =>
      _baseUniversities.map(_deepenUniversity).toList(growable: false);

  static AcademicUniversity _deepenUniversity(AcademicUniversity university) {
    return AcademicUniversity(
      id: university.id,
      name: university.name,
      colleges: university.colleges.map((college) => AcademicCollege(
        id: college.id,
        name: college.name,
        specializations: college.specializations
            .map(_deepenSpecialization)
            .toList(growable: false),
      )).toList(growable: false),
    );
  }

  static AcademicSpecialization _deepenSpecialization(
      AcademicSpecialization specialization) {
    return AcademicSpecialization(
      id: specialization.id,
      name: specialization.name,
      years: specialization.years.map((year) => AcademicYear(
        number: year.number,
        semesters: year.semesters.map((semester) => AcademicSemester(
          number: semester.number,
          courses: semester.courses.map(_deepenCourse).toList(growable: false),
        )).toList(growable: false),
      )).toList(growable: false),
    );
  }

  static AcademicCourse _deepenCourse(AcademicCourse course) {
    // Normalize provenance for existing hand-authored content as well as
    // generated content. This completes the provenance layer without
    // duplicating or replacing existing academic material.
    final normalizedLessons = course.lessons.map(_withLibraryProvenance).toList(growable: false);
    final lessons = <AcademicLesson>[...normalizedLessons];

    if (lessons.length < 6) {
      for (var number = lessons.length + 1; number <= 6; number++) {
        lessons.add(_deepCurriculumLesson(
          courseId: course.id,
          courseName: course.name,
          lessonNumber: number,
        ));
      }
    }

    final units = <AcademicUnit>[
      ...course.units,
      ...lessons.skip(course.units.length).take(6 - course.units.length).toList()
          .asMap()
          .entries
          .map((entry) => AcademicUnit(
                id: '${course.id}-deep-unit-${entry.key + 1}',
                title: 'وحدة تعميق ${entry.key + 1}: المعرفة والتطبيق',
                lessons: [entry.value],
              )),
    ];

    return AcademicCourse(
      id: course.id,
      name: course.name,
      lessons: lessons,
      units: units,
      prerequisiteCourseIds: course.prerequisiteCourseIds,
      knowledgeAreaIds: course.knowledgeAreaIds.isNotEmpty
          ? course.knowledgeAreaIds
          : _knowledgeAreasFor(course.name),
      knowledgeUnitIds: course.knowledgeUnitIds.isNotEmpty
          ? course.knowledgeUnitIds
          : _knowledgeUnitsFor(course.name),
      curriculumProfile: course.curriculumProfile,
      provenance: course.provenance.hasSource ? course.provenance : _libraryProvenance,
      projects: course.projects.isNotEmpty
          ? course.projects.map(_normalizeProject).toList(growable: false)
          : [_courseProject(courseId: course.id, courseName: course.name, lessons: lessons)],
    );
  }

  static AcademicProject _normalizeProject(AcademicProject project) {
    return AcademicProject(
      id: project.id,
      title: project.title,
      description: project.description,
      skillIds: project.skillIds,
      conceptIds: project.conceptIds,
      requirements: project.requirements.isNotEmpty
          ? project.requirements
          : const ['تحديد المشكلة والهدف والنطاق.', 'ربط التنفيذ بالمفاهيم والمهارات.'],
      deliverables: project.deliverables.isNotEmpty
          ? project.deliverables
          : const ['تنفيذ أو نموذج أولي.', 'اختبارات ونتائج موثقة.', 'توثيق المشروع.'],
      milestones: project.milestones.isNotEmpty
          ? project.milestones
          : const ['تحليل', 'تنفيذ', 'اختبار وتصحيح', 'توثيق'],
      acceptanceCriteria: project.acceptanceCriteria.isNotEmpty
          ? project.acceptanceCriteria
          : const ['تحقيق المتطلبات الأساسية.', 'وجود دليل اختبار قابل للمراجعة.'],
      implementationTasks: project.implementationTasks.isNotEmpty
          ? project.implementationTasks
          : const ['تحويل المتطلبات إلى خطوات تنفيذية.', 'تنفيذ الحل.', 'اختبار وتصحيح السبب.'],
      testCases: project.testCases.isNotEmpty
          ? project.testCases
          : const ['حالة طبيعية.', 'حالة حدية أو غير متوقعة.', 'حالة فشل متوقعة.'],
      evidenceRequirements: project.evidenceRequirements.isNotEmpty
          ? project.evidenceRequirements
          : const ['دليل تنفيذ أو تحليل.', 'سجل الاختبارات والنتائج.', 'توثيق القيود والقرارات.'],
      recommendedToolCategories: project.recommendedToolCategories,
    );
  }

  static AcademicLesson _withLibraryProvenance(AcademicLesson lesson) {
    if (lesson.provenance.hasSource) return lesson;
    return AcademicLesson(
      id: lesson.id,
      title: lesson.title,
      isFree: lesson.isFree,
      content: lesson.content,
      definition: lesson.definition,
      applications: lesson.applications,
      errorAnalysisGuidance: lesson.errorAnalysisGuidance,
      learningOutcomes: lesson.learningOutcomes,
      keyTerms: lesson.keyTerms,
      examples: lesson.examples,
      practices: lesson.practices,
      assessments: lesson.assessments,
      projects: lesson.projects.map(_normalizeProject).toList(growable: false),
      conceptIds: lesson.conceptIds,
      skillIds: lesson.skillIds,
      skillEvidence: lesson.skillEvidence,
      provenance: _libraryProvenance,
    );
  }

  /// Global computing specializations. These entries complete the academic
  /// skeleton across four years and two semesters; lesson content is expanded
  /// incrementally from the same approved global curriculum foundation.
  static final List<AcademicSpecialization> _globalSpecializations = [
    _specialization('computer-science', 'علوم الحاسوب', [
      ['البرمجة 1', 'رياضيات متقطعة', 'أساسيات الحوسبة'], ['البرمجة 2', 'هياكل البيانات', 'منطق رقمي'],
      ['الخوارزميات', 'قواعد البيانات', 'أنظمة التشغيل'], ['شبكات الحاسوب', 'هندسة البرمجيات', 'تحليل الخوارزميات'],
      ['البرمجة المتقدمة', 'الأنظمة الموزعة', 'أمن الحاسوب'], ['تطوير الويب', 'تفاعل الإنسان والحاسوب', 'الحوسبة السحابية'],
      ['الذكاء الاصطناعي', 'علم البيانات', 'المترجمات'], ['مشروع التخرج 1', 'موضوعات متقدمة في علوم الحاسوب', 'منهجية البحث'],
    ]),
    _specialization('software-engineering', 'هندسة البرمجيات', [
      ['أساسيات البرمجة', 'رياضيات متقطعة', 'أساسيات هندسة البرمجيات'], ['البرمجة الكائنية', 'هياكل البيانات', 'إدارة الإصدارات'],
      ['تحليل المتطلبات', 'تصميم البرمجيات', 'اختبار البرمجيات'], ['قواعد البيانات', 'هندسة البرمجيات المتقدمة', 'إدارة المشاريع البرمجية'],
      ['معمارية البرمجيات', 'DevOps', 'ضمان الجودة'], ['تطوير التطبيقات', 'الأمن البرمجي', 'الأنظمة الموزعة'],
      ['الأنظمة السحابية', 'هندسة البرمجيات الحديثة', 'منهجية البحث'], ['مشروع التخرج 1', 'مشروع التخرج 2', 'ندوة هندسة البرمجيات'],
    ]),
    _specialization('information-technology', 'تقنية المعلومات', [
      ['أساسيات تقنية المعلومات', 'البرمجة', 'رياضيات للحوسبة'], ['قواعد البيانات', 'شبكات 1', 'أنظمة التشغيل'],
      ['شبكات 2', 'إدارة الأنظمة', 'أمن المعلومات'], ['خدمات الشبكات', 'إدارة قواعد البيانات', 'دعم المستخدم'],
      ['الحوسبة السحابية', 'أمن الشبكات', 'إدارة البنية التحتية'], ['افتراضية الحوسبة', 'DevOps', 'استمرارية الأعمال'],
      ['إدارة خدمات تقنية المعلومات', 'حوكمة تقنية المعلومات', 'تدقيق الأنظمة'], ['مشروع التخرج 1', 'مشروع التخرج 2', 'منهجية البحث'],
    ]),
    _specialization('information-systems', 'نظم المعلومات', [
      ['مقدمة نظم المعلومات', 'البرمجة', 'رياضيات وإحصاء'], ['تحليل النظم', 'قواعد البيانات', 'إدارة الأعمال'],
      ['تصميم النظم', 'نمذجة البيانات', 'إدارة المشاريع'], ['نظم المؤسسات', 'ذكاء الأعمال', 'أمن نظم المعلومات'],
      ['تحليل البيانات', 'تخطيط موارد المؤسسة', 'إدارة العمليات'], ['نظم دعم القرار', 'الحوسبة السحابية', 'إدارة الخدمات'],
      ['التحول الرقمي', 'حوكمة البيانات', 'منهجية البحث'], ['مشروع التخرج 1', 'مشروع التخرج 2', 'ندوة نظم المعلومات'],
    ]),
    _specialization('data-science', 'علم البيانات', [
      ['البرمجة للبيانات', 'رياضيات متقطعة', 'إحصاء 1'], ['هياكل البيانات', 'إحصاء 2', 'قواعد البيانات'],
      ['تنقيب البيانات', 'تحليل البيانات', 'تصوير البيانات'], ['تعلم الآلة', 'هندسة البيانات', 'الاحتمالات'],
      ['تعلم الآلة المتقدم', 'معالجة البيانات الضخمة', 'التجارب وتحليلها'], ['معالجة اللغة للبيانات', 'السلاسل الزمنية', 'الحوسبة السحابية'],
      ['الذكاء الاصطناعي التطبيقي', 'هندسة منصات البيانات', 'أخلاقيات البيانات'], ['مشروع التخرج 1', 'مشروع التخرج 2', 'منهجية البحث'],
    ]),
    _specialization('cybersecurity', 'الأمن السيبراني', [
      ['أساسيات الحوسبة الآمنة', 'البرمجة للأمن السيبراني', 'رياضيات وأسس التشفير'],
      ['شبكات وأمن الشبكات 1', 'أنظمة التشغيل والأمن', 'مبادئ الأمن السيبراني'],
      ['شبكات وأمن الشبكات 2', 'التشفير التطبيقي', 'أمن الأنظمة'],
      ['أمن تطبيقات الويب', 'الاستجابة للحوادث', 'تحليل البرمجيات الخبيثة'],
      ['اختبار الاختراق الأخلاقي 1', 'أمن الشبكات المتقدم', 'أمن قواعد البيانات'],
      ['اختبار الاختراق الأخلاقي 2', 'التحقيق الجنائي الرقمي', 'أمن الحوسبة السحابية'],
      ['الهجوم والدفاع في المختبرات الأمنية', 'أمن البرمجيات وDevSecOps', 'إدارة المخاطر والحوكمة'],
      ['مشروع التخرج الأمني 1', 'مشروع التخرج الأمني 2', 'تمرين الفريق الأحمر والأزرق'],
    ]),
    _specialization('computer-engineering', 'هندسة الحاسوب', [
      ['أساسيات البرمجة', 'رياضيات 1', 'منطق رقمي'], ['برمجة منخفضة المستوى', 'رياضيات 2', 'معمارية الحاسوب'],
      ['دوائر ومنطق متقدم', 'هياكل البيانات', 'أنظمة التشغيل'], ['معمارية المعالجات', 'أنظمة مضمنة', 'شبكات الحاسوب'],
      ['تصميم الأنظمة الرقمية', 'إنترنت الأشياء', 'الأنظمة الزمنية الحقيقية'], ['معالجة الإشارة', 'الأنظمة المضمنة المتقدمة', 'الأمن العتادي'],
      ['الحوسبة المتوازية', 'تصميم الأنظمة', 'منهجية البحث'], ['مشروع التخرج 1', 'مشروع التخرج 2', 'ندوة هندسة الحاسوب'],
    ]),
    _specialization('graphics-hci', 'الرسوميات وتفاعل الإنسان والحاسوب', [
      ['أساسيات البرمجة', 'مبادئ التصميم', 'رياضيات للحوسبة'], ['برمجة واجهات المستخدم', 'تصميم تجربة المستخدم', 'رسوميات الحاسوب 1'],
      ['رسوميات الحاسوب 2', 'تفاعل الإنسان والحاسوب', 'تصميم المعلومات'], ['النمذجة ثلاثية الأبعاد', 'تصميم الألعاب', 'اختبار قابلية الاستخدام'],
      ['الرسوميات المتقدمة', 'الواقع الافتراضي', 'تصميم التفاعل'], ['الرؤية الحاسوبية', 'الواقع المعزز', 'الوسائط التفاعلية'],
      ['التصميم التفاعلي المتقدم', 'أبحاث HCI', 'منهجية البحث'], ['مشروع التخرج 1', 'مشروع التخرج 2', 'ندوة الرسوميات وHCI'],
    ]),
  ];

  static AcademicSpecialization _specialization(String id, String name, List<List<String>> semesters) {
    return AcademicSpecialization(
      id: id,
      name: name,
      years: List.generate(4, (yearIndex) => AcademicYear(
        number: yearIndex + 1,
        semesters: [
          AcademicSemester(number: 1, courses: semesters[yearIndex * 2].map((name) => _course(id, yearIndex + 1, 1, name)).toList()),
          AcademicSemester(number: 2, courses: semesters[yearIndex * 2 + 1].map((name) => _course(id, yearIndex + 1, 2, name)).toList()),
        ],
      )),
    );
  }

  static List<String> _knowledgeAreasFor(String courseName) {
    final n = courseName.toLowerCase();
    final areas = <String>{};

    void add(String id) => areas.add(id);

    if (n.contains('خوارزم') || n.contains('هياكل البيانات') || n.contains('algorithms') || n.contains('data structure')) add('AL');
    if (n.contains('معمار') || n.contains('منطق رقمي') || n.contains('architecture') || n.contains('processor')) add('AR');
    if (n.contains('ذكاء اصطناعي') || n.contains('تعلم الآلة') || n.contains('رؤية حاسوبية') || n.contains('معالجة اللغة') || n.contains('agents') || n.contains('ai')) add('AI');
    if (n.contains('قواعد البيانات') || n.contains('هندسة البيانات') || n.contains('data management') || n.contains('نمذجة البيانات')) add('DM');
    if (n.contains('لغات البرمجة') || n.contains('مترجمات') || n.contains('programming language') || n.contains('compiler')) add('FPL');
    if (n.contains('رسوميات') || n.contains('graphics') || n.contains('واقع افتراضي') || n.contains('واقع معزز')) add('GIT');
    if (n.contains('تفاعل') || n.contains('hci') || n.contains('تجربة المستخدم') || n.contains('قابلية الاستخدام')) add('HCI');
    if (n.contains('رياضيات') || n.contains('إحصاء') || n.contains('احتمال') || n.contains('math') || n.contains('statistics')) add('MSF');
    if (n.contains('شبك') || n.contains('network') || n.contains('اتصال')) add('NC');
    if (n.contains('نظم التشغيل') || n.contains('أنظمة التشغيل') || n.contains('operating system')) add('OS');
    if (n.contains('متواز') || n.contains('موزع') || n.contains('parallel') || n.contains('distributed')) add('PDC');
    if (n.contains('أمن') || n.contains('تشفير') || n.contains('security') || n.contains('cyber')) add('SEC');
    if (n.contains('أخلاقيات') || n.contains('المهنة') || n.contains('المجتمع') || n.contains('ethics') || n.contains('profession')) add('SEP');
    if (n.contains('برمجة') || n.contains('python') || n.contains('تطوير') || n.contains('programming')) add('SDF');
    if (n.contains('هندسة البرمجيات') || n.contains('software engineering') || n.contains('devops') || n.contains('اختبار البرمجيات')) add('SE');
    if (n.contains('مضمن') || n.contains('إنترنت الأشياء') || n.contains('embedded') || n.contains('mobile') || n.contains('متنقل')) add('SPD');
    if (n.contains('أساسيات الحوسبة') || n.contains('أنظمة الحاسوب') || n.contains('systems fundamentals')) add('SF');

    if (areas.isEmpty) add('SDF');
    return areas.toList(growable: false);
  }

  static List<String> _knowledgeUnitsFor(String courseName) {
    final n = courseName.toLowerCase();
    final units = <String>[];
    void add(String id) => units.add(id);

    if (n.contains('خوارز') || n.contains('هياكل البيانات') || n.contains('data structure')) { add('al-02'); add('al-03'); }
    if (n.contains('معمار') || n.contains('منطق رقمي') || n.contains('processor')) { add('ar-01'); add('ar-02'); }
    if (n.contains('ذكاء اصطناعي') || n.contains('تعلم الآلة') || n.contains('رؤية حاسوبية') || n.contains('معالجة اللغة') || n.contains('agents')) { add('ai-01'); add('ai-04'); }
    if (n.contains('قواعد البيانات') || n.contains('هندسة البيانات') || n.contains('نمذجة البيانات')) { add('dm-01'); add('dm-02'); }
    if (n.contains('لغات البرمجة') || n.contains('مترجمات') || n.contains('compiler')) { add('fpl-01'); add('fpl-04'); }
    if (n.contains('رسوميات') || n.contains('graphics') || n.contains('واقع افتراضي') || n.contains('واقع معزز')) { add('git-01'); add('git-05'); }
    if (n.contains('تفاعل') || n.contains('hci') || n.contains('تجربة المستخدم') || n.contains('قابلية الاستخدام')) { add('hci-02'); add('hci-04'); }
    if (n.contains('رياضيات') || n.contains('إحصاء') || n.contains('احتمال') || n.contains('math') || n.contains('statistics')) { add('msf-01'); add('msf-02'); }
    if (n.contains('شبك') || n.contains('network') || n.contains('اتصال')) { add('nc-01'); add('nc-03'); }
    if (n.contains('نظم التشغيل') || n.contains('أنظمة التشغيل') || n.contains('operating system')) { add('os-01'); add('os-03'); }
    if (n.contains('متواز') || n.contains('موزع') || n.contains('parallel') || n.contains('distributed')) { add('pdc-01'); add('pdc-04'); }
    if (n.contains('أمن') || n.contains('تشفير') || n.contains('security') || n.contains('cyber')) { add('sec-01'); add('sec-03'); }
    if (n.contains('أخلاقيات') || n.contains('المهنة') || n.contains('المجتمع') || n.contains('ethics') || n.contains('profession')) { add('sep-01'); add('sep-02'); }
    if (n.contains('برمجة') || n.contains('python') || n.contains('تطوير') || n.contains('programming')) { add('sdf-01'); add('sdf-04'); }
    if (n.contains('هندسة البرمجيات') || n.contains('software engineering') || n.contains('devops') || n.contains('اختبار البرمجيات')) { add('se-01'); add('se-03'); }
    if (n.contains('مضمن') || n.contains('إنترنت الأشياء') || n.contains('embedded') || n.contains('mobile') || n.contains('متنقل')) { add('spd-03'); add('spd-04'); }
    if (n.contains('أساسيات الحوسبة') || n.contains('أنظمة الحاسوب') || n.contains('systems fundamentals')) { add('sf-01'); add('sf-05'); }
    // If a course name does not match a specialized keyword, derive its
    // units from the canonical knowledge-area classification instead of
    // attaching unrelated programming content as a fallback.
    if (units.isEmpty) {
      for (final areaId in _knowledgeAreasFor(courseName)) {
        final areaUnits = AcademicKnowledgeUnitCatalog.forArea(areaId);
        if (areaUnits.isNotEmpty) add(areaUnits.first.id);
      }
    }
    return units.toSet().toList(growable: false);
  }

  static AcademicCourse _course(String specializationId, int year, int semester, String name) {
    final courseId = '${specializationId}-y$year-s$semester-${name.toLowerCase().replaceAll(' ', '-')}'
        .replaceAll('—', '-');

    // Generated global courses use a six-lesson depth model:
    // foundation -> core concepts -> application -> knowledge-unit deep dive 1
    // -> knowledge-unit deep dive 2 -> integration/capstone.
    final lessons = List<AcademicLesson>.generate(
      6,
      (index) => _generatedLesson(courseId: courseId, courseName: name, lessonNumber: index + 1),
    );

    return AcademicCourse(
      id: courseId,
      name: name,
      lessons: lessons,
      prerequisiteCourseIds: const [],
      knowledgeAreaIds: _knowledgeAreasFor(name),
      knowledgeUnitIds: _knowledgeUnitsFor(name),
      projects: [_courseProject(courseId: courseId, courseName: name, lessons: lessons)],
      units: [
        AcademicUnit(id: '$courseId-unit-1', title: 'الوحدة الأولى: المدخل والمفاهيم الأساسية', lessons: [lessons[0]]),
        AcademicUnit(id: '$courseId-unit-2', title: 'الوحدة الثانية: المفاهيم والمكونات', lessons: [lessons[1]]),
        AcademicUnit(id: '$courseId-unit-3', title: 'الوحدة الثالثة: التطبيقات الأساسية', lessons: [lessons[2]]),
        AcademicUnit(id: '$courseId-unit-4', title: 'الوحدة الرابعة: تعميق المعرفة المتخصصة', lessons: [lessons[3]]),
        AcademicUnit(id: '$courseId-unit-5', title: 'الوحدة الخامسة: التحليل والتطبيق المتقدم', lessons: [lessons[4]]),
        AcademicUnit(id: '$courseId-unit-6', title: 'الوحدة السادسة: التكامل والمشروع المصغر', lessons: [lessons[5]]),
      ],
      provenance: _libraryProvenance,
    );
  }

  static AcademicProject _courseProject({
    required String courseId,
    required String courseName,
    required List<AcademicLesson> lessons,
  }) {
    final skills = <String>{for (final lesson in lessons) ...lesson.skillIds}.toList(growable: false);
    final concepts = <String>{for (final lesson in lessons) ...lesson.conceptIds}.toList(growable: false);
    return AcademicProject(
      id: '$courseId-capstone',
      title: 'مشروع المقرر: $courseName',
      description: 'مشروع تكاملي يطلب من الطالب تحويل المعرفة والمهارات المتراكمة في مقرر «$courseName» إلى حل قابل للاختبار والتوثيق.',
      conceptIds: concepts,
      skillIds: skills,
      requirements: [
        'صياغة المشكلة والهدف ونطاق المشروع.',
        'استخدام المفاهيم والمهارات المكتسبة من دروس المقرر.',
        'تحديد المدخلات والمخرجات والقيود وحالات الفشل.',
      ],
      deliverables: [
        'تصميم أو مخطط للحل.',
        'تنفيذ أو نموذج أولي قابل للاختبار بحسب طبيعة المقرر.',
        'اختبارات ونتائج موثقة.',
        'تقرير يربط التنفيذ بالدروس والمهارات.',
      ],
      milestones: [
        'تحليل المتطلبات.',
        'التصميم.',
        'التنفيذ.',
        'الاختبار والتصحيح.',
        'التوثيق وعرض الدليل.',
      ],
      acceptanceCriteria: [
        'كل متطلب رئيسي له دليل تنفيذ أو تحليل.',
        'الاختبارات تغطي الحالات الطبيعية والحالات الحدية المناسبة.',
        'النتائج قابلة للتفسير والمراجعة.',
      ],
      implementationTasks: [
        'تحويل المتطلبات إلى مكونات أو خطوات قابلة للتنفيذ.',
        'تنفيذ كل مكون مع ربطه بالمفاهيم والمهارات التي يثبتها.',
        'دمج المكونات ثم تشغيل اختبار تكاملي قبل التسليم.',
      ],
      testCases: [
        'حالة استخدام طبيعية تحقق المخرج المتوقع.',
        'حالة حدية أو إدخال غير متوقع مناسب لطبيعة المشروع.',
        'حالة فشل متعمدة للتحقق من التشخيص والتعافي.',
      ],
      evidenceRequirements: [
        'دليل يربط كل مخرج بالدروس والمهارات المستخدمة.',
        'سجل اختبارات يوضح المدخلات والمخرجات والنتائج.',
        'توثيق للقرارات والقيود وما تم تغييره بعد الاختبار.',
      ],
      recommendedToolCategories: ['أدوات التطوير', 'أدوات الاختبار', 'أدوات التوثيق'],
    );
  }

  static AcademicLesson _generatedLesson({
    required String courseId,
    required String courseName,
    required int lessonNumber,
  }) {
    final units = _knowledgeUnitsFor(courseName);
    final specs = AcademicCourseLessonBlueprints.forCourse(courseName, units);
    final spec = specs[lessonNumber - 1];
    final lessonId = '$courseId-$lessonNumber';
    final conceptId = 'concept-$courseId-$lessonNumber';
    final skillId = 'skill-$courseId-$lessonNumber';

    return AcademicLesson(
      id: lessonId,
      title: spec.title,
      content: spec.content,
      definition: spec.definition,
      applications: spec.applications,
      errorAnalysisGuidance:
          'افصل بين تعريف المفهوم، والمدخلات والافتراضات، وخطوات التطبيق. حدّد أول خطوة تغيّرت فيها النتيجة، ثم أعد الاختبار بحالة مستقلة.',
      learningOutcomes: [
        'يشرح الطالب «${spec.topic}» بلغة علمية واضحة.',
        'يميز المكونات والعلاقات والافتراضات المرتبطة بالمفهوم.',
        'يطبق المفهوم على حالة جديدة مرتبطة بمقرر «$courseName».',
        'يحلل النتيجة ويبرر الاختيار ويحدد القيود.',
      ],
      keyTerms: spec.terms,
      examples: spec.examples,
      practices: [
        LessonPractice(
          id: '$lessonId-practice',
          title: 'تدريب متدرج: ${spec.title}',
          tasks: [
            PracticeTask(
              id: '$lessonId-p1',
              instruction: 'عرّف «${spec.topic}» وحدد البيانات أو الشروط التي تحتاجها قبل التطبيق.',
            ),
            PracticeTask(
              id: '$lessonId-p2',
              instruction: 'طبّق المفهوم على حالة جديدة وسجل الخطوات والافتراضات والنتيجة.',
            ),
            PracticeTask(
              id: '$lessonId-p3',
              instruction: 'غيّر قيدًا واحدًا، ثم حلّل الفرق وحدد سبب تغير النتيجة.',
            ),
          ],
        ),
      ],
      assessments: [
        LessonAssessment(
          id: '$lessonId-assessment',
          title: 'تقييم تحليلي: ${spec.title}',
          questions: [
            AssessmentQuestion(
              id: '$lessonId-q1',
              text: 'ما الذي يثبت فهم «${spec.topic}»؟',
              options: [
                'حفظ المصطلح فقط',
                'تطبيقه وتفسير أثره في سياق المقرر',
                'نسخ مثال دون تفسير',
                'تجاهل القيود',
              ],
              correctIndex: 1,
              learningOutcomeIndexes: [0],
              conceptIds: [conceptId],
              skillIds: [skillId],
            ),
            AssessmentQuestion(
              id: '$lessonId-q2',
              text: 'ما الذي يجب فحصه قبل قبول نتيجة تطبيقية؟',
              options: [
                'النتيجة النهائية فقط',
                'المدخلات والافتراضات والخطوات والقيود',
                'طول الحل',
                'اسم الأداة',
              ],
              correctIndex: 1,
              learningOutcomeIndexes: [1],
              conceptIds: [conceptId],
              skillIds: [skillId],
            ),
            AssessmentQuestion(
              id: '$lessonId-q3',
              text: 'كيف نختبر نقل المعرفة إلى مسألة جديدة؟',
              options: [
                'تكرار المثال نفسه',
                'حفظ التعريف',
                'حل حالة مختلفة وتحليل النتيجة',
                'تجاهل الحالات الحدية',
              ],
              correctIndex: 2,
              learningOutcomeIndexes: [2],
              conceptIds: [conceptId],
              skillIds: [skillId],
            ),
          ],
        ),
      ],
      projects: [
        AcademicProject(
          id: '$lessonId-project',
          title: 'مشروع تطبيقي: ${spec.title}',
          description:
              'أنجز تطبيقًا صغيرًا في «$courseName» يثبت فهم «${spec.topic}». وثّق المتطلبات والخطوات والاختبارات والنتيجة والقيود.',
          conceptIds: [conceptId],
          skillIds: [skillId],
        ),
      ],
      conceptIds: [conceptId],
      skillIds: [skillId],
      skillEvidence: [
        'يشرح المفهوم ويربطه بوحدات المعرفة في المقرر.',
        'يطبقه على حالة جديدة ويوثق خطواته.',
        'يحلل نتيجة أو خطأ ويقترح تحققًا أو تحسينًا قابلًا للقياس.',
      ],
      provenance: _libraryProvenance,
    );
  }

  static AcademicLesson _deepCurriculumLesson({
    required String courseId,
    required String courseName,
    required int lessonNumber,
  }) {
    return _generatedLesson(
      courseId: courseId,
      courseName: courseName,
      lessonNumber: lessonNumber,
    );
  }

  static String _definitionFor({
    required String topic,
    required String content,
  }) {
    final firstSentence = content.split(RegExp(r'[.!؟]')).first.trim();
    if (firstSentence.isNotEmpty) return '$firstSentence.';
    return 'يقصد بـ«$topic» المفهوم الذي يدرسه هذا الدرس ويستخدمه الطالب في التحليل والتطبيق.';
  }

  static List<LessonAssessment> _alignedAssessments({
    required List<LessonAssessment> assessments,
    required List<String> conceptIds,
    required List<String> skillIds,
    required int outcomeCount,
  }) {
    return assessments.map((assessment) {
      return LessonAssessment(
        id: assessment.id,
        title: assessment.title,
        questions: assessment.questions.asMap().entries.map((entry) {
          final index = entry.key;
          final question = entry.value;
          final outcome = index < outcomeCount ? index : outcomeCount - 1;
          return AssessmentQuestion(
            id: question.id,
            text: question.text,
            options: question.options,
            correctIndex: question.correctIndex,
            learningOutcomeIndexes: [outcome],
            conceptIds: conceptIds,
            skillIds: skillIds,
          );
        }).toList(),
      );
    }).toList();
  }

  static List<AcademicProject> _alignedProjects({
    required List<AcademicProject> projects,
    required List<String> conceptIds,
    required List<String> skillIds,
  }) {
    return projects.map((project) => AcademicProject(
      id: project.id,
      title: project.title,
      description: project.description,
      conceptIds: conceptIds,
      skillIds: skillIds,
    )).toList();
  }

  static List<LessonPractice> _practicesFor({
    required String lessonId,
    required String courseName,
    required String topic,
  }) {
    final n = courseName.toLowerCase();
    if (n.contains('أخلاقيات') || n.contains('المهنة') || n.contains('المجتمع') || n.contains('ethics') || n.contains('profession')) {
      return [
        LessonPractice(
          id: '$lessonId-practice',
          title: 'تدريب متدرج: التحليل الأخلاقي',
          tasks: [
            PracticeTask(id: '$lessonId-p1', instruction: 'حدد أصحاب المصلحة في موقف تقني مرتبط بـ«$topic»، ثم اذكر فائدة ومخاطرة محتملتين لكل طرف.'),
            PracticeTask(id: '$lessonId-p2', instruction: 'حلل موقفًا قصيرًا: حدد الوقائع والافتراضات والقيم المتعارضة، ثم قارن بديلين واذكر سبب اختيارك.'),
            PracticeTask(id: '$lessonId-p3', instruction: 'اكتب توصية مهنية قابلة للمراجعة تتضمن الخصوصية أو الملكية الفكرية أو الإتاحة أو الاستدامة بحسب الحالة، واذكر الدليل الذي تستند إليه.'),
          ],
        ),
      ];
    }
    if (n.contains('python')) {
      return [
        LessonPractice(id: '$lessonId-practice', title: 'تدريب متدرج: $topic', tasks: [
          PracticeTask(id: '$lessonId-p1', instruction: 'اكتب برنامجًا صغيرًا يستخدم مفهوم «$topic» مع مدخل واحد، ثم اشرح وظيفة كل سطر.'),
          PracticeTask(id: '$lessonId-p2', instruction: 'اختبر البرنامج بثلاث حالات مختلفة، وسجل المدخلات والمخرجات وأي خطأ ظهر وكيف عالجته.'),
          PracticeTask(id: '$lessonId-p3', instruction: 'عدّل البرنامج ليعالج حالة حدية جديدة، ثم برر أن التعديل لا يكسر السلوك السابق.'),
        ]),
      ];
    }
    if (n.contains('رياضيات') || n.contains('mathemat')) {
      return [
        LessonPractice(id: '$lessonId-practice', title: 'تدريب متدرج: $topic', tasks: [
          PracticeTask(id: '$lessonId-p1', instruction: 'اكتب التعريفات والرموز اللازمة لمسألة عن «$topic»، ثم حدد المعطيات والمطلوب.'),
          PracticeTask(id: '$lessonId-p2', instruction: 'حل المسألة خطوة بخطوة، واكتب القاعدة التي تبرر كل انتقال مهم في الحل.'),
          PracticeTask(id: '$lessonId-p3', instruction: 'أنشئ مثالًا مضادًا أو حالة حدية إن أمكن، ثم تحقق هل ما توصلت إليه صحيح دائمًا أم تحت شروط محددة.'),
        ]),
      ];
    }
    if (n.contains('ذكاء اصطناعي') || n.contains('ai')) {
      return [
        LessonPractice(id: '$lessonId-practice', title: 'تدريب متدرج: $topic', tasks: [
          PracticeTask(id: '$lessonId-p1', instruction: 'حدد المدخلات والمخرجات والهدف والقيود في مسألة ذكاء اصطناعي مرتبطة بـ«$topic».'),
          PracticeTask(id: '$lessonId-p2', instruction: 'اختر تمثيلًا أو خوارزمية مناسبة للمسألة، ثم اشرح سبب الاختيار وما الافتراضات التي تعتمد عليها.'),
          PracticeTask(id: '$lessonId-p3', instruction: 'اقترح طريقة تقييم للنتيجة، وحدد خطأً أو تحيزًا محتملًا وكيف يمكن اكتشافه.'),
        ]),
      ];
    }
    return [
      LessonPractice(
        id: '$lessonId-practice',
        title: 'تدريب متدرج: $topic',
        tasks: [
          PracticeTask(id: '$lessonId-p1', instruction: 'عرّف «$topic» وحدد عناصره الأساسية داخل مثال من مقرر «$courseName».'),
          PracticeTask(id: '$lessonId-p2', instruction: 'طبّق «$topic» على حالة صغيرة، وسجل خطوات الحل والافتراضات والنتيجة.'),
          PracticeTask(id: '$lessonId-p3', instruction: 'غيّر أحد المدخلات أو القيود، ثم حلل كيف ولماذا تغيرت النتيجة.'),
        ],
      ),
    ];
  }

  static List<LessonAssessment> _assessmentsFor({
    required String lessonId,
    required String courseName,
    required String title,
    required String topic,
  }) {
    final n = courseName.toLowerCase();
    if (n.contains('أخلاقيات') || n.contains('المهنة') || n.contains('المجتمع') || n.contains('ethics') || n.contains('profession')) {
      return [
        LessonAssessment(
          id: '$lessonId-assessment',
          title: 'تقييم: $title',
          questions: [
            AssessmentQuestion(id: '$lessonId-q1', text: 'في تحليل موقف تقني، ما البداية الأكثر فائدة؟', options: ['اختيار الحل قبل فهم المشكلة', 'تحديد الوقائع وأصحاب المصلحة', 'تجاهل الأطراف المتأثرة', 'الاعتماد على الانطباع الشخصي فقط'], correctIndex: 1),
            AssessmentQuestion(id: '$lessonId-q2', text: 'ما الذي يجعل التوصية المهنية قابلة للدفاع عنها؟', options: ['كونها أسرع حل فقط', 'إخفاء القيود والمخاطر', 'ربطها بالأدلة والقيم والالتزامات والآثار', 'تجنب توثيق القرار'], correctIndex: 2),
            AssessmentQuestion(id: '$lessonId-q3', text: 'أي موقف يمثل ممارسة مسؤولة؟', options: ['جمع كل البيانات بلا حاجة', 'تجاهل الترخيص', 'إخفاء مشكلة تؤثر في المستخدمين', 'حماية البيانات واحترام الحقوق وتوثيق المخاطر'], correctIndex: 3),
          ],
        ),
      ];
    }
    if (n.contains('python')) {
      return [
        LessonAssessment(
          id: '$lessonId-assessment',
          title: 'تقييم تطبيقي: $title',
          questions: [
            AssessmentQuestion(id: '$lessonId-q1', text: 'أي خيار يوضح فهم «$topic» في Python؟', options: ['حفظ اسم الدالة فقط', 'استخدامه في برنامج وشرح أثره على التنفيذ', 'نسخ الكود دون تشغيله', 'تجاهل نوع البيانات'], correctIndex: 1),
            AssessmentQuestion(id: '$lessonId-q2', text: 'عند ظهور مخرج غير متوقع، ما الإجراء الصحيح؟', options: ['تغيير المخرج يدويًا', 'حذف الاختبار', 'فحص المدخلات والأنواع وخطوات التنفيذ', 'افتراض أن البرنامج صحيح'], correctIndex: 2),
            AssessmentQuestion(id: '$lessonId-q3', text: 'ما الاختبار الأفضل للتحقق من برنامج صغير؟', options: ['حالة واحدة فقط', 'عدم الاختبار', 'اختبار المخرجات دون المدخلات', 'حالات عادية وحدية ومدخلات غير متوقعة'], correctIndex: 3),
          ],
        ),
      ];
    }
    if (n.contains('رياضيات') || n.contains('mathemat')) {
      return [
        LessonAssessment(
          id: '$lessonId-assessment',
          title: 'تقييم استدلالي: $title',
          questions: [
            AssessmentQuestion(id: '$lessonId-q1', text: 'ما الأساس الصحيح للحكم على حل مسألة «$topic»؟', options: ['الشكل النهائي فقط', 'التعريفات والشروط وخطوات الاستدلال', 'التخمين', 'حفظ مثال واحد'], correctIndex: 1),
            AssessmentQuestion(id: '$lessonId-q2', text: 'متى تكون النتيجة الرياضية مقيدة؟', options: ['عندما تكون مكتوبة بالأرقام فقط', 'عندما تكون طويلة', 'عندما تعتمد على شروط أو افتراضات محددة', 'عندما لا يمكن التحقق منها'], correctIndex: 2),
            AssessmentQuestion(id: '$lessonId-q3', text: 'ما أفضل طريقة لاختبار ادعاء عام؟', options: ['مثال واحد يؤيده فقط', 'تغيير التعريف', 'تجاهل الحالات الخاصة', 'برهان مناسب أو مثال مضاد عند الحاجة'], correctIndex: 3),
          ],
        ),
      ];
    }
    if (n.contains('ذكاء اصطناعي') || n.contains('ai')) {
      return [
        LessonAssessment(
          id: '$lessonId-assessment',
          title: 'تقييم تحليلي: $title',
          questions: [
            AssessmentQuestion(id: '$lessonId-q1', text: 'ما العامل الذي يجب تحديده قبل اختيار طريقة حل لمشكلة «$topic»؟', options: ['اسم الخوارزمية فقط', 'الهدف والبيانات والقيود', 'حجم الكود فقط', 'النتيجة المرغوبة دون بيانات'], correctIndex: 1),
            AssessmentQuestion(id: '$lessonId-q2', text: 'كيف نعرف أن نموذجًا أو خوارزمية مناسبة؟', options: ['بمجرد تشغيلها مرة', 'لأنها الأكثر تعقيدًا', 'بمقارنة أدائها بمقياس مناسب وعلى بيانات ملائمة', 'لأنها لا تحتاج اختبارًا'], correctIndex: 2),
            AssessmentQuestion(id: '$lessonId-q3', text: 'ما خطر تجاهل تحيز البيانات؟', options: ['يزيد دقة النظام دائمًا', 'يلغي الحاجة للتقييم', 'لا يؤثر في النتائج', 'قد ينتج النظام أداءً غير عادل أو غير موثوق لبعض الحالات'], correctIndex: 3),
          ],
        ),
      ];
    }
    return [
      LessonAssessment(
        id: '$lessonId-assessment',
        title: 'تقييم تحليلي: $title',
        questions: [
          AssessmentQuestion(id: '$lessonId-q1', text: 'ما الخطوة التي تثبت فهم «$topic»؟', options: ['حفظ المصطلح فقط', 'تطبيقه على حالة وتفسير النتيجة', 'نسخ المثال', 'تجاهل القيود'], correctIndex: 1),
          AssessmentQuestion(id: '$lessonId-q2', text: 'ما الذي يجب فحصه عند نتيجة غير متوقعة؟', options: ['النتيجة فقط', 'اسم الموضوع', 'المدخلات والافتراضات والخطوات والنتيجة', 'حذف الحالة'], correctIndex: 2),
          AssessmentQuestion(id: '$lessonId-q3', text: 'كيف نتحقق من جودة الحل؟', options: ['بزيادة طول الحل', 'بعدم تغيير المدخلات', 'بالاعتماد على الانطباع', 'باختبار مناسب وتفسير النتيجة ومراجعة القيود'], correctIndex: 3),
        ],
      ),
    ];
  }

  static List<AcademicProject> _projectsFor({
    required String lessonId,
    required String courseName,
    required String topic,
  }) {
    final n = courseName.toLowerCase();
    String description;
    if (n.contains('أخلاقيات') || n.contains('المهنة') || n.contains('المجتمع') || n.contains('ethics') || n.contains('profession')) {
      description = 'حلل حالة تقنية حقيقية أو افتراضية مرتبطة بـ«$topic». وثّق أصحاب المصلحة والوقائع والمخاطر والحقوق والبدائل، ثم قدم قرارًا مهنيًا مبررًا والضوابط المقترحة.';
    } else if (n.contains('python')) {
      description = 'ابنِ برنامج Python صغيرًا يطبق «$topic». وثّق المدخلات والمخرجات والخوارزمية والكود والاختبارات والأخطاء والتعديلات، ثم اشرح لماذا يعمل الحل.';
    } else if (n.contains('رياضيات') || n.contains('mathemat')) {
      description = 'أنجز دراسة أو نموذجًا رياضيًا صغيرًا حول «$topic». اذكر التعريفات والافتراضات والخطوات، ثم تحقق من النتيجة ببرهان أو أمثلة مناسبة.';
    } else if (n.contains('ذكاء اصطناعي') || n.contains('ai')) {
      description = 'صمّم تجربة صغيرة حول «$topic» في الذكاء الاصطناعي. حدد المشكلة والبيانات والطريقة ومقياس التقييم، ثم حلل النتائج والقيود والتحيزات المحتملة.';
    } else {
      description = 'أنجز مشروعًا مصغرًا في «$courseName» يطبق «$topic». وثّق المشكلة والمفاهيم والخطوات والنتيجة والاختبارات والأخطاء، ثم اشرح كيف تحققت من صحة الحل.';
    }
    return [
      AcademicProject(
        id: '$lessonId-project',
        title: 'مشروع تطبيقي: $topic',
        description: description,
      ),
    ];
  }

  static _LessonBlueprint _blueprintFor(String courseName) {
    final n = courseName.toLowerCase();

    if (n.contains('python')) {
      return _LessonBlueprint(
        titles: ['البرمجة والمتغيرات وأنواع البيانات', 'الإدخال والتعبيرات وتدفق التنفيذ', 'بناء برنامج Python واختباره'],
        topics: ['المتغيرات وأنواع البيانات والعمليات الأساسية', 'input والتحويل والتعبيرات وترتيب التنفيذ', 'تحويل مشكلة بسيطة إلى خوارزمية وبرنامج واختباره'],
        terms: ['متغير', 'str', 'int', 'float', 'input', 'تعبير', 'خوارزمية'],
        content: [
          'تبدأ البرمجة بتحويل المشكلة إلى بيانات وتعليمات. في Python يشير المتغير إلى قيمة باسم يمكن للبرنامج استخدامها وتحديثها. من الأنواع الأساسية النص str والأعداد int وfloat والقيم المنطقية bool. اختيار النوع جزء من فهم المشكلة لأن العمليات المتاحة تعتمد على طبيعة القيمة.',
          'تقرأ الدالة input الإدخال من المستخدم كنص. عندما نحتاج إلى عدد نستخدم تحويلًا مثل int أو float. بعد ذلك يمكن بناء تعبيرات باستخدام + و- و* و/ و// و% و**. يجب الانتباه إلى ترتيب العمليات وإلى الفرق بين القيمة النصية والقيمة العددية.',
          'في التطبيق العملي نحدد المدخلات والمخرجات والخطوات، ثم نحولها إلى كود. بعد التنفيذ نختبر حالات عادية وحالات حدية ونراجع الأخطاء. الهدف ليس حفظ الصيغة، بل القدرة على تفسير كل سطر وسبب وجوده.',
        ],
      );
    }

    if (n.contains('رياضيات') || n.contains('mathemat')) {
      return _LessonBlueprint(
        titles: ['اللغة الرياضية والتعريفات', 'العمليات والعلاقات والاستدلال', 'النمذجة الرياضية لمشكلة حاسوبية'],
        topics: ['المجموعات والرموز والتعريفات الدقيقة', 'العلاقات والعمليات وبناء استدلال صحيح', 'تحويل مشكلة حاسوبية إلى نموذج رياضي'],
        terms: ['مجموعة', 'عنصر', 'علاقة', 'اتحاد', 'تقاطع', 'استدلال', 'برهان'],
        content: [
          'الرياضيات المتقطعة توفر لغة دقيقة لوصف الكيانات والعلاقات التي تظهر في علوم الحاسوب. المجموعة تجميع محدد من عناصر مميزة، ويمكن التعبير عن الانتماء والمساواة والاحتواء باستخدام رموز واضحة.',
          'تسمح العمليات مثل الاتحاد والتقاطع والفرق ببناء مجموعات جديدة، بينما تمثل العلاقة ارتباطًا بين عناصر ويمكن وصفها بالأزواج المرتبة. صحة النتيجة تعتمد على التعريفات والشروط، وليس على التخمين.',
          'في الحوسبة نستخدم النماذج الرياضية لوصف البيانات والعلاقات والخوارزميات. يبدأ الحل بتحديد الكيانات والافتراضات، ثم صياغة العلاقة أو القاعدة، ثم التحقق من النتيجة بمثال أو برهان مناسب.',
        ],
      );
    }

    if (n.contains('ذكاء اصطناعي') || n.contains('ai')) {
      return _LessonBlueprint(
        titles: [
          'أساسيات الذكاء الاصطناعي والوكلاء وخصائص المشكلات',
          'تمثيل المشكلات والبحث: من فضاء الحالات إلى A*',
          'أساسيات التعلم الآلي والبيانات والتقييم',
        ],
        topics: [
          'تعريف الذكاء الاصطناعي، الوكيل، البيئة، والخصائص التي تؤثر في اختيار الحل',
          'صياغة المشكلة كفضاء حالات ومقارنة BFS وDFS وUniform Cost وGreedy وA*',
          'التعلم الخاضع للإشراف، البيانات، فرط التوافق، التقييم، والتحيز',
        ],
        terms: [
          'ذكاء اصطناعي',
          'وكيل',
          'بيئة',
          'حالة',
          'فضاء حالات',
          'بحث',
          'دالة إرشادية',
          'تعلم آلي',
          'تعميم',
          'تحيز',
        ],
        content: [
          '''الذكاء الاصطناعي مجال من علوم الحاسوب يهتم ببناء أنظمة قادرة على تنفيذ مهام تتطلب قدرًا من الاستدلال أو التعلم أو التخطيط أو الإدراك. لا يعني ذلك أن النظام «يفكر مثل الإنسان» بالضرورة؛ يمكن تقييم النظام وفق السلوك والهدف والبيئة التي يعمل فيها.

الوكيل الذكي يستقبل ملاحظات من البيئة ثم يختار أفعالًا وفق هدف أو معيار أداء. لفهم الوكيل نحدد: ما البيئة؟ ماذا يستطيع أن يلاحظ؟ ما الأفعال المتاحة؟ وما معيار النجاح؟ تختلف المشكلات بحسب كون البيئة كاملة أو جزئية الملاحظة، حتمية أو احتمالية، ساكنة أو ديناميكية، منفردة أو متعددة الوكلاء.

مثال: في نظام تعليمي ذكي، الطالب جزء من البيئة، وتوجد ملاحظات مثل نتائج الاختبارات والتقدم، بينما يمكن للوكيل اختيار أفعال مثل اقتراح درس أو تدريب. لا يكفي أن نقول «النظام ذكي»؛ يجب تحديد الهدف، المدخلات، الأفعال، ومعيار تقييم القرار.

التمييز المهم: الذكاء الاصطناعي هو المجال الأوسع، والتعلم الآلي أسلوب من أساليبه يعتمد على التعلم من البيانات، بينما التعلم العميق يعتمد عادة على شبكات عصبية متعددة الطبقات. هذه المصطلحات ليست مترادفة.''',
          '''تبدأ مشكلة البحث بتحديد الحالة الابتدائية، مجموعة الحالات الممكنة، العمليات التي تنقلنا بين الحالات، وحالة الهدف. يسمى هذا التمثيل فضاء الحالات. بعد ذلك نختار استراتيجية بحث مناسبة.

في البحث بعرض الشجرة BFS نستكشف عادة المستوى الأقرب قبل الانتقال إلى مستويات أعمق، بينما DFS يتجه إلى العمق قبل الرجوع. البحث ذو الكلفة الموحدة يختار المسار ذي الكلفة المتراكمة الأقل، لذلك يناسب الحالات التي تختلف فيها كلفة الانتقالات.

البحث الموجّه يستخدم دالة إرشادية h(n) لتقدير الكلفة المتبقية. في A* تجمع الأولوية بين الكلفة التي دُفعت حتى العقدة g(n) والتقدير h(n): f(n)=g(n)+h(n). عندما تكون الدالة الإرشادية مناسبة، يمكن أن تساعد على تقليل الاستكشاف مقارنة ببحث غير موجّه، مع بقاء صحة الحل مرتبطة بخصائص الخوارزمية والافتراضات.

مثال: في إيجاد طريق بين مدن، تمثل المدينة حالة، والطريق انتقالًا، والمسافة كلفة. إذا كانت لدينا مسافة تقديرية إلى الهدف يمكن استخدامها كإرشاد. يجب على الطالب تتبع قائمة العقد خطوة بخطوة، لا الاكتفاء بمعرفة اسم الخوارزمية.

كما ندرس التعقيد الزمني والذاكري؛ فقد تكون الخوارزمية صحيحة لكنها غير عملية عندما يكبر فضاء الحالات.''',
          '''التعلم الآلي يبني نموذجًا يستفيد من البيانات لإجراء تنبؤ أو تصنيف أو اكتشاف بنية. في التعلم الخاضع للإشراف تكون لدينا أمثلة مع مخرجات معروفة؛ التصنيف يتنبأ بفئة، والانحدار يتنبأ بقيمة. في التعلم غير الخاضع للإشراف نبحث عن بنية في بيانات غير معنونة، مثل التجميع.

تبدأ دورة العمل بتحديد الهدف، ثم جمع البيانات وفحصها وتنظيفها وتمثيلها، ثم تقسيمها أو اختيار طريقة تحقق مناسبة، ثم تدريب النموذج، ثم تقييمه على بيانات لم يستخدمها في التدريب. إذا كان النموذج شديد التخصص في بيانات التدريب فقد يحدث فرط توافق، فيضعف التعميم على بيانات جديدة.

اختيار مقياس التقييم يعتمد على المشكلة. الدقة قد لا تكون كافية في حالة عدم توازن الفئات، ولذلك يمكن دراسة precision وrecall ومقاييس أخرى بحسب الهدف. يجب كذلك فحص مصادر التحيز: البيانات قد لا تمثل السكان المستهدفين، أو قد يحتوي القياس نفسه على تحيز، أو قد تؤدي طريقة التقييم إلى استنتاج مضلل.

مثال: إذا بنينا نموذجًا لتصنيف رسائل البريد، فلا يكفي أن نحصل على رقم مرتفع على بيانات التدريب. نحتاج إلى اختبار على بيانات جديدة، وفحص الأخطاء، ومعرفة الحالات التي يفشل فيها النموذج، ثم تفسير هل مستوى الأداء مناسب للغرض المقصود.

الهدف من هذا الدرس هو أن يستطيع الطالب شرح دورة التعلم الآلي، اختيار تقييم مناسب، وذكر حدود النموذج بدل التعامل مع مخرجاته كحقيقة مطلقة.''',
        ],
      );
    }

    if (n.contains('شبك') || n.contains('network')) {
      return _LessonBlueprint(
        titles: ['بنية الشبكات وانتقال البيانات', 'البروتوكولات والعنونة والتوجيه', 'تشخيص شبكة وتصميم اتصال'],
        topics: ['الأجهزة والطبقات ومسار حزمة البيانات', 'العناوين والبروتوكولات والتوجيه بين الشبكات', 'تحليل مشكلة اتصال وتصميم شبكة مناسبة'],
        terms: ['حزمة', 'بروتوكول', 'عنوان IP', 'توجيه', 'منفذ', 'طبقة'],
        content: [
          'الشبكة تربط أجهزة لتبادل البيانات. تنتقل البيانات في صورة وحدات منظمة، وتؤدي الأجهزة المختلفة أدوارًا مثل التوصيل أو التوجيه. يساعد التقسيم إلى طبقات في فصل المسؤوليات وفهم أين تحدث كل وظيفة.',
          'يحدد العنوان وجهة البيانات، بينما يحدد البروتوكول قواعد الاتصال. يعمل التوجيه على اختيار مسار مناسب للوصول إلى شبكة أو جهاز آخر. لفهم المشكلة يجب التمييز بين مشكلة العنوان، ومشكلة المسار، ومشكلة الخدمة أو المنفذ.',
          'تشخيص الشبكة يبدأ بتحديد ما يعمل وما لا يعمل، ثم اختبار الاتصال تدريجيًا من الطبقة الأقرب إلى الجهاز حتى الخدمة المطلوبة. التصميم الجيد يوازن بين المتطلبات والأداء والموثوقية والأمن وقابلية الإدارة.',
        ],
      );
    }

    if (n.contains('قواعد البيانات')) {
      return _LessonBlueprint(
        titles: ['نمذجة البيانات والكيانات والعلاقات', 'الاستعلام وجودة البيانات', 'تصميم قاعدة بيانات لمشكلة واقعية'],
        topics: ['الكيانات والسمات والعلاقات والقيود', 'استرجاع البيانات والتحقق من صحتها', 'تحويل متطلبات واقعية إلى نموذج بيانات'],
        terms: ['كيان', 'سمة', 'علاقة', 'مفتاح', 'استعلام', 'قيد'],
        content: [
          'قاعدة البيانات تنظم بيانات مترابطة بحيث يمكن تخزينها واسترجاعها وتحديثها. تبدأ النمذجة بتحديد الكيانات التي نحتاج إلى حفظ معلومات عنها، ثم السمات التي تصفها والعلاقات بينها.',
          'الاستعلام يحدد المعلومات المطلوبة من البيانات. جودة البيانات تتطلب الانتباه إلى القيم الناقصة والتكرار والأنواع والقيود. المفاتيح والقيود تساعد على الحفاظ على الاتساق ومنع حالات غير صحيحة.',
          'عند بناء حل واقعي نبدأ بالمتطلبات، ثم نرسم الكيانات والعلاقات، ونحدد المفاتيح، ثم نختبر حالات الإدخال والاستعلام. التصميم الجيد يجعل البيانات قابلة للفهم والتحديث ويقلل المشكلات الناتجة عن التكرار والتناقض.',
        ],
      );
    }

    if (n.contains('اختبار الاختراق') || n.contains('ethical hacking') || n.contains('الهجوم والدفاع') || n.contains('تمرين الفريق الأحمر') || n.contains('تقييم الاختراق')) {
      return _LessonBlueprint(
        titles: [
          'منهجية الاختبار الأخلاقي ونطاق العمل',
          'اختبار تطبيقات الويب والتحكم في الوصول',
          'التقرير والمعالجة والتحقق من الإصلاح',
        ],
        topics: [
          'النطاق والتفويض ونموذج التهديد والاستطلاع المصرح به',
          'اختبار نقاط الدخول والمصادقة والتفويض وإدارة الجلسات في مختبر آمن',
          'توثيق الأدلة وتصنيف المخاطر والتوصيات وإعادة الاختبار',
        ],
        terms: [
          'اختبار اختراق', 'هكر أخلاقي', 'نطاق', 'تفويض', 'سطح هجوم',
          'نقطة دخول', 'مصادقة', 'تفويض', 'جلسة', 'ثغرة', 'دليل',
          'تقرير', 'إعادة اختبار', 'معالجة',
        ],
        content: [
          '''اختبار الاختراق الأخلاقي نشاط أمني مصرح به يهدف إلى اكتشاف نقاط ضعف يمكن معالجتها قبل أن يستغلها مهاجم. يبدأ العمل بتحديد نطاق واضح، والأصول المسموح باختبارها، وما هو خارج النطاق، وقواعد الاشتباك، وطريقة الإبلاغ عن النتائج. لا يتحول «الهكر الأخلاقي» إلى اختراق عشوائي؛ قيمة الاختبار تأتي من التفويض والتوثيق والقدرة على إعادة إنتاج النتيجة داخل الحدود المحددة.

تتضمن منهجية الاختبار فهم بنية التطبيق، تحديد نقاط الدخول، تحليل المصادقة والتفويض والجلسات، ثم اختيار اختبارات مناسبة للمخاطر. يعتمد هذا المسار على منهجيات اختبار معروفة مثل OWASP WSTG، الذي ينظم اختبار تطبيقات الويب إلى مجالات تشمل جمع المعلومات وإدارة الهوية والمصادقة والتفويض والجلسات والتحقق من المدخلات وغيرها. في TOFAN تُنفذ التدريبات الهجومية داخل مختبرات تعليمية أو أهداف يملك الطالب تفويضًا صريحًا لاختبارها.''',
          '''في اختبار تطبيق ويب، نبدأ برسم سطح الهجوم وتحديد نقاط الدخول والطلبات والمعاملات التي يعالجها التطبيق. بعد ذلك نفحص الضوابط مثل المصادقة والتفويض وإدارة الجلسات والتحقق من المدخلات، مع الحفاظ على نطاق الاختبار وعدم إحداث ضرر غير ضروري.

من الأمثلة التعليمية الآمنة التحقق من أن مستخدمًا عاديًا لا يستطيع الوصول إلى وظيفة إدارية، أو أن مستخدمًا لا يستطيع قراءة مورد يخص مستخدمًا آخر داخل مختبر مصمم لهذا الغرض. يركز الاختبار على إثبات وجود أو غياب الضابط، ثم تسجيل الدليل، بدل تحويل الدرس إلى تعليمات لاستهداف أنظمة حقيقية. هذا يتوافق مع تركيز OWASP WSTG على اختبار تجاوز الصلاحيات الأفقية والرأسية والتحقق من تطبيق أدوار الوصول.''',
          '''نتيجة الاختبار الأمني الجيدة ليست «وجدت ثغرة» فقط. يجب أن يتضمن التقرير النطاق، والمنهجية، والأصل المتأثر، والخطوات القابلة لإعادة الإنتاج في البيئة المصرح بها، والأثر، وشدة الخطر، والدليل، والتوصية، ثم نتيجة إعادة الاختبار بعد المعالجة.

يتعلم الطالب الفصل بين الدليل والاستنتاج، وعدم نشر أسرار أو بيانات حساسة غير لازمة، وتحديد ما إذا كان الإصلاح أغلق السبب الجذري أم غيّر السلوك الظاهر فقط. ويجب أن تقيس التمارين مهارات مثل اكتشاف ضعف في التفويض داخل مختبر، كتابة تقرير واضح، اقتراح معالجة، ثم التحقق من أن المعالجة نجحت.''',
        ],
      );
    }

    if (n.contains('أمن') || n.contains('security') || n.contains('تشفير')) {
      return _LessonBlueprint(
        titles: [
          'الأصول والتهديدات والثغرات ونموذج المخاطر',
          'الهوية والصلاحيات والتشفير والدفاع متعدد الطبقات',
          'العزل وتقسيم الشبكات وقواعد البيانات والاستجابة للحوادث',
        ],
        topics: [
          'تحديد الأصول والتهديدات والثغرات والأثر وبناء نموذج خطر',
          'المصادقة والتفويض وأقل صلاحية والتشفير وحماية البيانات',
          'التقسيم والعزل والمراقبة واحتواء الاختراق واستعادة الخدمة',
        ],
        terms: [
          'أصل', 'تهديد', 'ثغرة', 'خطر', 'ضابط', 'سرية', 'سلامة',
          'توافر', 'مصادقة', 'تفويض', 'أقل صلاحية', 'تشفير',
          'تقسيم الشبكة', 'عزل', 'سجل تدقيق', 'احتواء',
        ],
        content: [
          '''الأمن السيبراني هو ممارسة حماية الأنظمة والبيانات والخدمات من المخاطر التي قد تؤثر في السرية أو السلامة أو التوافر. يبدأ التحليل بحصر الأصول، ثم تحديد التهديدات والثغرات والآثار والافتراضات. لا يكفي ذكر «هجوم»؛ يجب وصف الأصل المستهدف ومسار التهديد والنتيجة المتوقعة والضابط الذي يقلل الخطر.

يُبنى نموذج الخطر من سيناريو واضح يمكن اختباره. نحدد ما الذي نحاول حمايته، ومن أين يمكن أن يأتي التهديد، وما الحدود الموثوقة، وما الأدلة التي نحتاجها للتحقق. هذا الأسلوب يجعل الأمن جزءًا من هندسة النظام بدل أن يكون خطوة أخيرة بعد البناء.''',
          '''تبدأ الحماية من هوية يمكن التحقق منها ثم صلاحية محددة للعمل المطلوب. المصادقة تثبت الهوية، والتفويض يحدد ما يجوز للهوية فعله. مبدأ أقل صلاحية يعني منح الحد الأدنى اللازم، مع فصل حسابات الخدمات والمهام الحساسة بدل استخدام حساب إداري واحد لكل شيء.

يحمي التشفير البيانات وفق الغرض وآلية إدارة المفاتيح، لكنه لا يعوض عن التحكم في الوصول أو سلامة التصميم. الدفاع متعدد الطبقات يجمع ضوابط مختلفة بحيث لا يؤدي فشل طبقة واحدة إلى فتح النظام بالكامل. يجب كذلك تسجيل العمليات الحساسة حتى يمكن اكتشاف السلوك غير المتوقع والتحقيق فيه.''',
          '''العزل وتقسيم الشبكات والمصادر يقللان من انتقال المهاجم بين أجزاء النظام. في مكتبة TOFAN لا تُعامل كل المعرفة كمخزن واحد مفتوح؛ تُقسم إلى نطاقات حماية، ولا يسمح بالوصول بين النطاقات إلا عبر سياسة صريحة. لذلك فإن وكيل التعلم لا يحصل على صلاحية قاعدة البيانات نفسها، بل يمر عبر واجهة استرجاع محكومة بالهوية والسياسة والنطاق.

عند اكتشاف اختراق، لا يكون الهدف إخفاء المشكلة، بل احتواء الجزء المتأثر، إلغاء الاعتمادات المتضررة، حفظ أدلة التدقيق، منع الانتقال الجانبي، ثم الاستعادة من حالة موثوقة. في التدريب العملي يجب أن يكون الاختبار مصرحًا به وعلى بيئة آمنة، وتُقاس الحماية بنتائج قابلة للتحقق مثل نسبة الصلاحيات غير الضرورية التي أزيلت أو زمن اكتشاف الحادث واحتوائه.''',
        ],
      );
    }

    if (n.contains('هندسة البرمجيات') || n.contains('software') || n.contains('devops')) {
      return _LessonBlueprint(
        titles: ['دورة حياة البرمجيات والمتطلبات', 'التصميم والاختبار وضمان الجودة', 'التكامل والتسليم والصيانة'],
        topics: ['المشكلة وأصحاب المصلحة والمتطلبات', 'تحويل المتطلبات إلى تصميم قابل للاختبار', 'إدارة التغيير والتكامل والتسليم والصيانة'],
        terms: ['متطلب', 'معمارية', 'اختبار', 'إصدار', 'تكامل', 'صيانة'],
        content: [
          'هندسة البرمجيات تتعامل مع بناء البرمجيات بطريقة منظمة قابلة للقياس والصيانة. يبدأ العمل بفهم المشكلة وأصحاب المصلحة وتحديد المتطلبات الوظيفية وغير الوظيفية، ثم تحويلها إلى خطة تنفيذ قابلة للتحقق.',
          'التصميم يحدد بنية الحل والعلاقات بين مكوناته. الاختبار لا يثبت أن البرنامج خالٍ من كل الأخطاء، لكنه يوفر أدلة على سلوك محدد وفق حالات اختبار واضحة. الجودة تشمل قابلية الصيانة والاعتمادية والأداء والأمن وغيرها من الخصائص.',
          'إدارة الإصدارات والتكامل المستمر تساعد الفريق على اكتشاف المشكلات مبكرًا. الصيانة تشمل إصلاح العيوب والتكيف مع التغييرات وتحسين النظام. المشروع الجيد يوثق القرارات والاختبارات ونتائجها بدل الاعتماد على الذاكرة.',
        ],
      );
    }

    if (n.contains('الواقع الافتراضي') || n.contains('الواقع المعزز') || n.contains('virtual reality') || n.contains('augmented reality') || n.contains('mixed reality') || n.contains('extended reality') || n.contains('xr')) {
      return _LessonBlueprint(
        titles: ['أساسيات الواقع الافتراضي والمعزز والتفاعل المكاني', 'بناء التجربة وتتبع المستخدم والبيئة', 'تقييم تجربة XR والسلامة وقابلية الاستخدام'],
        topics: [
          'الفرق بين الواقع الافتراضي والواقع المعزز والواقع الممتد ونماذج التفاعل',
          'تتبع الوضعية والبيئة ونمذجة المشهد وتصميم التفاعل المكاني',
          'تقييم تجربة XR من حيث الأداء والراحة والسلامة وقابلية الاستخدام',
        ],
        terms: ['واقع افتراضي', 'واقع معزز', 'واقع ممتد', 'تتبع', 'وضعية', 'مشهد', 'تفاعل مكاني', 'قابلية استخدام'],
        content: [
          'الواقع الافتراضي ينشئ بيئة رقمية يشعر المستخدم بأنه يتفاعل معها، بينما يضيف الواقع المعزز عناصر رقمية إلى البيئة المادية. يشير الواقع الممتد إلى مجموعة تقنيات تجمع أنماطًا مختلفة من المزج بين العالمين. يبدأ التصميم بتحديد المهمة والمستخدم والبيئة ووسيلة الإدخال والإخراج.',
          'تحتاج تجارب XR إلى تمثيل للمشهد وتتبع لحركة المستخدم أو الجهاز بحسب التطبيق. يجب أن يكون التفاعل متوافقًا مع الإدراك المكاني وألا يفرض على المستخدم خطوات غير ضرورية. عند تصميم تجربة تعليمية، نحدد ما الذي يجب أن يراه الطالب وما الذي يجب أن يفعله وكيف تسجل المنصة أدلة التعلم.',
          'لا تقاس جودة تجربة XR بالمظهر فقط. يجب فحص زمن الاستجابة ومعدل الإطارات ودقة التتبع والراحة والسلامة وقابلية الاستخدام، مع اختبار التجربة على حالات مستخدمين مختلفة. المشروع الجيد يحدد معيار نجاح قابلًا للقياس ويجمع ملاحظات المستخدم ثم يحسن التصميم بناءً عليها.',
        ],
      );
    }

    if (n.contains('رسوميات') || n.contains('graphics') || n.contains('تفاعل') || n.contains('hci') || n.contains('تصميم')) {
      return _LessonBlueprint(
        titles: ['المستخدم والمشكلة وسياق الاستخدام', 'التصميم البصري والتفاعل', 'النمذجة والاختبار والتحسين'],
        topics: ['فهم المستخدم والهدف والقيود', 'تنظيم المعلومات والعناصر ومسارات التفاعل', 'اختبار قابلية الاستخدام وتكرار التصميم'],
        terms: ['مستخدم', 'واجهة', 'تفاعل', 'نموذج أولي', 'قابلية الاستخدام'],
        content: [
          'يبدأ التصميم الجيد بفهم المستخدم والسياق والهدف، وليس باختيار الألوان أو الأدوات أولًا. نحدد المهمة التي يريد المستخدم إنجازها، القيود، المعلومات المطلوبة، ونقاط التعثر المحتملة.',
          'تنظيم الواجهة يهدف إلى جعل المعلومات والإجراءات مفهومة وقابلة للتنبؤ. الاتساق والتغذية الراجعة والوضوح وتقليل الحمل المعرفي تساعد المستخدم على إكمال المهمة دون ارتباك.',
          'النموذج الأولي يسمح باختبار الفكرة قبل تنفيذها بالكامل. في اختبار قابلية الاستخدام نراقب المهام والأخطاء والوقت وملاحظات المستخدمين، ثم نعدل التصميم بناءً على الأدلة. التصميم عملية تكرارية وليست قرارًا نهائيًا من المحاولة الأولى.',
        ],
      );
    }

    if (n.contains('معمارية الحاسوب') || n.contains('computer architecture') || n.contains('architecture') || n.contains('تنظيم الحاسوب')) {
      return _LessonBlueprint(
        titles: ['تمثيل البيانات وبنية الحاسوب', 'المعالج والذاكرة وتنفيذ التعليمات', 'تحليل أداء نظام حاسوبي'],
        topics: ['التمثيل الثنائي والمنطق ومكونات النظام الأساسية', 'دورة تنفيذ التعليمات والعلاقة بين المعالج والذاكرة', 'مقارنة تصميمين حاسوبيين وفق الأداء والقيود'],
        terms: ['تمثيل ثنائي', 'بوابة منطقية', 'معالج', 'ذاكرة', 'تعليمة', 'سجل', 'ناقل', 'ذاكرة مخبئية'],
        content: [
          'تشرح معمارية الحاسوب كيف تتعاون المكونات المادية لتنفيذ البرامج. يبدأ الفهم بتمثيل المعلومات رقميًا، ثم التعرف على المعالج والذاكرة وأجهزة الإدخال والإخراج ومسارات الاتصال بينها. التمثيل الثنائي مهم لأن الدوائر الرقمية تعمل على حالات منطقية محددة.',
          'تنفذ وحدة المعالجة التعليمات عبر دورة تتضمن جلب التعليمة وفكها وتنفيذها وحفظ النتيجة بحسب تصميم المعالج. السجلات توفر تخزينًا سريعًا داخل المعالج، بينما تؤثر الذاكرة المخبئية وترتيب مستويات الذاكرة في زمن الوصول إلى البيانات. فهم هذه العلاقة يساعد الطالب على تفسير لماذا لا يعتمد الأداء على سرعة المعالج وحدها.',
          'عند مقارنة نظامين لا يكفي النظر إلى تردد المعالج. يجب تحديد عبء العمل، حجم الذاكرة وسرعة الوصول، طبيعة التعليمات، وقيود الطاقة أو التكلفة، ثم اختيار مؤشرات قياس مناسبة. التحليل الجيد يربط النتيجة بسبب معماري واضح بدل إطلاق حكم عام على النظام.',
        ],
      );
    }

    if (n.contains('لغات البرمجة') || n.contains('programming language') || n.contains('برمجة لغات') || n.contains('مبادئ البرمجة')) {
      return _LessonBlueprint(
        titles: ['مفاهيم لغات البرمجة ونماذجها', 'الأنواع والتجريد وتنفيذ البرامج', 'مقارنة لغات البرمجة واختيارها'],
        topics: ['النحو والدلالة والنماذج البرمجية', 'أنظمة الأنواع والتجريد ونموذج تنفيذ البرنامج', 'مقارنة لغة أو نموذجين وفق المشكلة والقيود'],
        terms: ['نحو', 'دلالة', 'نموذج برمجي', 'نوع', 'تجريد', 'مترجم', 'مفسر', 'وقت التشغيل'],
        content: [
          'لغة البرمجة وسيلة رسمية لوصف الحلول والخوارزميات بصورة يمكن للإنسان قراءتها ومعالجتها آليًا. لفهم اللغة نميز بين النحو الذي يحدد شكل البرنامج، والدلالة التي تشرح معنى البرنامج وسلوكه، والنموذج البرمجي الذي يحدد طريقة تنظيم الحل والتعبير عنه.',
          'نظام الأنواع يحدد القيم والعمليات التي يسمح بها البرنامج وكيف تكتشف بعض الأخطاء. التجريد يسمح للمبرمج بإخفاء تفاصيل غير ضرورية خلف واجهة أو بنية مفهومة. عند التنفيذ تتحول البرامج عبر آليات مثل التفسير أو الترجمة إلى تمثيل يمكن للنظام تشغيله، مع وجود مكونات وقت تشغيل تدير بعض الموارد والسلوك.',
          'اختيار لغة البرمجة لا يعتمد على شهرتها فقط. نحدد طبيعة المشكلة، النموذج البرمجي المناسب، متطلبات الأداء والسلامة والصيانة، المكتبات والأدوات، ثم نقارن البدائل بالأدلة. دراسة أكثر من لغة تساعد الطالب على نقل المفاهيم الأساسية بدل ربط المعرفة بلغة واحدة فقط.',
        ],
      );
    }

    if (n.contains('الحوسبة المتوازية') || n.contains('الحوسبة الموزعة') || n.contains('parallel') || n.contains('distributed') || n.contains('concurrent')) {
      return _LessonBlueprint(
        titles: ['أساسيات الحوسبة المتوازية والموزعة', 'التواصل والتزامن بين العمليات', 'تحليل أداء الأنظمة المتوازية والموزعة'],
        topics: ['التوازي والتزامن والتوزيع وتقسيم المشكلة', 'الذاكرة المشتركة وتمرير الرسائل والتزامن', 'التسارع والكفاءة والتأخير والتعامل مع الأعطال'],
        terms: ['توازي', 'تزامن', 'توزيع', 'خيط', 'ذاكرة مشتركة', 'تمرير رسائل', 'سباق بيانات', 'تسارع'],
        content: [
          'الحوسبة المتوازية والموزعة تنظم عدة عمليات حسابية يمكن تنفيذها في الوقت نفسه أو عبر مواقع حاسوبية مختلفة. يبدأ الفهم بالتمييز بين التنفيذ المتسلسل والتوازي والتزامن والتوزيع، ثم تقسيم المشكلة إلى أجزاء يمكن تنفيذها بصورة مستقلة أو منسقة.',
          'تحتاج العمليات المتوازية والموزعة إلى التواصل والتنسيق عندما تعتمد النتائج بعضها على بعض. يمكن استخدام الذاكرة المشتركة أو تمرير الرسائل، وتستخدم آليات التزامن لمنع تعارض الوصول إلى الحالة المشتركة. سباق البيانات مثال على مشكلة تنتج من وصول متداخل غير آمن إلى بيانات مشتركة.',
          'لا يقاس نجاح الحل المتوازي بعدد الخيوط فقط. نحلل التسارع والكفاءة وزمن الاستجابة والإنتاجية وكلفة التواصل، وننظر إلى الأجزاء التي تحد من الاستفادة من الموارد. في النظام الموزع يجب أيضًا تحليل أثر فشل العقد أو الاتصال وسلوك النظام عند حدوثه.',
        ],
      );
    }

    if (n.contains('تنقيب البيانات') || n.contains('data mining')) {
      return _LessonBlueprint(
        titles: ['اكتشاف الأنماط وتجهيز البيانات', 'التجميع والتصنيف وقواعد الارتباط', 'تقييم نتائج التنقيب وتفسيرها'],
        topics: ['جودة البيانات والسمات والأنماط القابلة للاكتشاف', 'مقارنة أساليب التجميع والتصنيف وقواعد الارتباط', 'تقييم النمط المكتشف والتحقق من فائدته وحدوده'],
        terms: ['تنقيب البيانات', 'سمة', 'نمط', 'تجميع', 'تصنيف', 'دعم', 'ثقة', 'تقييم'],
        content: [
          'يبدأ تنقيب البيانات بفهم مصدر البيانات وجودتها ثم تنظيفها واختيار السمات المناسبة. يجب الانتباه إلى القيم الناقصة والتكرار وتسرب المعلومات قبل البحث عن الأنماط.',
          'يستخدم التجميع لاكتشاف مجموعات متشابهة، ويستخدم التصنيف للتنبؤ بفئات معروفة، بينما تبحث قواعد الارتباط عن علاقات متكررة. اختيار الأسلوب يتبع سؤال المشكلة وطبيعة البيانات.',
          'النمط المكتشف ليس مفيدًا لمجرد ظهوره. نتحقق من المقاييس والاستقرار والبيانات المستخدمة، ثم نفسر النتيجة في سياق المشكلة ونتجنب تحويل الارتباط إلى سببية دون دليل.',
        ],
      );
    }

    if (n.contains('تعلم الآلة') || n.contains('machine learning')) {
      return _LessonBlueprint(
        titles: ['مشكلة التعلم والبيانات والميزات', 'التدريب والتعميم والتقييم', 'اختيار نموذج وتحليل الأخطاء'],
        topics: ['صياغة مهمة تعلم وتمثيل البيانات', 'فصل التدريب والاختبار وفرط التوافق', 'مقارنة النماذج وتحليل الأخطاء والقيود'],
        terms: ['تعلم آلي', 'ميزة', 'وسم', 'تدريب', 'اختبار', 'تعميم', 'فرط التوافق', 'مقياس'],
        content: [
          'يبدأ تعلم الآلة بصياغة المشكلة وتحديد المدخلات والهدف والبيانات. في التعلم الخاضع للإشراف ترتبط الأمثلة بوسوم، ويجب اختيار ميزات مناسبة وتجنب تسرب معلومات التقييم.',
          'يتعلم النموذج من بيانات التدريب، لكن الهدف هو التعميم على أمثلة لم يرها. فصل التدريب عن التقييم يساعد على تقدير الأداء، بينما فرط التوافق يعني التكيف الزائد مع تفاصيل التدريب.',
          'لا تكفي قيمة مقياس واحدة. نختار مقياسًا مناسبًا للمهمة ونفحص الحالات الخاطئة وتوازن البيانات والقيود التي قد تمنع تعميم النتيجة.',
        ],
      );
    }

    if (n.contains('الحوسبة السحابية') || n.contains('cloud')) {
      return _LessonBlueprint(
        titles: ['مفاهيم الحوسبة السحابية والخدمات', 'التوسع والموثوقية وإدارة الموارد', 'تصميم خدمة سحابية وتحليل تكلفتها'],
        topics: ['الخدمات السحابية ونماذج الموارد والمسؤولية المشتركة', 'التوسع والتوافر والمراقبة وإدارة الموارد', 'اختيار بنية وفق الحمل والأمن والتكلفة'],
        terms: ['حوسبة سحابية', 'خدمة', 'توسع', 'توافر', 'مراقبة', 'حاوية', 'مسؤولية مشتركة', 'تكلفة'],
        content: [
          'توفر الحوسبة السحابية موارد وخدمات يمكن تخصيصها عند الطلب. يبدأ الفهم بتمييز نماذج الخدمات وتحديد مسؤوليات المزود والمستخدم بدل اعتبار السحابة منتجًا واحدًا.',
          'التوسع والموثوقية يتطلبان مراقبة الحمل والتعامل مع فشل المكونات وتحديد مؤشرات الخدمة. يجب تصميم الاسترجاع والتنبيه ضمن الحل لا بعد حدوث المشكلة.',
          'تصميم الخدمة يبدأ بالمتطلبات والحمل والبيانات والتهديدات والميزانية، ثم مقارنة البدائل. التكلفة تشمل الموارد والتخزين والنقل والمراقبة والنسخ الاحتياطي.',
        ],
      );
    }

    if (n.contains('تطوير الويب') || n.contains('web development')) {
      return _LessonBlueprint(
        titles: ['بنية تطبيقات الويب والطلب والاستجابة', 'الواجهة والبيانات وواجهات البرمجة', 'اختبار تطبيق ويب وتأمينه'],
        topics: ['المتصفح والخادم والطلب والاستجابة', 'الواجهة وAPI والبيانات', 'التحقق والمصادقة والتفويض والاختبار'],
        terms: ['HTTP', 'متصفح', 'خادم', 'API', 'واجهة', 'جلسة', 'مصادقة', 'تفويض'],
        content: [
          'يفهم تطبيق الويب من خلال دورة الطلب والاستجابة بين العميل والخادم. تحديد مكان تنفيذ كل وظيفة يوضح كيف تنتقل البيانات وأين يجب فرض القواعد.',
          'تبني الواجهة العرض والتفاعل، بينما يوفر الخادم منطق التطبيق والبيانات. واجهة API تحدد عقدًا واضحًا للطلبات والاستجابات والحالات الناجحة والأخطاء.',
          'يشمل اختبار الويب الحالات العادية والحدية والأخطاء، مع التحقق من المدخلات والمصادقة والتفويض وحماية البيانات. يجب أن يفرض الخادم الصلاحيات ولا يعتمد على إخفاء عناصر الواجهة.',
        ],
      );
    }

    if (n.contains('المترجمات') || n.contains('compiler')) {
      return _LessonBlueprint(
        titles: ['التحليل المعجمي والنحوي', 'التحليل الدلالي والتمثيل الوسيط', 'التوليد والتحسين واختبار المترجم'],
        topics: ['الرموز وقواعد اللغة وبناء شجرة التحليل', 'الأنواع والدلالة والتمثيل الوسيط', 'تحويل البرنامج وتحسينه واختبار الأخطاء'],
        terms: ['مترجم', 'محلل معجمي', 'محلل نحوي', 'شجرة', 'دلالة', 'تمثيل وسيط', 'تحسين', 'كود هدف'],
        content: [
          'يحول المترجم برنامج المصدر إلى تمثيل يمكن تشغيله أو معالجته. يبدأ التحليل المعجمي بتحويل النص إلى رموز، ثم يتحقق التحليل النحوي من ترتيبها وفق قواعد اللغة.',
          'يفحص التحليل الدلالي أمورًا مثل الأنواع ونطاق الأسماء، ثم يمكن بناء تمثيل وسيط يفصل مراحل التحليل عن التوليد للمنصة المستهدفة.',
          'يجب أن تحافظ التحسينات على السلوك الصحيح. يختبر المترجم ببرامج صحيحة وخاطئة وحالات حدودية، وتكون رسائل الأخطاء قابلة للتتبع.',
        ],
      );
    }

    if (n.contains('المنطق الرقمي') || n.contains('دوائر ومنطق') || n.contains('digital logic')) {
      return _LessonBlueprint(
        titles: ['المنطق البولي والتمثيل الرقمي', 'البوابات والدوائر التوافقية', 'الدوائر المتتابعة وتحليل التصميم'],
        topics: ['القيم المنطقية والجداول والعمليات البوليانية', 'البوابات وجداول الحقيقة وتصميم الدائرة', 'الحالة والذاكرة والدوائر المتتابعة'],
        terms: ['منطق بولي', 'بوابة', 'جدول حقيقة', 'دائرة توافقية', 'دائرة متتابعة', 'حالة', 'ساعة', 'قلاب'],
        content: [
          'يمثل المنطق الرقمي المعلومات والعمليات بحالات منطقية محددة. تساعد جداول الحقيقة والجبر البولياني على وصف العلاقة بين المدخلات والمخرجات والتحقق منها.',
          'تعتمد الدائرة التوافقية على المدخلات الحالية. يبدأ التصميم من جدول الحقيقة ثم تبسيط التعبير واختيار بوابات تحقق الوظيفة المطلوبة.',
          'تضيف الدوائر المتتابعة مفهوم الحالة والذاكرة. تحليلها يتطلب تتبع الانتقالات والتحقق من السلوك في الحالات العادية والحدية.',
        ],
      );
    }

    if (n.contains('الأنظمة المضمنة') || n.contains('embedded') || n.contains('إنترنت الأشياء') || n.contains('internet of things') || n.contains('iot')) {
      return _LessonBlueprint(
        titles: ['بنية الأنظمة المضمنة والحساسات', 'الزمن الحقيقي والتواصل بين المكونات', 'تصميم نظام مضمن وتحليل قيوده'],
        topics: ['المعالج والذاكرة والحساسات والمشغلات', 'الاستجابة الزمنية والبروتوكولات وإدارة الموارد', 'موازنة الطاقة والأداء والموثوقية والأمن'],
        terms: ['نظام مضمن', 'حساس', 'مشغل', 'زمن حقيقي', 'طاقة', 'متحكم', 'بروتوكول', 'موثوقية'],
        content: [
          'النظام المضمن حاسوب مخصص لوظيفة داخل منتج أو بيئة. يتكون من معالجة وذاكرة وواجهات مع حساسات أو مشغلات، وتؤثر الطاقة والحجم والكلفة في التصميم.',
          'في النظام الزمني الحقيقي قد يكون توقيت الاستجابة جزءًا من المتطلب. يجب تحليل التأخير والأولويات والاتصال وسلوك النظام عند فقدان رسالة أو تغير قراءة حساس.',
          'التصميم الجيد يوازن الأداء والطاقة والموثوقية والأمن. نحدد متطلبات قابلة للقياس ثم نختبر الاستجابة والأعطال والحدود.',
        ],
      );
    }

    if (n.contains('منهجية البحث') || n.contains('research methods') || n.contains('البحث العلمي')) {
      return _LessonBlueprint(
        titles: ['سؤال البحث والمشكلة والأدلة', 'تصميم الدراسة وجمع البيانات', 'تحليل النتائج وكتابة البحث'],
        topics: ['صياغة سؤال قابل للدراسة وتحديد الأدلة', 'اختيار المنهج والعينة وأداة جمع البيانات', 'تفسير النتائج والقيود والتوثيق'],
        terms: ['سؤال بحث', 'فرضية', 'منهج', 'عينة', 'متغير', 'دليل', 'تحيز', 'توثيق'],
        content: [
          'يبدأ البحث بمشكلة وسؤال محدد يمكن فحصه بالأدلة. يجب تحديد نوع السؤال والبيانات اللازمة للإجابة عنه.',
          'يحدد تصميم الدراسة المنهج والعينة والمتغيرات وأداة جمع البيانات. يجب توثيق القيود ومصادر التحيز بدل تقديم العينة كأنها تمثل الحقيقة كاملة.',
          'يربط التحليل النتائج بالسؤال والأدلة ويذكر القيود والتفسيرات البديلة. الكتابة العلمية تفصل بين ما أظهرته البيانات وما يستنتجه الباحث منها.',
        ],
      );
    }

    if (n.contains('مشروع التخرج') || n.contains('capstone')) {
      return _LessonBlueprint(
        titles: ['تحديد المشكلة والمتطلبات وخطة المشروع', 'التنفيذ والتحقق وإدارة المخاطر', 'التوثيق والعرض والتقييم النهائي'],
        topics: ['تحويل مشكلة واقعية إلى أهداف ونطاق قابلين للقياس', 'تنفيذ حل قابل للاختبار وإدارة التغيير والمخاطر', 'تقييم النتائج وتوثيق القرارات وعرض المنتج'],
        terms: ['نطاق', 'متطلب', 'مخاطر', 'نموذج أولي', 'اختبار', 'مؤشر نجاح', 'توثيق', 'عرض'],
        content: [
          'يبدأ المشروع بمشكلة وأهداف قابلة للقياس ونطاق واضح. يحدد الفريق أصحاب المصلحة والمتطلبات والقيود ومؤشرات النجاح ثم يقسم العمل إلى مراحل.',
          'أثناء التنفيذ يجب الحفاظ على حل قابل للاختبار وإدارة التغييرات والمخاطر. القرارات المهمة تحتاج سببًا وأثرًا معروفًا، وتكشف الاختبارات الانحراف مبكرًا.',
          'يقارن التقييم النهائي النتائج بمؤشرات النجاح ويعرض القيود. يوثق المشروع المشكلة والتصميم والتنفيذ والاختبارات والنتائج ويميز بين الأدلة والعمل المستقبلي.',
        ],
      );
    }

    if (n.contains('ذكاء الأعمال') || n.contains('business intelligence')) {
      return _LessonBlueprint(
        titles: ['أساسيات ذكاء الأعمال ومصادر البيانات', 'المؤشرات ولوحات المعلومات والتحليل', 'بناء تحليل داعم للقرار'],
        topics: ['مصادر البيانات ونماذج التحليل وأسئلة العمل', 'المؤشرات والتجميع والتصور ولوحات المعلومات', 'ربط الدليل بالقرار وقياس أثره'],
        terms: ['ذكاء الأعمال', 'مؤشر أداء', 'لوحة معلومات', 'مستودع بيانات', 'تجميع', 'قرار', 'مقياس', 'سياق'],
        content: [
          'ذكاء الأعمال يحول البيانات التشغيلية إلى معلومات تساعد على فهم الأداء واتخاذ القرار. يبدأ بتحديد سؤال العمل ومصادر البيانات ومؤشرات القياس، مع التأكد من تعريف كل مؤشر ومصدره.',
          'لوحات المعلومات تجمع مؤشرات وتمثيلات تساعد على اكتشاف الاتجاهات والفروق. يجب اختيار مستوى التجميع والوحدة والفترة المناسبة، وتجنب المؤشرات التي يمكن تفسيرها دون سياق.',
          'التحليل الداعم للقرار يربط الملاحظة بالسبب المحتمل والبدائل والقيود. لا يكفي عرض رقم؛ يجب توضيح ما الذي يدعمه الدليل وما الذي يحتاج بيانات إضافية ثم متابعة أثر القرار.',
        ],
      );
    }

    if (n.contains('نظم المؤسسات') || n.contains('تخطيط موارد المؤسسة') || n.contains('erp') || n.contains('enterprise systems')) {
      return _LessonBlueprint(
        titles: ['العمليات ونظم المؤسسات', 'تكامل البيانات وسير العمل', 'تحليل نظام مؤسسي واختيار الحل'],
        topics: ['العمليات والوظائف وأصحاب المصلحة في المؤسسة', 'تكامل الوحدات والبيانات وسير العمل', 'مقارنة حل مؤسسي وفق المتطلبات والمخاطر'],
        terms: ['نظام مؤسسي', 'عملية', 'سير عمل', 'تكامل', 'بيانات رئيسية', 'ERP', 'متطلب', 'مخاطر'],
        content: [
          'نظم المؤسسات تربط عمليات ووظائف متعددة داخل المنظمة. يبدأ التحليل بتحديد العملية وأصحاب المصلحة والمدخلات والمخرجات والقيود بدل البدء باسم المنتج.',
          'تكامل الأنظمة يحدد كيف تنتقل البيانات بين الوحدات ومتى تتغير حالتها. يجب تحديد مصدر الحقيقة وقواعد الاتساق ومعالجة فشل التكامل والتكرار.',
          'اختيار حل مؤسسي يعتمد على المتطلبات والتكلفة والتكامل والأمن وقابلية التغيير. توثيق المفاضلات يساعد المؤسسة على فهم سبب الاختيار وحدوده.',
        ],
      );
    }

    if (n.contains('نظم دعم القرار') || n.contains('decision support')) {
      return _LessonBlueprint(
        titles: ['المشكلة والقرار والبيانات', 'النماذج والمعايير والمفاضلات', 'تقييم نظام دعم القرار'],
        topics: ['تعريف القرار والبدائل والمعلومات المطلوبة', 'بناء نموذج مقارنة وفق معايير وأوزان معلنة', 'تحليل الحساسية والقيود وتأثير التوصية'],
        terms: ['دعم القرار', 'بديل', 'معيار', 'وزن', 'نموذج', 'تحليل حساسية', 'توصية', 'قيود'],
        content: [
          'نظام دعم القرار يساعد الإنسان على تحليل بدائل في مشكلة محددة. يبدأ بتعريف القرار والبدائل والمعلومات المطلوبة ومن يملك القرار النهائي.',
          'يمكن بناء نموذج يقارن البدائل وفق معايير معلنة وأوزان مناسبة. يجب توثيق مصدر القيم والافتراضات، لأن تغييرها قد يغير التوصية.',
          'تحليل الحساسية يختبر مدى استقرار التوصية عند تغيير المدخلات أو الأوزان. يجب عرض القيود وعدم تقديم النموذج كبديل عن الحكم البشري عندما تكون البيانات أو الافتراضات غير كافية.',
        ],
      );
    }

    if (n.contains('إدارة خدمات تقنية المعلومات') || n.contains('it service management') || n.contains('itil')) {
      return _LessonBlueprint(
        titles: ['الخدمة والقيمة وأصحاب المصلحة', 'الحوادث والتغيير ومستويات الخدمة', 'قياس الخدمة والتحسين المستمر'],
        topics: ['مفهوم الخدمة والقيمة والطلب والمخاطر', 'إدارة الحوادث والطلبات والتغيير ومستويات الخدمة', 'المؤشرات وتحليل السبب والتحسين'],
        terms: ['خدمة', 'قيمة', 'حادث', 'طلب', 'تغيير', 'SLA', 'مؤشر', 'تحسين مستمر'],
        content: [
          'إدارة خدمات تقنية المعلومات تنظر إلى التقنية كخدمات تقدم قيمة للمستفيدين. يبدأ العمل بتحديد أصحاب المصلحة والنتائج المطلوبة والقيود والمخاطر.',
          'الحادث يعطل خدمة متوقعة، بينما الطلب يمثل حاجة محددة وفق العملية المعتمدة. إدارة التغيير تهدف إلى تعديل النظام مع تقليل المخاطر، وتحدد اتفاقية مستوى الخدمة توقعات قابلة للقياس.',
          'التحسين المستمر يعتمد على مؤشرات وأدلة وتحليل أسباب المشكلات. لا يكفي قياس عدد التذاكر؛ يجب فهم زمن الاستجابة والحل وجودة الخدمة وأثر التغيير.',
        ],
      );
    }

    if (n.contains('إدارة المشاريع') || n.contains('project management')) {
      return _LessonBlueprint(
        titles: ['نطاق المشروع وأصحاب المصلحة', 'الجدولة والمخاطر وإدارة التغيير', 'متابعة المشروع والتسليم'],
        topics: ['الأهداف والنطاق والمتطلبات وأصحاب المصلحة', 'المهام والتبعيات والمخاطر والتغييرات', 'قياس التقدم والجودة وقبول المخرجات'],
        terms: ['مشروع', 'نطاق', 'متطلب', 'تبعيات', 'خطر', 'تغيير', 'تسليم', 'قبول'],
        content: [
          'المشروع عمل مؤقت له هدف ومخرجات محددة. يبدأ بتعريف النطاق والمتطلبات وأصحاب المصلحة ومعايير القبول حتى يعرف الفريق ما الذي سيدخله المشروع وما الذي سيبقى خارجه.',
          'الجدولة ترتب المهام والتبعيات والموارد. إدارة المخاطر تحدد الأحداث المحتملة واحتمالها وأثرها وخطة الاستجابة، بينما تحتاج التغييرات إلى تقييم أثرها قبل اعتمادها.',
          'متابعة المشروع تقارن التقدم الفعلي بالخطة وتستخدم أدلة قابلة للقياس. التسليم يتطلب التحقق من معايير القبول وتوثيق النتائج والمشكلات المتبقية والدروس المستفادة.',
        ],
      );
    }

    if (n.contains('معالجة الإشارة') || n.contains('معالجة الإشارات') || n.contains('signal processing')) {
      return _LessonBlueprint(
        titles: ['الإشارة والعينة والتمثيل الرقمي', 'الترشيح والتحويل والتحليل', 'تصميم معالجة إشارة وتقييمها'],
        topics: ['الإشارة المستمرة والمتقطعة ومعدل أخذ العينات', 'الترشيح ومجال الزمن والتردد', 'اختيار معالجة مناسبة وتحليل أثرها'],
        terms: ['إشارة', 'عينة', 'تردد', 'ضوضاء', 'ترشيح', 'طيف', 'تحويل', 'استجابة'],
        content: [
          'الإشارة تمثل كمية متغيرة تحمل معلومات، وقد تكون مستمرة أو ممثلة بعينات رقمية. عند أخذ العينات يجب مراعاة معدل أخذ العينات ومحتوى الإشارة لتجنب فقدان معلومات لا يمكن استعادتها.',
          'الترشيح يهدف إلى تغيير مكونات محددة من الإشارة، ويمكن تحليل السلوك في مجال الزمن أو التردد. اختيار المرشح يعتمد على الضوضاء والمعلومة المطلوبة وقيود النظام.',
          'تقييم معالجة الإشارة يقارن المدخل والمخرج بمقياس مناسب، مثل تقليل الضوضاء مع الحفاظ على المعلومة المهمة. يجب اختبار حالات مختلفة وتوثيق الافتراضات والقيود.',
        ],
      );
    }

    if (n.contains('معالجة اللغة') || n.contains('اللغة الطبيعية') || n.contains('nlp')) {
      return _LessonBlueprint(
        titles: ['تمثيل النص وتنظيف اللغة', 'تصنيف واستخراج المعلومات من النص', 'تقييم أنظمة معالجة اللغة'],
        topics: ['التجزئة والتطبيع وتمثيل النص', 'تصنيف النصوص واستخراج الكيانات والمعلومات', 'المقاييس والأخطاء والتحيز اللغوي'],
        terms: ['معالجة اللغة الطبيعية', 'رمز', 'تجزئة', 'تمثيل', 'تصنيف', 'كيان', 'استخراج', 'تحيز'],
        content: [
          'تعالج معالجة اللغة الطبيعية اللغة البشرية بوصفها بيانات تحتاج إلى تمثيل قابل للمعالجة. يبدأ المسار بتحديد النص وتنظيفه وتجزئته، مع الانتباه إلى السياق واللهجات والاختلافات اللغوية.',
          'يمكن استخدام النص في مهام مثل التصنيف أو استخراج الكيانات والمعلومات. اختيار التمثيل والطريقة يتبع المهمة والبيانات، ويجب فصل تجهيز البيانات عن التدريب أو الاستدلال.',
          'يقاس نظام اللغة بمقياس مناسب للمهمة مع فحص أمثلة صحيحة وخاطئة. يجب تحليل الأداء عبر صيغ وفئات لغوية مختلفة وعدم افتراض أن متوسط النتيجة يمثل جميع السياقات.',
        ],
      );
    }

    if (n.contains('تصوير البيانات') || n.contains('تصور البيانات') || n.contains('data visualization')) {
      return _LessonBlueprint(
        titles: ['السؤال التحليلي والرسالة البصرية', 'اختيار التمثيل وبناء الرسم', 'قراءة الرسم واكتشاف التضليل'],
        topics: ['تحويل سؤال البيانات إلى رسالة واضحة', 'اختيار مخطط مناسب للمتغيرات والمقارنة', 'فحص المقاييس والنطاق والبيانات الناقصة'],
        terms: ['تصوير البيانات', 'محور', 'مقياس', 'توزيع', 'مخطط', 'ترميز بصري', 'سياق', 'تضليل'],
        content: [
          'تصوير البيانات يحول القيم إلى تمثيل بصري يساعد على الفهم والمقارنة. يبدأ التصميم بسؤال واضح وجمهور محدد وما نريد إظهاره، لا باختيار الرسم أولًا.',
          'يعتمد نوع الرسم على المهمة؛ المقارنة والتغير والتوزيع والعلاقة بين المتغيرات قد تحتاج تمثيلات مختلفة. تسمية المحاور والوحدات والمصدر جزء من صحة العرض.',
          'قراءة الرسم تتطلب فحص النطاق والمقياس وحجم العينة والبيانات الناقصة. قد يؤدي تغيير المحور أو حذف بيانات إلى انطباع مضلل، لذلك يجب ربط الاستنتاج بما تدعمه البيانات.',
        ],
      );
    }

    if (n.contains('السلاسل الزمنية') || n.contains('time series')) {
      return _LessonBlueprint(
        titles: ['بنية السلسلة الزمنية', 'النمذجة والتنبؤ', 'تقييم التنبؤ وتحليل الخطأ'],
        topics: ['الاتجاه والموسمية والتغير عبر الزمن', 'بناء تنبؤ مع احترام ترتيب الزمن', 'قياس خطأ التنبؤ وتحليل الحالات غير المتوقعة'],
        terms: ['سلسلة زمنية', 'اتجاه', 'موسمية', 'تنبؤ', 'تأخر زمني', 'نافذة', 'خطأ', 'تسرب زمني'],
        content: [
          'السلسلة الزمنية بيانات مرتبة زمنيًا، ولذلك لا تعامل دائمًا كعينة عشوائية. نحدد الفترة ومعدل القياس ونبحث عن الاتجاه والموسمية والتغيرات غير المنتظمة.',
          'يستخدم التنبؤ معلومات الماضي لتقدير المستقبل. يجب الحفاظ على ترتيب الزمن عند تقسيم البيانات، لأن استخدام معلومات مستقبلية في التدريب يسبب تسربًا ويشوه التقييم.',
          'نقيس خطأ التنبؤ بمقياس مناسب ونفحص الفترات التي يفشل فيها النموذج. قد تكشف الأخطاء تغيرًا في النظام أو بيانات شاذة أو نمطًا لم يمثله النموذج.',
        ],
      );
    }

    if (n.contains('الرؤية الحاسوبية') || n.contains('computer vision')) {
      return _LessonBlueprint(
        titles: ['الصورة والتمثيل والميزات', 'التصنيف والكشف والتجزئة', 'تقييم نموذج رؤية وتحليل أخطائه'],
        topics: ['تمثيل الصور والقنوات والدقة والمعالجة الأولية', 'مهام التصنيف والكشف والتجزئة', 'مقاييس الأداء ومصادر الخطأ والتحيز'],
        terms: ['رؤية حاسوبية', 'بكسل', 'قناة', 'ميزة', 'تصنيف', 'كشف', 'تجزئة', 'مصفوفة التباس'],
        content: [
          'تعالج الرؤية الحاسوبية الصور أو الفيديو لاستخراج معلومات قابلة للاستخدام. تبدأ العملية بتمثيل الصورة وفهم الأبعاد والقنوات والدقة، ثم تجهيز البيانات بما يتوافق مع المهمة.',
          'التصنيف يحدد فئة للصورة، والكشف يحدد عناصر ومواقعها، والتجزئة تحدد مناطق على مستوى البكسلات. اختيار المهمة يتبع المطلوب من النظام وليس شكل النموذج فقط.',
          'التقييم يستخدم مقاييس مناسبة للمهمة مع تحليل الحالات الخاطئة. يجب فحص جودة البيانات وتوازن الفئات والاختلاف في ظروف التصوير، لأن متوسط الأداء قد يخفي ضعفًا في فئة أو سياق معين.',
        ],
      );
    }

    if (n.contains('الأمن') || n.contains('cybersecurity') || n.contains('أمن') || n.contains('security')) {
      return _LessonBlueprint(
        titles: ['الأصول والتهديدات والثغرات', 'الضوابط والتشفير والممارسات الآمنة', 'تحليل مخاطر ودراسة حالة أمنية'],
        topics: ['تحديد الأصل والتهديد والثغرة والأثر', 'اختيار ضابط أمني وحماية البيانات', 'تقييم الخطر واقتراح معالجة قابلة للقياس'],
        terms: ['أصل', 'تهديد', 'ثغرة', 'خطر', 'ضابط', 'سرية', 'سلامة', 'توافر'],
        content: [
          'الأمن السيبراني يهدف إلى حماية الأنظمة والبيانات. يبدأ التحليل بتحديد الأصول والتهديدات والثغرات والأثر، مع فهم أهداف السرية والسلامة والتوافر.',
          'تستخدم الضوابط الإدارية والتقنية والفيزيائية مع مبادئ مثل أقل صلاحية والدفاع متعدد الطبقات. يوفر التشفير آليات حماية بحسب الخوارزمية وإدارة المفاتيح ونموذج التهديد.',
          'نحدد سيناريو الخطر والأصل والأثر والضوابط الحالية ثم نقترح معالجة ونحدد طريقة قياسها. الاختبارات الأمنية يجب أن تكون مصرحًا بها وعلى بيئة آمنة.',
        ],
      );
    }

    if (n.contains('المهنة') || n.contains('أخلاقيات') || n.contains('المجتمع') || n.contains('society') || n.contains('ethics') || n.contains('profession')) {
      return _LessonBlueprint(
        titles: ['السياق الاجتماعي للحوسبة والمسؤولية المهنية', 'التحليل الأخلاقي واتخاذ القرار التقني', 'الخصوصية والملكية الفكرية والتواصل والاستدامة'],
        topics: ['تأثير الحوسبة والذكاء الاصطناعي على الأفراد والمجتمع', 'تحليل أصحاب المصلحة والقيم والمفاضلات الأخلاقية', 'المسؤولية المهنية والخصوصية والملكية الفكرية والتواصل والاستدامة'],
        terms: ['مسؤولية مهنية', 'صاحب مصلحة', 'خصوصية', 'ملكية فكرية', 'مساءلة', 'إتاحة', 'استدامة', 'تحليل أخلاقي'],
        content: [
          'تؤثر أنظمة الحوسبة في الأفراد والمؤسسات والمجتمعات، لذلك لا يكفي تقييم النظام من ناحية تقنية فقط. يحدد الطالب أصحاب المصلحة، والفوائد والأضرار المحتملة، والقيود الاجتماعية والقانونية، ثم يربط القرار التقني بالسياق الذي سيستخدم فيه النظام. وتشمل المسؤولية المهنية إدراك أثر القرارات على السلامة والموثوقية وحقوق المستخدمين.',
          'التحليل الأخلاقي عملية منظمة وليست مجرد إبداء رأي. نحدد الوقائع والافتراضات، ثم أصحاب المصلحة والقيم المتعارضة، ونفحص الحجج والأدلة والمخاطر والبدائل، ثم نبرر قرارًا يمكن مراجعته. يجب التمييز بين وصف ما يحدث وبين الحكم على ما ينبغي فعله، والانتباه إلى اختلاف السياقات والثقافات والقوانين.',
          'يمتد العمل المهني إلى حماية الخصوصية والبيانات، واحترام الملكية الفكرية والتراخيص، والتواصل الواضح مع الفرق والمستخدمين، ومراعاة الإتاحة والاستدامة. عندما تظهر مشكلة تمس السلامة أو القانون أو قواعد المهنة يجب توثيقها واتباع قنوات الإبلاغ المناسبة بدل إخفائها. الهدف أن يصبح الطالب قادرًا على تفسير القرار التقني ومسؤوليته وآثاره.',
        ],
      );
    }

    if (n.contains('هياكل البيانات') || n.contains('data structure') || n.contains('خوارزميات') || n.contains('algorithms')) {
      return _LessonBlueprint(
        titles: ['تمثيل البيانات واختيار البنية المناسبة', 'الخوارزميات والتعقيد وتحليل الكلفة', 'حل مشكلة برمجية ومقارنة البدائل'],
        topics: ['المصفوفات والقوائم والمكدسات والطوابير وتمثيل البيانات', 'التعقيد الزمني والفضائي ومقارنة استراتيجيات الحل', 'اختيار بنية وخوارزمية مناسبة لمشكلة محددة'],
        terms: ['بنية بيانات', 'خوارزمية', 'مصفوفة', 'قائمة', 'مكدس', 'طابور', 'تعقيد', 'Big-O'],
        content: [
          'بنية البيانات هي طريقة منظمة لتمثيل البيانات بحيث يمكن تنفيذ العمليات المطلوبة عليها بكفاءة. لا توجد بنية واحدة مناسبة لكل مشكلة؛ الاختيار يعتمد على العمليات المطلوبة، مثل الوصول أو الإدراج أو الحذف أو البحث، وعلى قيود الذاكرة.',
          'الخوارزمية سلسلة محددة من الخطوات لحل مشكلة. عند مقارنة الحلول لا يكفي أن تعمل الخوارزمية على مثال صغير؛ نحلل كلفة التنفيذ مع نمو حجم المدخلات. يصف Big-O معدل النمو التقريبي للكلفة، مع التمييز بين الزمن والذاكرة والحالات التي نقيسها.',
          'حل المشكلة يبدأ بتحديد المدخلات والمخرجات والقيود، ثم اختيار تمثيل مناسب للبيانات، ثم تصميم الخوارزمية، ثم اختبارها على حالات عادية وحدية، وأخيرًا مقارنة البدائل من حيث الصحة والكلفة وقابلية الفهم. الهدف أن يستطيع الطالب تبرير الاختيار، لا مجرد حفظ اسم بنية أو خوارزمية.',
        ],
      );
    }

    if (n.contains('نظم التشغيل') || n.contains('operating system') || n.contains('أنظمة التشغيل')) {
      return _LessonBlueprint(
        titles: ['دور نظام التشغيل وإدارة الموارد', 'العمليات والذاكرة والملفات', 'تحليل حالة تشغيلية واختيار الحل'],
        topics: ['وظائف نظام التشغيل والموارد التي يديرها', 'العمليات والذاكرة ونظم الملفات والتزامن', 'تحليل مشكلة موارد أو تنفيذ واقتراح معالجة'],
        terms: ['نظام تشغيل', 'عملية', 'خيط', 'ذاكرة', 'نظام ملفات', 'جدولة', 'تزامن'],
        content: [
          'نظام التشغيل طبقة برمجية تدير موارد الحاسوب وتوفر خدمات للبرامج والمستخدمين. من مسؤولياته إدارة المعالج والذاكرة والتخزين وأجهزة الإدخال والإخراج، مع توفير تجريدات تجعل استخدام الموارد أكثر تنظيمًا.',
          'العملية تمثل برنامجًا قيد التنفيذ، ويمكن تقسيم العمل إلى خيوط تنفيذ. تحتاج أنظمة التشغيل إلى سياسات للجدولة وإدارة الذاكرة والملفات والتزامن. تظهر مشكلات مثل التعارض على الموارد أو الانتظار المتبادل عندما لا تُدار العمليات بعناية.',
          'تحليل مشكلة في نظام التشغيل يبدأ بتحديد المورد والحالة الحالية والعمليات المتنافسة، ثم تحديد القيد أو سبب المشكلة، ثم مقارنة سياسة أو معالجة بديلة. يجب تبرير الحل بمصطلحات النظام وبيان أثره على الأداء والاعتمادية.',
        ],
      );
    }

    if (n.contains('إحصاء') || n.contains('احتمال') || n.contains('statistics') || n.contains('probability')) {
      return _LessonBlueprint(
        titles: ['البيانات والمتغيرات والاحتمال', 'التوزيعات والاستدلال الإحصائي', 'تحليل بيانات وتفسير النتيجة'],
        topics: ['أنواع البيانات والمتغيرات ومقاييس النزعة والتشتت', 'الاحتمال والتوزيعات والعينة والاستدلال', 'اختيار مقياس مناسب وتحليل نتيجة مع حدودها'],
        terms: ['متغير', 'عينة', 'مجتمع', 'احتمال', 'متوسط', 'تباين', 'توزيع', 'استدلال'],
        content: [
          'يبدأ التحليل الإحصائي بتحديد المجتمع المستهدف والمتغيرات وطبيعة البيانات. المتوسط والوسيط والمنوال تصف مركز البيانات بطرق مختلفة، بينما يقيس التباين والانحراف المعياري مقدار التشتت. اختيار المقياس يجب أن يتوافق مع نوع البيانات وشكل توزيعها.',
          'الاحتمال إطار لقياس عدم اليقين، وتستخدم التوزيعات لوصف سلوك متغير عشوائي. عند استخدام عينة للاستدلال على مجتمع أكبر يجب الانتباه إلى طريقة أخذ العينة وحجمها ومصادر التحيز وعدم التعامل مع نتيجة العينة كحقيقة مطلقة.',
          'تحليل البيانات الجيد يربط الرقم بالسؤال الذي نريد الإجابة عنه. نحدد المقياس أو الاختبار المناسب، نتحقق من الافتراضات، ثم نفسر النتيجة مع حدودها. لا تكفي قيمة إحصائية منفردة إذا كانت طريقة جمع البيانات أو تصميم الدراسة لا يدعمان الاستنتاج.',
        ],
      );
    }

    if (n.contains('ويب') || n.contains('web development') || n.contains('تطوير الويب')) {
      return _LessonBlueprint(
        titles: ['بنية تطبيق الويب والعميل والخادم', 'البيانات وواجهات API ودورة الطلب', 'بناء ميزة ويب واختبارها'],
        topics: ['المتصفح والخادم وHTTP ومكونات تطبيق الويب', 'الطلبات والاستجابات والبيانات وواجهات API', 'تصميم ميزة صغيرة والتحقق من سلوكها وأمانها'],
        terms: ['عميل', 'خادم', 'HTTP', 'واجهة API', 'طلب', 'استجابة', 'جلسة', 'JSON'],
        content: [
          'تطبيق الويب يتكون عادة من عميل يتفاعل مع المستخدم وخادم يعالج الطلبات أو البيانات. يرسل العميل طلبًا ويستقبل استجابة وفق بروتوكول مثل HTTP. فهم هذا الفصل يساعد على تحديد مكان تنفيذ كل وظيفة ومصدر كل بيانات.',
          'واجهة API تحدد عقدًا واضحًا بين العميل والخادم، بما في ذلك المسارات والبيانات وحالات الخطأ. JSON تمثيل شائع للبيانات، لكن صحة التصميم تتطلب التحقق من المدخلات وإدارة الصلاحيات وعدم افتراض أن بيانات العميل موثوقة.',
          'عند بناء ميزة ويب نبدأ بسلوك مطلوب قابل للاختبار، ثم نحدد الطلب والاستجابة والحالات غير الصحيحة، وننفذ أقل تصميم مناسب، ثم نختبر النجاح والفشل والحدود. يجب أن تكون المصادقة والتفويض والتحقق من المدخلات جزءًا من التصميم لا إضافة لاحقة.',
        ],
      );
    }

    return _LessonBlueprint(
      titles: ['مدخل إلى $courseName', 'المفاهيم والمكونات في $courseName', 'تطبيقات $courseName وتحليلها'],
      topics: ['مشكلة المجال ومفاهيمه الأساسية', 'المكونات والعلاقات والمبادئ', 'تطبيق المفاهيم على مسألة واقعية'],
      terms: ['مفهوم', 'مكوّن', 'مبدأ', 'تطبيق'],
      content: [
        'يبدأ هذا المقرر بتحديد المشكلة التي يعالجها المجال والمفاهيم التي يحتاج الطالب إلى فهمها قبل التطبيق.',
        'بعد فهم الأساسيات ندرس المكونات والعلاقات والمبادئ التي تفسر كيفية عمل الحلول في هذا المجال.',
        'في التطبيق ننتقل من المفهوم إلى حالة عملية، ثم نحلل النتيجة والافتراضات والقيود ونوثق ما تعلمناه.',
      ],
    );
  }

class _LessonBlueprint {
  const _LessonBlueprint({
    required this.titles,
    required this.topics,
    required this.terms,
    required this.content,
  });
  final List<String> titles;
  final List<String> topics;
  final List<String> terms;
  final List<String> content;
}
