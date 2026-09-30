class AcademicUniversity {
  const AcademicUniversity({required this.id, required this.name, required this.colleges});
  final String id;
  final String name;
  final List<AcademicCollege> colleges;
}

class AcademicCollege {
  const AcademicCollege({required this.id, required this.name, required this.specializations});
  final String id;
  final String name;
  final List<AcademicSpecialization> specializations;
}

class AcademicSpecialization {
  const AcademicSpecialization({required this.id, required this.name, required this.years});
  final String id;
  final String name;
  final List<AcademicYear> years;
}

class AcademicYear {
  const AcademicYear({required this.number, required this.semesters});
  final int number;
  final List<AcademicSemester> semesters;
}

class AcademicSemester {
  const AcademicSemester({required this.number, required this.courses});
  final int number;
  final List<AcademicCourse> courses;
}

class AcademicCourse {
  const AcademicCourse({required this.id, required this.name, required this.lessons});
  final String id;
  final String name;
  final List<AcademicLesson> lessons;
}

class AcademicLesson {
  const AcademicLesson({required this.id, required this.title, this.isFree = true});
  final String id;
  final String title;
  final bool isFree;
}
