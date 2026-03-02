// Express app konfiguracija
const express = require('express');
const cors = require('cors');
const healthRoutes = require('./routes/health.routes');
const errorHandler = require('./middleware/error.middleware');

const app = express();

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Rute
app.use('/api', healthRoutes);

// Global error handler
app.use(errorHandler);

module.exports = app;
