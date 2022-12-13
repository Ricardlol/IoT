import 'package:json_annotation/json_annotation.dart';

import 'sensor.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
   String id;
   String phone_number;
   String full_name;
   String avatar_url;
   bool disabled;
   String creation_date;
   List<Sensor> sensors;
   User({required this.id, required this.phone_number, required this.full_name, required this.avatar_url, required this.disabled, required this.creation_date, required this.sensors});


   /// A necessary factory constructor for creating a new User instance
   /// from a map. Pass the map to the generated `_$UserFromJson()` constructor.
   /// The constructor is named after the source class, in this case, User.
   factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

   /// `toJson` is the convention for a class to declare support for serialization
   /// to JSON. The implementation simply calls the private, generated
   /// helper method `_$UserToJson`.
   Map<String, dynamic> toJson() => _$UserToJson(this);
}