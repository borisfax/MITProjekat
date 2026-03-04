const jwt = require('jsonwebtoken');
const User = require('../models/User.model');

// Middleware za zaštitu ruta - proverava JWT token
const protect = async (req, res, next) => {
  try {
    let token;

    console.log('🔐 AUTH MIDDLEWARE - Checking token...');
    console.log('📍 URL:', req.method, req.path);
    console.log('📋 Headers:', Object.keys(req.headers));

    // Proveri da li postoji Authorization header
    if (
      req.headers.authorization &&
      req.headers.authorization.startsWith('Bearer')
    ) {
      // Izvuci token iz "Bearer <token>"
      token = req.headers.authorization.split(' ')[1];
      console.log('✅ Token found, length:', token?.length);
    }

    // Proveri da li postoji token
    if (!token) {
      console.log('❌ No token provided');
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

      console.log('✅ Token verified, user ID:', decoded.id);

      // Dodaj korisnika u request
      req.user = await User.findById(decoded.id).select('-password');

      console.log('✅ User found:', req.user?.email, 'Role:', req.user?.role);

      if (!req.user) {
        console.log('❌ User not found in database');
        return res.status(401).json({
          success: false,
          message: 'Korisnik više ne postoji',
        });
      }

      next();
    } catch (error) {
      console.log('❌ Token verification failed:', error.message);
      return res.status(401).json({
        success: false,
        message: 'Token nije validan',
      });
    }
  } catch (error) {
    console.error('❌ Auth middleware error:', error);
    res.status(500).json({
      success: false,
      message: 'Greška pri autentifikaciji',
      error: error.message,
    });
  }
};

// Middleware za proveru admin role
const admin = (req, res, next) => {
  console.log('🔐 ADMIN MIDDLEWARE - Checking role...');
  console.log('👤 User:', req.user?.email, 'Role:', req.user?.role);

  if (req.user && req.user.role === 'admin') {
    console.log('✅ User is admin, allowing access');
    next();
  } else {
    console.log('❌ User is not admin, access denied');
    res.status(403).json({
      success: false,
      message: 'Pristup dozvoljen samo administratorima',
    });
  }
};

module.exports = { protect, admin };
