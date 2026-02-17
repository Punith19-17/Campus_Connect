const db = require("../config/database");

const Club = {
  create: async (clubData) => {
    console.log("🔍 Club.create received data:", clubData);
    const {
      pic,
      club_name,
      club_discription,
      department,
      responsible_faculty,
      president,
      vice_president,
      joint_secretary,
      treasury,
      group_members,
      club_type = "institutional",
    } = clubData;

    console.log("🔍 Club.create extracted club_type:", club_type);

    const query = `
      INSERT INTO add_club
      (pic, club_name, club_discription, department, responsible_faculty, president, vice_president, joint_secretary, treasury, group_members, club_type)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    `;

    const [results] = await db.execute(query, [
      pic,
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
    ]);

    return results;
  },

  getAll: async () => {
    const query = "SELECT * FROM add_club ORDER BY created_at ASC";
    const [results] = await db.execute(query);
    return results;
  },

  update: async (id, clubData) => {
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
    } = clubData;

    const query = `
      UPDATE add_club 
      SET club_name = ?, club_discription = ?, department = ?, responsible_faculty = ?, 
          president = ?, vice_president = ?, joint_secretary = ?, treasury = ?, 
          group_members = ?, club_type = ?, updated_at = CURRENT_TIMESTAMP
      WHERE id = ?
    `;

    const [results] = await db.execute(query, [
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
      id,
    ]);

    return results;
  },

  delete: async (id) => {
    const query = "DELETE FROM add_club WHERE id = ?";
    const [results] = await db.execute(query, [id]);
    return results;
  },
};

module.exports = Club;
