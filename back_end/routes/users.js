const express = require('express');
const router = express.Router();

// Add a simple test route
router.get('/', (req, res) => {
  res.json({ message: 'Users endpoint' });
});

module.exports = router;