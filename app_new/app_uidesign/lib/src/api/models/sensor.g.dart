// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sensor.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Sensor _$SensorFromJson(Map<String, dynamic> json) => Sensor(
      id: json['id'] as String,
      sensor_type: json['sensor_type'] as String,
      name: json['name'] as String,
      data: (json['data'] as num).toDouble(),
      user_id: json['user_id'] as String,
      unit_of_measurement: json['unit_of_measurement'] as String,
    );

Map<String, dynamic> _$SensorToJson(Sensor instance) => <String, dynamic>{
      'id': instance.id,
      'sensor_type': instance.sensor_type,
      'name': instance.name,
      'data': instance.data,
      'user_id': instance.user_id,
      'unit_of_measurement': instance.unit_of_measurement,
    };
