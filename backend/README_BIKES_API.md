# API Dokumentasi - Bikes CRUD (No Authentication Required)

## Bikes Endpoints yang Tersedia

### 1. Create New Bike

**POST** `/api/bikes`

**Request Body:**

```json
{
  "brand": "Honda",
  "tipe": "CBR1000RR",
  "deskripsi": "Superbike Honda dengan performa tinggi dan teknologi MotoGP"
}
```

**Response Success:**

```json
{
  "success": true,
  "message": "Bike created successfully",
  "data": {
    "id": 1,
    "brand": "Honda",
    "tipe": "CBR1000RR",
    "deskripsi": "Superbike Honda dengan performa tinggi dan teknologi MotoGP",
    "hasBikeImage": false,
    "createdAt": "2024-01-01T00:00:00.000Z",
    "updatedAt": "2024-01-01T00:00:00.000Z"
  }
}
```

### 2. Get All Bikes

**GET** `/api/bikes`

**Response Success:**

```json
{
  "success": true,
  "message": "Bikes retrieved successfully",
  "data": [
    {
      "id": 1,
      "brand": "Honda",
      "tipe": "CBR1000RR",
      "deskripsi": "Superbike Honda dengan performa tinggi dan teknologi MotoGP",
      "hasBikeImage": true,
      "createdAt": "2024-01-01T00:00:00.000Z",
      "updatedAt": "2024-01-01T00:00:00.000Z"
    },
    {
      "id": 2,
      "brand": "Yamaha",
      "tipe": "YZF-R1",
      "deskripsi": "Superbike Yamaha dengan teknologi MotoGP dan crossplane crankshaft",
      "hasBikeImage": false,
      "createdAt": "2024-01-01T01:00:00.000Z",
      "updatedAt": "2024-01-01T01:00:00.000Z"
    }
  ]
}
```

### 3. Get Bike by ID

**GET** `/api/bikes/:id`

**Response Success:**

```json
{
  "success": true,
  "message": "Bike retrieved successfully",
  "data": {
    "id": 1,
    "brand": "Honda",
    "tipe": "CBR1000RR",
    "deskripsi": "Superbike Honda dengan performa tinggi dan teknologi MotoGP",
    "hasBikeImage": true,
    "createdAt": "2024-01-01T00:00:00.000Z",
    "updatedAt": "2024-01-01T00:00:00.000Z"
  }
}
```

### 4. Upload Bike Image

**POST** `/api/bike-images/upload`

**Request Body:**

```json
{
  "bikeId": 1,
  "bikeImageBase64": "data:image/jpeg;base64,/9j/4AAQSkZJRgABAQAAAQ..."
}
```

**Response Success:**

```json
{
  "success": true,
  "message": "Bike image uploaded successfully",
  "data": {
    "bikeId": 1,
    "brand": "Honda",
    "tipe": "CBR1000RR",
    "hasBikeImage": true
  }
}
```

### 5. Get Bike Image

**GET** `/api/bike-images/:bikeId`

**Response Success:**

```json
{
  "success": true,
  "message": "Bike image retrieved successfully",
  "data": {
    "bikeId": 1,
    "brand": "Honda",
    "tipe": "CBR1000RR",
    "imageBase64": "data:image/jpeg;base64,/9j/4AAQSkZJRgABAQAAAQ..."
  }
}
```

## Error Responses

### 400 Bad Request

```json
{
  "success": false,
  "message": "Brand and tipe are required"
}
```

```json
{
  "success": false,
  "message": "Invalid image format"
}
```

### 404 Not Found

```json
{
  "success": false,
  "message": "Bike not found"
}
```

```json
{
  "success": false,
  "message": "Bike image not found"
}
```

### 500 Internal Server Error

```json
{
  "success": false,
  "message": "Internal server error",
  "error": "Error details..."
}
```

## Cara Penggunaan dari Flutter

### 1. Create New Bike

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;

Future<void> createBike(String brand, String tipe, String deskripsi) async {
  final response = await http.post(
    Uri.parse('http://your-server.com/api/bikes'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'brand': brand,
      'tipe': tipe,
      'deskripsi': deskripsi,
    }),
  );

  if (response.statusCode == 201) {
    print('Bike created successfully');
  } else {
    print('Failed to create bike');
  }
}
```

### 2. Upload Bike Image

```dart
Future<void> uploadBikeImage(int bikeId, String imageBase64) async {
  final response = await http.post(
    Uri.parse('http://your-server.com/api/bike-images/upload'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'bikeId': bikeId,
      'bikeImageBase64': imageBase64,
    }),
  );

  if (response.statusCode == 200) {
    print('Bike image uploaded successfully');
  } else {
    print('Failed to upload bike image');
  }
}
```

### 3. Get All Bikes

```dart
Future<List<dynamic>> getAllBikes() async {
  final response = await http.get(
    Uri.parse('http://your-server.com/api/bikes'),
    headers: {'Content-Type': 'application/json'},
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data['data'];
  }
  return [];
}
```

### 4. Get Bike by ID

```dart
Future<Map<String, dynamic>?> getBikeById(int bikeId) async {
  final response = await http.get(
    Uri.parse('http://your-server.com/api/bikes/$bikeId'),
    headers: {'Content-Type': 'application/json'},
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data['data'];
  }
  return null;
}
```

### 5. Get Bike Image

```dart
Future<String?> getBikeImage(int bikeId) async {
  final response = await http.get(
    Uri.parse('http://your-server.com/api/bike-images/$bikeId'),
    headers: {'Content-Type': 'application/json'},
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data['data']['imageBase64'];
  }
  return null;
}
```

### 6. Menampilkan Bike Image dalam Flutter

```dart
// Untuk menampilkan gambar dari Base64
Widget buildBikeImage(String? imageBase64) {
  if (imageBase64 == null) {
    return Icon(Icons.motorcycle, size: 100, color: Colors.grey);
  }

  return Image.memory(
    base64Decode(imageBase64.split(',')[1]),
    fit: BoxFit.cover,
    width: 200,
    height: 150,
  );
}

