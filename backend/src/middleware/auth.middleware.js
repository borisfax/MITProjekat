const jwt = require('jsonwebtoken');
const User = require('../models/User.model');

// Middleware za zaštitu ruta - proverava JWT token
const protect = async (req, res, next) => {
  try {
    let token;

    // Proveri da li postoji Authorization header
    if (
      req.headers.authorization &&
      req.headers.authorization.startsWith('Bearer')
    ) {
      // Izvuci token iz "Bearer <token>"
      token = req.headers.authorization.split(' ')[1];
    }

    // Proveri da li postoji token
    if (!token) {
      return res.status(401).json({
        success: false,
        message: 'Niste autorizovani. Token nije prosleđen.',
      });
    }

    try {
      // Verifikuj token
      const decoded = jwt.verify(
        token,
        process.env.JWT_SECRET || 'candy_shop_secret_key_2024'
      );

      // Dodaj korisnika u request
      req.user = await User.findById(decoded.id).select('-password');

      if (!req.user) {
        return res.status(401).json({
          success: false,
          message: 'Korisnik više ne postoji',
        });
      }

      next();
    } catch (error) {
      return res.status(401).json({
        success: false,
        message: 'Token nije validan',
      });
    }
  } catch (error) {
    console.error('Auth middleware error:', error);
    res.status(500).json({
      success: false,
      message: 'Greška pri autentifikaciji',
      error: error.message,
    });
  }
};

// Middleware za proveru admin role
const admin = (req, res, next) => {
  if (req.user && req.user.role === 'admin') {
    next();
  } else {
    res.status(403).json({
      success: false,
      message: 'Pristup dozvoljen samo administratorima',
    });
  }
};

module.exports = { protect, admin };
