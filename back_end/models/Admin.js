// models/Admin.js

const db = require("../config/database");

const Admin = {
  findById: async (id) => {
    const query = "SELECT id, name, email, department FROM admin_signup WHERE id = ?";
    const [[admin]] = await db.execute(query, [id]);
    return admin;
  },
};

module.exports = Admin;