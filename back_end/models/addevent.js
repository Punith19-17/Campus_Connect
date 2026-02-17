const db = require("../config/database");

const AddEvent = {
  create: async (eventData) => {
    const {
      event_type,
      event_title,
      description,
      date,
      time,
      end_time,
      location,
      organized_club,
      award,
    } = eventData;

    const query = `
      INSERT INTO add_events 
      (event_type, event_title, description, date, time, end_time, location, organized_club, award) 
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
    `;

    const [results] = await db.execute(query, [
      event_type,
      event_title,
      description,
      date,
      time,
      end_time,
      location,
      organized_club,
      award,
    ]);

    return results;
  },

  // Add update method for end_time
  update: async (id, eventData) => {
    const {
      event_type,
      event_title,
      description,
      date,
      time,
      end_time,
      location,
      organized_club,
      award,
    } = eventData;

    const query = `
      UPDATE add_events 
      SET event_type = ?, event_title = ?, description = ?, date = ?, 
          time = ?, end_time = ?, location = ?, organized_club = ?, award = ?
      WHERE id = ?
    `;

    const [results] = await db.execute(query, [
      event_type,
      event_title,
      description,
      date,
      time,
      end_time,
      location,
      organized_club,
      award,
      id,
    ]);

    return results;
  },

  // Add other required methods (getAll, delete, etc.)
  getAll: async () => {
    const [results] = await db.execute("SELECT * FROM add_events ORDER BY date DESC, time DESC");
    return results;
  },

  getById: async (id) => {
    const [results] = await db.execute("SELECT * FROM add_events WHERE id = ?", [id]);
    return results[0];
  },

  delete: async (id) => {
    const [results] = await db.execute("DELETE FROM add_events WHERE id = ?", [id]);
    return results;
  },

  getClubEvents: async () => {
    const [results] = await db.execute(
      "SELECT * FROM add_events WHERE event_type = 'Club Event' ORDER BY date DESC, time DESC"
    );
    return results;
  },

  // Add like-related methods if needed
  addLike: async (eventId, studentId) => {
    const [results] = await db.execute(
      "INSERT INTO event_likes (event_id, student_id) VALUES (?, ?)",
      [eventId, studentId]
    );
    return results;
  },

  removeLike: async (eventId, studentId) => {
    const [results] = await db.execute(
      "DELETE FROM event_likes WHERE event_id = ? AND student_id = ?",
      [eventId, studentId]
    );
    return results;
  },

  isLiked: async (eventId, studentId) => {
    const [results] = await db.execute(
      "SELECT * FROM event_likes WHERE event_id = ? AND student_id = ?",
      [eventId, studentId]
    );
    return results.length > 0;
  },

  getInterestedEvents: async (studentId) => {
    const [results] = await db.execute(
      `SELECT ae.* FROM add_events ae 
       INNER JOIN event_likes el ON ae.id = el.event_id 
       WHERE el.student_id = ? 
       ORDER BY ae.date DESC, ae.time DESC`,
      [studentId]
    );
    return results;
  }
};

module.exports = AddEvent;