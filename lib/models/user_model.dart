class User {
  final int id;
  final String username;
  final String email;
  final String? profileImage;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.username,
    required this.email,
    this.profileImage,
    required this.createdAt,
    required this.updatedAt,
  });
  factory User.fromJson(Map<String, dynamic> json) {
    // Handle profileImage yang bisa berupa String atau Object/Map
    String? profileImageString;
    if (json['profileImage'] != null) {
      if (json['profileImage'] is String) {
        profileImageString = json['profileImage'];
      } else if (json['profileImage'] is Map) {
        // Jika profileImage adalah Map/Object, ambil data sebagai base64
        try {
          // Convert Map to base64 string jika diperlukan
          var profileImageData = json['profileImage'];
          if (profileImageData['data'] != null) {
            // Jika ada field 'data' dalam object
            profileImageString = profileImageData['data'].toString();
          } else {
            // Convert seluruh object ke string
            profileImageString = profileImageData.toString();
          }
        } catch (e) {
          print('Error parsing profileImage object: $e');
          profileImageString = null;
        }
      }
    }

    return User(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      profileImage: profileImageString,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'profileImage': profileImage,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class AuthResponse {
  final String? message;
  final User? user;
  final String? token;
  final bool success;

  AuthResponse({
    this.message,
    this.user,
    this.token,
    required this.success,
  });
  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      message: json['message'],
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      token: json['token'],
      success: json['success'] ?? false,
    );
  }
}
