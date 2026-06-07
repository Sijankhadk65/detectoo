import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'user.g.dart';

/// Represents an authenticated user.
abstract class User implements Built<User, UserBuilder> {
  /// The user's display name.
  String get name;

  /// The user's email address.
  String get email;

  /// When the user joined (e.g. "Apr 2026").
  String get memberSince;

  /// Whether the user has verified their email address.
  ///
  /// Null when the value is not yet known (e.g. during session restore from
  /// an older cached token before the field existed).
  bool? get isEmailVerified;

  User._();

  factory User([void Function(UserBuilder) updates]) = _$User;

  static Serializer<User> get serializer => _$userSerializer;
}
