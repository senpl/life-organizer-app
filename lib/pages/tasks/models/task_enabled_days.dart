class TaskEnabledDays {
  static final tblTaskEnableDays = "taskEnabledDays";
  static final dbId = "id";
  static final dbTaskId = "taskId";
  static final dbEnabledDaysId = "enabledDaysId";

  int id, taskId, enabledDaysId;

  TaskEnabledDays.create(this.taskId, this.enabledDaysId);

  TaskEnabledDays.update({this.id, this.taskId, this.enabledDaysId});

  TaskEnabledDays.fromMap(Map<String, dynamic> map)
      : this.update(
            id: map[dbId], taskId: map[dbTaskId], enabledDaysId: map[dbEnabledDaysId]);
}
