import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutterapp/models/holiday_model.dart';

class HolidayRepository {
  final url = Uri.parse('https://brasilapi.com.br/api/feriados/v1/2023');

  Future<List<HolidayModel>> getHolidays() async {
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((json) => HolidayModel.fromJson(json)).toList();
    } else {
      throw Exception('Erro ao carregar feriados');
    }
  }
}
