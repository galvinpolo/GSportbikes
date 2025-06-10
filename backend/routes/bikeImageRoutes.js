import express from "express";
import {
  uploadBikeImage,
  getBikeImage,
} from "../controllers/bikeImageController.js";

const router = express.Router();

// POST /api/bike-images/upload - Upload bike image (no authentication required)
router.post("/upload", uploadBikeImage);

// GET /api/bike-images/:bikeId - Get bike image (no authentication required)
router.get("/:bikeId", getBikeImage);

export default router;
