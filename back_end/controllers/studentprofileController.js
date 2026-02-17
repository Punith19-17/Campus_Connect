const db = require('../config/database');

exports.getProfile = async (req, res) => {
  try {
    // The user's ID is attached to the request by the 'auth' middleware
    const userId = req.user.id;

    // Find the user in the database by their ID
    const [results] = await db.execute(
      'SELECT id, register_number, name, email, phone_number, department FROM user_signup WHERE id = ?',
      [userId]
    );

    if (results.length === 0) {
      return res.status(404).json({ message: 'User not found' });
    }

    const userProfile = results[0];

    // TODO: You can also fetch event statistics here if needed
    // For now, we'll send dummy stats
    const interestedEvents = 20; // Replace with actual query
    const totalEvents = 35;     // Replace with actual query

    res.json({
      success: true,
      profile: {
        ...userProfile,
        interestedEvents,
        totalEvents,
      },
    });

  } catch (error) {
    console.error('Error fetching user profile:', error);
    res.status(500).json({ success: false, message: 'Internal server error' });
  }
};
