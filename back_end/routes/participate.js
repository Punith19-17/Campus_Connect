const express = require('express');
const router = express.Router();
const participateController = require('../controllers/participateController');

// @route POST /api/participate/register
// @desc Register a new participant
// @access Public
router.post('/register', participateController.registerParticipant);


router.get('/', participateController.getAllParticipants);

module.exports = router;
