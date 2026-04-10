// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recovery_plan.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<RecoveryPlan> _$recoveryPlanSerializer = _$RecoveryPlanSerializer();
Serializer<RecoveryStep> _$recoveryStepSerializer = _$RecoveryStepSerializer();

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
        specifiedType: const FullType(String),
      ),
      'estimatedRecovery',
      serializers.serialize(
        object.estimatedRecovery,
        specifiedType: const FullType(String),
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
                    specifiedType: const FullType(String),
                  )!
                  as String;
          break;
        case 'estimatedRecovery':
          result.estimatedRecovery =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )!
                  as String;
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
      }
    }

    return result.build();
  }
}

class _$RecoveryPlan extends RecoveryPlan {
  @override
  final String condition;
  @override
  final String severity;
  @override
  final String summary;
  @override
  final double progress;
  @override
  final String startedOn;
  @override
  final String estimatedRecovery;
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
    required this.condition,
    required this.severity,
    required this.summary,
    required this.progress,
    required this.startedOn,
    required this.estimatedRecovery,
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
        condition == other.condition &&
        severity == other.severity &&
        summary == other.summary &&
        progress == other.progress &&
        startedOn == other.startedOn &&
        estimatedRecovery == other.estimatedRecovery &&
        steps == other.steps &&
        doList == other.doList &&
        dontList == other.dontList &&
        signsOfImprovement == other.signsOfImprovement;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, condition.hashCode);
    _$hash = $jc(_$hash, severity.hashCode);
    _$hash = $jc(_$hash, summary.hashCode);
    _$hash = $jc(_$hash, progress.hashCode);
    _$hash = $jc(_$hash, startedOn.hashCode);
    _$hash = $jc(_$hash, estimatedRecovery.hashCode);
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
          ..add('condition', condition)
          ..add('severity', severity)
          ..add('summary', summary)
          ..add('progress', progress)
          ..add('startedOn', startedOn)
          ..add('estimatedRecovery', estimatedRecovery)
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

  String? _startedOn;
  String? get startedOn => _$this._startedOn;
  set startedOn(String? startedOn) => _$this._startedOn = startedOn;

  String? _estimatedRecovery;
  String? get estimatedRecovery => _$this._estimatedRecovery;
  set estimatedRecovery(String? estimatedRecovery) =>
      _$this._estimatedRecovery = estimatedRecovery;

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
      _condition = $v.condition;
      _severity = $v.severity;
      _summary = $v.summary;
      _progress = $v.progress;
      _startedOn = $v.startedOn;
      _estimatedRecovery = $v.estimatedRecovery;
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
            estimatedRecovery: BuiltValueNullFieldError.checkNotNull(
              estimatedRecovery,
              r'RecoveryPlan',
              'estimatedRecovery',
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
  final String title;
  @override
  final String description;
  @override
  final int iconCodePoint;
  @override
  final bool completed;

  factory _$RecoveryStep([void Function(RecoveryStepBuilder)? updates]) =>
      (RecoveryStepBuilder()..update(updates))._build();

  _$RecoveryStep._({
    required this.title,
    required this.description,
    required this.iconCodePoint,
    required this.completed,
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
        title == other.title &&
        description == other.description &&
        iconCodePoint == other.iconCodePoint &&
        completed == other.completed;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, title.hashCode);
    _$hash = $jc(_$hash, description.hashCode);
    _$hash = $jc(_$hash, iconCodePoint.hashCode);
    _$hash = $jc(_$hash, completed.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'RecoveryStep')
          ..add('title', title)
          ..add('description', description)
          ..add('iconCodePoint', iconCodePoint)
          ..add('completed', completed))
        .toString();
  }
}

class RecoveryStepBuilder
    implements Builder<RecoveryStep, RecoveryStepBuilder> {
  _$RecoveryStep? _$v;

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

  RecoveryStepBuilder();

  RecoveryStepBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _title = $v.title;
      _description = $v.description;
      _iconCodePoint = $v.iconCodePoint;
      _completed = $v.completed;
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
    final _$result =
        _$v ??
        _$RecoveryStep._(
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
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
