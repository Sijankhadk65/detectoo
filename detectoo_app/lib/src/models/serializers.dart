import 'package:built_collection/built_collection.dart';
import 'package:built_value/serializer.dart';
import 'package:built_value/standard_json_plugin.dart';

import 'plant.dart';
import 'recovery.dart';
import 'recovery_plan.dart';
import 'reminder.dart';
import 'scan_result.dart';
import 'task.dart';
import 'user.dart';

part 'serializers.g.dart';

/// Collection of all built_value serializers used in the app.
@SerializersFor([
  Plant,
  PlantHealthStatus,
  Recovery,
  RecoveryPlan,
  RecoveryStep,
  RecoveryStepPhoto,
  Reminder,
  ScanResult,
  DetectedIssue,
  Task,
  User,
])
final Serializers serializers =
    (_$serializers.toBuilder()..addPlugin(StandardJsonPlugin())).build();
