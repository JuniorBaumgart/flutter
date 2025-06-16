import 'package:flutter/material.dart';
import 'package:flutterapp/models/course_model.dart';
import 'package:flutterapp/repository/course_repository.dart';
import 'package:intl/intl.dart';

class FormCourse extends StatefulWidget {
  FormCourse({super.key, this.courseEdit});

  CourseModel? courseEdit;

  @override
  State<FormCourse> createState() => _FormCourseState();
}

class _FormCourseState extends State<FormCourse> {
  String id = "";
  TextEditingController textNameController = TextEditingController();
  TextEditingController textDescController = TextEditingController();
  TextEditingController textStartAtController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  final repository = CourseRepository();

  @override
  void initState() {
    super.initState();
    if (widget.courseEdit != null) {
      textNameController.text = widget.courseEdit?.name ?? '';
      textDescController.text = widget.courseEdit?.description ?? '';
      textStartAtController.text = widget.courseEdit!.startAt ?? '';
      id = widget.courseEdit?.id ?? '';
    }
  }

  formatStringPtBrToApiStringFormat(date) {
    String day = date.substring(0, 2);
    String month = date.substring(3, 5);
    String year = date.substring(6, 10);

    return '$year-$month-${day}T00:00:00.000Z';
  }

  putUpdateCourse() async {
    try {
      await repository.putUpdateCourse(
        CourseModel(
          id: id,
          name: textNameController.text,
          description: textDescController.text,
          startAt: formatStringPtBrToApiStringFormat(
            textStartAtController.text,
          ),
        ),
      );
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Dados salvos!')));
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  postNewCourse() async {
    try {
      await repository.postNewCourse(
        CourseModel(
          name: textNameController.text,
          description: textDescController.text,
          startAt: formatStringPtBrToApiStringFormat(
            textStartAtController.text,
          ),
        ),
      );
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Dados salvos!')));
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Formulário")),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(
                  hintText: "Preencha o nome do curso",
                ),
                controller: textNameController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Campo obrigatório";
                  }
                  return null;
                },
              ),
              SizedBox(height: 15),
              TextFormField(
                decoration: InputDecoration(
                  hintText: "Preencha a descrição do curso",
                ),
                controller: textDescController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Campo obrigatório";
                  }
                  return null;
                },
              ),
              SizedBox(height: 15),
              TextFormField(
                decoration: InputDecoration(hintText: "Preencha data do curso"),
                controller: textStartAtController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Campo obrigatório";
                  }
                  return null;
                },
                onTap: () {
                  showDatePicker(
                    context: context,
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2030),
                  ).then((value) {
                    if (value != null) {
                      var outputFormat = DateFormat("dd/MM/yyyy");
                      textStartAtController.text = outputFormat.format(value);
                    }
                  });
                },
              ),
              SizedBox(height: 15),
              SizedBox(
                height: 50,
                width: MediaQuery.of(context).size.width * 0.9,
                child: ElevatedButton(
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      if (widget.courseEdit != null) {
                        putUpdateCourse();
                      } else {
                        postNewCourse();
                      }
                    }
                  },

                  child: Text("Salvar"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
