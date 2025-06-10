import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import '../models/bike_model.dart';

class ApiService {
  // Base URL API Anda
  static const String baseUrl =
      'https://api-sportbike-1061342868557.us-central1.run.app';
  static const String loginEndpoint = '$baseUrl/api/auth/login';
  static const String registerEndpoint = '$baseUrl/api/auth/register';
  static const String profileEndpoint = '$baseUrl/api/auth/profile';
  static const String bikesEndpoint = '$baseUrl/api/bikes';
  static const String bikeImagesEndpoint = '$baseUrl/api/bike-images';
  static const String usersEndpoint = '$baseUrl/api/users';
  static const String profileImageEndpoint = '$baseUrl/api/images';

  static Map<String, String> _getHeaders({String? token}) {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  static Future<AuthResponse> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse(loginEndpoint),
        headers: _getHeaders(),
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      print('Login Response Status: ${response.statusCode}');
      print('Login Response Body: ${response.body}');

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return AuthResponse.fromJson(responseData);
      } else {
        return AuthResponse(
          success: false,
          message: responseData['message'] ?? 'Login failed',
        );
      }
    } catch (e) {
      print('Login Error: $e');
      return AuthResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  static Future<AuthResponse> register(
      String username, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse(registerEndpoint),
        headers: _getHeaders(),
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
        }),
      );

      print('Register Response Status: ${response.statusCode}');
      print('Register Response Body: ${response.body}');

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        // For register, we need to return success without token since backend doesn't return token
        return AuthResponse(
          success: responseData['success'] ?? false,
          message: responseData['message'],
          user: responseData['data'] != null
              ? User.fromJson(responseData['data'])
              : null,
          token: null, // Register doesn't return token in this API
        );
      } else {
        return AuthResponse(
          success: false,
          message: responseData['message'] ?? 'Registration failed',
        );
      }
    } catch (e) {
      print('Register Error: $e');
      return AuthResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  static Future<User?> getProfile(String token) async {
    try {
      final response = await http.get(
        Uri.parse(profileEndpoint),
        headers: _getHeaders(token: token),
      );

      print('Profile Response Status: ${response.statusCode}');
      print('Profile Response Body: ${response.body}');

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        return User.fromJson(responseData['data']);
      }

      return null;
    } catch (e) {
      print('Profile Error: $e');
      return null;
    }
  }

  static Future<List<Bike>> getBikes() async {
    try {
      final response = await http.get(
        Uri.parse(bikesEndpoint),
        headers: _getHeaders(),
      );

      print('=== BIKES API RESPONSE DEBUG ===');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
      print('===============================');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        if (responseData['success'] == true && responseData['data'] != null) {
          List<dynamic> bikesJson = responseData['data'];

          print('=== BIKES DATA DEBUG ===');
          print('Number of bikes: ${bikesJson.length}');

          // Debug setiap bike
          for (int i = 0; i < bikesJson.length; i++) {
            var bikeData = bikesJson[i];
            print('Bike $i:');
            print('  - ID: ${bikeData['id']}');
            print('  - Brand: ${bikeData['brand']}');
            print('  - Type: ${bikeData['tipe']}');
            print(
                '  - Has bikeImage field: ${bikeData.containsKey('bikeImage')}');
            print('  - bikeImage value: ${bikeData['bikeImage']}');
            print(
                '  - bikeImage length: ${bikeData['bikeImage']?.toString().length ?? 0}');
            print('  - hasBikeImage: ${bikeData['hasBikeImage']}');
          }
          print('======================');

          // Convert to Bike objects and fetch images for bikes that have them
          List<Bike> bikes = [];
          for (dynamic json in bikesJson) {
            Bike bike = Bike.fromJson(
                json); // If bike has image, fetch the actual image data
            if (json['hasBikeImage'] == true) {
              try {
                print('Fetching image for bike ${bike.id}...');
                final imageResponse = await http.get(
                  Uri.parse('$bikeImagesEndpoint/${bike.id}'),
                  headers: _getHeaders(),
                );

                print('Image API Status: ${imageResponse.statusCode}');
                print('Image API Response: ${imageResponse.body}');

                if (imageResponse.statusCode == 200) {
                  final imageData = jsonDecode(imageResponse.body);
                  if (imageData['success'] == true) {
                    String base64Image = imageData['data']['imageBase64'];
                    print('Got base64 image, length: ${base64Image.length}');
                    print(
                        'First 50 chars: ${base64Image.substring(0, base64Image.length > 50 ? 50 : base64Image.length)}'); // Create new bike with image data
                    bike = Bike(
                      id: bike.id,
                      brand: bike.brand,
                      type: bike.type,
                      bikeImage: base64Image,
                      description: bike.description,
                      createdAt: bike.createdAt,
                      updatedAt: bike.updatedAt,
                    );
                    print('Successfully loaded image for bike ${bike.id}');
                  }
                }
              } catch (e) {
                print('Error loading image for bike ${bike.id}: $e');
              }
            } else {
              print(
                  'Bike ${bike.id} has no image (hasBikeImage: ${json['hasBikeImage']})');
            }

            bikes.add(bike);
          }

          return bikes;
        } else {
          throw Exception('API returned unsuccessful response');
        }
      } else {
        throw Exception('Failed to load bikes: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching bikes: $e');
      throw Exception('Network error: ${e.toString()}');
    }
  }

  static Future<Bike?> getBikeWithImage(int bikeId) async {
    try {
      // First get bike details
      final response = await http.get(
        Uri.parse('$bikesEndpoint/$bikeId'),
        headers: _getHeaders(),
      );

      print('Get Bike Response Status: ${response.statusCode}');

      if (response.statusCode != 200) {
        return null;
      }

      final Map<String, dynamic> responseData = jsonDecode(response.body);
      if (responseData['success'] != true) {
        return null;
      }

      Bike bike = Bike.fromJson(responseData[
          'data']); // If bike has image, fetch the actual image data
      if (responseData['data']['hasBikeImage'] == true) {
        try {
          final imageResponse = await http.get(
            Uri.parse('$bikeImagesEndpoint/$bikeId'),
            headers: _getHeaders(),
          );

          if (imageResponse.statusCode == 200) {
            final imageData = jsonDecode(imageResponse.body);
            if (imageData['success'] == true) {
              // Create new bike with image data
              bike = Bike(
                id: bike.id,
                brand: bike.brand,
                type: bike.type,
                bikeImage: imageData['data']['imageBase64'],
                description: bike.description,
                createdAt: bike.createdAt,
                updatedAt: bike.updatedAt,
              );
              print('Successfully loaded image for bike $bikeId');
            }
          }
        } catch (e) {
          print('Error loading image for bike $bikeId: $e');
        }
      }

      return bike;
    } catch (e) {
      print('Get Bike with Image Error: $e');
      return null;
    }
  }

  // Legacy method - kept for backward compatibility
  // Use updateUserProfile() and uploadProfileImage() separately instead
  static Future<Map<String, dynamic>> updateUser(
    String token,
    int userId, {
    String? username,
    String? email,
    String? profileImage,
  }) async {
    // This method is deprecated - use separate methods instead
    print(
        'WARNING: updateUser() is deprecated. Use updateUserProfile() and uploadProfileImage() separately.');
    return updateUserProfile(token, userId, username: username, email: email);
  }

  // Get user by ID
  static Future<User?> getUserById(String token, int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$usersEndpoint/$userId'),
        headers: _getHeaders(token: token),
      );

      print('Get User Response Status: ${response.statusCode}');
      print('Get User Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData['success'] == true && responseData['data'] != null) {
          return User.fromJson(responseData['data']);
        }
      }

      return null;
    } catch (e) {
      print('Get User Error: $e');
      return null;
    }
  }

  // Upload profile image using imageController
  static Future<Map<String, dynamic>> uploadProfileImage(
    String token,
    String imageBase64,
  ) async {
    try {
      print('=== UPLOAD PROFILE IMAGE DEBUG ===');
      print('Token: ${token.substring(0, 20)}...');
      print('ImageBase64 length: ${imageBase64.length}');
      print(
          'ImageBase64 starts with data:image: ${imageBase64.startsWith('data:image')}');
      print('================================');

      final response = await http.post(
        Uri.parse('$profileImageEndpoint/upload'),
        headers: _getHeaders(token: token),
        body: jsonEncode({
          'imageBase64': imageBase64,
        }),
      );

      print('Upload Profile Image Response Status: ${response.statusCode}');
      print('Upload Profile Image Response Body: ${response.body}');

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message':
              responseData['message'] ?? 'Profile image uploaded successfully',
          'data': responseData['data'],
        };
      } else {
        return {
          'success': false,
          'message':
              responseData['message'] ?? 'Failed to upload profile image',
        };
      }
    } catch (e) {
      print('Upload Profile Image Error: $e');
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Get profile image using imageController
  static Future<String?> getProfileImage(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$profileImageEndpoint/$userId'),
        headers: _getHeaders(),
      );

      print('Get Profile Image Response Status: ${response.statusCode}');
      print('Get Profile Image Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData['success'] == true && responseData['data'] != null) {
          return responseData['data']['imageBase64'];
        }
      }

      return null;
    } catch (e) {
      print('Get Profile Image Error: $e');
      return null;
    }
  }

  // Update profile image using imageController
  static Future<Map<String, dynamic>> updateProfileImage(
    String token,
    int userId,
    String imageBase64,
  ) async {
    try {
      print('=== UPDATE PROFILE IMAGE DEBUG ===');
      print('User ID: $userId');
      print('Token: ${token.substring(0, 20)}...');
      print('ImageBase64 length: ${imageBase64.length}');
      print('================================');

      final response = await http.put(
        Uri.parse('$profileImageEndpoint/$userId'),
        headers: _getHeaders(token: token),
        body: jsonEncode({
          'imageBase64': imageBase64,
        }),
      );

      print('Update Profile Image Response Status: ${response.statusCode}');
      print('Update Profile Image Response Body: ${response.body}');

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message':
              responseData['message'] ?? 'Profile image updated successfully',
          'data': responseData['data'],
        };
      } else {
        return {
          'success': false,
          'message':
              responseData['message'] ?? 'Failed to update profile image',
        };
      }
    } catch (e) {
      print('Update Profile Image Error: $e');
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Delete profile image using imageController
  static Future<Map<String, dynamic>> deleteProfileImage(
    String token,
    int userId,
  ) async {
    try {
      final response = await http.delete(
        Uri.parse('$profileImageEndpoint/$userId'),
        headers: _getHeaders(token: token),
      );

      print('Delete Profile Image Response Status: ${response.statusCode}');
      print('Delete Profile Image Response Body: ${response.body}');

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message':
              responseData['message'] ?? 'Profile image deleted successfully',
        };
      } else {
        return {
          'success': false,
          'message':
              responseData['message'] ?? 'Failed to delete profile image',
        };
      }
    } catch (e) {
      print('Delete Profile Image Error: $e');
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Update user profile (without image, only username and email)
  static Future<Map<String, dynamic>> updateUserProfile(
    String token,
    int userId, {
    String? username,
    String? email,
  }) async {
    try {
      Map<String, dynamic> updateData = {};

      if (username != null) updateData['username'] = username;
      if (email != null) updateData['email'] = email;

      print('=== UPDATE USER PROFILE DEBUG ===');
      print('User ID: $userId');
      print('Update data: $updateData');
      print('===============================');

      final response = await http.put(
        Uri.parse('$usersEndpoint/$userId'),
        headers: _getHeaders(token: token),
        body: jsonEncode(updateData),
      );

      print('Update User Profile Response Status: ${response.statusCode}');
      print('Update User Profile Response Body: ${response.body}');

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': responseData['message'] ?? 'Profile updated successfully',
          'user': responseData['data'] != null
              ? User.fromJson(responseData['data'])
              : null,
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to update profile',
        };
      }
    } catch (e) {
      print('Update User Profile Error: $e');
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Get user with profile image - combines user data and image data
  static Future<User?> getUserWithProfileImage(String token, int userId) async {
    try {
      // First get user basic data
      User? user = await getUserById(token, userId);
      if (user == null) return null;

      // Then try to get profile image separately
      try {
        String? profileImageBase64 = await getProfileImage(userId);
        if (profileImageBase64 != null) {
          // Create new user object with the image data
          user = User(
            id: user.id,
            username: user.username,
            email: user.email,
            profileImage: profileImageBase64,
            createdAt: user.createdAt,
            updatedAt: user.updatedAt,
          );
          print('Successfully loaded user with profile image');
        } else {
          print('No profile image found for user $userId');
        }
      } catch (e) {
        print('Error loading profile image for user $userId: $e');
        // Return user without image if image loading fails
      }

      return user;
    } catch (e) {
      print('Get User with Profile Image Error: $e');
      return null;
    }
  }
}
