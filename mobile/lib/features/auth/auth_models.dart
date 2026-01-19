class TokenPair {
  const TokenPair({
    required this.accessToken,
    required this.refreshToken,
  });

  final String accessToken;
  final String refreshToken;

  factory TokenPair.fromJson(Map<String, dynamic> json) {
    return TokenPair(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'access_token': accessToken,
        'refresh_token': refreshToken,
      };
}

class UserProvider {
  const UserProvider({
    required this.provider,
    required this.providerUserId,
  });

  final String provider;
  final String providerUserId;

  factory UserProvider.fromJson(Map<String, dynamic> json) {
    return UserProvider(
      provider: json['provider'] as String,
      providerUserId: json['provider_user_id'] as String,
    );
  }
}

class UserMe {
  const UserMe({
    required this.id,
    required this.email,
    required this.planCode,
    required this.providers,
  });

  final String id;
  final String email;
  final String planCode;
  final List<UserProvider> providers;

  factory UserMe.fromJson(Map<String, dynamic> json) {
    return UserMe(
      id: json['id'] as String,
      email: json['email'] as String,
      planCode: json['plan_code'] as String,
      providers: (json['providers'] as List<dynamic>?)
              ?.map((provider) => UserProvider.fromJson(provider as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }
}

class AuthResponse {
  const AuthResponse({
    required this.user,
    required this.tokens,
  });

  final UserMe user;
  final TokenPair tokens;

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      user: UserMe.fromJson(json['user'] as Map<String, dynamic>),
      tokens: TokenPair.fromJson(json['tokens'] as Map<String, dynamic>),
    );
  }
}
