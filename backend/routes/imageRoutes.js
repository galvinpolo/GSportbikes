import express from "express";
import {
  uploadProfileImage,
  getProfileImage,
  updateProfileImage,
  deleteProfileImage,
} from "../controllers/imageController.js";
import { verifyToken } from "../middleware/authMiddleware.js";

const router = express.Router();

// POST /api/images/upload - Upload profile image (requires authentication)
router.post("/upload", verifyToken, uploadProfileImage);

// GET /api/images/:userId - Get profile image (public access)
router.get("/:userId", getProfileImage);

// PUT /api/images/:userId - Update profile image (requires authentication)
router.put("/:userId", verifyToken, updateProfileImage);

// DELETE /api/images/:userId - Delete profile image (requires authentication)
router.delete("/:userId", verifyToken, deleteProfileImage);

export default router;
