// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scan_result.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<ScanResult> _$scanResultSerializer = _$ScanResultSerializer();
Serializer<DetectedIssue> _$detectedIssueSerializer =
    _$DetectedIssueSerializer();

class _$ScanResultSerializer implements StructuredSerializer<ScanResult> {
  @override
  final Iterable<Type> types = const [ScanResult, _$ScanResult];
  @override
  final String wireName = 'ScanResult';

  @override
  Iterable<Object?> serialize(
    Serializers serializers,
    ScanResult object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = <Object?>[
      'id',
      serializers.serialize(object.id, specifiedType: const FullType(int)),
      'plantName',
      serializers.serialize(
        object.plantName,
        specifiedType: const FullType(String),
      ),
      'species',
      serializers.serialize(
        object.species,
        specifiedType: const FullType(String),
      ),
      'isHealthy',
      serializers.serialize(
        object.isHealthy,
        specifiedType: const FullType(bool),
      ),
      'issues',
      serializers.serialize(
        object.issues,
        specifiedType: const FullType(BuiltList, const [
          const FullType(DetectedIssue),
        ]),
      ),
    ];
    Object? value;
    value = object.plantId;
    if (value != null) {
      result
        ..add('plantId')
        ..add(serializers.serialize(value, specifiedType: const FullType(int)));
    }
    value = object.imageUrl;
    if (value != null) {
      result
        ..add('imageUrl')
        ..add(
          serializers.serialize(value, specifiedType: const FullType(String)),
        );
    }
    value = object.createdAt;
    if (value != null) {
      result
        ..add('createdAt')
        ..add(
          serializers.serialize(value, specifiedType: const FullType(DateTime)),
        );
    }
    return result;
  }

  @override
  ScanResult deserialize(
    Serializers serializers,
    Iterable<Object?> serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ScanResultBuilder();

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
        case 'plantName':
          result.plantName =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )!
                  as String;
          break;
        case 'species':
          result.species =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )!
                  as String;
          break;
        case 'isHealthy':
          result.isHealthy =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(bool),
                  )!
                  as bool;
          break;
        case 'issues':
          result.issues.replace(
            serializers.deserialize(
                  value,
                  specifiedType: const FullType(BuiltList, const [
                    const FullType(DetectedIssue),
                  ]),
                )!
                as BuiltList<Object?>,
          );
          break;
        case 'plantId':
          result.plantId =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int?;
          break;
        case 'imageUrl':
          result.imageUrl =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String?;
          break;
        case 'createdAt':
          result.createdAt =
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

class _$DetectedIssueSerializer implements StructuredSerializer<DetectedIssue> {
  @override
  final Iterable<Type> types = const [DetectedIssue, _$DetectedIssue];
  @override
  final String wireName = 'DetectedIssue';

  @override
  Iterable<Object?> serialize(
    Serializers serializers,
    DetectedIssue object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = <Object?>[
      'name',
      serializers.serialize(object.name, specifiedType: const FullType(String)),
      'description',
      serializers.serialize(
        object.description,
        specifiedType: const FullType(String),
      ),
      'severity',
      serializers.serialize(
        object.severity,
        specifiedType: const FullType(String),
      ),
      'confidence',
      serializers.serialize(
        object.confidence,
        specifiedType: const FullType(double),
      ),
    ];

    return result;
  }

  @override
  DetectedIssue deserialize(
    Serializers serializers,
    Iterable<Object?> serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = DetectedIssueBuilder();

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
        case 'description':
          result.description =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )!
                  as String;
          break;
        case 'severity':
          result.severity =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )!
                  as String;
          break;
        case 'confidence':
          result.confidence =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(double),
                  )!
                  as double;
          break;
      }
    }

    return result.build();
  }
}

class _$ScanResult extends ScanResult {
  @override
  final int id;
  @override
  final String plantName;
  @override
  final String species;
  @override
  final bool isHealthy;
  @override
  final BuiltList<DetectedIssue> issues;
  @override
  final int? plantId;
  @override
  final String? imageUrl;
  @override
  final DateTime? createdAt;

  factory _$ScanResult([void Function(ScanResultBuilder)? updates]) =>
      (ScanResultBuilder()..update(updates))._build();

  _$ScanResult._({
    required this.id,
    required this.plantName,
    required this.species,
    required this.isHealthy,
    required this.issues,
    this.plantId,
    this.imageUrl,
    this.createdAt,
  }) : super._();
  @override
  ScanResult rebuild(void Function(ScanResultBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ScanResultBuilder toBuilder() => ScanResultBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ScanResult &&
        id == other.id &&
        plantName == other.plantName &&
        species == other.species &&
        isHealthy == other.isHealthy &&
        issues == other.issues &&
        plantId == other.plantId &&
        imageUrl == other.imageUrl &&
        createdAt == other.createdAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, plantName.hashCode);
    _$hash = $jc(_$hash, species.hashCode);
    _$hash = $jc(_$hash, isHealthy.hashCode);
    _$hash = $jc(_$hash, issues.hashCode);
    _$hash = $jc(_$hash, plantId.hashCode);
    _$hash = $jc(_$hash, imageUrl.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ScanResult')
          ..add('id', id)
          ..add('plantName', plantName)
          ..add('species', species)
          ..add('isHealthy', isHealthy)
          ..add('issues', issues)
          ..add('plantId', plantId)
          ..add('imageUrl', imageUrl)
          ..add('createdAt', createdAt))
        .toString();
  }
}

