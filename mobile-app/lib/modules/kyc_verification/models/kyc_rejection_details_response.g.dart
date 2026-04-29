// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kyc_rejection_details_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_KycRejectionDetailsResponse _$KycRejectionDetailsResponseFromJson(
  Map<String, dynamic> json,
) => _KycRejectionDetailsResponse(
  canResubmit: json['canResubmit'] as bool? ?? false,
  rejectedProvider: json['rejectedProvider'] as String?,
  rejectionReason: json['rejectionReason'] as String?,
  rejectionReasonAr: json['rejectionReason_ar'] as String?,
  rejectType: json['rejectType'] as String?,
  previousData: json['previousData'] == null
      ? null
      : KycPreviousData.fromJson(json['previousData'] as Map<String, dynamic>),
  documents: json['documents'] == null
      ? null
      : KycDocuments.fromJson(json['documents'] as Map<String, dynamic>),
);

Map<String, dynamic> _$KycRejectionDetailsResponseToJson(
  _KycRejectionDetailsResponse instance,
) => <String, dynamic>{
  'canResubmit': instance.canResubmit,
  'rejectedProvider': instance.rejectedProvider,
  'rejectionReason': instance.rejectionReason,
  'rejectionReason_ar': instance.rejectionReasonAr,
  'rejectType': instance.rejectType,
  'previousData': instance.previousData,
  'documents': instance.documents,
};

_KycPreviousData _$KycPreviousDataFromJson(Map<String, dynamic> json) =>
    _KycPreviousData(
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      dob: json['dob'] as String?,
      country: json['country'] as String?,
      nationality: json['nationality'] as String?,
      address: json['address'] as String?,
      city: json['city'] as String?,
    );

Map<String, dynamic> _$KycPreviousDataToJson(_KycPreviousData instance) =>
    <String, dynamic>{
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'dob': instance.dob,
      'country': instance.country,
      'nationality': instance.nationality,
      'address': instance.address,
      'city': instance.city,
    };

_KycDocuments _$KycDocumentsFromJson(Map<String, dynamic> json) =>
    _KycDocuments(
      frontUrl: json['frontUrl'] as String?,
      backUrl: json['backUrl'] as String?,
      faceUrl: json['faceUrl'] as String?,
    );

Map<String, dynamic> _$KycDocumentsToJson(_KycDocuments instance) =>
    <String, dynamic>{
      'frontUrl': instance.frontUrl,
      'backUrl': instance.backUrl,
      'faceUrl': instance.faceUrl,
    };
