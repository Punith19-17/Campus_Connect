const db = require('../config/database');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

// Student registration - NO AUTH REQUIRED
exports.register = async (req, res) => {
  try {
    // ⬇️ FIXED HERE: Changed to camelCase to match the frontend
    const { registerNumber, name, email, phoneNumber, department, password } = req.body;

    console.log('Registration attempt for:', email);

    // ⬇️ FIXED HERE: Use the correct variable name
    if (!registerNumber || !name || !email || !password) {
      return res.status(400).json({ message: 'Please provide all required fields' });
    }

    // Check if user already exists
    try {
      const [results] = await db.execute(
        'SELECT * FROM user_signup WHERE email = ? OR register_number = ?',
        // ⬇️ FIXED HERE: Use the correct variable name
        [email, registerNumber]
      );

      if (results.length > 0) {
        return res.status(400).json({ message: 'User already exists with this email or registration number' });
      }
    } catch (err) {
      console.error('Error checking user existence:', err);
      return res.status(500).json({ error: 'Database error' });
    }

    // Hash password
    const hashedPassword = await bcrypt.hash(password, 10);

    // Insert user
    try {
      const [result] = await db.execute(
        'INSERT INTO user_signup (register_number, name, email, phone_number, department, password) VALUES (?, ?, ?, ?, ?, ?)',
        // ⬇️ FIXED HERE: Use the correct variables in the correct order for the SQL query
        [registerNumber, name, email, phoneNumber, department, hashedPassword]
      );

      // Generate JWT token
      const token = jwt.sign(
        {
          id: result.insertId,
          email: email,
          // ⬇️ FIXED HERE: Use the correct variable name
          register_number: registerNumber
        },
        process.env.JWT_SECRET || 'fallback_secret',
        { expiresIn: '7d' }
      );

      res.status(201).json({
        message: 'User registered successfully',
        token: token,
        user: {
          id: result.insertId,
          // ⬇️ FIXED HERE: Use the correct variable names
          register_number: registerNumber,
          name: name,
          email: email,
          phone_number: phoneNumber,
          department: department
        }
      });
    } catch (err) {
      console.error('Error inserting user:', err);
      return res.status(500).json({ error: 'Failed to register user' });
    }
  } catch (error) {
    console.error('Unexpected error in register:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
};

// Student login - NO AUTH REQUIRED
exports.login = async (req, res) => {
  try {
    const { email, password } = req.body;

    console.log('Login attempt for:', email);

    // Validate required fields
    if (!email || !password) {
      return res.status(400).json({ message: 'Please provide email and password' });
    }

    // Find user
    try {
      const [results] = await db.execute(
        'SELECT * FROM user_signup WHERE email = ?',
        [email]
      );

      if (results.length === 0) {
        return res.status(401).json({ message: 'Invalid credentials' });
      }

      const user = results[0];

      // Check password
      const isMatch = await bcrypt.compare(password, user.password);
      if (!isMatch) {
        return res.status(401).json({ message: 'Invalid credentials' });
      }

      // Generate JWT token
      const token = jwt.sign(
        {
          id: user.id,
          email: user.email,
          register_number: user.register_number
        },
        process.env.JWT_SECRET || 'fallback_secret',
        { expiresIn: '7d' }
      );

      res.json({
        message: 'Login successful',
        token: token,
        user: {
          id: user.id,
          register_number: user.register_number,
          name: user.name,
          email: user.email,
          phone_number: user.phone_number,
          department: user.department
        }
      });
    } catch (err) {
      console.error('Error during login:', err);
      return res.status(500).json({ error: 'Database error' });
    }
  } catch (error) {
    console.error('Unexpected error in login:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
};

// Admin signup - NO AUTH REQUIRED
exports.adminSignup = async (req, res) => {
  try {
    const { name, email, department, password } = req.body;

    console.log('Admin registration attempt for:', email);

    // Validate required fields
    if (!name || !email || !department || !password) {
      return res.status(400).json({
        success: false,
        message: 'All fields are required'
      });
    }

    // Check if admin already exists
    try {
      const [results] = await db.execute(
        'SELECT * FROM admin_signup WHERE email = ?',
        [email]
      );

      if (results.length > 0) {
        return res.status(409).json({
          success: false,
          message: 'Admin with this email already exists'
        });
      }
    } catch (err) {
      console.error('Error checking admin existence:', err);
      return res.status(500).json({
        success: false,
        error: 'Database error'
      });
    }

    // Hash password
    const hashedPassword = await bcrypt.hash(password, 10);

    // Insert admin
    try {
      const [result] = await db.execute(
        'INSERT INTO admin_signup (name, email, department, password) VALUES (?, ?, ?, ?)',
        [name, email, department, hashedPassword]
      );

      res.status(201).json({
        success: true,
        message: 'Admin account created successfully',
        userId: result.insertId
      });
    } catch (err) {
      console.error('Error inserting admin:', err);
      return res.status(500).json({
        success: false,
        error: 'Failed to create admin account'
      });
    }
  } catch (error) {
    console.error('Unexpected error in adminSignup:', error);
    res.status(500).json({
      success: false,
      error: 'Internal server error'
    });
  }
};

// ADMIN LOGIN
exports.adminLogin = async (req, res) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({ success: false, message: 'Please provide email and password' });
    }

    // 1. Find the specific admin by their email
    const [results] = await db.execute('SELECT * FROM admin_signup WHERE email = ?', [email]);

    if (results.length === 0) {
      return res.status(401).json({ success: false, message: 'Invalid credentials' });
    }

    const admin = results[0];

    // 2. Compare the provided password with the hashed password in the database
    const isMatch = await bcrypt.compare(password, admin.password);
    if (!isMatch) {
      return res.status(401).json({ success: false, message: 'Invalid credentials' });
    }

    // 3. Create a token containing the ID of the admin who just logged in
    const payload = {
      id: admin.id,
      email: admin.email,
      role: 'admin'
    };

    const token = jwt.sign(payload, process.env.JWT_SECRET || 'fallback_secret', { expiresIn: '7d' });

    res.json({
      success: true,
      message: 'Admin login successful',
      token: token,
      user: {
        id: admin.id,
        name: admin.name,
        email: admin.email,
        department: admin.department,
        role: 'admin'
      }
    });
  } catch (err) {
    console.error('Error during admin login:', err);
    return res.status(500).json({ success: false, error: 'Database error' });
  }
};