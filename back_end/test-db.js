const db = require('./config/database');
require('dotenv').config();

async function testDatabase() {
  try {
    console.log('Testing database connection...');

    // Test connection
    const [result] = await db.execute('SELECT 1 as test');
    console.log('✓ Database connection successful');

    // Check if user_signup table exists
    try {
      const [users] = await db.execute('SELECT * FROM user_signup LIMIT 1');
      console.log('✓ user_signup table exists');
      console.log('Table structure:', users.length > 0 ? users[0] : 'Table is empty');
    } catch (err) {
      if (err.code === 'ER_NO_SUCH_TABLE') {
        console.log('✗ user_signup table does not exist');
        console.log('Please create the table with the following structure:');
        console.log(`
          CREATE TABLE user_signup (
            id INT AUTO_INCREMENT PRIMARY KEY,
            register_number VARCHAR(50) UNIQUE NOT NULL,
            name VARCHAR(100) NOT NULL,
            email VARCHAR(100) UNIQUE NOT NULL,
            phone_number VARCHAR(15),
            department VARCHAR(100),
            password VARCHAR(255) NOT NULL,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
          )
        `);
      } else {
        console.error('Error checking table:', err);
      }
    }

  } catch (error) {
    console.error('Database test failed:', error);
  } finally {
    process.exit();
  }
}

testDatabase();