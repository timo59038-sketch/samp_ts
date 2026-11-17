class Advisor {
  const Advisor({
    required this.id,
    required this.userId,
    required this.department,
  });
  final String id;
  final String userId;
  final String department;
  factory Advisor.fromMap(String id, Map<String, dynamic> data) => Advisor(
    id: id,
    userId: data['userId'] as String,
    department: data['department'] as String,
  );
  Map<String, dynamic> toMap() => {'userId': userId, 'department': department};
}
