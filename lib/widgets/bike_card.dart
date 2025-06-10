import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../models/bike_model.dart';
import '../pages/bike_detail_page.dart';
import '../services/favorite_service.dart';

class BikeCard extends StatefulWidget {
  final Bike bike;
  final VoidCallback? onTap;
  final double? width;
  final double? height;

  const BikeCard({
    super.key,
    required this.bike,
    this.onTap,
    this.width,
    this.height = 200,
  });

  @override
  State<BikeCard> createState() => _BikeCardState();
}

class _BikeCardState extends State<BikeCard> {
  bool _isFavorite = false;
  bool _isToggling = false;

  @override
  void initState() {
    super.initState();
    _checkFavoriteStatus();
  }

  Future<void> _checkFavoriteStatus() async {
    final isFavorite = await FavoriteService.isFavorite(widget.bike.id);
    if (mounted) {
      setState(() {
        _isFavorite = isFavorite;
      });
    }
  }

  Future<void> _toggleFavorite() async {
    if (_isToggling) return;

    setState(() {
      _isToggling = true;
    });

    try {
      final isNowFavorite = await FavoriteService.toggleFavorite(widget.bike);

      if (mounted) {
        setState(() {
          _isFavorite = isNowFavorite;
          _isToggling = false;
        });

        // Show snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isNowFavorite
                  ? '${widget.bike.brand} ${widget.bike.type} ditambahkan ke favorit'
                  : '${widget.bike.brand} ${widget.bike.type} dihapus dari favorit',
            ),
            backgroundColor: isNowFavorite ? Colors.green : Colors.orange,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isToggling = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal memperbarui favorit'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _navigateToDetail(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BikeDetailPage(bike: widget.bike),
      ),
    );
  }

  // Convert base64 string to Image widget
  Widget _buildBikeImage() {
    if (widget.bike.bikeImage == null || widget.bike.bikeImage!.isEmpty) {
      // Placeholder image when no bike image
      return Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.directions_bike,
                size: 40,
                color: Colors.grey,
              ),
              SizedBox(height: 4),
              Text(
                'No Image',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      );
    }

    try {
      // Clean and prepare base64 string
      String base64String = widget.bike.bikeImage!.trim();

      // Remove data:image prefix if present (e.g., data:image/jpeg;base64,)
      if (base64String.contains(',')) {
        List<String> parts = base64String.split(',');
        if (parts.length > 1) {
          base64String = parts.last;
        }
      }

      // Remove any whitespace or newlines
      base64String = base64String.replaceAll(RegExp(r'\s'), '');

      // Validate base64 string length (must be multiple of 4)
      while (base64String.length % 4 != 0) {
        base64String += '=';
      }

      // Validate it's a valid base64 string
      if (base64String.isEmpty) {
        throw Exception('Empty base64 string after processing');
      }

      // Test decode
      Uint8List bytes = base64Decode(base64String);
      return Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          child: Image.memory(
            bytes,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.red[100],
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 40,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Image Error',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 10,
                        ),
                      ),
                      Text(
                        '${widget.bike.brand}',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 8,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      );
    } catch (e) {
      return Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: Colors.orange[100],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.broken_image,
                size: 40,
                color: Colors.orange,
              ),
              const SizedBox(height: 4),
              const Text(
                'Decode Error',
                style: TextStyle(
                  color: Colors.orange,
                  fontSize: 10,
                ),
              ),
              Text(
                '${widget.bike.brand}',
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 8,
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height ?? 220, // Set default height if not provided
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          onTap: widget.onTap ?? () => _navigateToDetail(context),
          borderRadius: BorderRadius.circular(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Bike Image - Fixed height
              SizedBox(
                height: 120,
                child: _buildBikeImage(),
              ),

              // Bike Information - Flexible but constrained
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Brand
                      Text(
                        widget.bike.brand,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),

                      // Type
                      Text(
                        widget.bike.type,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const Spacer(),

                      // Action Row - Compact layout
                      SizedBox(
                        height: 28,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Favorite Icon - Compact
                            SizedBox(
                              width: 28,
                              height: 28,
                              child: IconButton(
                                onPressed: _isToggling ? null : _toggleFavorite,
                                icon: _isToggling
                                    ? SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.grey[400],
                                        ),
                                      )
                                    : Icon(
                                        _isFavorite
                                            ? Icons.favorite
                                            : Icons.favorite_border,
                                        size: 16,
                                        color: _isFavorite
                                            ? Colors.red
                                            : Colors.grey,
                                      ),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                splashRadius: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Grid version of BikeCard for better layout in grid view
class BikeCardGrid extends StatelessWidget {
  final Bike bike;
  final VoidCallback? onTap;
  const BikeCardGrid({
    super.key,
    required this.bike,
    this.onTap,
  });

  void _navigateToDetail(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BikeDetailPage(bike: bike),
      ),
    );
  }

  Widget _buildBikeImage() {
    if (bike.bikeImage == null || bike.bikeImage!.isEmpty) {
      return Container(
        height: 100,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
        ),
        child: const Center(
          child: Icon(
            Icons.directions_bike,
            size: 32,
            color: Colors.grey,
          ),
        ),
      );
    }
    try {
      // Clean and prepare base64 string
      String base64String = bike.bikeImage!.trim();

      // Remove data:image prefix if present
      if (base64String.contains(',')) {
        base64String = base64String.split(',').last;
      }

      // Remove any whitespace or newlines
      base64String = base64String.replaceAll(RegExp(r'\s'), '');

      // Validate base64 string length
      while (base64String.length % 4 != 0) {
        base64String += '=';
      }

      // Validate it's a valid base64 string
      if (base64String.isEmpty) {
        throw Exception('Empty base64 string');
      }

      Uint8List bytes = base64Decode(base64String);

      return Container(
        height: 100,
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
          child: Image.memory(
            bytes,
            fit: BoxFit.cover,
            width: double.infinity,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: 100,
                color: Colors.grey[200],
                child: const Center(
                  child: Icon(
                    Icons.broken_image,
                    size: 32,
                    color: Colors.orange,
                  ),
                ),
              );
            },
          ),
        ),
      );
    } catch (e) {
      return Container(
        height: 100,
        color: Colors.grey[200],
        child: const Center(
          child: Icon(
            Icons.broken_image,
            size: 32,
            color: Colors.orange,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: onTap ?? () => _navigateToDetail(context),
        borderRadius: BorderRadius.circular(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBikeImage(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bike.brand,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      bike.type,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Updated Grid version with favorite functionality
class BikeCardGridFavorite extends StatefulWidget {
  final Bike bike;
  final VoidCallback? onTap;

  const BikeCardGridFavorite({
    super.key,
    required this.bike,
    this.onTap,
  });

  @override
  State<BikeCardGridFavorite> createState() => _BikeCardGridFavoriteState();
}

class _BikeCardGridFavoriteState extends State<BikeCardGridFavorite> {
  bool _isFavorite = false;
  bool _isToggling = false;

  @override
  void initState() {
    super.initState();
    _checkFavoriteStatus();
  }

  Future<void> _checkFavoriteStatus() async {
    final isFavorite = await FavoriteService.isFavorite(widget.bike.id);
    if (mounted) {
      setState(() {
        _isFavorite = isFavorite;
      });
    }
  }

  Future<void> _toggleFavorite() async {
    if (_isToggling) return;

    setState(() {
      _isToggling = true;
    });

    try {
      final isNowFavorite = await FavoriteService.toggleFavorite(widget.bike);

      if (mounted) {
        setState(() {
          _isFavorite = isNowFavorite;
          _isToggling = false;
        });

        // Show snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isNowFavorite
                  ? '${widget.bike.brand} ${widget.bike.type} ditambahkan ke favorit'
                  : '${widget.bike.brand} ${widget.bike.type} dihapus dari favorit',
            ),
            backgroundColor: isNowFavorite ? Colors.green : Colors.orange,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isToggling = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal memperbarui favorit'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _navigateToDetail(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BikeDetailPage(bike: widget.bike),
      ),
    );
  }

  Widget _buildBikeImage() {
    if (widget.bike.bikeImage == null || widget.bike.bikeImage!.isEmpty) {
      return Container(
        height: 100,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
        ),
        child: const Center(
          child: Icon(
            Icons.directions_bike,
            size: 32,
            color: Colors.grey,
          ),
        ),
      );
    }
    try {
      // Clean and prepare base64 string
      String base64String = widget.bike.bikeImage!.trim();

      // Remove data:image prefix if present
      if (base64String.contains(',')) {
        base64String = base64String.split(',').last;
      }

      // Remove any whitespace or newlines
      base64String = base64String.replaceAll(RegExp(r'\s'), '');

      // Validate base64 string length
      while (base64String.length % 4 != 0) {
        base64String += '=';
      }

      // Validate it's a valid base64 string
      if (base64String.isEmpty) {
        throw Exception('Empty base64 string');
      }

      Uint8List bytes = base64Decode(base64String);

      return Container(
        height: 100,
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
          child: Image.memory(
            bytes,
            fit: BoxFit.cover,
            width: double.infinity,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: 100,
                color: Colors.grey[200],
                child: const Center(
                  child: Icon(
                    Icons.broken_image,
                    size: 32,
                    color: Colors.orange,
                  ),
                ),
              );
            },
          ),
        ),
      );
    } catch (e) {
      return Container(
        height: 100,
        color: Colors.grey[200],
        child: const Center(
          child: Icon(
            Icons.broken_image,
            size: 32,
            color: Colors.orange,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          child: InkWell(
            onTap: widget.onTap ?? () => _navigateToDetail(context),
            borderRadius: BorderRadius.circular(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBikeImage(),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.bike.brand,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.bike.type,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Favorite button positioned at top right
        Positioned(
          top: 8,
          right: 8,
          child: GestureDetector(
            onTap: _isToggling ? null : _toggleFavorite,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: _isToggling
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.grey[400],
                      ),
                    )
                  : Icon(
                      _isFavorite ? Icons.favorite : Icons.favorite_border,
                      size: 16,
                      color: _isFavorite ? Colors.red : Colors.grey,
                    ),
            ),
          ),
        ),
      ],
    );
  }
}
