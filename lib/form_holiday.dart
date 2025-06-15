import 'package:flutter/material.dart';
import 'package:flutterapp/models/holiday_model.dart';
import 'package:flutterapp/repository/holiday_repository.dart';
import 'package:intl/intl.dart';

class HolidaysPage extends StatefulWidget {
  const HolidaysPage({super.key});

  @override
  State<HolidaysPage> createState() => _HolidaysPageState();
}

class _HolidaysPageState extends State<HolidaysPage> {
  final repository = HolidayRepository();
  late Future<List<HolidayModel>> holidays;
  
  TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    holidays = repository.getHolidays();

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  // Função para formatar a data
  String formatDate(DateTime date) {
    final List<String> meses = [
      'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
      'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro'
    ];

    String dia = date.day.toString();
    String mes = meses[date.month - 1];  // Ajuste para o mês começar do índice 0
    String ano = date.year.toString();

    return '$dia de $mes de $ano';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Feriados Nacionais - 2023')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Buscar por nome ou data',
                hintText: 'Ex: Natal ou 25/12/2023',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<HolidayModel>>(
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

                // Filtrando
                final filtered = snapshot.data!.where((holiday) {
                  final name = holiday.name.toLowerCase();
                  final isoDate = holiday.date;

                  // Converte a string ISO para DateTime
                  DateTime? parsedDate;
                  try {
                    parsedDate = DateTime.parse(isoDate);
                  } catch (_) {
                    parsedDate = null;
                  }

                  // Converte a data para o formato desejado sem utilizar a biblioteca intl
                  String formattedFullDate = parsedDate != null ? formatDate(parsedDate) : '';
                  String formattedShortDate = parsedDate != null ? DateFormat('dd/MM').format(parsedDate) : '';  // Mantemos o formato curto para a busca por data, caso necessário

                  return name.contains(_searchQuery) ||
                         isoDate.contains(_searchQuery) ||
                         formattedFullDate.contains(_searchQuery) ||
                         formattedShortDate.contains(_searchQuery);
                }).toList();

                if (filtered.isEmpty) {
                  return Center(child: Text('Nenhum feriado correspondente.'));
                }

                return ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final holiday = filtered[index];
                    DateTime? parsedDate;
                    try {
                      parsedDate = DateTime.parse(holiday.date);
                    } catch (_) {
                      parsedDate = null;
                    }

                    // Exibindo a data formatada
                    String formattedDate = parsedDate != null ? formatDate(parsedDate) : holiday.date;

                    return Card(
                      elevation: 4,
                      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      child: ListTile(
                        leading: Icon(Icons.calendar_today, color: Colors.deepPurple),
                        title: Text(holiday.name),
                        subtitle: Text('Data: $formattedDate'),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
