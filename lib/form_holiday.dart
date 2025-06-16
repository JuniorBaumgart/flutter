import 'package:flutter/material.dart';
import 'package:flutterapp/models/holiday_model.dart';
import 'package:flutterapp/repository/holiday_repository.dart';
import 'package:intl/intl.dart';

class HolidaysPage extends StatefulWidget {
  const HolidaysPage({super.key});

  @override
  State<HolidaysPage> createState() => _HolidaysPageState();
}

final Map<String, String> feriadoDescricoes = {
  'confraternização mundial':
      'Primeiro dia do ano, comemorado em 1º de janeiro, marcado por celebrações em todo o mundo.',
  'carnaval':
      'Festa popular brasileira, marcada por desfiles, fantasias e muita música, antecedendo a Quaresma.',
  'sexta-feira santa':
      'Dia de luto cristão que relembra a crucificação de Jesus Cristo, celebrado na sexta-feira antes da Páscoa.',
  'páscoa':
      'Comemoração cristã da ressurreição de Jesus Cristo, celebrada no domingo após a Sexta-feira Santa.',
  'tiradentes':
      'Homenagem a Joaquim José da Silva Xavier, conhecido como Tiradentes, mártir da Inconfidência Mineira.',
  'dia do trabalho':
      'Celebração das conquistas dos trabalhadores, comemorada em 1º de maio.',
  'corpus christi':
      'Festa religiosa católica que celebra a presença de Cristo na Eucaristia, celebrada na quinta-feira após o domingo da Santíssima Trindade.',
  'independência do brasil':
      'Declaração da independência do Brasil de Portugal em 7 de setembro de 1822.',
  'nossa senhora de aparecida':
      'Dia dedicado à padroeira do Brasil, Nossa Senhora Aparecida, comemorado em 12 de outubro.',
  'finados': 'Dia de homenagem aos mortos, celebrado em 2 de novembro.',
  'proclamação da república':
      'Comemoração do fim da monarquia e início da república no Brasil, em 15 de novembro de 1889.',
  'natal':
      'Comemoração cristã do nascimento de Jesus Cristo, celebrada em 25 de dezembro.',
};

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

  String formatDate(DateTime date) {
    final List<String> meses = [
      'Janeiro',
      'Fevereiro',
      'Março',
      'Abril',
      'Maio',
      'Junho',
      'Julho',
      'Agosto',
      'Setembro',
      'Outubro',
      'Novembro',
      'Dezembro',
    ];

    String dia = date.day.toString();
    String mes = meses[date.month - 1];
    String ano = date.year.toString();

    return '$dia de $mes de $ano';
  }

  IconData _getIconForHoliday(String name) {
    name = name.toLowerCase();

    if (name.contains('confraternização')) return Icons.celebration;
    if (name.contains('carnaval')) return Icons.masks;
    if (name.contains('sexta-feira santa') ||
        name.contains('sexta feira santa'))
      return Icons.spa;
    if (name.contains('páscoa') || name.contains('pascoa')) return Icons.egg;
    if (name.contains('tiradentes')) return Icons.gavel;
    if (name.contains('dia do trabalho')) return Icons.work;
    if (name.contains('corpus christi')) return Icons.church;
    if (name.contains('independência')) return Icons.flag;
    if (name.contains('nossa senhora de aparecida')) return Icons.local_parking;
    if (name.contains('finados')) return Icons.brightness_3;
    if (name.contains('proclamação')) return Icons.account_balance;
    if (name.contains('natal')) return Icons.church;

    return Icons.event;
  }

  void _showHolidayDetails(HolidayModel holiday) {
    DateTime? parsedDate;
    try {
      parsedDate = DateTime.parse(holiday.date);
    } catch (_) {}

    final formattedDate =
        parsedDate != null ? formatDate(parsedDate) : holiday.date;

    final iconData = _getIconForHoliday(holiday.name);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(iconData, color: Colors.deepPurple),
              SizedBox(width: 8),
              Expanded(child: Text(holiday.name)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Data: $formattedDate', style: TextStyle(fontSize: 16)),
              SizedBox(height: 12),
              Text(
                (() {
                  String descricao = 'Nenhuma descrição disponível.';
                  for (final key in feriadoDescricoes.keys) {
                    if (holiday.name.toLowerCase().contains(
                      key.toLowerCase(),
                    )) {
                      descricao = feriadoDescricoes[key]!;
                      break;
                    }
                  }
                  return descricao;
                })(),
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Fechar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
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

          final filtered =
          _searchQuery.isEmpty
          ? snapshot.data!
          : snapshot.data!.where((holiday) {
            final name = holiday.name.toLowerCase();
            final isoDate = holiday.date;

            DateTime? parsedDate;
            try {
              parsedDate = DateTime.parse(isoDate);
            } catch (_) {}

            final formattedFullDate =
                parsedDate != null
                    ? formatDate(parsedDate).toLowerCase()
                    : '';
            final formattedShortDate =
                parsedDate != null
                    ? DateFormat('dd/MM').format(parsedDate)
                    : '';
            final dia =
                parsedDate != null
                    ? parsedDate.day.toString().padLeft(2, '0')
                    : '';
            final mesNome =
                parsedDate != null
                    ? DateFormat.MMMM(
                      'pt_BR',
                    ).format(parsedDate).toLowerCase()
                    : '';
            return name.contains(_searchQuery) ||
                isoDate.contains(_searchQuery) ||
                formattedFullDate.contains(_searchQuery) ||
                formattedShortDate.contains(_searchQuery) ||
                dia.contains(_searchQuery) ||
                mesNome.contains(_searchQuery);
          }).toList();

          final groupedByMonth = <String, List<HolidayModel>>{};
          for (var holiday in filtered) {
            DateTime? parsedDate;
            try {
              parsedDate = DateTime.parse(holiday.date);
            } catch (_) {
              continue;
            }
            final rawMonthName = DateFormat.MMMM('pt_BR').format(parsedDate);
            final monthName = rawMonthName[0].toUpperCase() + rawMonthName.substring(1);
            groupedByMonth.putIfAbsent(monthName, () => []).add(holiday);
          }

          return ListView(
            padding: EdgeInsets.all(8),
            children: [
              Autocomplete<String>(
                optionsBuilder: (TextEditingValue textEditingValue) {
                  if (textEditingValue.text == '') {
                    return const Iterable<String>.empty();
                  }
                  return snapshot.data!
                      .map((h) => h.name)
                      .where(
                        (name) => name.toLowerCase().contains(
                              textEditingValue.text.toLowerCase(),
                            ),
                      );
                },
                onSelected: (String selection) {
                  setState(() {
                    _searchController.text = selection;
                    _searchQuery = selection.toLowerCase();
                  });
                },
                fieldViewBuilder: (
                  context,
                  textEditingController,
                  focusNode,
                  onEditingComplete,
                ) {
                  return TextField(
                    controller: _searchController,
                    focusNode: focusNode,
                    onEditingComplete: onEditingComplete,
                    decoration: InputDecoration(
                      labelText: 'Buscar por nome ou data',
                      hintText: 'Ex: Natal ou 25/12',
                      prefixIcon: Icon(Icons.search),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.clear),
                              onPressed: () {
                                setState(() {
                                  _searchController.clear();
                                  _searchQuery = '';
                                });
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: 12),
              if (filtered.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: Text(
                      'Nenhum feriado correspondente.',
                      style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                    ),
                  ),
                )
              else
                ...groupedByMonth.entries.map((entry) {
                  final monthName = entry.key;
                  final holidaysInMonth = entry.value;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding:
                            const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        child: Text(
                          monthName,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                          ),
                        ),
                      ),
                      ...holidaysInMonth.map((holiday) {
                        DateTime? parsedDate;
                        try {
                          parsedDate = DateTime.parse(holiday.date);
                        } catch (_) {
                          parsedDate = null;
                        }
                        final formattedDate = parsedDate != null
                            ? formatDate(parsedDate)
                            : holiday.date;
                        return Card(
                          elevation: 3,
                          margin: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          child: ListTile(
                            leading: Icon(
                              _getIconForHoliday(holiday.name),
                              color: Colors.indigo,
                            ),
                            title: Text(holiday.name),
                            subtitle: Text(formattedDate),
                            onTap: () => _showHolidayDetails(holiday),
                          ),
                        );
                      }).toList(),
                    ],
                  );
                }).toList(),
            ],
          );
        },
      ),
    );
  }
}
