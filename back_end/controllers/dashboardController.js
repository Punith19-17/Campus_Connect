// controllers/dashboardController.js

const Dashboard = require("../models/Dashboard");

const dashboardController = {
  getDashboardStats: async (req, res) => {
    try {
      const stats = await Dashboard.getStats();
      res.json({
        success: true,
        stats: stats,
      });
    } catch (error) {
      console.error("Error fetching dashboard stats:", error);
      res.status(500).json({
        success: false,
        message: "Error fetching dashboard statistics",
      });
    }
  },
};

module.exports = dashboardController;