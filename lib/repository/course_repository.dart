import 'dart:convert';

import 'package:flutterapp/models/course_model.dart';
import 'package:flutterapp/utils/constants.dart';
import 'package:http/http.dart' as http;

class CourseRepository {
  final url = Uri.parse('$URL_MOCKAPI/courses');

  Future<List<CourseModel>> getAll() async {
    final courseList = <CourseModel>[];
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body) as List;

      for (var course in jsonData) {
        courseList.add(CourseModel.fromJson(course));
      }
      return courseList;
    }
    throw Exception('Problemas ao carregar cursos');
  }

  postNewCourse(CourseModel courseModel) async {
    final jsonCourse = jsonEncode(CourseModel.toJson(courseModel));
    var response = await http.post(url, body: jsonCourse);
    if (response.statusCode != 201) {
      throw 'Problemas ao inserir curso';
    }
  }

  deleteCourse(String id) async {
    final _url = '$url/$id';
    var response = await http.delete(Uri.parse(_url));
    if (response.statusCode != 200) {
      throw 'Problemas ao excluir curso';
    }
  }

  putUpdateCourse(CourseModel courseModel) async {
    final _url = '$url/${courseModel.id}';
    final jsonCourse = jsonEncode(CourseModel.toJson(courseModel));
    var response = await http.put(Uri.parse(_url), body: jsonCourse);
    if (response.statusCode != 200) {
      throw 'Problemas ao atualizar curso';
    }
  }
}
