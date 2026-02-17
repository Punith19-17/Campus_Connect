const db = require('../config/database');

const User = {
  create: (userData, callback) => {
    const { name, email, department, password } = userData;
    const query = 'INSERT INTO admin_signup (name, email, department, password) VALUES (?, ?, ?, ?)';

    db.execute(query, [name, email, department, password], (err, results) => {
      if (err) {
        return callback(err, null);
      }
      return callback(null, results);
    });
  },

  findByEmail: (email, callback) => {
    const query = 'SELECT * FROM admin_signup WHERE email = ?';

    db.execute(query, [email], (err, results) => {
      if (err) {
        return callback(err, null);
      }
      return callback(null, results[0]);
    });
  }
};

module.exports = User;