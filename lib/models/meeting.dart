enum MeetingStatus { pending, approved, rejected, cancelled, completed }

class Meeting {
  const Meeting({
    required this.id,
    required this.studentId,
    required this.advisorId,
    required this.scheduledAt,
    required this.durationMinutes,
    required this.status,
    required this.notes,
  });
  final String id;
  final String studentId;
  final String advisorId;
  final DateTime scheduledAt;
  final int durationMinutes;
  final MeetingStatus status;
  final String notes;
  factory Meeting.fromMap(String id, Map<String, dynamic> data) => Meeting(
    id: id,
    studentId: data['studentId'] as String,
    advisorId: data['advisorId'] as String,
    scheduledAt: DateTime.fromMillisecondsSinceEpoch(
      (data['scheduledAt'] as num).toInt(),
      isUtc: true,
    ),
    durationMinutes: data['durationMinutes'] as int,
    status: MeetingStatus.values.byName(data['status'] as String),
    notes: data['notes'] as String,
  );
  Map<String, dynamic> toMap() => {
    'studentId': studentId,
    'advisorId': advisorId,
    'scheduledAt': scheduledAt.toUtc().millisecondsSinceEpoch,
    'durationMinutes': durationMinutes,
    'status': status.name,
    'notes': notes,
  };
}
