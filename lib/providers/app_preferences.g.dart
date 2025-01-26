// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_preferences.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AppPreferencesAdapter extends TypeAdapter<AppPreferences> {
  @override
  final int typeId = 0;

  @override
  AppPreferences read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AppPreferences(
      theme: fields[0] as AppTheme,
      sortOrder: fields[1] as TaskSortOrder,
    );
  }

  @override
  void write(BinaryWriter writer, AppPreferences obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.theme)
      ..writeByte(1)
      ..write(obj.sortOrder);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppPreferencesAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AppThemeAdapter extends TypeAdapter<AppTheme> {
  @override
  final int typeId = 1;

  @override
  AppTheme read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return AppTheme.light;
      case 1:
        return AppTheme.dark;
      default:
        return AppTheme.light;
    }
  }

  @override
  void write(BinaryWriter writer, AppTheme obj) {
    switch (obj) {
      case AppTheme.light:
        writer.writeByte(0);
        break;
      case AppTheme.dark:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppThemeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TaskSortOrderAdapter extends TypeAdapter<TaskSortOrder> {
  @override
  final int typeId = 2;

  @override
  TaskSortOrder read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TaskSortOrder.byDate;
      case 1:
        return TaskSortOrder.byPriority;
      default:
        return TaskSortOrder.byDate;
    }
  }

  @override
  void write(BinaryWriter writer, TaskSortOrder obj) {
    switch (obj) {
      case TaskSortOrder.byDate:
        writer.writeByte(0);
        break;
      case TaskSortOrder.byPriority:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskSortOrderAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
