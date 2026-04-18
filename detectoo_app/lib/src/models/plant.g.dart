// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plant.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const PlantHealthStatus _$healthy = const PlantHealthStatus._('healthy');
const PlantHealthStatus _$needsAttention = const PlantHealthStatus._(
  'needsAttention',
);
const PlantHealthStatus _$recovering = const PlantHealthStatus._('recovering');

PlantHealthStatus _$plantHealthStatusValueOf(String name) {
  switch (name) {
    case 'healthy':
      return _$healthy;
    case 'needsAttention':
      return _$needsAttention;
    case 'recovering':
      return _$recovering;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PlantHealthStatus> _$plantHealthStatusValues =
    BuiltSet<PlantHealthStatus>(const <PlantHealthStatus>[
      _$healthy,
      _$needsAttention,
      _$recovering,
    ]);

Serializer<Plant> _$plantSerializer = _$PlantSerializer();
Serializer<PlantHealthStatus> _$plantHealthStatusSerializer =
    _$PlantHealthStatusSerializer();

class _$PlantSerializer implements StructuredSerializer<Plant> {
  @override
  final Iterable<Type> types = const [Plant, _$Plant];
  @override
  final String wireName = 'Plant';

  @override
  Iterable<Object?> serialize(
    Serializers serializers,
    Plant object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = <Object?>[
      'id',
      serializers.serialize(object.id, specifiedType: const FullType(int)),
      'name',
      serializers.serialize(object.name, specifiedType: const FullType(String)),
      'iconCodePoint',
      serializers.serialize(
        object.iconCodePoint,
        specifiedType: const FullType(int),
      ),
      'healthStatus',
      serializers.serialize(
        object.healthStatus,
        specifiedType: const FullType(PlantHealthStatus),
      ),
    ];
    Object? value;
    value = object.lastWatered;
    if (value != null) {
      result
        ..add('lastWatered')
        ..add(
          serializers.serialize(value, specifiedType: const FullType(DateTime)),
        );
    }
    return result;
  }

  @override
  Plant deserialize(
    Serializers serializers,
    Iterable<Object?> serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PlantBuilder();

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
        case 'name':
          result.name =
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
        case 'healthStatus':
          result.healthStatus =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(PlantHealthStatus),
                  )!
                  as PlantHealthStatus;
          break;
        case 'lastWatered':
          result.lastWatered =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(DateTime),
                  )
                  as DateTime?;
          break;
      }
    }

    return result.build();
  }
}

class _$PlantHealthStatusSerializer
    implements PrimitiveSerializer<PlantHealthStatus> {
  @override
  final Iterable<Type> types = const <Type>[PlantHealthStatus];
  @override
  final String wireName = 'PlantHealthStatus';

  @override
  Object serialize(
    Serializers serializers,
    PlantHealthStatus object, {
    FullType specifiedType = FullType.unspecified,
  }) => object.name;

  @override
  PlantHealthStatus deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => PlantHealthStatus.valueOf(serialized as String);
}

class _$Plant extends Plant {
  @override
  final int id;
  @override
  final String name;
  @override
  final int iconCodePoint;
  @override
  final PlantHealthStatus healthStatus;
  @override
  final DateTime? lastWatered;

  factory _$Plant([void Function(PlantBuilder)? updates]) =>
      (PlantBuilder()..update(updates))._build();

  _$Plant._({
    required this.id,
    required this.name,
    required this.iconCodePoint,
    required this.healthStatus,
    this.lastWatered,
  }) : super._();
  @override
  Plant rebuild(void Function(PlantBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PlantBuilder toBuilder() => PlantBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Plant &&
        id == other.id &&
        name == other.name &&
        iconCodePoint == other.iconCodePoint &&
        healthStatus == other.healthStatus &&
        lastWatered == other.lastWatered;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, iconCodePoint.hashCode);
    _$hash = $jc(_$hash, healthStatus.hashCode);
    _$hash = $jc(_$hash, lastWatered.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'Plant')
          ..add('id', id)
          ..add('name', name)
          ..add('iconCodePoint', iconCodePoint)
          ..add('healthStatus', healthStatus)
          ..add('lastWatered', lastWatered))
        .toString();
  }
}

class PlantBuilder implements Builder<Plant, PlantBuilder> {
  _$Plant? _$v;

  int? _id;
  int? get id => _$this._id;
  set id(int? id) => _$this._id = id;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  int? _iconCodePoint;
  int? get iconCodePoint => _$this._iconCodePoint;
  set iconCodePoint(int? iconCodePoint) =>
      _$this._iconCodePoint = iconCodePoint;

  PlantHealthStatus? _healthStatus;
  PlantHealthStatus? get healthStatus => _$this._healthStatus;
  set healthStatus(PlantHealthStatus? healthStatus) =>
      _$this._healthStatus = healthStatus;

  DateTime? _lastWatered;
  DateTime? get lastWatered => _$this._lastWatered;
  set lastWatered(DateTime? lastWatered) => _$this._lastWatered = lastWatered;

  PlantBuilder();

  PlantBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _name = $v.name;
      _iconCodePoint = $v.iconCodePoint;
      _healthStatus = $v.healthStatus;
      _lastWatered = $v.lastWatered;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Plant other) {
    _$v = other as _$Plant;
  }

  @override
  void update(void Function(PlantBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  Plant build() => _build();

  _$Plant _build() {
    final _$result =
        _$v ??
        _$Plant._(
          id: BuiltValueNullFieldError.checkNotNull(id, r'Plant', 'id'),
          name: BuiltValueNullFieldError.checkNotNull(name, r'Plant', 'name'),
          iconCodePoint: BuiltValueNullFieldError.checkNotNull(
            iconCodePoint,
            r'Plant',
            'iconCodePoint',
          ),
          healthStatus: BuiltValueNullFieldError.checkNotNull(
            healthStatus,
            r'Plant',
            'healthStatus',
          ),
          lastWatered: lastWatered,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
