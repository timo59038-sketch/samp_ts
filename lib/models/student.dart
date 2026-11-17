class Student {
  const Student({
    required this.id,
    required this.userId,
    required this.studentNumber,
    this.advisorId,
  });
  final String id;
  final String userId;
  final String studentNumber;
  final String? advisorId;
  factory Student.fromMap(String id, Map<String, dynamic> data) => Student(
    id: id,
    userId: data['userId'] as String,
    studentNumber: data['studentNumber'] as String,
    advisorId: data['advisorId'] as String?,
  );
  Map<String, dynamic> toMap() => {
    'userId': userId,
    'studentNumber': studentNumber,
    'advisorId': advisorId,
  };
}
