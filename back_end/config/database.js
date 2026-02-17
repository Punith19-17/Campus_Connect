const mysql = require('mysql2');
require('dotenv').config();

// Create a connection pool for better handling
const pool = mysql.createPool({
  host: process.env.DB_HOST || 'localhost',
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASSWORD || '',
  database: process.env.DB_NAME || 'events',
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0
});

// Test the connection
pool.getConnection((err, connection) => {
  if (err) {
    console.error('Error connecting to MySQL: ' + err.message);

    // Provide more specific error messages
    if (err.code === 'ER_ACCESS_DENIED_ERROR') {
      console.error('Access denied. Check your MySQL username and password.');
    } else if (err.code === 'ER_BAD_DB_ERROR') {
      console.error('Database "' + process.env.DB_NAME + '" does not exist. Please create the database first.');
    } else if (err.code === 'ECONNREFUSED') {
      console.error('MySQL server is not running. Please start MySQL service.');
    }

    return;
  }

  console.log('Connected to MySQL database "' + process.env.DB_NAME + '" as id ' + connection.threadId);
  connection.release(); // Release the connection back to the pool
});

// Promisify for async/await
const promisePool = pool.promise();

module.exports = promisePool;