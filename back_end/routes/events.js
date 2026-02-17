const express = require("express");
const router = express.Router();
const eventController = require("../controllers/eventController");
const auth = require("../middleware/auth");
const upload = require("../middleware/upload");

// Get all events
router.get("/", eventController.getAllEvents);

// Get event by ID
router.get("/:id", eventController.getEventById);

// Create new event (temporarily not protected for testing)
router.post("/", upload.single("image"), eventController.createEvent);

// Register for an event (temporarily not protected for testing)
router.post("/:eventId/register", eventController.registerForEvent);

// Get user's registered events (temporarily not protected for testing)
router.post("/user/events", eventController.getUserEvents);

// Update event (temporarily not protected for testing)
router.put("/:eventId", eventController.updateEvent);

// Delete event (temporarily not protected for testing)
router.delete("/:eventId", eventController.deleteEvent);

module.exports = router;
