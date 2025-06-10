import express from "express";
import {
  createBike,
  getAllBikes,
  getBikeById,
} from "../controllers/bikeController.js";

const router = express.Router();

// POST /api/bikes - Create new bike (no authentication required)
router.post("/", createBike);

// GET /api/bikes - Get all bikes (no authentication required)
router.get("/", getAllBikes);

// GET /api/bikes/:id - Get bike by ID (no authentication required)
router.get("/:id", getBikeById);

export default router;
