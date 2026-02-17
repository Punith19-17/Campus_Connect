// models/Dashboard.js

const db = require("../config/database");

const Dashboard = {
  getStats: async () => {
    // Define all the count queries
    const eventsQuery = "SELECT COUNT(*) as totalEvents FROM add_events";
    const activeEventsQuery = "SELECT COUNT(*) as activeEvents FROM add_events WHERE date >= CURDATE()";
    const clubsQuery = "SELECT COUNT(*) as totalClubs FROM add_club";
    const studentsQuery = "SELECT COUNT(*) as totalStudents FROM user_signup";

    // Execute all queries in parallel for efficiency
    const [
      eventsData,
      activeEventsData,
      clubsData,
      studentsData
    ] = await Promise.all([
      db.execute(eventsQuery),
      db.execute(activeEventsQuery),
      db.execute(clubsQuery),
      db.execute(studentsQuery),
    ]);

    // ** THE FIX IS HERE: Correctly access the count from the database result **
    // The result from db.execute() is [rows, fields]. We need the first column of the first row.
    return {
      totalEvents: eventsData[0][0].totalEvents,
      activeEvents: activeEventsData[0][0].activeEvents,
      totalClubs: clubsData[0][0].totalClubs,
      totalStudents: studentsData[0][0].totalStudents,
    };
  },
};

module.exports = Dashboard;