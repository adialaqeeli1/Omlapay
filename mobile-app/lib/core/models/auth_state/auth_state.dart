import 'package:freezed_annotation/freezed_annotation.dart';
import '../user_model/user_model.dart';

part 'auth_state.freezed.dart';

enum AuthStatus { authorized, unauthorized }

@freezed
abstract class AuthState with _$AuthState {
  const AuthState._();

  const factory AuthState({
    @Default(false) bool isLoading,
    @Default(AuthStatus.unauthorized) AuthStatus authStatus,
    UserModel? user,
    String? errorMessage,
  }) = _AuthState;

  bool get isAuthenticated => authStatus == AuthStatus.authorized;
}
