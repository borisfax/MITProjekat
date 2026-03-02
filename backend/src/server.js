// Server startup
require('dotenv').config();
const app = require('./app');
const { connectDB } = require('./config/db');

const PORT = process.env.PORT || 5000;

// Kreni sa serverom
const startServer = async () => {
  try {
    await connectDB();
    
    app.listen(PORT, () => {
      console.log(`🍬 Candy Shop API running on http://localhost:${PORT}`);
    });
  } catch (error) {
    console.error('Greška pri pokretanju:', error);
    process.exit(1);
  }
};

startServer();
