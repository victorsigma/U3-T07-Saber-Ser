import 'package:mqtt_client/mqtt_client.dart'; // Importa la biclioteca MQTT Client
import 'package:mqtt_client/mqtt_server_client.dart'; // Importa la biblioteca MQTT Server Client

class MqttService {
  final MqttServerClient client; // Declaracion del cliente MQTT

  // Constructor de MqttService que inicializa el cliente MQTT
  MqttService(String server, String clientId) : 
    client = MqttServerClient(server, ''){
      // Asegúrate de qe el clienteId sea valido
      const sanitizedClientId = '';

      client.logging(on: true); // Habilita el loggin para el cliente MQTT
      client.setProtocolV311(); // Configura el rotocolo MQTT 3.1.1
      client.keepAlivePeriod = 20; // Configura el periodo de keep alive en 20 segundos

      // Configuración del mensaje de conexión
      final connMessage = MqttConnectMessage()
        .withClientIdentifier(sanitizedClientId) // Identifiador del cliente
        .startClean() // Indica que el cliente debe comenzar con una sesion limpia
        .withWillQos(MqttQos.atLeastOnce); // Configura el Qos para el mensaje de "última voluntad"
  }

  // Método que retorna un stream de dats de temperatura
  Stream<double> getTemperatureDataStream() async* {
    try {
      // Intenta conectar al servidor MQTT
      await client.connect();
    } catch (e) {
      // Si la conexión falla, desconecta el cliente y retorna
      client.disconnect();
      return;
    }
  
    // Verifica si la conexión fue exitosa
    if (client.connectionStatus?.state == MqttConnectionState.connected){
      // Se suscribe al tópico de temperatura con QoS 1
      client.subscribe("temperature/topic/oivm", MqttQos.atLeastOnce);

      // Escucha los mensajes entrantes sy emite los valores de temperatura
      await for (final c in client.updates!){
        final MqttPublishMessage recMess = c[0].payload as MqttPublishMessage; // Obtiene el mensaje publicado
        final String pt = MqttPublishPayload.bytesToStringAsString(recMess.payload.message); // Convierte el payload a String
        yield double.tryParse(pt) ?? 0.0; // Convierte el payload a double y lo emite en el stream
      }    
    } else {
      // Si la conexión no fue exitosa, desconecta el cliente
      client.disconnect();
    }
  }

}