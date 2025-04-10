class UserResponse {
  final List<String> usernames;

  UserResponse({required this.usernames});

  factory UserResponse.fromJson(Map<String, dynamic> json) {
    return UserResponse(usernames: List<String>.from(json['usernames'] ?? []));
  }
}
