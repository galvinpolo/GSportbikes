import Bike from "../models/bikeModel.js";

// Create new bike (without image)
export const createBike = async (req, res) => {
  try {
    const { brand, tipe, deskripsi } = req.body;

    // Validasi input
    if (!brand || !tipe) {
      return res.status(400).json({
        success: false,
        message: "Brand and tipe are required",
      });
    }

    // Create new bike
    const newBike = await Bike.create({
      brand,
      tipe,
      deskripsi,
      bikeImage: null, // Image akan diupload terpisah via bikeImageController
    });

    res.status(201).json({
      success: true,
      message: "Bike created successfully",
      data: {
        id: newBike.id,
        brand: newBike.brand,
        tipe: newBike.tipe,
        deskripsi: newBike.deskripsi,
        hasBikeImage: false,
        createdAt: newBike.createdAt,
        updatedAt: newBike.updatedAt,
      },
    });
  } catch (error) {
    console.error("Create bike error:", error);
    res.status(500).json({
      success: false,
      message: "Internal server error",
      error: error.message,
    });
  }
};

// Get all bikes
export const getAllBikes = async (req, res) => {
  try {
    const bikes = await Bike.findAll({
      attributes: [
        "id",
        "brand",
        "tipe",
        "deskripsi",
        "createdAt",
        "updatedAt",
      ],
      order: [["createdAt", "DESC"]],
    });

    // Add hasBikeImage field untuk setiap bike
    const bikesWithImageInfo = await Promise.all(
      bikes.map(async (bike) => {
        const bikeWithImage = await Bike.findByPk(bike.id, {
          attributes: ["bikeImage"],
        });

        return {
          id: bike.id,
          brand: bike.brand,
          tipe: bike.tipe,
          deskripsi: bike.deskripsi,
          hasBikeImage: !!bikeWithImage.bikeImage,
          createdAt: bike.createdAt,
          updatedAt: bike.updatedAt,
        };
      })
    );

    res.status(200).json({
      success: true,
      message: "Bikes retrieved successfully",
      data: bikesWithImageInfo,
    });
  } catch (error) {
    console.error("Get all bikes error:", error);
    res.status(500).json({
      success: false,
      message: "Internal server error",
      error: error.message,
    });
  }
};

// Get bike by ID
export const getBikeById = async (req, res) => {
  try {
    const { id } = req.params;

    // Cari bike berdasarkan ID
    const bike = await Bike.findByPk(id);

    if (!bike) {
      return res.status(404).json({
        success: false,
        message: "Bike not found",
      });
    }

    res.status(200).json({
      success: true,
      message: "Bike retrieved successfully",
      data: {
        id: bike.id,
        brand: bike.brand,
        tipe: bike.tipe,
        deskripsi: bike.deskripsi,
        hasBikeImage: !!bike.bikeImage,
        createdAt: bike.createdAt,
        updatedAt: bike.updatedAt,
      },
    });
  } catch (error) {
    console.error("Get bike by ID error:", error);
    res.status(500).json({
      success: false,
      message: "Internal server error",
      error: error.message,
    });
  }
};
