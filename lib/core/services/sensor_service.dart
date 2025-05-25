import 'package:sensors_plus/sensors_plus.dart';

class SensorService {
  // Stream data accelerometer
  Stream<AccelerometerEvent> get accelerometerStream => accelerometerEvents;
}
