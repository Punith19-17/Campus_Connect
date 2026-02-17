const Club = require("../models/Club");
const path = require("path");
const fs = require("fs");

const clubController = {
  createClub: async (req, res) => {
    try {
      console.log("🔍 Received club data:", req.body);
      const {
        club_name,
        club_discription,
        department,
        responsible_faculty,
        president,
        vice_president,
        joint_secretary,
        treasury,
        group_members,
        club_type,
      } = req.body;

      console.log("🔍 Extracted club_type:", club_type);

      // Validate required fields
      if (
        !club_name ||
        !department ||
        !president ||
        !vice_president ||
        !joint_secretary ||
        !treasury
      ) {
        return res.status(400).json({
          success: false,
          message: "Please provide all required fields",
        });
      }

      let picPath = null;
      if (req.file) {
        picPath = `/uploads/${req.file.filename}`;
      }

      // Convert group members array to string if it's an array
      let membersString = group_members;
      if (Array.isArray(group_members)) {
        membersString = group_members.join(", ");
      }

      const clubData = {
        pic: picPath,
        club_name,
        club_discription: club_discription || "",
        department,
        responsible_faculty: responsible_faculty || "",
        president,
        vice_president,
        joint_secretary,
        treasury,
        group_members: membersString,
        club_type: club_type || "institutional",
      };

      const results = await Club.create(clubData);
      res.status(201).json({
        success: true,
        message: "Club created successfully",
        clubId: results.insertId,
      });
    } catch (error) {
      console.error("Unexpected error in createClub:", error);
      res.status(500).json({
        success: false,
        message: "Internal server error",
      });
    }
  },

  getAllClubs: async (req, res) => {
    try {
      const results = await Club.getAll();
      res.json({
        success: true,
        clubs: results,
      });
    } catch (error) {
      console.error("Error fetching clubs:", error);
      res.status(500).json({
        success: false,
        message: "Error fetching clubs",
      });
    }
  },

  updateClub: async (req, res) => {
    try {
      const clubId = req.params.id;
      const {
        club_name,
        club_discription,
        department,
        responsible_faculty,
        president,
        vice_president,
        joint_secretary,
        treasury,
        group_members,
        club_type,
      } = req.body;

      // Validate required fields
      if (
        !club_name ||
        !department ||
        !president ||
        !vice_president ||
        !joint_secretary ||
        !treasury
      ) {
        return res.status(400).json({
          success: false,
          message: "Please provide all required fields",
        });
      }

      // Convert group members array to string if it's an array
      let membersString = group_members;
      if (Array.isArray(group_members)) {
        membersString = group_members.join(", ");
      }

      const clubData = {
        club_name,
        club_discription: club_discription || "",
        department,
        responsible_faculty: responsible_faculty || "",
        president,
        vice_president,
        joint_secretary,
        treasury,
        group_members: membersString,
        club_type: club_type || "institutional",
      };

      const results = await Club.update(clubId, clubData);

      if (results.affectedRows === 0) {
        return res.status(404).json({
          success: false,
          message: "Club not found",
        });
      }

      res.json({
        success: true,
        message: "Club updated successfully",
      });
    } catch (error) {
      console.error("Error updating club:", error);
      res.status(500).json({
        success: false,
        message: "Error updating club",
      });
    }
  },

  deleteClub: async (req, res) => {
    try {
      const clubId = req.params.id;
      const results = await Club.delete(clubId);

      if (results.affectedRows === 0) {
        return res.status(404).json({
          success: false,
          message: "Club not found",
        });
      }

      res.json({
        success: true,
        message: "Club deleted successfully",
      });
    } catch (error) {
      console.error("Error deleting club:", error);
      res.status(500).json({
        success: false,
        message: "Error deleting club",
      });
    }
  },
};

module.exports = clubController;
