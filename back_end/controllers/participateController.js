const db = require('../config/database');

// @route POST /api/participate/register
// @desc Register a new participant, checking for duplicates (eventName + registerNumber)
// @access Public
exports.registerParticipant = async (req, res) => {
    // Destructure all the fields from the request body, including eventName
    const { eventName, registerNumber, name, phoneNumber, department } = req.body;

    // Basic validation to ensure required fields are present
    if (!eventName || !registerNumber || !name || !phoneNumber || !department) {
        return res.status(400).json({ msg: 'Please fill all required fields.' });
    }

    try {
        // 1. CHECK FOR DUPLICATE REGISTRATION
        const checkSql = `
            SELECT 1 FROM participate 
            WHERE event_name = ? AND register_number = ?
        `;
        const [existing] = await db.query(checkSql, [eventName, registerNumber]);

        if (existing.length > 0) {
            // If a record is found, return a 409 Conflict error
            return res.status(409).json({
                msg: 'event is already registered with this register number',
                isDuplicate: true, // Custom flag for frontend
            });
        }

        // 2. PROCEED WITH INSERTION
        const insertSql = `
            INSERT INTO participate (event_name, register_number, name, phone_number, department)
            VALUES (?, ?, ?, ?, ?);
        `;
        const values = [eventName, registerNumber, name, phoneNumber, department];

        const [rows] = await db.query(insertSql, values);

        if (rows.affectedRows > 0) {
            return res.status(201).json({ msg: 'Registration successful' });
        } else {
            return res.status(500).json({ msg: 'Registration failed.' });
        }
    } catch (err) {
        console.error(err.message);
        // Handle database-level unique key constraint errors (though the check above should catch them)
        if (err.code === 'ER_DUP_ENTRY') {
            return res.status(409).json({ msg: 'Register number already exists.' });
        }
        return res.status(500).send('Server Error');
    }
};

// ... (Rest of the file remains the same)

//fetch data

exports.getAllParticipants = async (req, res) => {
  try {
    const [rows] = await db.query('SELECT * FROM participate ORDER BY created_at DESC');
    return res.status(200).json(rows);
  } catch (err) {
    console.error(err.message);
    return res.status(500).send('Server Error');
  }
};
