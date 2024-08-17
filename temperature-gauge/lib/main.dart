import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart'; // Importa la biblioteca para el gauge
import 'mqtt_service.dart'; // Importa el servicio Mqtt

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gauge MQTT App', // Titulo de la aplicación
      theme: ThemeData(
        primarySwatch: Colors.blue, // Tema princial de la aplicación
      ),
      home: const GaugeScreen(), // Define GaugeScreen como la pantalla principal
    );
  }
}

// GaugeScreen es un Stategulwidge que mostrará el gauge de temperatura
class GaugeScreen extends StatefulWidget {
  const GaugeScreen({super.key});

  @override
  _GaugeScreenState createState() =>
      _GaugeScreenState(); // Crea el estado asociado a este widget
}

class _GaugeScreenState extends State<GaugeScreen> {
  late MqttService _mqttService; // Declaración del servicio MQTT
  double _temperature = 0.0; // Variable para almacenar la temperatura actual

  @override
  void initState() {
    super.initState();
    // Inicializa el servicio MQTT con el broker y el clienteId
    _mqttService = MqttService('broker.emqx.io', '');
    // Escucha el stream de temperatura y actualiza el estado cuando lleuge un nuevo valor
    _mqttService.getTemperatureDataStream().listen((temperature) {
      setState(() {
        _temperature = temperature; // Actualiza la temperatura
      });
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Temperature Gauge'), // Título de la barra de la aplicación
      ),
      body: Center(
        // Contenedor principal de la pantalla
        child: SfRadialGauge(
          // Widget para mostrar el gauge radial
          axes: <RadialAxis> [
            RadialAxis(
              // Configuración del eje radial
              minimum: -20, // Valor minimo del gauge
              maximum: 50, // Valor máximo del gauge
              ranges: <GaugeRange> [
                // Definición de rangos de colores en el gauge
                GaugeRange(startValue: -20, endValue: 0, color: Colors.blue), // Rango azul para temperaturas frias
                GaugeRange(startValue: 0, endValue: 25, color: Colors.green),// Rango verde para temperaturas moderadas
                GaugeRange(startValue: 25, endValue: 50, color: Colors.red), // Rango rojo para temperaturas calientes
              ],
              pointers: <GaugePointer>[
                // Aguja del gauge que eindica la temperatura actual
                NeedlePointer(value: _temperature),
              ],
              // Anotación quue muestra el valor de la temperatura en el centro del gauge
              annotations: <GaugeAnnotation> [
                // Anotación que muestra el valor de la temperatura en el centro del gauge
                GaugeAnnotation(
                  widget: Text(
                    '$_temperature°C', // muestra la temperatura on un formato de texto
                  ),
                  angle: 90, // angulo de la anotación
                  positionFactor: 0.5, // Posición de la anotación en el gauge
                  )
              ],
            )
          ]
        )
      )
      );
  }
}
