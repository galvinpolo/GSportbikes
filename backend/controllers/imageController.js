import User from "../models/userModel.js";

// Upload profile image dengan Base64 ke BLOB
export const uploadProfileImage = async (req, res) => {
  try {
    const { imageBase64 } = req.body;
    const userId = req.user.id; // Ambil userId dari JWT token

    // Validasi input
    if (!imageBase64) {
      return res.status(400).json({
        success: false,
        message: "Image data is required",
      });
    }

    // Cari user berdasarkan ID
    const user = await User.findByPk(userId);
    if (!user) {
      return res.status(404).json({
        success: false,
        message: "User not found",
      });
    }

    // Convert Base64 string ke Buffer untuk BLOB
    let imageBuffer;
    try {
      // Remove data:image/jpeg;base64, prefix jika ada
      const base64Data = imageBase64.replace(/^data:image\/[a-z]+;base64,/, "");
      imageBuffer = Buffer.from(base64Data, "base64");
    } catch (error) {
      return res.status(400).json({
        success: false,
        message: "Invalid image format",
      });
    }

    // Update user dengan gambar baru
    await user.update({
      profileImage: imageBuffer,
    });

    res.status(200).json({
      success: true,
      message: "Profile image uploaded successfully",
      data: {
        userId: user.id,
        username: user.username,
        hasProfileImage: true,
      },
    });
  } catch (error) {
    console.error("Upload image error:", error);
    res.status(500).json({
      success: false,
      message: "Internal server error",
      error: error.message,
    });
  }
};

// Get profile image dari database
export const getProfileImage = async (req, res) => {
  try {
    const { userId } = req.params;

    // Cari user dan ambil gambar
    const user = await User.findByPk(userId, {
      attributes: ["id", "profileImage"],
    });

    if (!user) {
      return res.status(404).json({
        success: false,
        message: "User not found",
      });
    }

    if (!user.profileImage) {
      return res.status(404).json({
        success: false,
        message: "Profile image not found",
      });
    }

    // Convert BLOB ke Base64 untuk dikirim ke client
    const imageBase64 = user.profileImage.toString("base64");

    res.status(200).json({
      success: true,
      message: "Profile image retrieved successfully",
      data: {
        userId: user.id,
        imageBase64: `data:image/jpeg;base64,${imageBase64}`,
      },
    });
  } catch (error) {
    console.error("Get image error:", error);
    res.status(500).json({
      success: false,
      message: "Internal server error",
      error: error.message,
    });
  }
};

// Update profile image (mengganti yang lama)
export const updateProfileImage = async (req, res) => {
  try {
    const { userId } = req.params;
    const { imageBase64 } = req.body;
    const requestingUserId = req.user.id;

    // Check if user is updating their own image
    if (requestingUserId !== parseInt(userId)) {
      return res.status(403).json({
        success: false,
        message: "Access denied. You can only update your own profile image.",
      });
    }

    // Validasi input
    if (!imageBase64) {
      return res.status(400).json({
        success: false,
        message: "Image data is required",
      });
    }

    // Cari user
    const user = await User.findByPk(userId);
    if (!user) {
      return res.status(404).json({
        success: false,
        message: "User not found",
      });
    }

    // Convert Base64 ke Buffer
    let imageBuffer;
    try {
      const base64Data = imageBase64.replace(/^data:image\/[a-z]+;base64,/, "");
      imageBuffer = Buffer.from(base64Data, "base64");
    } catch (error) {
      return res.status(400).json({
        success: false,
        message: "Invalid image format",
      });
    }

    // Update gambar (otomatis mengganti yang lama)
    await user.update({
      profileImage: imageBuffer,
    });

    res.status(200).json({
      success: true,
      message: "Profile image updated successfully",
      data: {
        userId: user.id,
        username: user.username,
        hasProfileImage: true,
      },
    });
  } catch (error) {
    console.error("Update image error:", error);
    res.status(500).json({
      success: false,
      message: "Internal server error",
      error: error.message,
    });
  }
};

// Delete profile image
export const deleteProfileImage = async (req, res) => {
  try {
    const { userId } = req.params;
    const requestingUserId = req.user.id;

    // Check if user is deleting their own image
    if (requestingUserId !== parseInt(userId)) {
      return res.status(403).json({
        success: false,
        message: "Access denied. You can only delete your own profile image.",
      });
    }

    // Cari user
    const user = await User.findByPk(userId);
    if (!user) {
      return res.status(404).json({
        success: false,
        message: "User not found",
      });
    }

    // Hapus gambar (set ke null)
    await user.update({
      profileImage: null,
    });

    res.status(200).json({
      success: true,
      message: "Profile image deleted successfully",
      data: {
        userId: user.id,
        username: user.username,
        hasProfileImage: false,
      },
    });
  } catch (error) {
    console.error("Delete image error:", error);
    res.status(500).json({
      success: false,
      message: "Internal server error",
      error: error.message,
    });
  }
};
