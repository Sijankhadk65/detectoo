// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<User> _$userSerializer = _$UserSerializer();

class _$UserSerializer implements StructuredSerializer<User> {
  @override
  final Iterable<Type> types = const [User, _$User];
  @override
  final String wireName = 'User';

  @override
  Iterable<Object?> serialize(
    Serializers serializers,
    User object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = <Object?>[
      'name',
      serializers.serialize(object.name, specifiedType: const FullType(String)),
      'email',
      serializers.serialize(
        object.email,
        specifiedType: const FullType(String),
      ),
      'memberSince',
      serializers.serialize(
        object.memberSince,
        specifiedType: const FullType(String),
      ),
    ];
    Object? value;
    value = object.isEmailVerified;
    if (value != null) {
      result
        ..add('isEmailVerified')
        ..add(
          serializers.serialize(value, specifiedType: const FullType(bool)),
        );
    }
    return result;
  }

  @override
  User deserialize(
    Serializers serializers,
    Iterable<Object?> serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = UserBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case 'name':
          result.name =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )!
                  as String;
          break;
        case 'email':
          result.email =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )!
                  as String;
          break;
        case 'memberSince':
          result.memberSince =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )!
                  as String;
          break;
        case 'isEmailVerified':
          result.isEmailVerified =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(bool),
                  )
                  as bool?;
          break;
      }
    }

    return result.build();
  }
}

class _$User extends User {
  @override
  final String name;
  @override
  final String email;
  @override
  final String memberSince;
  @override
  final bool? isEmailVerified;

  factory _$User([void Function(UserBuilder)? updates]) =>
      (UserBuilder()..update(updates))._build();

  _$User._({
    required this.name,
    required this.email,
    required this.memberSince,
    this.isEmailVerified,
  }) : super._();
  @override
  User rebuild(void Function(UserBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  UserBuilder toBuilder() => UserBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is User &&
        name == other.name &&
        email == other.email &&
        memberSince == other.memberSince &&
        isEmailVerified == other.isEmailVerified;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, email.hashCode);
    _$hash = $jc(_$hash, memberSince.hashCode);
    _$hash = $jc(_$hash, isEmailVerified.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'User')
          ..add('name', name)
          ..add('email', email)
          ..add('memberSince', memberSince)
          ..add('isEmailVerified', isEmailVerified))
        .toString();
  }
}

class UserBuilder implements Builder<User, UserBuilder> {
  _$User? _$v;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  String? _email;
  String? get email => _$this._email;
  set email(String? email) => _$this._email = email;

  String? _memberSince;
  String? get memberSince => _$this._memberSince;
  set memberSince(String? memberSince) => _$this._memberSince = memberSince;

  bool? _isEmailVerified;
  bool? get isEmailVerified => _$this._isEmailVerified;
  set isEmailVerified(bool? isEmailVerified) =>
      _$this._isEmailVerified = isEmailVerified;

  UserBuilder();

  UserBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _name = $v.name;
      _email = $v.email;
      _memberSince = $v.memberSince;
      _isEmailVerified = $v.isEmailVerified;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(User other) {
    _$v = other as _$User;
  }

  @override
  void update(void Function(UserBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  User build() => _build();

  _$User _build() {
    final _$result =
        _$v ??
        _$User._(
          name: BuiltValueNullFieldError.checkNotNull(name, r'User', 'name'),
          email: BuiltValueNullFieldError.checkNotNull(email, r'User', 'email'),
          memberSince: BuiltValueNullFieldError.checkNotNull(
            memberSince,
            r'User',
            'memberSince',
          ),
          isEmailVerified: isEmailVerified,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
