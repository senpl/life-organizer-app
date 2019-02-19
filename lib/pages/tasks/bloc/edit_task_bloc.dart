import 'dart:async';

import 'package:flutter_app/bloc/bloc_provider.dart';
import 'package:flutter_app/models/priority.dart';
import 'package:flutter_app/models/repeat.dart';
import 'package:flutter_app/pages/labels/label.dart';
import 'package:flutter_app/pages/labels/label_db.dart';
import 'package:flutter_app/pages/projects/project.dart';
import 'package:flutter_app/pages/projects/project_db.dart';
import 'package:flutter_app/pages/tasks/models/tasks.dart';
import 'package:flutter_app/pages/tasks/task_db.dart';
import 'package:rxdart/rxdart.dart';
import 'package:rxdart/subjects.dart';

class EditTaskBloc implements BlocBase {
  final TaskDB _taskDB;
  final ProjectDB _projectDB;
  final LabelDB _labelDB;
  Status lastPrioritySelection = Status.PRIORITY_4;
  StatusRepeat lastRepeatSelection = StatusRepeat.REPEAT_NO;

  EditTaskBloc(this._taskDB, this._projectDB, this._labelDB) {
    _loadProjects();
    _loadLabels();
    updateDueDate(DateTime.now().millisecondsSinceEpoch);
    _projectSelection.add(Project.getInbox());
    _prioritySelected.add(lastPrioritySelection);
    _repeatSelected.add(lastRepeatSelection);
  }

  BehaviorSubject<List<Project>> _projectController =
      BehaviorSubject<List<Project>>();

  Stream<List<Project>> get projects => _projectController.stream;

  BehaviorSubject<List<Label>> _labelController =
      BehaviorSubject<List<Label>>();

  Stream<List<Label>> get labels => _labelController.stream;

  BehaviorSubject<Project> _projectSelection = BehaviorSubject<Project>();

  Stream<Project> get selectedProject => _projectSelection.stream;

  BehaviorSubject<String> _labelSelected = BehaviorSubject<String>();

  Stream<String> get labelSelection => _labelSelected.stream;

  List<Label> _selectedLabelList = List();

  List<Label> get selectedLabels => _selectedLabelList;

  BehaviorSubject<bool> _daysSelected = BehaviorSubject<bool>();

  Stream<bool> get daysSelection => _daysSelected.stream;

  List<bool> selectedDaysList = List();

  List<bool> get selectedDays => selectedDaysList;

  BehaviorSubject<Status> _prioritySelected = BehaviorSubject<Status>();

  Stream<Status> get prioritySelected => _prioritySelected.stream;
 
  BehaviorSubject<StatusRepeat> _repeatSelected = BehaviorSubject<StatusRepeat>();

  Stream<StatusRepeat> get repeatSelected => _repeatSelected.stream;

  BehaviorSubject<int> _dueDateSelected = BehaviorSubject<int>();

  Stream<int> get dueDateSelected => _dueDateSelected.stream;

  String updateTitle = "";

  @override
  void dispose() {
    _projectController.close();
    _labelController.close();
    _projectSelection.close();
    _labelSelected.close();
    _daysSelected.close();
    _prioritySelected.close();
    _repeatSelected.close();
    _dueDateSelected.close();
  }

  void _loadProjects() {
    _projectDB.getProjects(isInboxVisible: true).then((projects) {
      _projectController.add(List.unmodifiable(projects));
    });
  }

  void _loadLabels() {
    _labelDB.getLabels().then((labels) {
      _labelController.add(List.unmodifiable(labels));
    });
  }

  void projectSelected(Project project) {
    _projectSelection.add(project);
  }

  void labelAddOrRemove(Label label) {
    if (_selectedLabelList.contains(label)) {
      _selectedLabelList.remove(label);
    } else {
      _selectedLabelList.add(label);
    }
    _buildLabelsString();
  }

  void _buildLabelsString() {
    List<String> selectedLabelNameList = List();
    _selectedLabelList.forEach((label) {
      selectedLabelNameList.add("@${label.name}");
    });
    String labelJoinString = selectedLabelNameList.join("  ");
    String displayLabels =
        labelJoinString.length == 0 ? "No Labels" : labelJoinString;
    _labelSelected.add(displayLabels);
  }

  void updatePriority(Status priority) {
    _prioritySelected.add(priority);
    lastPrioritySelection = priority;
  }

  Observable<String> createTask() {
    return Observable.zip4(selectedProject, dueDateSelected, prioritySelected, repeatSelected,
        (Project project, int dueDateSelected, Status status, StatusRepeat statusRepeat) {
      List<bool> daysToStore=List();
      // selectedDaysList
      daysToStore=selectedDaysList;
      // .forEach(day){
      //   daysToStore.add(day);
      // };

      List<int> labelIds = List();
      _selectedLabelList.forEach((label) {
        labelIds.add(label.id);
      }
      );

      var task = Tasks.create(
        title: updateTitle,
        dueDate: dueDateSelected,
        priority: status,
        projectId: project.id,
        repeat: statusRepeat,
      );
      _taskDB.updateTask(task, labelIDs: labelIds, selectedDays: daysToStore).then((task) {
        Notification.onDone();
      });
    });
  }

  void updateDueDate(int millisecondsSinceEpoch) {
    _dueDateSelected.add(millisecondsSinceEpoch);
  }

  void updateRepeat(StatusRepeat repeat) {
    _repeatSelected.add(repeat);
    lastRepeatSelection = repeat;
  }
}
