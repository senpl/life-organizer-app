import 'dart:async';
import 'dart:collection';

import 'package:flutter_app/bloc/bloc_provider.dart';
import 'package:flutter_app/pages/tasks/task_db.dart';
import 'package:flutter_app/pages/tasks/models/tasks.dart';
import 'package:flutter_app/models/repeat.dart';

class TaskBloc implements BlocBase {
  ///
  /// Synchronous Stream to handle the provision of the movie genres
  ///
  StreamController<List<Tasks>> _taskController =
      StreamController<List<Tasks>>.broadcast(); 

  Stream<List<Tasks>> get tasks => _taskController.stream;

  ///
  StreamController<int> _cmdController = StreamController<int>.broadcast();

  TaskDB _taskDb;
  List<Tasks> _tasksList;
  Filter _lastFilterStatus;

  TaskBloc(this._taskDb) {
    filterTodayTasks();
    _cmdController.stream.listen((_) {
      _updateTaskStream(_tasksList);
    });
  }

  void _filterTask(int taskStartTime, int taskEndTime, TaskStatus status) {
    _taskDb
        .getTasks(
            startDate: taskStartTime, endDate: taskEndTime, taskStatus: status)
        .then((tasks) {
      _updateTaskStream(tasks);
    });
  }

  void _updateTaskStream(List<Tasks> tasks) {
    _tasksList = tasks;
    _taskController.sink.add(UnmodifiableListView<Tasks>(_tasksList));
  }

  void dispose() {
    _taskController.close();
    _cmdController.close();
  }

  void filterTodayTasks() {
    final dateTime = DateTime.now();
    final int taskStartTime =
        DateTime(dateTime.year, dateTime.month, dateTime.day)
            .millisecondsSinceEpoch;
    final int taskEndTime =
        DateTime(dateTime.year, dateTime.month, dateTime.day, 23, 59)
            .millisecondsSinceEpoch;

    // Read all today's tasks from database
    _filterTask(taskStartTime, taskEndTime, TaskStatus.PENDING);
    _lastFilterStatus = Filter.byToday();
  }

  void filterTasksForNextWeek() {
    var dateTime = DateTime.now();
    var taskStartTime =
        DateTime(dateTime.year, dateTime.month, dateTime.day)
            .millisecondsSinceEpoch;
    var taskEndTime =
        DateTime(dateTime.year, dateTime.month, dateTime.day + 7, 23, 59)
            .millisecondsSinceEpoch;
    // Read all next week tasks from database
    _filterTask(taskStartTime, taskEndTime, TaskStatus.PENDING);
    _lastFilterStatus = Filter.byNextWeek();
  }

  void filterByProject(int projectId) {
    _taskDb
        .getTasksByProject(projectId, status: TaskStatus.PENDING)
        .then((tasks) {
      if (tasks == null) return;
      _lastFilterStatus = Filter.byProject(projectId);
      _updateTaskStream(tasks);
    });
  }

  void filterByLabel(String labelName) {
    _taskDb
        .getTasksByLabel(labelName, status: TaskStatus.COMPLETE)
        .then((tasks) {
      if (tasks == null) return;
      _lastFilterStatus = Filter.byLabel(labelName);
      _updateTaskStream(tasks);
    });
  }

  void filterByStatus(TaskStatus status) {
    _taskDb.getTasks(taskStatus: status).then((tasks) {
      if (tasks == null) return;
      _lastFilterStatus = Filter.byStatus(status);
      _updateTaskStream(tasks);
    });
  }

  void updateStatus(int taskID, TaskStatus status) {
    _taskDb.updateTaskStatus(taskID, status).then((value) {
      refresh();
    });
  }

  void updateRepeat(Tasks task, StatusRepeat repeat) {
    if(repeat==StatusRepeat.REPEAT_DAILY){
      Tasks taskNew=task;
      DateTime oldDate=new DateTime(task.dueDate);
      DateTime tomorrow=new DateTime.now().add(new Duration(days: 1));
      DateTime tomorowRepeated=new DateTime(tomorrow.year, tomorrow.month, tomorrow.day, oldDate.hour, oldDate.minute, oldDate.second, oldDate.millisecond, oldDate.microsecond);
      taskNew.dueDate=tomorowRepeated.millisecondsSinceEpoch;
      _taskDb.updateTask(taskNew).then((value) {
        refresh();
      });
    } else if(repeat==StatusRepeat.REPEAT_WEEKLY){
      Tasks taskNew=task;
      DateTime oldDate=new DateTime(task.dueDate);
      DateTime nextWeek=new DateTime.now().add(new Duration(days: 7));
      DateTime tomorowRepeated=new DateTime(nextWeek.year, nextWeek.month, nextWeek.day, oldDate.hour, oldDate.minute, oldDate.second, oldDate.millisecond, oldDate.microsecond);
      taskNew.dueDate=tomorowRepeated.millisecondsSinceEpoch;
      _taskDb.updateTask(taskNew).then((value) {
        refresh();
      });
    }
  }

  void delete(int taskID) {
    _taskDb.deleteTask(taskID).then((value) {
      refresh();
    });
  }

  void refresh() {
    if (_lastFilterStatus != null) {
      switch (_lastFilterStatus.filterStatus) {
        case FILTER_STATUS.BY_TODAY:
          filterTodayTasks();
          break;

        case FILTER_STATUS.BY_WEEK:
          filterTasksForNextWeek();
          break;

        case FILTER_STATUS.BY_LABEL:
          filterByLabel(_lastFilterStatus.labelName);
          break;

        case FILTER_STATUS.BY_PROJECT:
          filterByProject(_lastFilterStatus.projectId);
          break;

        case FILTER_STATUS.BY_STATUS:
          filterByStatus(_lastFilterStatus.status);
          break;
      }
    }
  }

  void updateFilters(Filter filter) {
    _lastFilterStatus = filter;
    refresh();
  }
}

enum FILTER_STATUS { BY_TODAY, BY_WEEK, BY_PROJECT, BY_LABEL, BY_STATUS }

class Filter {
  String labelName;
  int projectId;
  FILTER_STATUS filterStatus;
  TaskStatus status;

  Filter.byToday() {
    filterStatus = FILTER_STATUS.BY_TODAY;
  }

  Filter.byNextWeek() {
    filterStatus = FILTER_STATUS.BY_WEEK;
  }

  Filter.byProject(this.projectId) {
    filterStatus = FILTER_STATUS.BY_PROJECT;
  }

  Filter.byLabel(this.labelName) {
    filterStatus = FILTER_STATUS.BY_LABEL;
  }

  Filter.byStatus(this.status) {
    filterStatus = FILTER_STATUS.BY_STATUS;
  }
}
