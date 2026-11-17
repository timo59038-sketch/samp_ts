import 'package:flutter_test/flutter_test.dart';
import 'package:samp_ts/models/user.dart';
import 'package:samp_ts/models/student.dart';
import 'package:samp_ts/models/advisor.dart';
import 'package:samp_ts/models/project.dart';
import 'package:samp_ts/models/meeting.dart';

void main() {
  test(
    'Profiles preserve identifiers and roles without storing credentials',
    () {
      const user = User(
        id: 'u1',
        name: 'Ada',
        email: 'ada@example.com',
        role: UserRole.student,
      );
      final restored = User.fromMap(user.id, user.toMap());
      expect(restored.role, UserRole.student);
      expect(restored.id, 'u1');
      expect(restored.toMap().containsKey('password'), isFalse);
      const student = Student(id: 'u1', userId: 'u1', studentNumber: '123');
      expect(Student.fromMap(student.id, student.toMap()).advisorId, isNull);
      const advisor = Advisor(id: 'a1', userId: 'a1', department: 'Computing');
      expect(
        Advisor.fromMap(advisor.id, advisor.toMap()).department,
        'Computing',
      );
    },
  );

  test(
    'Project status and meeting timestamps survive Realtime Database serialization',
    () {
      const project = Project(
        id: 'p1',
        studentId: 'u1',
        advisorId: 'a1',
        title: 'SAMPTS',
        description: 'Tracking',
        status: ProjectStatus.inProgress,
      );
      expect(
        Project.fromMap(project.id, project.toMap()).status,
        ProjectStatus.inProgress,
      );
      final time = DateTime.utc(2026, 11, 20, 10);
      final meeting = Meeting(
        id: 'm1',
        studentId: 'u1',
        advisorId: 'a1',
        scheduledAt: time,
        durationMinutes: 30,
        status: MeetingStatus.pending,
        notes: 'Review',
      );
      final restored = Meeting.fromMap(meeting.id, meeting.toMap());
      expect(restored.scheduledAt, time);
      expect(restored.status, MeetingStatus.pending);
      expect(restored.durationMinutes, 30);
    },
  );
}
