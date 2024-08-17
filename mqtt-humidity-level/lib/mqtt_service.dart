import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MqttService {
  final MqttServerClient client;

  MqttService(String server, String clientId)
      : client = MqttServerClient.withPort(server, '', 1883,
            maxConnectionAttempts: 4) {
    const sanitizedClientId = '';

    client.logging(on: true);
    client.setProtocolV311();
    client.keepAlivePeriod = 20;
    client.secure = false;
    client.connectTimeoutPeriod = 10;

    final connMessage = MqttConnectMessage()
        .withClientIdentifier(sanitizedClientId)
        .startClean()
        .withWillQos(MqttQos.atLeastOnce);

    client.connectionMessage = connMessage;
  }

  Stream<double> getHumidityLevelStream() async* {
    try {
      await client.connect();
    } catch (e) {
      print('Connection failed: $e');
      client.disconnect();
      return;
    }

    if (client.connectionStatus?.state == MqttConnectionState.connected) {
      client.subscribe("humidity/level", MqttQos.atLeastOnce);

      await for (final c in client.updates!) {
        final MqttPublishMessage recMess = c[0].payload as MqttPublishMessage;

        print(c);
        final String pt =
            MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
        yield double.tryParse(pt) ?? 0.0;
      }
    } else {
      client.disconnect();
    }
  }
}
