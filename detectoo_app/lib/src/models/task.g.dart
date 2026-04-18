// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<Task> _$taskSerializer = _$TaskSerializer();

class _$TaskSerializer implements StructuredSerializer<Task> {
  @override
  final Iterable<Type> types = const [Task, _$Task];
  @override
  final String wireName = 'Task';

  @override
  Iterable<Object?> serialize(
    Serializers serializers,
    Task object, {
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
      'done',
      serializers.serialize(object.done, specifiedType: const FullType(bool)),
      'dueDate',
      serializers.serialize(
        object.dueDate,
        specifiedType: const FullType(DateTime),
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
  Task deserialize(
    Serializers serializers,
    Iterable<Object?> serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TaskBuilder();

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
        case 'done':
          result.done =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(bool),
                  )!
                  as bool;
          break;
        case 'dueDate':
          result.dueDate =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(DateTime),
                  )!
                  as DateTime;
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

class _$Task extends Task {
  @override
  final int id;
  @override
  final String title;
  @override
  final bool done;
  @override
  final DateTime dueDate;
  @override
  final int? plantId;

  factory _$Task([void Function(TaskBuilder)? updates]) =>
      (TaskBuilder()..update(updates))._build();

  _$Task._({
    required this.id,
    required this.title,
    required this.done,
    required this.dueDate,
    this.plantId,
  }) : super._();
  @override
  Task rebuild(void Function(TaskBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TaskBuilder toBuilder() => TaskBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Task &&
        id == other.id &&
        title == other.title &&
        done == other.done &&
        dueDate == other.dueDate &&
        plantId == other.plantId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, title.hashCode);
    _$hash = $jc(_$hash, done.hashCode);
    _$hash = $jc(_$hash, dueDate.hashCode);
    _$hash = $jc(_$hash, plantId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'Task')
          ..add('id', id)
          ..add('title', title)
          ..add('done', done)
          ..add('dueDate', dueDate)
          ..add('plantId', plantId))
        .toString();
  }
}

class TaskBuilder implements Builder<Task, TaskBuilder> {
  _$Task? _$v;

  int? _id;
  int? get id => _$this._id;
  set id(int? id) => _$this._id = id;

  String? _title;
  String? get title => _$this._title;
  set title(String? title) => _$this._title = title;

  bool? _done;
  bool? get done => _$this._done;
  set done(bool? done) => _$this._done = done;

  DateTime? _dueDate;
  DateTime? get dueDate => _$this._dueDate;
  set dueDate(DateTime? dueDate) => _$this._dueDate = dueDate;

  int? _plantId;
  int? get plantId => _$this._plantId;
  set plantId(int? plantId) => _$this._plantId = plantId;

  TaskBuilder();

  TaskBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _title = $v.title;
      _done = $v.done;
      _dueDate = $v.dueDate;
      _plantId = $v.plantId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Task other) {
    _$v = other as _$Task;
  }

  @override
  void update(void Function(TaskBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  Task build() => _build();

  _$Task _build() {
    final _$result =
        _$v ??
        _$Task._(
          id: BuiltValueNullFieldError.checkNotNull(id, r'Task', 'id'),
          title: BuiltValueNullFieldError.checkNotNull(title, r'Task', 'title'),
          done: BuiltValueNullFieldError.checkNotNull(done, r'Task', 'done'),
          dueDate: BuiltValueNullFieldError.checkNotNull(
            dueDate,
            r'Task',
            'dueDate',
          ),
          plantId: plantId,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
