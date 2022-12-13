import 'package:json_annotation/json_annotation.dart';

part 'sensor.g.dart';

@JsonSerializable()
class Sensor {
  final String id;
  final String sensor_type;
  final String name;
  double data;
  final String user_id;
  final String unit_of_measurement;

  Sensor({required this.id, required this.sensor_type, required this.name, required this.data, required this.user_id, required this.unit_of_measurement});

  /// A necessary factory constructor for creating a new User instance
  /// from a map. Pass the map to the generated `_$UserFromJson()` constructor.
  /// The constructor is named after the source class, in this case, User.
  factory Sensor.fromJson(Map<String, dynamic> json) => _$SensorFromJson(json);

  /// `toJson` is the convention for a class to declare support for serialization
  /// to JSON. The implementation simply calls the private, generated
  /// helper method `_$UserToJson`.
  Map<String, dynamic> toJson() => _$SensorToJson(this);


}