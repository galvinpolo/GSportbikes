import Bike from "../models/bikeModel.js";

// Upload bike image dengan Base64 ke BLOB
export const uploadBikeImage = async (req, res) => {
  try {
    const { bikeId, bikeImageBase64 } = req.body;

    // Validasi input
    if (!bikeId || !bikeImageBase64) {
      return res.status(400).json({
        success: false,
        message: "Bike ID and image data are required",
      });
    }

    // Cari bike berdasarkan ID
    const bike = await Bike.findByPk(bikeId);
    if (!bike) {
      return res.status(404).json({
        success: false,
        message: "Bike not found",
      });
    }

    // Convert Base64 string ke Buffer untuk BLOB
    let imageBuffer;
    try {
      // Remove data:image/jpeg;base64, prefix jika ada
      const base64Data = bikeImageBase64.replace(
        /^data:image\/[a-z]+;base64,/,
        ""
      );
      imageBuffer = Buffer.from(base64Data, "base64");
    } catch (error) {
      return res.status(400).json({
        success: false,
        message: "Invalid image format",
      });
    }

    // Update bike dengan gambar baru
    await bike.update({
      bikeImage: imageBuffer,
    });

    res.status(200).json({
      success: true,
      message: "Bike image uploaded successfully",
      data: {
        bikeId: bike.id,
        brand: bike.brand,
        tipe: bike.tipe,
        hasBikeImage: true,
      },
    });
  } catch (error) {
    console.error("Upload bike image error:", error);
    res.status(500).json({
      success: false,
      message: "Internal server error",
      error: error.message,
    });
  }
};

// Get bike image dari database
export const getBikeImage = async (req, res) => {
  try {
    const { bikeId } = req.params;

    // Cari bike dan ambil gambar
    const bike = await Bike.findByPk(bikeId, {
      attributes: ["id", "brand", "tipe", "bikeImage"],
    });

    if (!bike) {
      return res.status(404).json({
        success: false,
        message: "Bike not found",
      });
    }

    if (!bike.bikeImage) {
      return res.status(404).json({
        success: false,
        message: "Bike image not found",
      });
    }

    // Convert BLOB ke Base64 untuk dikirim ke client
    const imageBase64 = bike.bikeImage.toString("base64");

    res.status(200).json({
      success: true,
      message: "Bike image retrieved successfully",
      data: {
        bikeId: bike.id,
        brand: bike.brand,
        tipe: bike.tipe,
        imageBase64: `data:image/jpeg;base64,${imageBase64}`,
      },
    });
  } catch (error) {
    console.error("Get bike image error:", error);
    res.status(500).json({
      success: false,
      message: "Internal server error",
      error: error.message,
    });
  }
};
