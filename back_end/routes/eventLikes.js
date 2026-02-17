const express = require("express");
const router = express.Router();
const eventLikesController = require("../controllers/eventLikesController");
const auth = require("../middleware/auth");

// Toggle event like (protected)
router.post("/:eventId/like", auth, eventLikesController.toggleEventLike);

// Get event likes count
router.get("/:eventId/likes", eventLikesController.getEventLikes);

// Get user's like status for an event (protected)
router.get("/:eventId/user-like", auth, eventLikesController.getUserLikeStatus);

module.exports = router;
