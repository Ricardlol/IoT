// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
      id: json['id'] as String,
      phone_number: json['phone_number'] as String,
      full_name: json['full_name'] as String,
      avatar_url: json['avatar_url'] as String,
      disabled: json['disabled'] as bool,
      creation_date: json['creation_date'] as String,
      sensors: (json['sensors'] as List<dynamic>)
          .map((e) => Sensor.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'id': instance.id,
      'phone_number': instance.phone_number,
      'full_name': instance.full_name,
      'avatar_url': instance.avatar_url,
      'disabled': instance.disabled,
      'creation_date': instance.creation_date,
      'sensors': instance.sensors,
    };
