import express from "express";
import {
  getAllUsers,
  getUserById,
  updateUser,
  deleteUser,
} from "../controllers/userController.js";
import { verifyToken } from "../middleware/authMiddleware.js";

const router = express.Router();

// GET /api/users - Get all users (requires authentication)
router.get("/", verifyToken, getAllUsers);

// GET /api/users/:id - Get user by ID (requires authentication)
router.get("/:id", verifyToken, getUserById);

// PUT /api/users/:id - Update user (requires authentication)
router.put("/:id", verifyToken, updateUser);

// DELETE /api/users/:id - Delete user (requires authentication)
router.delete("/:id", verifyToken, deleteUser);

export default router;