class ScanResultBuilder implements Builder<ScanResult, ScanResultBuilder> {
  _$ScanResult? _$v;

  int? _id;
  int? get id => _$this._id;
  set id(int? id) => _$this._id = id;

  String? _plantName;
  String? get plantName => _$this._plantName;
  set plantName(String? plantName) => _$this._plantName = plantName;

  String? _species;
  String? get species => _$this._species;
  set species(String? species) => _$this._species = species;

  bool? _isHealthy;
  bool? get isHealthy => _$this._isHealthy;
  set isHealthy(bool? isHealthy) => _$this._isHealthy = isHealthy;

  ListBuilder<DetectedIssue>? _issues;
  ListBuilder<DetectedIssue> get issues =>
      _$this._issues ??= ListBuilder<DetectedIssue>();
  set issues(ListBuilder<DetectedIssue>? issues) => _$this._issues = issues;

  int? _plantId;
  int? get plantId => _$this._plantId;
  set plantId(int? plantId) => _$this._plantId = plantId;

  String? _imageUrl;
  String? get imageUrl => _$this._imageUrl;
  set imageUrl(String? imageUrl) => _$this._imageUrl = imageUrl;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  ScanResultBuilder();

  ScanResultBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _plantName = $v.plantName;
      _species = $v.species;
      _isHealthy = $v.isHealthy;
      _issues = $v.issues.toBuilder();
      _plantId = $v.plantId;
      _imageUrl = $v.imageUrl;
      _createdAt = $v.createdAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ScanResult other) {
    _$v = other as _$ScanResult;
  }

  @override
  void update(void Function(ScanResultBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ScanResult build() => _build();

  _$ScanResult _build() {
    _$ScanResult _$result;
    try {
      _$result =
          _$v ??
          _$ScanResult._(
            id: BuiltValueNullFieldError.checkNotNull(id, r'ScanResult', 'id'),
            plantName: BuiltValueNullFieldError.checkNotNull(
              plantName,
              r'ScanResult',
              'plantName',
            ),
            species: BuiltValueNullFieldError.checkNotNull(
              species,
              r'ScanResult',
              'species',
            ),
            isHealthy: BuiltValueNullFieldError.checkNotNull(
              isHealthy,
              r'ScanResult',
              'isHealthy',
            ),
            issues: issues.build(),
            plantId: plantId,
            imageUrl: imageUrl,
            createdAt: createdAt,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'issues';
        issues.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'ScanResult',
          _$failedField,
          e.toString(),
        );
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

class _$DetectedIssue extends DetectedIssue {
  @override
  final String name;
  @override
  final String description;
  @override
  final String severity;
  @override
  final double confidence;

  factory _$DetectedIssue([void Function(DetectedIssueBuilder)? updates]) =>
      (DetectedIssueBuilder()..update(updates))._build();

  _$DetectedIssue._({
    required this.name,
    required this.description,
    required this.severity,
    required this.confidence,
  }) : super._();
  @override
  DetectedIssue rebuild(void Function(DetectedIssueBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  DetectedIssueBuilder toBuilder() => DetectedIssueBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DetectedIssue &&
        name == other.name &&
        description == other.description &&
        severity == other.severity &&
        confidence == other.confidence;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, description.hashCode);
    _$hash = $jc(_$hash, severity.hashCode);
    _$hash = $jc(_$hash, confidence.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'DetectedIssue')
          ..add('name', name)
          ..add('description', description)
          ..add('severity', severity)
          ..add('confidence', confidence))
        .toString();
  }
}

class DetectedIssueBuilder
    implements Builder<DetectedIssue, DetectedIssueBuilder> {
  _$DetectedIssue? _$v;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  String? _description;
  String? get description => _$this._description;
  set description(String? description) => _$this._description = description;

  String? _severity;
  String? get severity => _$this._severity;
  set severity(String? severity) => _$this._severity = severity;

  double? _confidence;
  double? get confidence => _$this._confidence;
  set confidence(double? confidence) => _$this._confidence = confidence;

  DetectedIssueBuilder();

  DetectedIssueBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _name = $v.name;
      _description = $v.description;
      _severity = $v.severity;
      _confidence = $v.confidence;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(DetectedIssue other) {
    _$v = other as _$DetectedIssue;
  }

  @override
  void update(void Function(DetectedIssueBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  DetectedIssue build() => _build();

  _$DetectedIssue _build() {
    final _$result =
        _$v ??
        _$DetectedIssue._(
          name: BuiltValueNullFieldError.checkNotNull(
            name,
            r'DetectedIssue',
            'name',
          ),
          description: BuiltValueNullFieldError.checkNotNull(
            description,
            r'DetectedIssue',
            'description',
          ),
          severity: BuiltValueNullFieldError.checkNotNull(
            severity,
            r'DetectedIssue',
            'severity',
          ),
          confidence: BuiltValueNullFieldError.checkNotNull(
            confidence,
            r'DetectedIssue',
            'confidence',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
