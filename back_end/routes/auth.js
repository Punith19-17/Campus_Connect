const express = require('express');
const router = express.Router();
const authController = require('../controllers/authController');

// Student routes
router.post('/register', authController.register);
router.post('/login', authController.login);

// Admin routes
router.post('/admin/signup', authController.adminSignup);
router.post('/admin/login', authController.adminLogin);

module.exports = router;