// Untuk membuat list bikes
Widget buildBikesList() {
  return FutureBuilder<List<dynamic>>(
    future: getAllBikes(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return CircularProgressIndicator();
      }

      if (snapshot.hasError) {
        return Text('Error: ${snapshot.error}');
      }

      final bikes = snapshot.data ?? [];

      return ListView.builder(
        itemCount: bikes.length,
        itemBuilder: (context, index) {
          final bike = bikes[index];
          return Card(
            child: ListTile(
              title: Text('${bike['brand']} ${bike['tipe']}'),
              subtitle: Text(bike['deskripsi'] ?? 'No description'),
              trailing: bike['hasBikeImage']
                ? Icon(Icons.image, color: Colors.green)
                : Icon(Icons.image, color: Colors.grey),
              onTap: () {
                // Navigate to bike detail
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BikeDetailPage(bikeId: bike['id']),
                  ),
                );
              },
            ),
          );
        },
      );
    },
  );
}
```

### 7. Complete Bike Management Example

```dart
// Complete example for creating bike with image
Future<void> createBikeWithImage(String brand, String tipe, String deskripsi, String imageBase64) async {
  // Step 1: Create bike first
  final createResponse = await http.post(
    Uri.parse('http://your-server.com/api/bikes'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'brand': brand,
      'tipe': tipe,
      'deskripsi': deskripsi,
    }),
  );

  if (createResponse.statusCode == 201) {
    final bikeData = jsonDecode(createResponse.body);
    final bikeId = bikeData['data']['id'];

    // Step 2: Upload image for the created bike
    await uploadBikeImage(bikeId, imageBase64);
    print('Bike created with image successfully');
  } else {
    print('Failed to create bike');
  }
}
```

## Contoh Data untuk Testing

### Sample Bike Data

```json
{
  "brand": "Honda",
  "tipe": "CBR1000RR-R Fireblade SP",
  "deskripsi": "Superbike Honda terbaru dengan teknologi MotoGP, winglet aerodinamika, dan performa luar biasa"
}
```

```json
{
  "brand": "Yamaha",
  "tipe": "YZF-R1M",
  "deskripsi": "Yamaha R1M dengan suspensi Ohlins, carbon fiber bodywork, dan teknologi elektronik canggih"
}
```

```json
{
  "brand": "Kawasaki",
  "tipe": "Ninja ZX-10R",
  "deskripsi": "Kawasaki Ninja ZX-10R dengan mesin 998cc dan teknologi traction control terdepan"
}
```

```json
{
  "brand": "Ducati",
  "tipe": "Panigale V4S",
  "deskripsi": "Ducati Panigale V4S dengan mesin Desmosedici Stradale dan desain aerodynamic yang memukau"
}
```

## Catatan Penting

1. **No Authentication**: Semua endpoint bikes tidak memerlukan token JWT
2. **Image Storage**: Gambar disimpan sebagai BLOB di database
3. **Image Format**: Base64 dengan prefix `data:image/jpeg;base64,`
4. **Required Fields**: Hanya `brand` dan `tipe` yang wajib diisi
5. **Image Optional**: Field `bikeImageBase64` bersifat opsional
6. **Size Limit**: Server mendukung file hingga 50MB
7. **Performance**: Untuk production, pertimbangkan menggunakan cloud storage untuk gambar

## Testing dengan Postman

### Create Bike

- Method: POST
- URL: `http://localhost:5000/api/bikes`
- Body (JSON):

```json
{
  "brand": "Honda",
  "tipe": "CBR600RR",
  "deskripsi": "Honda CBR600RR supersport motorcycle"
}
```

### Get All Bikes

- Method: GET
- URL: `http://localhost:5000/api/bikes`

### Get Bike by ID

- Method: GET
- URL: `http://localhost:5000/api/bikes/1`

### Upload Bike Image

- Method: POST
- URL: `http://localhost:5000/api/bike-images/upload`
- Body (JSON):

```json
{
  "bikeId": 1,
  "bikeImageBase64": "data:image/jpeg;base64,/9j/4AAQSkZJRgABAQAAAQ..."
}
```

### Get Bike Image

- Method: GET
- URL: `http://localhost:5000/api/bike-images/1`
