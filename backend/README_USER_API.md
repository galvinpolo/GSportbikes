# API Dokumentasi - User CRUD

## User Endpoints yang Tersedia

### 1. Get All Users

**GET** `/api/users`

**Response Success:**

```json
{
  "success": true,
  "message": "Users retrieved successfully",
  "data": [
    {
      "id": 1,
      "username": "john",
      "email": "john@example.com",
      "profileImage": null,
      "createdAt": "2024-01-01T00:00:00.000Z",
      "updatedAt": "2024-01-01T00:00:00.000Z"
    }
  ]
}
```

### 2. Get User by ID

**GET** `/api/users/:id`

**Response Success:**

```json
{
  "success": true,
  "message": "User retrieved successfully",
  "data": {
    "id": 1,
    "username": "john",
    "email": "john@example.com",
    "profileImage": null,
    "createdAt": "2024-01-01T00:00:00.000Z",
    "updatedAt": "2024-01-01T00:00:00.000Z"
  }
}
```

### 3. Create New User

**POST** `/api/users`

**Request Body:**

```json
{
  "username": "john",
  "email": "john@example.com",
  "password": "securepassword123"
}
```

**Response Success:**

```json
{
  "success": true,
  "message": "User created successfully",
  "data": {
    "id": 1,
    "username": "john",
    "email": "john@example.com",
    "profileImage": null,
    "createdAt": "2024-01-01T00:00:00.000Z",
    "updatedAt": "2024-01-01T00:00:00.000Z"
  }
}
```

### 4. Update User

**PUT** `/api/users/:id`

**Request Body (semua field optional):**

```json
{
  "username": "john_updated",
  "email": "john_new@example.com",
  "password": "newpassword123"
}
```

**Response Success:**

```json
{
  "success": true,
  "message": "User updated successfully",
  "data": {
    "id": 1,
    "username": "john_updated",
    "email": "john_new@example.com",
    "profileImage": null,
    "createdAt": "2024-01-01T00:00:00.000Z",
    "updatedAt": "2024-01-01T12:00:00.000Z"
  }
}
```

### 5. Delete User

**DELETE** `/api/users/:id`

**Response Success:**

```json
{
  "success": true,
  "message": "User deleted successfully",
  "data": {
    "id": 1,
    "username": "john",
    "email": "john@example.com"
  }
}
```

### 6. Login User

**POST** `/api/users/login`

**Request Body:**

```json
{
  "username": "john",
  "password": "securepassword123"
}
```

**Response Success:**

```json
{
  "success": true,
  "message": "Login successful",
  "data": {
    "id": 1,
    "username": "john",
    "email": "john@example.com",
    "profileImage": null,
    "createdAt": "2024-01-01T00:00:00.000Z",
    "updatedAt": "2024-01-01T00:00:00.000Z"
  }
}
```

## Error Responses

### 400 Bad Request

```json
{
  "success": false,
  "message": "Username, email, and password are required"
}
```

### 401 Unauthorized

```json
{
  "success": false,
  "message": "Invalid credentials"
}
```

### 404 Not Found

```json
{
  "success": false,
  "message": "User not found"
}
```

### 409 Conflict

```json
{
  "success": false,
  "message": "Username or email already exists"
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

### 1. Create User (Register)

```dart
Future<void> registerUser(String username, String email, String password) async {
  final response = await http.post(
    Uri.parse('http://your-server.com/api/users'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'username': username,
      'email': email,
      'password': password,
    }),
  );

  if (response.statusCode == 201) {
    print('User registered successfully');
  } else {
    print('Registration failed');
  }
}
```

### 2. Login User

```dart
Future<Map<String, dynamic>?> loginUser(String username, String password) async {
  final response = await http.post(
    Uri.parse('http://your-server.com/api/users/login'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'username': username,
      'password': password,
    }),
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body)['data'];
  }
  return null;
}
```

### 3. Get All Users

```dart
Future<List<dynamic>> getAllUsers() async {
  final response = await http.get(
    Uri.parse('http://your-server.com/api/users'),
    headers: {'Content-Type': 'application/json'},
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body)['data'];
  }
  return [];
}
```

### 4. Update User

```dart
Future<void> updateUser(int userId, Map<String, dynamic> updateData) async {
  final response = await http.put(
    Uri.parse('http://your-server.com/api/users/$userId'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(updateData),
  );

  if (response.statusCode == 200) {
    print('User updated successfully');
  }
}
```

## Fitur Keamanan

1. **Password Hashing**: Menggunakan bcrypt dengan salt rounds 10
2. **Input Validation**: Validasi email format dan required fields
3. **Unique Constraints**: Username dan email harus unique
4. **Password Exclusion**: Password tidak pernah dikirim dalam response
5. **Error Handling**: Comprehensive error handling untuk semua scenarios

## Catatan Penting

- Password otomatis di-hash menggunakan bcrypt
- Password tidak pernah dikembalikan dalam response API
- Username atau email bisa digunakan untuk login
- Semua endpoint memiliki error handling yang proper
