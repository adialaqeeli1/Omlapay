part of './network_client.dart';

class NetworkToken {
  NetworkToken({this.access, this.refresh});

  final String? access;
  final String? refresh;

  NetworkToken copyWith({String? access, String? refresh}) => NetworkToken(
    access: access ?? this.access,
    refresh: refresh ?? this.refresh,
  );

  factory NetworkToken.fromJson(Map<String, dynamic> json) =>
      NetworkToken(access: json['accessToken'], refresh: json['refreshToken']);

  NetworkToken copyWithfromJson(Map<String, dynamic> json) => copyWith(
    access: json['accessToken'] ?? access,
    refresh: json['refreshToken'] ?? refresh,
  );

  Map<String, dynamic> toJson() => {
    'accessToken': access,
    'refreshToken': refresh,
  };

  String get token => 'Bearer $access';

  @override
  String toString() {
    return {'accessToken': access, 'refreshToken': refresh}.toString();
  }

  bool get isAccessTokenNull => access == null;

  bool get isRefreshTokenNull => refresh == null;

  bool get isAccessTokenExpired {
    assert(access != null, 'Access token cannot be null');
    return JwtDecoder.isExpired(access!);
  }

  bool get isRefreshTokenExpired {
    assert(refresh != null, 'Refresh token cannot be null');
    return JwtDecoder.isExpired(refresh!);
  }
}
