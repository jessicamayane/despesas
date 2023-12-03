import 'package:FLUTTER_APPLICATION_3/views/Home.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ChartScreen extends StatefulWidget {
  @override
  _ChartScreenState createState() => _ChartScreenState();
}

class _ChartScreenState extends State<ChartScreen> {
  final List<Color> categoryColors = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.yellow,
    Colors.orange,
    Colors.purple,
    // Adicione mais cores conforme necessário
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Relatorio'),
        leading: IconButton(
          icon: Icon(Icons.home),
          onPressed: () {
            // Navegar de volta para a homePage
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => HomePage(),
                ));
          },
        ),
      ),
      body: Center(
        child: FutureBuilder(
          future: fetchDataFromFirebase(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              List<DataPoint>? dataPoints = snapshot.data;

              // Adiciona uma seção para cada categoria com seu valor total e porcentagem
              return PieChart(
                PieChartData(
                  sections: _createSections(dataPoints!),
                  borderData: FlBorderData(show: false),
                  sectionsSpace: 0,
                  centerSpaceRadius: 40,
                  centerSpaceColor: Colors.white,
                ),
              );
            }
          },
        ),
      ),
    );
  }

  List<PieChartSectionData> _createSections(List<DataPoint> dataPoints) {
    List<PieChartSectionData> sections = [];

    int total = _calculateTotal(dataPoints);

    for (var i = 0; i < dataPoints.length; i++) {
      var dataPoint = dataPoints[i];

      double percentage = (dataPoint.value / total) * 100;

      sections.add(
        PieChartSectionData(
          color: categoryColors[i % categoryColors.length],
          value: dataPoint.value.toDouble(),
          title:
              '${dataPoint.title}\nR\$ ${dataPoint.value} (${percentage.toStringAsFixed(2)}%)',
          radius: 100,
          titleStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      );
    }

    return sections;
  }

  int _calculateTotal(List<DataPoint> dataPoints) {
    int total = 0;
    for (var dataPoint in dataPoints) {
      total += dataPoint.value;
    }
    return total;
  }

  Future<List<DataPoint>> fetchDataFromFirebase() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('Despesas').where('userId', isEqualTo: FirebaseAuth.instance.currentUser?.uid).get();

    Map<String, int> totaisPorCategoria = {};

    querySnapshot.docs.forEach((doc) {
      int valor = doc['valor'];
      String categoria = doc['categoria'];

      totaisPorCategoria[categoria] =
          (totaisPorCategoria[categoria] ?? 0) + valor;
    });

    List<DataPoint> dataPoints = totaisPorCategoria.entries.map((entry) {
      return DataPoint(title: entry.key, value: entry.value);
    }).toList();

    return dataPoints;
  }
}

class DataPoint {
  final String title;
  final int value;

  DataPoint({required this.title, required this.value});
}
