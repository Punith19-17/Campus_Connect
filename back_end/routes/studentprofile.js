const express = require('express');
const router = express.Router();
const studentprofileController = require('../controllers/studentprofileController');
const auth = require('../middleware/auth');

// @route   GET api/profile
// @desc    Get current student's profile
// @access  Private (requires login token)
// ✨ FIX: Changed '/studentprofile' to '/'
// This makes the full path 'GET /api/profile' which matches the frontend.
router.get('/', auth, studentprofileController.getProfile);


module.exports = router;