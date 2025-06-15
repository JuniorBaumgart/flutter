import 'package:flutter/material.dart';
import 'package:flutterapp/models/holiday_model.dart';
import 'package:flutterapp/repository/holiday_repository.dart';


class HolidaysPage extends StatefulWidget {
  const HolidaysPage({super.key});

  @override
  State<HolidaysPage> createState() => _HolidaysPageState();
}

class _HolidaysPageState extends State<HolidaysPage> {
  final repository = HolidayRepository();
  late Future<List<HolidayModel>> holidays;

  @override
  void initState() {
    super.initState();
    holidays = repository.getHolidays();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Feriados Nacionais - 2023')),
      body: FutureBuilder<List<HolidayModel>>(
        future: holidays,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erro ao carregar feriados'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Nenhum feriado encontrado.'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final holiday = snapshot.data![index];
              return Card(
                elevation: 4,
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                child: ListTile(
                  leading: Icon(Icons.calendar_today, color: Colors.deepPurple),
                  title: Text(holiday.name),
                  subtitle: Text('Data: ${holiday.date}'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
