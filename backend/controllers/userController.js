import User from "../models/userModel.js";
import bcrypt from "bcrypt";
import { Op } from "sequelize";

// GET ALL USERS
export const getAllUsers = async (req, res) => {
  try {
    const users = await User.findAll({
      attributes: { exclude: ["password"] }, // Exclude password dari response
      order: [["createdAt", "DESC"]],
    });

    res.status(200).json({
      success: true,
      message: "Users retrieved successfully",
      data: users,
    });
  } catch (error) {
    console.error("Get all users error:", error);
    res.status(500).json({
      success: false,
      message: "Internal server error",
      error: error.message,
    });
  }
};

// GET USER BY ID
export const getUserById = async (req, res) => {
  try {
    const { id } = req.params;
    const requestingUserId = req.user.id;

    // Check if user is accessing their own profile
    if (requestingUserId !== parseInt(id)) {
      return res.status(403).json({
        success: false,
        message: "Access denied. You can only access your own profile.",
      });
    }

    const user = await User.findByPk(id, {
      attributes: { exclude: ["password"] }, // Exclude password
    });

    if (!user) {
      return res.status(404).json({
        success: false,
        message: "User not found",
      });
    }

    res.status(200).json({
      success: true,
      message: "User retrieved successfully",
      data: user,
    });
  } catch (error) {
    console.error("Get user by ID error:", error);
    res.status(500).json({
      success: false,
      message: "Internal server error",
      error: error.message,
    });
  }
};

// UPDATE USER
export const updateUser = async (req, res) => {
  try {
    const { id } = req.params;
    const { username, email, password } = req.body;
    const requestingUserId = req.user.id;

    // Check if user is updating their own profile
    if (requestingUserId !== parseInt(id)) {
      return res.status(403).json({
        success: false,
        message: "Access denied. You can only update your own profile.",
      });
    }

    // Cari user
    const user = await User.findByPk(id);
    if (!user) {
      return res.status(404).json({
        success: false,
        message: "User not found",
      });
    }

    // Validasi email format jika email diupdate
    if (email) {
      const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
      if (!emailRegex.test(email)) {
        return res.status(400).json({
          success: false,
          message: "Invalid email format",
        });
      }
    }

    // Check apakah username atau email sudah digunakan user lain
    if (username || email) {
      const existingUser = await User.findOne({
        where: {
          id: { [Op.ne]: id }, // Exclude current user
          [Op.or]: [
            ...(username ? [{ username }] : []),
            ...(email ? [{ email }] : []),
          ],
        },
      });

      if (existingUser) {
        return res.status(409).json({
          success: false,
          message: "Username or email already exists",
        });
      }
    }

    // Prepare update data
    const updateData = {};
    if (username) updateData.username = username;
    if (email) updateData.email = email;

    // Hash password jika diupdate
    if (password) {
      const saltRounds = 10;
      updateData.password = await bcrypt.hash(password, saltRounds);
    }

    // Update user
    await user.update(updateData);

    // Response tanpa password
    const { password: _, ...userResponse } = user.toJSON();

    res.status(200).json({
      success: true,
      message: "User updated successfully",
      data: userResponse,
    });
  } catch (error) {
    console.error("Update user error:", error);

    if (error.name === "SequelizeUniqueConstraintError") {
      return res.status(409).json({
        success: false,
        message: "Username or email already exists",
      });
    }

    res.status(500).json({
      success: false,
      message: "Internal server error",
      error: error.message,
    });
  }
};

// DELETE USER
export const deleteUser = async (req, res) => {
  try {
    const { id } = req.params;
    const requestingUserId = req.user.id;

    // Check if user is deleting their own profile
    if (requestingUserId !== parseInt(id)) {
      return res.status(403).json({
        success: false,
        message: "Access denied. You can only delete your own profile.",
      });
    }

    // Cari user
    const user = await User.findByPk(id);
    if (!user) {
      return res.status(404).json({
        success: false,
        message: "User not found",
      });
    }

    // Delete user
    await user.destroy();

    res.status(200).json({
      success: true,
      message: "User deleted successfully",
      data: {
        id: parseInt(id),
        username: user.username,
        email: user.email,
      },
    });
  } catch (error) {
    console.error("Delete user error:", error);
    res.status(500).json({
      success: false,
      message: "Internal server error",
      error: error.message,
    });
  }
};
