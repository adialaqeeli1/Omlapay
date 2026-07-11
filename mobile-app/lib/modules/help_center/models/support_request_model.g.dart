// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'support_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SupportRequestsResponse _$SupportRequestsResponseFromJson(
  Map<String, dynamic> json,
) => _SupportRequestsResponse(
  requests:
      (json['requests'] as List<dynamic>?)
          ?.map((e) => SupportRequestModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  pagination: json['pagination'] == null
      ? null
      : SupportRequestPagination.fromJson(
          json['pagination'] as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$SupportRequestsResponseToJson(
  _SupportRequestsResponse instance,
) => <String, dynamic>{
  'requests': instance.requests,
  'pagination': instance.pagination,
};

_SupportRequestPagination _$SupportRequestPaginationFromJson(
  Map<String, dynamic> json,
) => _SupportRequestPagination(
  page: json['page'] as String? ?? '1',
  limit: json['limit'] as String? ?? '10',
  total: (json['total'] as num?)?.toInt() ?? 0,
  totalPages: (json['totalPages'] as num?)?.toInt() ?? 1,
);

Map<String, dynamic> _$SupportRequestPaginationToJson(
  _SupportRequestPagination instance,
) => <String, dynamic>{
  'page': instance.page,
  'limit': instance.limit,
  'total': instance.total,
  'totalPages': instance.totalPages,
};

_SupportRequestModel _$SupportRequestModelFromJson(Map<String, dynamic> json) =>
    _SupportRequestModel(
      id: json['id'] as String,
      title: json['title'] as String,
      status:
          $enumDecodeNullable(_$SupportRequestStatusEnumMap, json['status']) ??
          SupportRequestStatus.pending,
      statusColor: json['statusColor'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$SupportRequestModelToJson(
  _SupportRequestModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'status': _$SupportRequestStatusEnumMap[instance.status]!,
  'statusColor': instance.statusColor,
  'createdAt': instance.createdAt.toIso8601String(),
};

const _$SupportRequestStatusEnumMap = {
  SupportRequestStatus.open: 'OPEN',
  SupportRequestStatus.pending: 'PENDING',
  SupportRequestStatus.solved: 'SOLVED',
  SupportRequestStatus.rejected: 'REJECTED',
};
