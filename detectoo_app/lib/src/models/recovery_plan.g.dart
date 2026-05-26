// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recovery_plan.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<RecoveryStepPhoto> _$recoveryStepPhotoSerializer =
    _$RecoveryStepPhotoSerializer();
Serializer<RecoveryPlan> _$recoveryPlanSerializer = _$RecoveryPlanSerializer();
Serializer<RecoveryStep> _$recoveryStepSerializer = _$RecoveryStepSerializer();

class _$RecoveryStepPhotoSerializer
    implements StructuredSerializer<RecoveryStepPhoto> {
  @override
  final Iterable<Type> types = const [RecoveryStepPhoto, _$RecoveryStepPhoto];
  @override
  final String wireName = 'RecoveryStepPhoto';

  @override
  Iterable<Object?> serialize(
    Serializers serializers,
    RecoveryStepPhoto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = <Object?>[
      'id',
      serializers.serialize(object.id, specifiedType: const FullType(int)),
      'recoveryStepId',
      serializers.serialize(
        object.recoveryStepId,
        specifiedType: const FullType(int),
      ),
      'imageUrl',
      serializers.serialize(
        object.imageUrl,
        specifiedType: const FullType(String),
      ),
      'createdAt',
      serializers.serialize(
        object.createdAt,
        specifiedType: const FullType(DateTime),
      ),
    ];

    return result;
  }

  @override
  RecoveryStepPhoto deserialize(
    Serializers serializers,
    Iterable<Object?> serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = RecoveryStepPhotoBuilder();

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
        case 'recoveryStepId':
          result.recoveryStepId =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(int),
                  )!
                  as int;
          break;
        case 'imageUrl':
          result.imageUrl =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )!
                  as String;
          break;
        case 'createdAt':
          result.createdAt =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(DateTime),
                  )!
                  as DateTime;
          break;
      }
    }

    return result.build();
  }
}

class _$RecoveryPlanSerializer implements StructuredSerializer<RecoveryPlan> {
  @override
  final Iterable<Type> types = const [RecoveryPlan, _$RecoveryPlan];
  @override
  final String wireName = 'RecoveryPlan';

  @override
  Iterable<Object?> serialize(
    Serializers serializers,
    RecoveryPlan object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = <Object?>[
      'id',
      serializers.serialize(object.id, specifiedType: const FullType(int)),
      'plantId',
      serializers.serialize(object.plantId, specifiedType: const FullType(int)),
      'condition',
      serializers.serialize(
        object.condition,
        specifiedType: const FullType(String),
      ),
      'severity',
      serializers.serialize(
        object.severity,
        specifiedType: const FullType(String),
      ),
      'summary',
      serializers.serialize(
        object.summary,
        specifiedType: const FullType(String),
      ),
      'progress',
      serializers.serialize(
        object.progress,
        specifiedType: const FullType(double),
      ),
      'startedOn',
      serializers.serialize(
        object.startedOn,
        specifiedType: const FullType(DateTime),
      ),
      'isActive',
      serializers.serialize(
        object.isActive,
        specifiedType: const FullType(bool),
      ),
      'steps',
      serializers.serialize(
        object.steps,
        specifiedType: const FullType(BuiltList, const [
          const FullType(RecoveryStep),
        ]),
      ),
      'doList',
      serializers.serialize(
        object.doList,
        specifiedType: const FullType(BuiltList, const [
          const FullType(String),
        ]),
      ),
      'dontList',
      serializers.serialize(
        object.dontList,
        specifiedType: const FullType(BuiltList, const [
          const FullType(String),
        ]),
      ),
      'signsOfImprovement',
      serializers.serialize(
        object.signsOfImprovement,
        specifiedType: const FullType(BuiltList, const [
          const FullType(String),
        ]),
      ),
    ];
    Object? value;
    value = object.scanId;
    if (value != null) {
      result
        ..add('scanId')
        ..add(serializers.serialize(value, specifiedType: const FullType(int)));
    }
    value = object.estimatedRecovery;
    if (value != null) {
      result
        ..add('estimatedRecovery')
        ..add(
          serializers.serialize(value, specifiedType: const FullType(String)),
        );
    }
    return result;
  }

