class StudentProfile {
  const StudentProfile({
    required this.name,
    required this.university,
    required this.college,
    required this.specialization,
    required this.currentYear,
    required this.currentSemester,
  });

  final String name;
  final String university;
  final String college;
  final String specialization;
  final int currentYear;
  final int currentSemester;
}

class SmartStudentState {
  const SmartStudentState({
    this.knowledgeLevel = 0,
    this.skillLevel = 0,
    this.capabilityLevel = 0,
    this.learningStreak = 0,
  });

  final double knowledgeLevel;
  final double skillLevel;
  final double capabilityLevel;
  final int learningStreak;

  SmartStudentState copyWith({
    double? knowledgeLevel,
    double? skillLevel,
    double? capabilityLevel,
    int? learningStreak,
  }) {
    return SmartStudentState(
      knowledgeLevel: knowledgeLevel ?? this.knowledgeLevel,
      skillLevel: skillLevel ?? this.skillLevel,
      capabilityLevel: capabilityLevel ?? this.capabilityLevel,
      learningStreak: learningStreak ?? this.learningStreak,
    );
  }
}
