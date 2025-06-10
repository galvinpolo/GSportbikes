import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import '../models/user_model.dart';
import '../models/bike_model.dart';
import '../widgets/bike_card.dart';
import 'edit_profile_page.dart';
import 'favorite_page.dart';
import 'price_page.dart';
import 'dart:convert';
import 'dart:typed_data';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  User? _currentUser;
  bool _isLoading = true;
  bool _isLoadingBikes = true;
  List<Bike> _bikes = [];
  List<Bike> _filteredBikes = [];
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadBikesFromAPI();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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

  Future<void> _navigateToEditProfile() async {
    if (_currentUser == null) return;

    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditProfilePage(user: _currentUser!),
      ),
    );

    // If profile was updated, reload user data
    if (result == true) {
      _loadUserData();
    }
  }

  Widget _buildProfileAvatar() {
    if (_currentUser?.profileImage != null &&
        _currentUser!.profileImage!.isNotEmpty) {
      try {
        String base64String = _currentUser!.profileImage!;

        // Remove data:image prefix if present
        if (base64String.contains(',')) {
          base64String = base64String.split(',').last;
        }

        Uint8List bytes = base64Decode(base64String);

        return CircleAvatar(
          radius: 30,
          backgroundImage: MemoryImage(bytes),
          backgroundColor: Colors.white.withOpacity(0.2),
        );
      } catch (e) {
        print('Error loading profile image: $e');
      }
    }

    return CircleAvatar(
      radius: 30,
      backgroundColor: Colors.white.withOpacity(0.2),
      child: const Icon(
        Icons.person,
        size: 30,
        color: Colors.white,
      ),
    );
  }

  // Load bikes from API with base64 BLOB images
  Future<void> _loadBikesFromAPI() async {
    setState(() {
      _isLoadingBikes = true;
    });

    try {
      print('Loading bikes from API...');
      final bikes = await ApiService.getBikes();

      if (bikes.isNotEmpty) {
        print('Successfully loaded ${bikes.length} bikes from API');
        setState(() {
          _bikes = bikes;
          _filteredBikes = bikes; // Initialize filtered bikes
          _isLoadingBikes = false;
        });
      } else {
        print('No bikes returned from API, using fallback sample data');
        setState(() {
          _isLoadingBikes = false;
        });
      }
    } catch (e) {
      print('Error loading bikes from API: $e');
      setState(() {
        _isLoadingBikes = false;
      });
    }
  }

  // Search bikes by type
  void _searchBikes(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredBikes = _bikes;
      } else {
        _filteredBikes = _bikes
            .where((bike) =>
                bike.type.toLowerCase().contains(query.toLowerCase()) ||
                bike.brand.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  // Clear search
  void _clearSearch() {
    _searchController.clear();
    _searchBikes('');
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
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Colors.deepPurple,
            child: SafeArea(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: _searchBikes,
                  decoration: InputDecoration(
                    hintText: 'Cari berdasarkan tipe atau brand motor...',
                    hintStyle: TextStyle(color: Colors.grey[500]),
                    prefixIcon:
                        const Icon(Icons.search, color: Colors.deepPurple),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: Colors.grey),
                            onPressed: _clearSearch,
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Main Content
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadBikesFromAPI,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // User Welcome Card
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
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: _navigateToEditProfile,
                                  child: _buildProfileAvatar(),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Welcome back!',
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _currentUser?.username ?? 'User',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Edit Profile Button
                                IconButton(
                                  onPressed: _navigateToEditProfile,
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                  tooltip: 'Edit Profile',
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),

                            // Quick Stats
                            Row(
                              children: [
                                Expanded(
                                  child: _buildInfoRow(
                                    Icons.email,
                                    'Email',
                                    _currentUser?.email ?? 'N/A',
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Action Buttons
                            Row(
                              children: [
                                Expanded(
                                  child: _buildActionButton(
                                    Icons.account_circle,
                                    'Profile',
                                    Colors.orange,
                                    _navigateToEditProfile,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildActionButton(
                                    Icons.favorite,
                                    'Favorites',
                                    Colors.red,
                                    () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const FavoritePage(),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildActionButton(
                                    Icons.attach_money,
                                    'Prices',
                                    Colors.green,
                                    () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const PricePage(),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24), // Bikes List
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Bikes',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                          ),
                        ),
                        if (_searchQuery.isNotEmpty)
                          Text(
                            '${_filteredBikes.length} hasil',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Loading state for bikes
                    if (_isLoadingBikes)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32.0),
                          child: Column(
                            children: [
                              CircularProgressIndicator(
                                color: Colors.deepPurple,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Loading bikes from database...',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else if (_filteredBikes.isEmpty && _searchQuery.isNotEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.search_off,
                                size: 64,
                                color: Colors.grey,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Tidak ada motor dengan tipe "${_searchQuery}"',
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              TextButton(
                                onPressed: _clearSearch,
                                child: const Text(
                                  'Hapus pencarian',
                                  style: TextStyle(color: Colors.deepPurple),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else if (_bikes.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32.0),
                          child: Column(
                            children: [
                              Icon(
                                Icons.directions_bike,
                                size: 64,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'No bikes available',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Pull down to refresh',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.7,
                        ),
                        itemCount: _filteredBikes.length,
                        itemBuilder: (context, index) {
                          final bike = _filteredBikes[index];
                          return BikeCard(
                            bike: bike,
                            height: 240, // Fixed height to prevent overflow
                            // Remove onTap to use default navigation to detail page
                          );
                        },
                      ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.white, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white70,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
      IconData icon, String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
