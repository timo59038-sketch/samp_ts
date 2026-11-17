import 'package:firebase_database/firebase_database.dart';
import '../models/user.dart';
import '../models/student.dart';
import '../models/advisor.dart';
import '../models/project.dart';
import '../models/meeting.dart';
import 'record_service.dart';

class DatabaseService {
  DatabaseService(FirebaseDatabase database)
    : users = RecordService<User>(
        database: database,
        collection: 'users',
        fromMap: User.fromMap,
        toMap: (record) => record.toMap(),
        idOf: (record) => record.id,
      ),
      students = RecordService<Student>(
        database: database,
        collection: 'students',
        fromMap: Student.fromMap,
        toMap: (record) => record.toMap(),
        idOf: (record) => record.id,
      ),
      advisors = RecordService<Advisor>(
        database: database,
        collection: 'advisors',
        fromMap: Advisor.fromMap,
        toMap: (record) => record.toMap(),
        idOf: (record) => record.id,
      ),
      projects = RecordService<Project>(
        database: database,
        collection: 'projects',
        fromMap: Project.fromMap,
        toMap: (record) => record.toMap(),
        idOf: (record) => record.id,
      ),
      meetings = RecordService<Meeting>(
        database: database,
        collection: 'meetings',
        fromMap: Meeting.fromMap,
        toMap: (record) => record.toMap(),
        idOf: (record) => record.id,
      );
  final RecordService<User> users;
  final RecordService<Student> students;
  final RecordService<Advisor> advisors;
  final RecordService<Project> projects;
  final RecordService<Meeting> meetings;
}
