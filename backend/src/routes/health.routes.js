// Health check ruta
const express = require('express');
const router = express.Router();

router.get('/health', (req, res) => {
  res.json({
    status: 'ok',
    app: 'Candy Shop API',
    timestamp: new Date().toISOString(),
  });
});

module.exports = router;
