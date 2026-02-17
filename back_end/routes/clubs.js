const express = require("express");
const router = express.Router();
const clubController = require("../controllers/clubController");
const upload = require("../middleware/upload");
const auth = require("../middleware/auth");

// Create club with image upload (multipart)
router.post("/clubs", upload.single("clubImage"), clubController.createClub);

// Create club without image (JSON)
router.post("/clubs/json", clubController.createClub);

// Get all clubs
router.get("/clubs", clubController.getAllClubs);

// Update club
router.put("/clubs/:id", clubController.updateClub);

// Delete club
router.delete("/clubs/:id", clubController.deleteClub);

module.exports = router;
