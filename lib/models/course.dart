class Course {
  final String name;
  final String semester;
  final int year;

  Course({
    required this.name,
    required this.semester,
    required this.year,
  });

  String get displayText => 'A: \(name (\)semester $year)';
}