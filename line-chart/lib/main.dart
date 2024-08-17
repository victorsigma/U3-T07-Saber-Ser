import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'mqtt_service.dart'; // Asegúrate de que este archivo esté definido y correctamente importado

// Definición de la clase TemperatureData
class TemperatureData {
  final DateTime time;
  final double temperature;

  TemperatureData(this.time, this.temperature);
}

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gauge Line Chart App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const LineChartScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class LineChartScreen extends StatefulWidget {
  const LineChartScreen({super.key});

  @override
  _LineChartScreenState createState() => _LineChartScreenState();
}

class _LineChartScreenState extends State<LineChartScreen> {
  late MqttService _mqttService;
  final List<TemperatureData> _data = [];
  late ChartSeriesController _chartSeriesController;

  @override
  void initState() {
    super.initState();

    _mqttService = MqttService('broker.emqx.io', '');
    _mqttService.getTemperatureStream().listen((temperature) {
      setState(() {
        _data.add(TemperatureData(DateTime.now(), temperature));
        if (_data.length > 20) {
          _data.removeAt(0);
        }
        _chartSeriesController.updateDataSource(
            addedDataIndex: _data.length - 1);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Temperature Line Chart'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SfCartesianChart(
          primaryXAxis: DateTimeAxis(),
          primaryYAxis: NumericAxis(),
          series: <ChartSeries<TemperatureData, DateTime>>[
            LineSeries<TemperatureData, DateTime>(
              dataSource: _data,
              xValueMapper: (TemperatureData data, _) => data.time,
              yValueMapper: (TemperatureData data, _) => data.temperature,
              onRendererCreated: (ChartSeriesController controller) {
                _chartSeriesController = controller;
              },
            ),
          ],
        ),
      ),
    );
  }
}
