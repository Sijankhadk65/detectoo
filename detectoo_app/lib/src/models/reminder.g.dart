// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reminder.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<Reminder> _$reminderSerializer = _$ReminderSerializer();

class _$ReminderSerializer implements StructuredSerializer<Reminder> {
  @override
  final Iterable<Type> types = const [Reminder, _$Reminder];
  @override
  final String wireName = 'Reminder';

  @override
  Iterable<Object?> serialize(
    Serializers serializers,
    Reminder object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = <Object?>[
      'title',
      serializers.serialize(
        object.title,
        specifiedType: const FullType(String),
      ),
      'time',
      serializers.serialize(object.time, specifiedType: const FullType(String)),
      'iconCodePoint',
      serializers.serialize(
        object.iconCodePoint,
        specifiedType: const FullType(int),
      ),
    ];

    return result;
  }

  @override
  Reminder deserialize(
    Serializers serializers,
    Iterable<Object?> serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ReminderBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case 'title':
          result.title =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )!
                  as String;
          break;
        case 'time':
          result.time =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )!
                  as String;
          break;
        case 'iconCodePoint':
          result.iconCodePoint =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(int),
                  )!
                  as int;
          break;
      }
    }

    return result.build();
  }
}

class _$Reminder extends Reminder {
  @override
  final String title;
  @override
  final String time;
  @override
  final int iconCodePoint;

  factory _$Reminder([void Function(ReminderBuilder)? updates]) =>
      (ReminderBuilder()..update(updates))._build();

  _$Reminder._({
    required this.title,
    required this.time,
    required this.iconCodePoint,
  }) : super._();
  @override
  Reminder rebuild(void Function(ReminderBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ReminderBuilder toBuilder() => ReminderBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Reminder &&
        title == other.title &&
        time == other.time &&
        iconCodePoint == other.iconCodePoint;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, title.hashCode);
    _$hash = $jc(_$hash, time.hashCode);
    _$hash = $jc(_$hash, iconCodePoint.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'Reminder')
          ..add('title', title)
          ..add('time', time)
          ..add('iconCodePoint', iconCodePoint))
        .toString();
  }
}

class ReminderBuilder implements Builder<Reminder, ReminderBuilder> {
  _$Reminder? _$v;

  String? _title;
  String? get title => _$this._title;
  set title(String? title) => _$this._title = title;

  String? _time;
  String? get time => _$this._time;
  set time(String? time) => _$this._time = time;

  int? _iconCodePoint;
  int? get iconCodePoint => _$this._iconCodePoint;
  set iconCodePoint(int? iconCodePoint) =>
      _$this._iconCodePoint = iconCodePoint;

  ReminderBuilder();

  ReminderBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _title = $v.title;
      _time = $v.time;
      _iconCodePoint = $v.iconCodePoint;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Reminder other) {
    _$v = other as _$Reminder;
  }

  @override
  void update(void Function(ReminderBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  Reminder build() => _build();

  _$Reminder _build() {
    final _$result =
        _$v ??
        _$Reminder._(
          title: BuiltValueNullFieldError.checkNotNull(
            title,
            r'Reminder',
            'title',
          ),
          time: BuiltValueNullFieldError.checkNotNull(
            time,
            r'Reminder',
            'time',
          ),
          iconCodePoint: BuiltValueNullFieldError.checkNotNull(
            iconCodePoint,
            r'Reminder',
            'iconCodePoint',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
