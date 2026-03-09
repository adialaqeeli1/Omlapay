import 'package:json_annotation/json_annotation.dart';

part 'contact_model.g.dart';

@JsonSerializable()
class ContactModel {
  final String id;
  final String name;
  final String phoneNumber;
  final String? imagePath;
  final bool isVerified;
  final String network; // Added network just in case it's needed for display

  ContactModel({
    required this.id,
    required this.name,
    required this.phoneNumber,
    this.imagePath,
    this.isVerified = false,
    this.network = 'TRC20',
  });

  factory ContactModel.fromJson(Map<String, dynamic> json) =>
      _$ContactModelFromJson(json);

  Map<String, dynamic> toJson() => _$ContactModelToJson(this);
}