  @override
  RecoveryPlan deserialize(
    Serializers serializers,
    Iterable<Object?> serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = RecoveryPlanBuilder();

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
        case 'plantId':
          result.plantId =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(int),
                  )!
                  as int;
          break;
        case 'scanId':
          result.scanId =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int?;
          break;
        case 'condition':
          result.condition =
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
        case 'summary':
          result.summary =
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
        case 'startedOn':
          result.startedOn =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(DateTime),
                  )!
                  as DateTime;
          break;
        case 'estimatedRecovery':
          result.estimatedRecovery =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String?;
          break;
        case 'isActive':
          result.isActive =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(bool),
                  )!
                  as bool;
          break;
        case 'steps':
          result.steps.replace(
            serializers.deserialize(
                  value,
                  specifiedType: const FullType(BuiltList, const [
                    const FullType(RecoveryStep),
                  ]),
                )!
                as BuiltList<Object?>,
          );
          break;
        case 'doList':
          result.doList.replace(
            serializers.deserialize(
                  value,
                  specifiedType: const FullType(BuiltList, const [
                    const FullType(String),
                  ]),
                )!
                as BuiltList<Object?>,
          );
          break;
        case 'dontList':
          result.dontList.replace(
            serializers.deserialize(
                  value,
                  specifiedType: const FullType(BuiltList, const [
                    const FullType(String),
                  ]),
                )!
                as BuiltList<Object?>,
          );
          break;
        case 'signsOfImprovement':
          result.signsOfImprovement.replace(
            serializers.deserialize(
                  value,
                  specifiedType: const FullType(BuiltList, const [
                    const FullType(String),
                  ]),
                )!
                as BuiltList<Object?>,
          );
          break;
      }
    }

    return result.build();
  }
}

class _$RecoveryStepSerializer implements StructuredSerializer<RecoveryStep> {
  @override
  final Iterable<Type> types = const [RecoveryStep, _$RecoveryStep];
  @override
  final String wireName = 'RecoveryStep';

  @override
  Iterable<Object?> serialize(
    Serializers serializers,
    RecoveryStep object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = <Object?>[
      'id',
      serializers.serialize(object.id, specifiedType: const FullType(int)),
      'recoveryPlanId',
      serializers.serialize(
        object.recoveryPlanId,
        specifiedType: const FullType(int),
      ),
      'title',
      serializers.serialize(
        object.title,
        specifiedType: const FullType(String),
      ),
      'description',
      serializers.serialize(
        object.description,
        specifiedType: const FullType(String),
      ),
      'iconCodePoint',
      serializers.serialize(
        object.iconCodePoint,
        specifiedType: const FullType(int),
      ),
      'completed',
      serializers.serialize(
        object.completed,
        specifiedType: const FullType(bool),
      ),
      'stepOrder',
      serializers.serialize(
        object.stepOrder,
        specifiedType: const FullType(int),
      ),
      'photos',
      serializers.serialize(
        object.photos,
        specifiedType: const FullType(BuiltList, const [
          const FullType(RecoveryStepPhoto),
        ]),
      ),
    ];

    return result;
  }

  @override
  RecoveryStep deserialize(
    Serializers serializers,
    Iterable<Object?> serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = RecoveryStepBuilder();

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
        case 'recoveryPlanId':
          result.recoveryPlanId =
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
        case 'description':
          result.description =
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
        case 'completed':
          result.completed =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(bool),
                  )!
                  as bool;
          break;
        case 'stepOrder':
          result.stepOrder =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(int),
                  )!
                  as int;
          break;
        case 'photos':
          result.photos.replace(
            serializers.deserialize(
                  value,
                  specifiedType: const FullType(BuiltList, const [
                    const FullType(RecoveryStepPhoto),
                  ]),
                )!
                as BuiltList<Object?>,
          );
          break;
      }
    }

    return result.build();
  }
}

