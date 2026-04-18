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
      'id',
      serializers.serialize(object.id, specifiedType: const FullType(int)),
      'title',
      serializers.serialize(
        object.title,
        specifiedType: const FullType(String),
      ),
      'time',
      serializers.serialize(
        object.time,
        specifiedType: const FullType(DateTime),
      ),
      'iconCodePoint',
      serializers.serialize(
        object.iconCodePoint,
        specifiedType: const FullType(int),
      ),
    ];
    Object? value;
    value = object.plantId;
    if (value != null) {
      result
        ..add('plantId')
        ..add(serializers.serialize(value, specifiedType: const FullType(int)));
    }
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
        case 'id':
          result.id =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(int),
                  )!
                  as int;
          break;
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
                    specifiedType: const FullType(DateTime),
                  )!
                  as DateTime;
          break;
        case 'iconCodePoint':
          result.iconCodePoint =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(int),
                  )!
                  as int;
          break;
        case 'plantId':
          result.plantId =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int?;
          break;
      }
    }

    return result.build();
  }
}

class _$Reminder extends Reminder {
  @override
  final int id;
  @override
  final String title;
  @override
  final DateTime time;
  @override
  final int iconCodePoint;
  @override
  final int? plantId;

  factory _$Reminder([void Function(ReminderBuilder)? updates]) =>
      (ReminderBuilder()..update(updates))._build();

  _$Reminder._({
    required this.id,
    required this.title,
    required this.time,
    required this.iconCodePoint,
    this.plantId,
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
        id == other.id &&
        title == other.title &&
        time == other.time &&
        iconCodePoint == other.iconCodePoint &&
        plantId == other.plantId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, title.hashCode);
    _$hash = $jc(_$hash, time.hashCode);
    _$hash = $jc(_$hash, iconCodePoint.hashCode);
    _$hash = $jc(_$hash, plantId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'Reminder')
          ..add('id', id)
          ..add('title', title)
          ..add('time', time)
          ..add('iconCodePoint', iconCodePoint)
          ..add('plantId', plantId))
        .toString();
  }
}

class ReminderBuilder implements Builder<Reminder, ReminderBuilder> {
  _$Reminder? _$v;

  int? _id;
  int? get id => _$this._id;
  set id(int? id) => _$this._id = id;

  String? _title;
  String? get title => _$this._title;
  set title(String? title) => _$this._title = title;

  DateTime? _time;
  DateTime? get time => _$this._time;
  set time(DateTime? time) => _$this._time = time;

  int? _iconCodePoint;
  int? get iconCodePoint => _$this._iconCodePoint;
  set iconCodePoint(int? iconCodePoint) =>
      _$this._iconCodePoint = iconCodePoint;

  int? _plantId;
  int? get plantId => _$this._plantId;
  set plantId(int? plantId) => _$this._plantId = plantId;

  ReminderBuilder();

  ReminderBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _title = $v.title;
      _time = $v.time;
      _iconCodePoint = $v.iconCodePoint;
      _plantId = $v.plantId;
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
          id: BuiltValueNullFieldError.checkNotNull(id, r'Reminder', 'id'),
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
          plantId: plantId,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
