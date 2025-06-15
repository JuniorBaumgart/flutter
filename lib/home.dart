import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutterapp/form_course.dart';
import 'package:flutterapp/models/course_model.dart';
import 'package:flutterapp/repository/course_repository.dart';
import 'package:flutterapp/form_holiday.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final repository = CourseRepository();
  late Future<List<CourseModel>> courses;

  Future<List<CourseModel>> getCourses() async {
    return await repository.getAll();
  }

  @override
  void initState() {
    courses = getCourses();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.purple),
              child: Text('Menu'),
            ),
            ListTile(
              title: const Text('Cursos'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                );
              },
            ),
            ListTile(
              title: const Text('Feriados'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HolidaysPage()),
                );
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(title: Text("Lista de cursos")),
      body: FutureBuilder(
        future: courses,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Problemas ao carregar cursos"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("Nenhum curso encontrado"));
          }
          return buildCourseList(snapshot.data);
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => FormCourse()),
          ).then((value) {
            setState(() {
              courses = getCourses();
            });
          });
        },
      ),
    );
  }

  Widget buildCourseList(courses) {
    return ListView.builder(
      itemCount: courses.length,
      itemBuilder: (context, index) {
        return Card(
          elevation: 5,
          child: Slidable(
            endActionPane: ActionPane(
              motion: ScrollMotion(),
              children: [
                SlidableAction(
                  onPressed: (context) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => FormCourse(courseEdit: courses[index]),
                      ),
                    ).then((value) {
                      courses = getCourses();
                      setState(() => {});
                    });
                  },

                  icon: Icons.edit,
                  backgroundColor: Colors.grey,
                  foregroundColor: Colors.black,
                  label: "Editar",
                ),
                SlidableAction(
                  onPressed: (context) async {
                    showDialog<String>(
                      context: context,
                      builder:
                          (BuildContext context) => AlertDialog(
                            title: const Text('Confirmação'),
                            content: const Text(
                              'Confirma exclusão deste Curso?',
                            ),
                            actions: [
                              ElevatedButton(
                                onPressed:
                                    () => Navigator.pop(context, 'Cancel'),
                                child: const Text('Cancel'),
                              ),
                              ElevatedButton(
                                onPressed: () async {
                                  await repository.deleteCourse(
                                    courses[index].id!,
                                  );
                                  Navigator.pop(context);
                                },
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                    ).then((value) async {
                      //aqui atualiza a lista após fechar dialog
                      courses = getCourses();
                      setState(() => {});
                    });
                  },
                  icon: Icons.delete,
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  label: "Excluir",
                ),
              ],
            ),
            child: ListTile(
              leading: CircleAvatar(child: Text("CC")),
              title: Text(courses[index].name ?? ''),
              subtitle: Text(courses[index].description ?? ''),
              trailing: Icon(Icons.arrow_forward_ios),
            ),
          ),
        );
      },
    );
  }
}
