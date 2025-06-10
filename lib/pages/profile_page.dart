import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import '../models/user_model.dart';
import 'currency_converter_page.dart';
import 'time_converter_page.dart';
import 'lbs_page.dart';
import 'compass_page.dart';
import 'price_page.dart';
import 'dart:convert';
import 'dart:typed_data';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  User? _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final token = await AuthService.getToken();
      if (token != null) {
        // Get user from local storage first
        final localUser = await AuthService.getUser();

        if (localUser != null) {
          // Try to get updated user data with profile image from server
          final updatedUser =
              await ApiService.getUserWithProfileImage(token, localUser.id);

          if (updatedUser != null) {
            // Save updated user data to local storage
            await AuthService.saveUser(updatedUser);
            setState(() {
              _currentUser = updatedUser;
              _isLoading = false;
            });
          } else {
            // Fallback to local user data if server request fails
            setState(() {
              _currentUser = localUser;
              _isLoading = false;
            });
          }
        } else {
          setState(() {
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Load user data error: $e');
      // Fallback to local user data
      final localUser = await AuthService.getUser();
      setState(() {
        _currentUser = localUser;
        _isLoading = false;
      });
    }
  }

  Widget _buildProfileAvatar() {
    print('=== PROFILE PAGE AVATAR DEBUG ===');
    print('Current user is null: ${_currentUser == null}');
    print('Profile image is null: ${_currentUser?.profileImage == null}');
    print(
        'Profile image is empty: ${_currentUser?.profileImage?.isEmpty ?? true}');

    if (_currentUser?.profileImage != null &&
        _currentUser!.profileImage!.isNotEmpty) {
      print('Profile image length: ${_currentUser!.profileImage!.length}');
      print(
          'Profile image first 50 chars: ${_currentUser!.profileImage!.length > 50 ? _currentUser!.profileImage!.substring(0, 50) : _currentUser!.profileImage}');

      try {
        String base64String = _currentUser!.profileImage!;

        // Remove data:image prefix if present
        if (base64String.contains(',')) {
          base64String = base64String.split(',').last;
        }

        Uint8List bytes = base64Decode(base64String);
        print('Successfully decoded ${bytes.length} bytes for profile avatar');
        print('=================================');

        return CircleAvatar(
          radius: 60,
          backgroundImage: MemoryImage(bytes),
          backgroundColor: Colors.white.withOpacity(0.2),
        );
      } catch (e) {
        print('Error loading profile image: $e');
        print('=================================');
      }
    } else {
      print('No profile image available, showing default avatar');
      print('=================================');
    }

    return CircleAvatar(
      radius: 60,
      backgroundColor: Colors.deepPurple.withOpacity(0.1),
      child: const Icon(
        Icons.person,
        size: 60,
        color: Colors.deepPurple,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: RefreshIndicator(
        onRefresh: _loadUserData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding:
              const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Profile Header Card
              Card(
                elevation: 8,
                shadowColor: Colors.deepPurpleAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Colors.deepPurple, Colors.purple],
                    ),
                  ),
                  padding: const EdgeInsets.all(24),
                  width: double.infinity,
                  child: Column(
                    children: [
                      _buildProfileAvatar(),
                      const SizedBox(height: 16),
                      Text(
                        _currentUser?.username ?? 'User',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _currentUser?.email ?? 'user@example.com',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Profile Information Cards
              _buildInfoCard(
                title: 'Account Information',
                icon: Icons.account_circle,
                children: [
                  _buildInfoRow('Username', _currentUser?.username ?? 'N/A'),
                  const Divider(),
                  _buildInfoRow('Email', _currentUser?.email ?? 'N/A'),
                  const Divider(),
                  _buildInfoRow(
                      'Member Since',
                      _currentUser?.createdAt != null
                          ? '${_currentUser!.createdAt.day}/${_currentUser!.createdAt.month}/${_currentUser!.createdAt.year}'
                          : 'N/A'),
                ],
              ),
              const SizedBox(height: 16),

              _buildInfoCard(
                title: 'App Features',
                icon: Icons.settings,
                children: [
                  _buildActionRow(
                    'Money Conversion',
                    Icons.currency_exchange,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CurrencyConverterPage(),
                        ),
                      );
                    },
                  ),
                  const Divider(),
                  _buildActionRow(
                    'Time Conversion',
                    Icons.access_time,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TimeConverterPage(),
                        ),
                      );
                    },
                  ),
                  const Divider(),
                  _buildActionRow(
                    'Showroom Locations',
                    Icons.location_on,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LBSPage(),
                        ),
                      );
                    },
                  ),
                  const Divider(),
                  _buildActionRow(
                    'Compass',
                    Icons.explore,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CompassPage(),
                        ),
                      );
                    },
                  ),
                  const Divider(),
                  _buildActionRow(
                    'Bike Prices',
                    Icons.attach_money,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PricePage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),

              _buildInfoCard(
                title: 'About',
                icon: Icons.info,
                children: [
                  _buildInfoRow('Framework', 'Flutter'),
                  const Divider(),
                  _buildInfoRow('Developer', 'Galvin Suryo Asmoro'),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: Colors.deepPurple,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Text(
            ': ',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionRow(String label, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              color: Colors.deepPurple,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey[400],
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
