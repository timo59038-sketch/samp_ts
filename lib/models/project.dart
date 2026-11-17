enum ProjectStatus { proposed, inProgress, completed }

class Project {
  const Project({
    required this.id,
    required this.studentId,
    required this.advisorId,
    required this.title,
    required this.description,
    required this.status,
  });
  final String id;
  final String studentId;
  final String advisorId;
  final String title;
  final String description;
  final ProjectStatus status;
  factory Project.fromMap(String id, Map<String, dynamic> data) => Project(
    id: id,
    studentId: data['studentId'] as String,
    advisorId: data['advisorId'] as String,
    title: data['title'] as String,
    description: data['description'] as String,
    status: ProjectStatus.values.byName(data['status'] as String),
  );
  Map<String, dynamic> toMap() => {
    'studentId': studentId,
    'advisorId': advisorId,
    'title': title,
    'description': description,
    'status': status.name,
  };
}
