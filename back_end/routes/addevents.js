const express = require("express");
const router = express.Router();
const addeventController = require("../controllers/addeventController");
const upload = require("../middleware/upload");

// --- Existing Routes ---

// Create a new event

// Check for event clash - POST route
router.post("/events/check-clash", addeventController.checkEventClash);

// Create a new event - POST route (CHANGED PATH)
router.post("/addevents", addeventController.createAddEvent);

// Update an event - PUT route (CHANGED PATH)
router.put("/addevents/:id", addeventController.updateAddEvent);


// GET all events
// GET /api/addevents
router.get("/addevents", addeventController.getAllAddEvents);

// Update an event by its ID
// PUT /api/addevents/:id
router.put("/addevents/:id", addeventController.updateAddEvent);

// Delete an event by its ID
// DELETE /api/addevents/:id
router.delete("/addevents/:id", addeventController.deleteAddEvent);


// --- ** NEW ROUTE ADDED ** ---

// GET only "College Function" events
// GET /api/addevents/college
router.get("/addevents/collegefunctions", addeventController.getCollegeFunctions);

//get only club events
router.get("/addevents/club", addeventController.getClubEvents);

router.get("/addevents/:id", addeventController.getAddEventById);


// POST /api/addevents/like
router.post("/addevents/like", addeventController.likeEvent);

// POST /api/addevents/unlike
router.post("/addevents/unlike", addeventController.unlikeEvent);

// GET /api/addevents/like/status?eventId=X&studentId=Y
router.get("/addevents/like/status", addeventController.getLikeStatus);

// GET /api/addevents/interested/:studentId
router.get("/addevents/interested/:studentId", addeventController.getInterestedEvents);


module.exports = router;