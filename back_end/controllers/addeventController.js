const AddEvent = require("../models/addevent");
const db = require("../config/database");

const addeventController = {
  // Enhanced clash detection with time range
  checkEventClash: async (req, res) => {
    try {
      const { date, time, end_time, location, event_id } = req.body;

      if (!date || !time || !end_time || !location) {
        if (res) {
          return res.status(400).json({
            success: false,
            message: "Missing required fields for clash check",
          });
        } else {
          throw new Error("Missing required fields for clash check");
        }
      }

      // Validate time order
      if (time >= end_time) {
        if (res) {
          return res.status(400).json({
            success: false,
            message: "End time must be after start time",
          });
        } else {
          throw new Error("End time must be after start time");
        }
      }

      // Query to find overlapping events at same location and date
      const query = `
        SELECT event_title, organized_club, date, time, end_time, location 
        FROM add_events 
        WHERE date = ? 
        AND location = ?
        AND id != ?
        AND (
          (time < ? AND end_time > ?) OR      -- New event starts during existing
          (time < ? AND end_time > ?) OR      -- New event ends during existing
          (time >= ? AND end_time <= ?) OR    -- New event completely within existing
          (time <= ? AND end_time >= ?)       -- New event completely covers existing
        )
      `;

      const [results] = await db.execute(query, [
        date, location, event_id || 0,
        // Parameters for overlap conditions
        end_time, time,     // Condition 1
        time, end_time,     // Condition 2  
        time, end_time,     // Condition 3
        time, end_time      // Condition 4
      ]);

      const clashResult = {
        success: true,
        hasClash: results.length > 0,
        clashingEvents: results,
        message: results.length > 0 
          ? `Found ${results.length} event(s) at the same venue with overlapping time`
          : "No event clashes detected"
      };

      if (res) {
        return res.json(clashResult);
      } else {
        return clashResult;
      }

    } catch (error) {
      console.error("Error in checkEventClash:", error);
      if (res) {
        return res.status(500).json({
          success: false,
          message: "Internal server error during clash check",
        });
      } else {
        throw error;
      }
    }
  },

  // Internal clash check method (without response object)
  _checkEventClashInternal: async (eventData) => {
    try {
      const { date, time, end_time, location, event_id } = eventData;

      if (!date || !time || !end_time || !location) {
        throw new Error("Missing required fields for clash check");
      }

      if (time >= end_time) {
        throw new Error("End time must be after start time");
      }

      const query = `
        SELECT event_title, organized_club, date, time, end_time, location 
        FROM add_events 
        WHERE date = ? 
        AND location = ?
        AND id != ?
        AND (
          (time < ? AND end_time > ?) OR
          (time < ? AND end_time > ?) OR
          (time >= ? AND end_time <= ?) OR
          (time <= ? AND end_time >= ?)
        )
      `;

      const [results] = await db.execute(query, [
        date, location, event_id || 0,
        end_time, time, time, end_time,
        time, end_time, time, end_time
      ]);

      return {
        success: true,
        hasClash: results.length > 0,
        clashingEvents: results,
        message: results.length > 0 
          ? `Found ${results.length} event(s) at the same venue with overlapping time`
          : "No event clashes detected"
      };

    } catch (error) {
      console.error("Error in internal clash check:", error);
      throw error;
    }
  },

  createAddEvent: async (req, res) => {
    try {
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
      } = req.body;

      // Validate required fields
      if (!event_type || !event_title || !date || !time || !end_time || !location || !organized_club) {
        return res.status(400).json({
          success: false,
          message: "Please provide all required fields including end time",
        });
      }

      // Validate time order
      if (time >= end_time) {
        return res.status(400).json({
          success: false,
          message: "End time must be after start time",
        });
      }

      // Check for clashes before creating using internal method
      const clashResult = await addeventController._checkEventClashInternal(req.body);
      if (clashResult.hasClash) {
        return res.status(409).json({
          success: false,
          message: "Event time clashes with existing events",
          clashingEvents: clashResult.clashingEvents
        });
      }

      const eventData = {
        event_type,
        event_title,
        description: description || null,
        date,
        time,
        end_time,
        location,
        organized_club,
        award: award || null,
      };

      const results = await AddEvent.create(eventData);
      res.status(201).json({
        success: true,
        message: "Event created successfully",
        eventId: results.insertId,
      });

    } catch (error) {
      console.error("Error in createAddEvent:", error);
      
      if (error.errno === 1062) {
        return res.status(409).json({
          success: false,
          message: "An event already exists at this venue and time. Please choose a different time or location.",
        });
      }

      res.status(500).json({
        success: false,
        message: "Internal server error",
      });
    }
  },

  updateAddEvent: async (req, res) => {
    try {
      const eventId = req.params.id;
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
      } = req.body;

      if (!event_type || !event_title || !date || !time || !end_time || !location || !organized_club) {
        return res.status(400).json({
          success: false,
          message: "Please provide all required fields including end time",
        });
      }

      // Validate time order
      if (time >= end_time) {
        return res.status(400).json({
          success: false,
          message: "End time must be after start time",
        });
      }

      // Check for clashes (excluding current event) using internal method
      const clashBody = { ...req.body, event_id: eventId };
      const clashResult = await addeventController._checkEventClashInternal(clashBody);
      if (clashResult.hasClash) {
        return res.status(409).json({
          success: false,
          message: "Event time clashes with existing events",
          clashingEvents: clashResult.clashingEvents
        });
      }

      const eventData = {
        event_type,
        event_title,
        description: description || null,
        date,
        time,
        end_time,
        location,
        organized_club,
        award: award || null,
      };

      const results = await AddEvent.update(eventId, eventData);
      
      if (results.affectedRows === 0) {
        return res.status(404).json({
          success: false,
          message: "Event not found",
        });
      }

      res.json({
        success: true,
        message: "Event updated successfully",
      });

    } catch (error) {
      console.error("Error in updateAddEvent:", error);
      res.status(500).json({
        success: false,
        message: "Internal server error",
      });
    }
  },

  // ... keep all your other methods unchanged (getAllAddEvents, deleteAddEvent, etc.)
  getAllAddEvents: async (req, res) => {
    try {
      const events = await AddEvent.getAll();
      res.json({
        success: true,
        events: events,
      });
    } catch (error) {
      console.error("Error fetching all events:", error);
      res.status(500).json({
        success: false,
        message: "Error fetching events",
      });
    }
  },

  deleteAddEvent: async (req, res) => {
    try {
      const eventId = req.params.id;
      const results = await AddEvent.delete(eventId);

      if (results.affectedRows === 0) {
        return res.status(404).json({
          success: false,
          message: "Event not found",
        });
      }

      res.json({
        success: true,
        message: "Event deleted successfully",
      });
    } catch (error) {
      console.error("Error deleting event:", error);
      res.status(500).json({
        success: false,
        message: "Error deleting event",
      });
    }
  },

  getCollegeFunctions: async (req, res) => {
    try {
      const [results] = await db.execute(
        "SELECT * FROM add_events WHERE event_type = 'College Function' ORDER BY date DESC, time DESC"
      );

      res.json({
        success: true,
        events: results,
      });
    } catch (error) {
      console.error("Error fetching college function events:", error);
      res.status(500).json({
        success: false,
        message: "Error fetching college function events",
      });
    }
  },

  getClubEvents: async (req, res) => {
    try {
      const results = await AddEvent.getClubEvents();
      res.json({
        success: true,
        events: results,
      });
    } catch (error) {
      console.error("Error fetching club events:", error);
      res.status(500).json({
        success: false,
        message: "Error fetching club events",
      });
    }
  },

  getAddEventById: async (req, res) => {
    try {
      const eventId = req.params.id;
      const result = await AddEvent.getById(eventId);

      if (!result) {
        return res.status(404).json({
          success: false,
          message: "Event not found",
        });
      }

      res.json({
        success: true,
        event: result,
      });
    } catch (error) {
      console.error("Error fetching event by ID:", error);
      res.status(500).json({
        success: false,
        message: "Error fetching event by ID",
      });
    }
  },

  likeEvent: async (req, res) => {
    try {
      const { eventId, studentId } = req.body;
      await AddEvent.addLike(eventId, studentId);
      res.status(201).json({ success: true, message: "Event liked successfully" });
    } catch (error) {
      console.error("Error liking event:", error);
      res.status(500).json({ success: false, message: "Error liking event" });
    }
  },

  unlikeEvent: async (req, res) => {
    try {
      const { eventId, studentId } = req.body;
      await AddEvent.removeLike(eventId, studentId);
      res.json({ success: true, message: "Event unliked successfully" });
    } catch (error) {
      console.error("Error unliking event:", error);
      res.status(500).json({ success: false, message: "Error unliking event" });
    }
  },

  getLikeStatus: async (req, res) => {
    try {
      const { eventId, studentId } = req.query;
      const isLiked = await AddEvent.isLiked(eventId, studentId);
      res.json({ success: true, isLiked: isLiked });
    } catch (error) {
      console.error("Error fetching like status:", error);
      res.status(500).json({ success: false, message: "Error fetching like status" });
    }
  },

  getInterestedEvents: async (req, res) => {
    try {
      const studentId = req.params.studentId;
      const results = await AddEvent.getInterestedEvents(studentId);
      res.json({
        success: true,
        events: results,
      });
    } catch (error) {
      console.error("Error fetching interested events:", error);
      res.status(500).json({
        success: false,
        message: "Error fetching interested events",
      });
    }
  }
};

module.exports = addeventController;