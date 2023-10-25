import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: StockInfoPage(),
    );
  }
}

class StockInfoPage extends StatefulWidget {
  @override
  _StockInfoPageState createState() => _StockInfoPageState();
}

class _StockInfoPageState extends State<StockInfoPage> {
  // API endpoint URL, ganti dengan URL sesungguhnya
  final String apiUrl = "https://api.polygon.io/v2/aggs/ticker/MNI/range/1/day/2023-01-09/2023-02-09?adjusted=true&sort=asc&limit=120&apiKey=2o1cfE1ldFJf_uUSnFe9RYjAZ_MIj1dC";

  String stockCode = "MNI";
  double lowestPrice = 120.0;
  List<FlSpot> stockData = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        stockCode = data['stockCode'];
        lowestPrice = data['lowestPrice'];
        stockData = List<FlSpot>.from(data['stockData']);
      });
    } else {
      throw Exception('Gagal mengambil data dari API');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Stock Info"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "Kode Saham: $stockCode",
              style: TextStyle(fontSize: 24),
            ),
            ElevatedButton(
              onPressed: fetchData,
              child: Text("Refresh Data"),
            ),
            SizedBox(height: 20),
            LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(show: false),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(
                    color: const Color(0xff37434d),
                    width: 1,
                  ),
                ),
                minX: 0,
                maxX: stockData.length - 1,
                minY: lowestPrice - 10,
                maxY: lowestPrice + 10,
                lineBarsData: [
                  LineChartBarData(
                    spots: stockData,
                    isCurved: true,
                    colors: [Colors.blue],
                    dotData: FlDotData(show: true),
                    belowBarData: BarAreaData(show: false),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            Text(
              "Harga Terendah: $lowestPrice",
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
