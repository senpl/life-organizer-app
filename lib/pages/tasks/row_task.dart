import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/pages/tasks/models/tasks.dart';
import 'package:flutter_app/utils/color_utils.dart';
import 'package:flutter_app/utils/date_util.dart';
import 'package:flutter_app/utils/app_constant.dart';
import 'package:flutter_app/bloc/bloc_provider.dart';
import 'package:flutter_app/pages/tasks/edit_task.dart';
import 'package:flutter_app/pages/tasks/bloc/task_bloc.dart';
import 'package:flutter_app/pages/tasks/task_db.dart';
import 'package:flutter_app/pages/projects/project_db.dart';
import 'package:flutter_app/pages/labels/label_db.dart';
import 'package:flutter_app/pages/tasks/bloc/edit_task_bloc.dart';

class TaskRow extends StatelessWidget {
  final Tasks tasks;
  static final date_label = "Date";
  final List<String> labelNames = List();

  TaskRow(this.tasks);
  final TaskBloc _taskBloc = TaskBloc(TaskDB.get());

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
          var blocProviderEditTask = BlocProvider(
            bloc: EditTaskBloc(TaskDB.get(), ProjectDB.get(), LabelDB.get()),
            child: EditTaskScreen(),
          );
          await Navigator.push(
            context,
            MaterialPageRoute<bool>(builder: (context) => blocProviderEditTask),
          );
          _taskBloc.refresh();
        },
      child: Column(
        children: <Widget>[
          Container(
            margin: const EdgeInsets.symmetric(vertical: PADDING_TINY),
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(
                  width: 4.0,
                  color: priorityColor[tasks.priority.index],
                ),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(PADDING_SMALL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(
                        left: PADDING_SMALL, bottom: PADDING_VERY_SMALL),
                    child: Text(tasks.title,
                        style: TextStyle(
                            fontSize: FONT_SIZE_TITLE,
                            fontWeight: FontWeight.bold)),
                  ),
                  getLabels(tasks.labelList),
                  Padding(
                    padding: const EdgeInsets.only(
                        left: PADDING_SMALL, bottom: PADDING_VERY_SMALL),
                    child: Row(
                      children: <Widget>[
                        Text(
                          getFormattedDate(tasks.dueDate),
                          style: TextStyle(
                              color: Colors.grey, fontSize: FONT_SIZE_DATE),
                          key: Key(date_label),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: <Widget>[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: <Widget>[
                                  Text(tasks.projectName,
                                      style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: FONT_SIZE_LABEL)),
                                  Container(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
                                    width: 8.0,
                                    height: 8.0,
                                    child: CircleAvatar(
                                      backgroundColor:
                                          Color(tasks.projectColor),
                                    ),
                                  )
                                ],
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
              decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                width: 0.5,
                color: Colors.grey,
              ),
            ),
          ))
        ],
      ),
    );
  }

  Widget getLabels(List<String> labelList) {
    if (labelList.isEmpty) {
      return Container();
    } else {
      return Padding(
        padding: const EdgeInsets.only(
            left: PADDING_SMALL, bottom: PADDING_VERY_SMALL),
        child: Text(tasks.labelList.join("  "),
            style: TextStyle(fontSize: FONT_SIZE_LABEL)),
      );
    }
  }
}
