import express from "express";
import cors from "cors";
import db from "./config/database.js";
import imageRoutes from "./routes/imageRoutes.js";
import userRoutes from "./routes/userRoutes.js";
import authRoutes from "./routes/authRoutes.js";
import bikeRoutes from "./routes/bikeRoutes.js";
import bikeImageRoutes from "./routes/bikeImageRoutes.js";

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json({ limit: "50mb" })); // Increase limit untuk Base64 images
app.use(express.urlencoded({ extended: true, limit: "50mb" }));

// Test database connection
async function connectDatabase() {
  try {
    await db.authenticate();
    console.log("Database connection established successfully.");

    // Sync database (create tables if not exist)
    await db.sync();
    console.log("Database synchronized successfully.");
  } catch (error) {
    console.error("Unable to connect to the database:", error);
  }
}

// Routes
app.use("/api/images", imageRoutes);
app.use("/api/users", userRoutes);
app.use("/api/auth", authRoutes);
app.use("/api/bikes", bikeRoutes);
app.use("/api/bike-images", bikeImageRoutes);

// Basic route
app.get("/", (req, res) => {
  res.json({
    success: true,
    message: "API Motor Backend is running!",
    endpoints: {
      // Auth endpoints
      register: "POST /api/auth/register",
      login: "POST /api/auth/login",
      getProfile: "GET /api/auth/profile (requires token)",
      // User endpoints (all require authentication)
      getAllUsers: "GET /api/users (requires authentication)",
      getUserById: "GET /api/users/:id (own profile only)",
      updateUser: "PUT /api/users/:id (own profile only)",
      deleteUser: "DELETE /api/users/:id (own profile only)",
      // Image endpoints
      uploadImage: "POST /api/images/upload (own image only)",
      getImage: "GET /api/images/:userId (public)",
      updateImage: "PUT /api/images/:userId (own image only)",
      deleteImage: "DELETE /api/images/:userId (own image only)",
       // Bike endpoints (no authentication required)
      createBike: "POST /api/bikes",
      getAllBikes: "GET /api/bikes",
      getBikeById: "GET /api/bikes/:id", // Bike Image endpoints (no authentication required)
      uploadBikeImage: "POST /api/bike-images/upload",
      getBikeImage: "GET /api/bike-images/:bikeId",
    },
  });
});

// Error handling middleware
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({
    success: false,
    message: "Something went wrong!",
    error: err.message,
  });
});

// 404 handler
app.use((req, res) => {
  res.status(404).json({
    success: false,
    message: "Endpoint not found",
  });
});

// Start server
app.listen(PORT, async () => {
  console.log(`Server is running on port ${PORT}`);
  await connectDatabase();
});

export default app;
