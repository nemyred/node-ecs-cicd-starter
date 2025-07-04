const express = require('express');
const mysql = require('mysql2/promise');
const app = express();
const port = process.env.PORT || 3000;

app.get('/', async (req, res) => {
  let dbStatus = '❌ Failed';
  let errorMsg = '';
  try {
    const connection = await mysql.createConnection({
      host: process.env.DB_HOST || 'localhost',
      port: process.env.DB_PORT || 3306,
      user: process.env.DB_USERNAME || 'user',
      password: process.env.DB_PASSWORD || 'password',
      database: process.env.DB_DATABASE || 'testdb'
    });
    await connection.connect();
    dbStatus = '✅ Connected';
    await connection.end();
  } catch (error) {
    console.error('Database connection failed:', error.message, new Date().toISOString());
    errorMsg = error.message;
  }
  res.status(200).send(`Hello from Sprint Freight CI/CD! Database: ${dbStatus}<br/>${errorMsg}`);
});

app.get('/health', (req, res) => {
  console.log('Health check called at', new Date().toISOString());
  res.status(200).send('OK');
});

process.on('uncaughtException', (error) => {
  console.error('Uncaught Exception:', error.message, new Date().toISOString());
});

process.on('unhandledRejection', (reason, promise) => {
  console.error('Unhandled Rejection:', reason.message, new Date().toISOString());
});

if (process.env.NODE_ENV !== 'test') {
  app.listen(port, () => {
    console.log(`Server running on port ${port}`, new Date().toISOString());
  });
}

module.exports = app;