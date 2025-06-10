import { Sequelize } from "sequelize";
import db from "../config/database.js";

const Bike = db.define(
  "bikes",
  {
    id: {
      type: Sequelize.INTEGER,
      primaryKey: true,
      autoIncrement: true,
    },
    brand: {
      type: Sequelize.STRING,
      allowNull: false,
    },
    tipe: {
      type: Sequelize.STRING,
      allowNull: false,
    },
    deskripsi: {
      type: Sequelize.TEXT,
      allowNull: true,
    },
    bikeImage: {
      type: Sequelize.BLOB("long"),
      allowNull: true,
    },
  },
  {
    timestamps: true, // Automatically adds createdAt and updatedAt fields
  }
);

export default Bike;
