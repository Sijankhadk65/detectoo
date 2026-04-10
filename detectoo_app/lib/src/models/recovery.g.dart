// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recovery.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<Recovery> _$recoverySerializer = _$RecoverySerializer();

class _$RecoverySerializer implements StructuredSerializer<Recovery> {
  @override
  final Iterable<Type> types = const [Recovery, _$Recovery];
  @override
  final String wireName = 'Recovery';

  @override
  Iterable<Object?> serialize(
    Serializers serializers,
    Recovery object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = <Object?>[
      'plantName',
      serializers.serialize(
        object.plantName,
        specifiedType: const FullType(String),
      ),
      'condition',
      serializers.serialize(
        object.condition,
        specifiedType: const FullType(String),
      ),
      'progress',
      serializers.serialize(
        object.progress,
        specifiedType: const FullType(double),
      ),
      'status',
      serializers.serialize(
        object.status,
        specifiedType: const FullType(String),
      ),
    ];

    return result;
  }

  @override
  Recovery deserialize(
    Serializers serializers,
    Iterable<Object?> serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = RecoveryBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case 'plantName':
          result.plantName =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )!
                  as String;
          break;
        case 'condition':
          result.condition =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )!
                  as String;
          break;
        case 'progress':
          result.progress =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(double),
                  )!
                  as double;
          break;
        case 'status':
          result.status =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )!
                  as String;
          break;
      }
    }

    return result.build();
  }
}

class _$Recovery extends Recovery {
  @override
  final String plantName;
  @override
  final String condition;
  @override
  final double progress;
  @override
  final String status;

  factory _$Recovery([void Function(RecoveryBuilder)? updates]) =>
      (RecoveryBuilder()..update(updates))._build();

  _$Recovery._({
    required this.plantName,
    required this.condition,
    required this.progress,
    required this.status,
  }) : super._();
  @override
  Recovery rebuild(void Function(RecoveryBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  RecoveryBuilder toBuilder() => RecoveryBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Recovery &&
        plantName == other.plantName &&
        condition == other.condition &&
        progress == other.progress &&
        status == other.status;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, plantName.hashCode);
    _$hash = $jc(_$hash, condition.hashCode);
    _$hash = $jc(_$hash, progress.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'Recovery')
          ..add('plantName', plantName)
          ..add('condition', condition)
          ..add('progress', progress)
          ..add('status', status))
        .toString();
  }
}

class RecoveryBuilder implements Builder<Recovery, RecoveryBuilder> {
  _$Recovery? _$v;

  String? _plantName;
  String? get plantName => _$this._plantName;
  set plantName(String? plantName) => _$this._plantName = plantName;

  String? _condition;
  String? get condition => _$this._condition;
  set condition(String? condition) => _$this._condition = condition;

  double? _progress;
  double? get progress => _$this._progress;
  set progress(double? progress) => _$this._progress = progress;

  String? _status;
  String? get status => _$this._status;
  set status(String? status) => _$this._status = status;

  RecoveryBuilder();

  RecoveryBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _plantName = $v.plantName;
      _condition = $v.condition;
      _progress = $v.progress;
      _status = $v.status;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Recovery other) {
    _$v = other as _$Recovery;
  }

  @override
  void update(void Function(RecoveryBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  Recovery build() => _build();

  _$Recovery _build() {
    final _$result =
        _$v ??
        _$Recovery._(
          plantName: BuiltValueNullFieldError.checkNotNull(
            plantName,
            r'Recovery',
            'plantName',
          ),
          condition: BuiltValueNullFieldError.checkNotNull(
            condition,
            r'Recovery',
            'condition',
          ),
          progress: BuiltValueNullFieldError.checkNotNull(
            progress,
            r'Recovery',
            'progress',
          ),
          status: BuiltValueNullFieldError.checkNotNull(
            status,
            r'Recovery',
            'status',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