class _$RecoveryStepPhoto extends RecoveryStepPhoto {
  @override
  final int id;
  @override
  final int recoveryStepId;
  @override
  final String imageUrl;
  @override
  final DateTime createdAt;

  factory _$RecoveryStepPhoto([
    void Function(RecoveryStepPhotoBuilder)? updates,
  ]) => (RecoveryStepPhotoBuilder()..update(updates))._build();

  _$RecoveryStepPhoto._({
    required this.id,
    required this.recoveryStepId,
    required this.imageUrl,
    required this.createdAt,
  }) : super._();
  @override
  RecoveryStepPhoto rebuild(void Function(RecoveryStepPhotoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  RecoveryStepPhotoBuilder toBuilder() =>
      RecoveryStepPhotoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is RecoveryStepPhoto &&
        id == other.id &&
        recoveryStepId == other.recoveryStepId &&
        imageUrl == other.imageUrl &&
        createdAt == other.createdAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, recoveryStepId.hashCode);
    _$hash = $jc(_$hash, imageUrl.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'RecoveryStepPhoto')
          ..add('id', id)
          ..add('recoveryStepId', recoveryStepId)
          ..add('imageUrl', imageUrl)
          ..add('createdAt', createdAt))
        .toString();
  }
}

class RecoveryStepPhotoBuilder
    implements Builder<RecoveryStepPhoto, RecoveryStepPhotoBuilder> {
  _$RecoveryStepPhoto? _$v;

  int? _id;
  int? get id => _$this._id;
  set id(int? id) => _$this._id = id;

  int? _recoveryStepId;
  int? get recoveryStepId => _$this._recoveryStepId;
  set recoveryStepId(int? recoveryStepId) =>
      _$this._recoveryStepId = recoveryStepId;

  String? _imageUrl;
  String? get imageUrl => _$this._imageUrl;
  set imageUrl(String? imageUrl) => _$this._imageUrl = imageUrl;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  RecoveryStepPhotoBuilder();

  RecoveryStepPhotoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _recoveryStepId = $v.recoveryStepId;
      _imageUrl = $v.imageUrl;
      _createdAt = $v.createdAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(RecoveryStepPhoto other) {
    _$v = other as _$RecoveryStepPhoto;
  }

  @override
  void update(void Function(RecoveryStepPhotoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  RecoveryStepPhoto build() => _build();

  _$RecoveryStepPhoto _build() {
    final _$result =
        _$v ??
        _$RecoveryStepPhoto._(
          id: BuiltValueNullFieldError.checkNotNull(
            id,
            r'RecoveryStepPhoto',
            'id',
          ),
          recoveryStepId: BuiltValueNullFieldError.checkNotNull(
            recoveryStepId,
            r'RecoveryStepPhoto',
            'recoveryStepId',
          ),
          imageUrl: BuiltValueNullFieldError.checkNotNull(
            imageUrl,
            r'RecoveryStepPhoto',
            'imageUrl',
          ),
          createdAt: BuiltValueNullFieldError.checkNotNull(
            createdAt,
            r'RecoveryStepPhoto',
            'createdAt',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

class _$RecoveryPlan extends RecoveryPlan {
  @override
  final int id;
  @override
  final int plantId;
  @override
  final int? scanId;
  @override
  final String condition;
  @override
  final String severity;
  @override
  final String summary;
  @override
  final double progress;
  @override
  final DateTime startedOn;
  @override
  final String? estimatedRecovery;
  @override
  final bool isActive;
  @override
  final BuiltList<RecoveryStep> steps;
  @override
  final BuiltList<String> doList;
  @override
  final BuiltList<String> dontList;
  @override
  final BuiltList<String> signsOfImprovement;

  factory _$RecoveryPlan([void Function(RecoveryPlanBuilder)? updates]) =>
      (RecoveryPlanBuilder()..update(updates))._build();

  _$RecoveryPlan._({
    required this.id,
    required this.plantId,
    this.scanId,
    required this.condition,
    required this.severity,
    required this.summary,
    required this.progress,
    required this.startedOn,
    this.estimatedRecovery,
    required this.isActive,
    required this.steps,
    required this.doList,
    required this.dontList,
    required this.signsOfImprovement,
  }) : super._();
  @override
  RecoveryPlan rebuild(void Function(RecoveryPlanBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  RecoveryPlanBuilder toBuilder() => RecoveryPlanBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is RecoveryPlan &&
        id == other.id &&
        plantId == other.plantId &&
        scanId == other.scanId &&
        condition == other.condition &&
        severity == other.severity &&
        summary == other.summary &&
        progress == other.progress &&
        startedOn == other.startedOn &&
        estimatedRecovery == other.estimatedRecovery &&
        isActive == other.isActive &&
        steps == other.steps &&
        doList == other.doList &&
        dontList == other.dontList &&
        signsOfImprovement == other.signsOfImprovement;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, plantId.hashCode);
    _$hash = $jc(_$hash, scanId.hashCode);
    _$hash = $jc(_$hash, condition.hashCode);
    _$hash = $jc(_$hash, severity.hashCode);
    _$hash = $jc(_$hash, summary.hashCode);
    _$hash = $jc(_$hash, progress.hashCode);
    _$hash = $jc(_$hash, startedOn.hashCode);
    _$hash = $jc(_$hash, estimatedRecovery.hashCode);
    _$hash = $jc(_$hash, isActive.hashCode);
    _$hash = $jc(_$hash, steps.hashCode);
    _$hash = $jc(_$hash, doList.hashCode);
    _$hash = $jc(_$hash, dontList.hashCode);
    _$hash = $jc(_$hash, signsOfImprovement.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'RecoveryPlan')
          ..add('id', id)
          ..add('plantId', plantId)
          ..add('scanId', scanId)
          ..add('condition', condition)
          ..add('severity', severity)
          ..add('summary', summary)
          ..add('progress', progress)
          ..add('startedOn', startedOn)
          ..add('estimatedRecovery', estimatedRecovery)
          ..add('isActive', isActive)
          ..add('steps', steps)
          ..add('doList', doList)
          ..add('dontList', dontList)
          ..add('signsOfImprovement', signsOfImprovement))
        .toString();
  }
}

class RecoveryPlanBuilder
    implements Builder<RecoveryPlan, RecoveryPlanBuilder> {
  _$RecoveryPlan? _$v;

  int? _id;
  int? get id => _$this._id;
  set id(int? id) => _$this._id = id;

  int? _plantId;
  int? get plantId => _$this._plantId;
  set plantId(int? plantId) => _$this._plantId = plantId;

  int? _scanId;
  int? get scanId => _$this._scanId;
  set scanId(int? scanId) => _$this._scanId = scanId;

  String? _condition;
  String? get condition => _$this._condition;
  set condition(String? condition) => _$this._condition = condition;

  String? _severity;
  String? get severity => _$this._severity;
  set severity(String? severity) => _$this._severity = severity;

  String? _summary;
  String? get summary => _$this._summary;
  set summary(String? summary) => _$this._summary = summary;

  double? _progress;
  double? get progress => _$this._progress;
  set progress(double? progress) => _$this._progress = progress;

  DateTime? _startedOn;
  DateTime? get startedOn => _$this._startedOn;
  set startedOn(DateTime? startedOn) => _$this._startedOn = startedOn;

  String? _estimatedRecovery;
  String? get estimatedRecovery => _$this._estimatedRecovery;
  set estimatedRecovery(String? estimatedRecovery) =>
      _$this._estimatedRecovery = estimatedRecovery;

  bool? _isActive;
  bool? get isActive => _$this._isActive;
  set isActive(bool? isActive) => _$this._isActive = isActive;

  ListBuilder<RecoveryStep>? _steps;
  ListBuilder<RecoveryStep> get steps =>
      _$this._steps ??= ListBuilder<RecoveryStep>();
  set steps(ListBuilder<RecoveryStep>? steps) => _$this._steps = steps;

  ListBuilder<String>? _doList;
  ListBuilder<String> get doList => _$this._doList ??= ListBuilder<String>();
  set doList(ListBuilder<String>? doList) => _$this._doList = doList;

  ListBuilder<String>? _dontList;
  ListBuilder<String> get dontList =>
      _$this._dontList ??= ListBuilder<String>();
  set dontList(ListBuilder<String>? dontList) => _$this._dontList = dontList;

  ListBuilder<String>? _signsOfImprovement;
  ListBuilder<String> get signsOfImprovement =>
      _$this._signsOfImprovement ??= ListBuilder<String>();
  set signsOfImprovement(ListBuilder<String>? signsOfImprovement) =>
      _$this._signsOfImprovement = signsOfImprovement;

  RecoveryPlanBuilder();

  RecoveryPlanBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _plantId = $v.plantId;
      _scanId = $v.scanId;
      _condition = $v.condition;
      _severity = $v.severity;
      _summary = $v.summary;
      _progress = $v.progress;
      _startedOn = $v.startedOn;
      _estimatedRecovery = $v.estimatedRecovery;
      _isActive = $v.isActive;
      _steps = $v.steps.toBuilder();
      _doList = $v.doList.toBuilder();
      _dontList = $v.dontList.toBuilder();
      _signsOfImprovement = $v.signsOfImprovement.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(RecoveryPlan other) {
    _$v = other as _$RecoveryPlan;
  }

  @override
  void update(void Function(RecoveryPlanBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  RecoveryPlan build() => _build();

  _$RecoveryPlan _build() {
    _$RecoveryPlan _$result;
    try {
      _$result =
          _$v ??
          _$RecoveryPlan._(
            id: BuiltValueNullFieldError.checkNotNull(
              id,
              r'RecoveryPlan',
              'id',
            ),
            plantId: BuiltValueNullFieldError.checkNotNull(
              plantId,
              r'RecoveryPlan',
              'plantId',
            ),
            scanId: scanId,
            condition: BuiltValueNullFieldError.checkNotNull(
              condition,
              r'RecoveryPlan',
              'condition',
            ),
            severity: BuiltValueNullFieldError.checkNotNull(
              severity,
              r'RecoveryPlan',
              'severity',
            ),
            summary: BuiltValueNullFieldError.checkNotNull(
              summary,
              r'RecoveryPlan',
              'summary',
            ),
            progress: BuiltValueNullFieldError.checkNotNull(
              progress,
              r'RecoveryPlan',
              'progress',
            ),
            startedOn: BuiltValueNullFieldError.checkNotNull(
              startedOn,
              r'RecoveryPlan',
              'startedOn',
            ),
            estimatedRecovery: estimatedRecovery,
            isActive: BuiltValueNullFieldError.checkNotNull(
              isActive,
              r'RecoveryPlan',
              'isActive',
            ),
            steps: steps.build(),
            doList: doList.build(),
            dontList: dontList.build(),
            signsOfImprovement: signsOfImprovement.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'steps';
        steps.build();
        _$failedField = 'doList';
        doList.build();
        _$failedField = 'dontList';
        dontList.build();
        _$failedField = 'signsOfImprovement';
        signsOfImprovement.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'RecoveryPlan',
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

class _$RecoveryStep extends RecoveryStep {
  @override
  final int id;
  @override
  final int recoveryPlanId;
  @override
  final String title;
  @override
  final String description;
  @override
  final int iconCodePoint;
  @override
  final bool completed;
  @override
  final int stepOrder;
  @override
  final BuiltList<RecoveryStepPhoto> photos;

  factory _$RecoveryStep([void Function(RecoveryStepBuilder)? updates]) =>
      (RecoveryStepBuilder()..update(updates))._build();

  _$RecoveryStep._({
    required this.id,
    required this.recoveryPlanId,
    required this.title,
    required this.description,
    required this.iconCodePoint,
    required this.completed,
    required this.stepOrder,
    required this.photos,
  }) : super._();
  @override
  RecoveryStep rebuild(void Function(RecoveryStepBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  RecoveryStepBuilder toBuilder() => RecoveryStepBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is RecoveryStep &&
        id == other.id &&
        recoveryPlanId == other.recoveryPlanId &&
        title == other.title &&
        description == other.description &&
        iconCodePoint == other.iconCodePoint &&
        completed == other.completed &&
        stepOrder == other.stepOrder &&
        photos == other.photos;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, recoveryPlanId.hashCode);
    _$hash = $jc(_$hash, title.hashCode);
    _$hash = $jc(_$hash, description.hashCode);
    _$hash = $jc(_$hash, iconCodePoint.hashCode);
    _$hash = $jc(_$hash, completed.hashCode);
    _$hash = $jc(_$hash, stepOrder.hashCode);
    _$hash = $jc(_$hash, photos.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'RecoveryStep')
          ..add('id', id)
          ..add('recoveryPlanId', recoveryPlanId)
          ..add('title', title)
          ..add('description', description)
          ..add('iconCodePoint', iconCodePoint)
          ..add('completed', completed)
          ..add('stepOrder', stepOrder)
          ..add('photos', photos))
        .toString();
  }
}

class RecoveryStepBuilder
    implements Builder<RecoveryStep, RecoveryStepBuilder> {
  _$RecoveryStep? _$v;

  int? _id;
  int? get id => _$this._id;
  set id(int? id) => _$this._id = id;

  int? _recoveryPlanId;
  int? get recoveryPlanId => _$this._recoveryPlanId;
  set recoveryPlanId(int? recoveryPlanId) =>
      _$this._recoveryPlanId = recoveryPlanId;

  String? _title;
  String? get title => _$this._title;
  set title(String? title) => _$this._title = title;

  String? _description;
  String? get description => _$this._description;
  set description(String? description) => _$this._description = description;

  int? _iconCodePoint;
  int? get iconCodePoint => _$this._iconCodePoint;
  set iconCodePoint(int? iconCodePoint) =>
      _$this._iconCodePoint = iconCodePoint;

  bool? _completed;
  bool? get completed => _$this._completed;
  set completed(bool? completed) => _$this._completed = completed;

  int? _stepOrder;
  int? get stepOrder => _$this._stepOrder;
  set stepOrder(int? stepOrder) => _$this._stepOrder = stepOrder;

  ListBuilder<RecoveryStepPhoto>? _photos;
  ListBuilder<RecoveryStepPhoto> get photos =>
      _$this._photos ??= ListBuilder<RecoveryStepPhoto>();
  set photos(ListBuilder<RecoveryStepPhoto>? photos) => _$this._photos = photos;

  RecoveryStepBuilder();

  RecoveryStepBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _recoveryPlanId = $v.recoveryPlanId;
      _title = $v.title;
      _description = $v.description;
      _iconCodePoint = $v.iconCodePoint;
      _completed = $v.completed;
      _stepOrder = $v.stepOrder;
      _photos = $v.photos.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(RecoveryStep other) {
    _$v = other as _$RecoveryStep;
  }

  @override
  void update(void Function(RecoveryStepBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  RecoveryStep build() => _build();

  _$RecoveryStep _build() {
    _$RecoveryStep _$result;
    try {
      _$result =
          _$v ??
          _$RecoveryStep._(
            id: BuiltValueNullFieldError.checkNotNull(
              id,
              r'RecoveryStep',
              'id',
            ),
            recoveryPlanId: BuiltValueNullFieldError.checkNotNull(
              recoveryPlanId,
              r'RecoveryStep',
              'recoveryPlanId',
            ),
            title: BuiltValueNullFieldError.checkNotNull(
              title,
              r'RecoveryStep',
              'title',
            ),
            description: BuiltValueNullFieldError.checkNotNull(
              description,
              r'RecoveryStep',
              'description',
            ),
            iconCodePoint: BuiltValueNullFieldError.checkNotNull(
              iconCodePoint,
              r'RecoveryStep',
              'iconCodePoint',
            ),
            completed: BuiltValueNullFieldError.checkNotNull(
              completed,
              r'RecoveryStep',
              'completed',
            ),
            stepOrder: BuiltValueNullFieldError.checkNotNull(
              stepOrder,
              r'RecoveryStep',
              'stepOrder',
            ),
            photos: photos.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'photos';
        photos.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'RecoveryStep',
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

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
