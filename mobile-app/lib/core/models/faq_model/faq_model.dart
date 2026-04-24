import 'package:freezed_annotation/freezed_annotation.dart';

part 'faq_model.freezed.dart';
part 'faq_model.g.dart';

@freezed
abstract class FaqModel with _$FaqModel {
  const factory FaqModel({
    required String id,
    required String question,
    required String answer,
    @Default(0) int displayOrder,
  }) = _FaqModel;

  factory FaqModel.fromJson(Map<String, dynamic> json) =>
      _$FaqModelFromJson(json);
}
