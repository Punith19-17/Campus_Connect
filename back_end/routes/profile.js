const express = require('express');
const router = express.Router();
const profileController = require('../controllers/profileController');
const auth = require('../middleware/auth');

// This route is protected. The 'auth' middleware runs first to verify the token.
router.get('/me', auth, profileController.getAdminProfile);

module.exports = router;