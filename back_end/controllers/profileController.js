const db = require("../config/database");

exports.getAdminProfile = async (req, res) => {
  try {
    // Get the admin ID from req.user, which was set by the auth middleware
    const adminId = req.user.id;

    const query = "SELECT id, name, email, department FROM admin_signup WHERE id = ?";
    const [[admin]] = await db.execute(query, [adminId]);

    if (!admin) {
      return res.status(404).json({ success: false, message: "Admin not found" });
    }

    // Return the correct admin's details
    res.json({ success: true, admin: admin });

  } catch (error) {
    console.error("Error fetching admin profile:", error);
    res.status(500).json({ success: false, message: "Internal server error" });
  }
};