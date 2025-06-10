# API Dokumentasi - Image Upload dengan BLOB

## Endpoints yang Tersedia

### 1. Upload Profile Image

**POST** `/api/images/upload`

**Request Body:**

```json
{
  "userId": 1,
  "imageBase64": "data:image/jpeg;base64,/9j/4AAQSkZJRgABAQAAAQ..."
}
```

**Response Success:**

```json
{
  "success": true,
  "message": "Profile image uploaded successfully",
  "data": {
    "userId": 1,
    "username": "john",
    "hasProfileImage": true
  }
}
```

### 2. Get Profile Image

**GET** `/api/images/:userId`

**Response Success:**

```json
{
  "success": true,
  "message": "Profile image retrieved successfully",
  "data": {
    "userId": 1,
    "imageBase64": "data:image/jpeg;base64,/9j/4AAQSkZJRgABAQAAAQ..."
  }
}
```

### 3. Update Profile Image

**PUT** `/api/images/:userId`

**Request Body:**

```json
{
  "imageBase64": "data:image/jpeg;base64,/9j/4AAQSkZJRgABAQAAAQ..."
}
```

**Response Success:**

```json
{
  "success": true,
  "message": "Profile image updated successfully",
  "data": {
    "userId": 1,
    "username": "john",
    "hasProfileImage": true
  }
}
```

### 4. Delete Profile Image

**DELETE** `/api/images/:userId`

**Response Success:**

```json
{
  "success": true,
  "message": "Profile image deleted successfully",
  "data": {
    "userId": 1,
    "username": "john",
    "hasProfileImage": false
  }
}
```

## Cara Penggunaan dari Flutter

### Mengambil gambar dan convert ke Base64:

```dart
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

// Pick image dari gallery/camera
final picker = ImagePicker();
final pickedFile = await picker.pickImage(source: ImageSource.gallery);

if (pickedFile != null) {
  File imageFile = File(pickedFile.path);
  List<int> imageBytes = await imageFile.readAsBytes();
  String base64Image = base64Encode(imageBytes);

  // Format untuk dikirim ke API
  String imageData = 'data:image/jpeg;base64,$base64Image';

  // Kirim ke API
  uploadImage(userId, imageData);
}
```

### Upload ke API:

```dart
import 'package:http/http.dart' as http;

Future<void> uploadImage(int userId, String imageBase64) async {
  final response = await http.post(
    Uri.parse('http://your-server.com/api/images/upload'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'userId': userId,
      'imageBase64': imageBase64,
    }),
  );

  if (response.statusCode == 200) {
    print('Image uploaded successfully');
  } else {
    print('Failed to upload image');
  }
}
```

### Menampilkan gambar dari API:

```dart
FutureBuilder<String>(
  future: getImageFromAPI(userId),
  builder: (context, snapshot) {
    if (snapshot.hasData) {
      return Image.memory(
        base64Decode(snapshot.data!.split(',')[1]),
        fit: BoxFit.cover,
      );
    }
    return CircularProgressIndicator();
  },
)
```

## Catatan Penting

1. **Size Limit**: Server sudah dikonfigurasi untuk menerima file hingga 50MB
2. **Format**: Gambar akan disimpan sebagai BLOB di database
3. **Performance**: Untuk production, pertimbangkan menggunakan file storage
4. **Memory**: BLOB dapat mempengaruhi performa database jika gambar banyak/besar
