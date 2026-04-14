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
        specifiedType: const FullType(String),
      ),
    ];

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
                    specifiedType: const FullType(String),
                  )!
                  as String;
          break;
      }
    }

    return result.build();
  }
}

class _$Task extends Task {
  @override
  final String title;
  @override
  final bool done;
  @override
  final String dueDate;

  factory _$Task([void Function(TaskBuilder)? updates]) =>
      (TaskBuilder()..update(updates))._build();

  _$Task._({required this.title, required this.done, required this.dueDate})
    : super._();
  @override
  Task rebuild(void Function(TaskBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TaskBuilder toBuilder() => TaskBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Task &&
        title == other.title &&
        done == other.done &&
        dueDate == other.dueDate;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, title.hashCode);
    _$hash = $jc(_$hash, done.hashCode);
    _$hash = $jc(_$hash, dueDate.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'Task')
          ..add('title', title)
          ..add('done', done)
          ..add('dueDate', dueDate))
        .toString();
  }
}

class TaskBuilder implements Builder<Task, TaskBuilder> {
  _$Task? _$v;

  String? _title;
  String? get title => _$this._title;
  set title(String? title) => _$this._title = title;

  bool? _done;
  bool? get done => _$this._done;
  set done(bool? done) => _$this._done = done;

  String? _dueDate;
  String? get dueDate => _$this._dueDate;
  set dueDate(String? dueDate) => _$this._dueDate = dueDate;

  TaskBuilder();

  TaskBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _title = $v.title;
      _done = $v.done;
      _dueDate = $v.dueDate;
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
          title: BuiltValueNullFieldError.checkNotNull(title, r'Task', 'title'),
          done: BuiltValueNullFieldError.checkNotNull(done, r'Task', 'done'),
          dueDate: BuiltValueNullFieldError.checkNotNull(
            dueDate,
            r'Task',
            'dueDate',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
