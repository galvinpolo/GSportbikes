import express from "express";
import { register, login, getProfile } from "../controllers/authController.js";
import { verifyToken } from "../middleware/authMiddleware.js";

const router = express.Router();

// POST /api/auth/register - Register new user
router.post("/register", register);

// POST /api/auth/login - Login user
router.post("/login", login);

// GET /api/auth/profile - Get current user profile (requires token)
router.get("/profile", verifyToken, getProfile);

export default router;
