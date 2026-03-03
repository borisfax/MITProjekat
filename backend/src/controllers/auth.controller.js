const jwt = require('jsonwebtoken');
const User = require('../models/User.model');

// Generisanje JWT tokena
const generateToken = (userId) => {
  return jwt.sign(
    { id: userId },
    process.env.JWT_SECRET || 'candy_shop_secret_key_2024',
    { expiresIn: '30d' }
  );
};

// @desc    Registracija novog korisnika
// @route   POST /api/auth/register
// @access  Public
const register = async (req, res) => {
  try {
    const { name, email, password, phone, address } = req.body;

    // Validacija
    if (!name || !email || !password) {
      return res.status(400).json({
        success: false,
        message: 'Ime, email i lozinka su obavezni',
      });
    }

    // Provera da li korisnik već postoji
    const existingUser = await User.findOne({ email });
    if (existingUser) {
      return res.status(400).json({
        success: false,
        message: 'Korisnik sa ovim emailom već postoji',
      });
    }

    // Kreiranje korisnika
    const user = await User.create({
      name,
      email,
      password,
      phone: phone || '',
      address: address || '',
    });

    // Generisanje tokena
    const token = generateToken(user._id);

    res.status(201).json({
      success: true,
      message: 'Korisnik uspešno registrovan',
      data: {
        user: {
          id: user._id,
          name: user.name,
          email: user.email,
          phone: user.phone,
          address: user.address,
          role: user.role,
        },
        token,
      },
    });
  } catch (error) {
    console.error('Register error:', error);
    res.status(500).json({
      success: false,
      message: 'Greška pri registraciji',
      error: error.message,
    });
  }
};

// @desc    Login korisnika
// @route   POST /api/auth/login
// @access  Public
const login = async (req, res) => {
  try {
    const { email, password } = req.body;

    // Validacija
    if (!email || !password) {
      return res.status(400).json({
        success: false,
        message: 'Email i lozinka su obavezni',
      });
    }

    // Pronađi korisnika (uključi password jer je select: false)
    const user = await User.findOne({ email }).select('+password');
    if (!user) {
      return res.status(401).json({
        success: false,
        message: 'Pogrešan email ili lozinka',
      });
    }

    // Provera lozinke
    const isPasswordValid = await user.comparePassword(password);
    if (!isPasswordValid) {
      return res.status(401).json({
        success: false,
        message: 'Pogrešan email ili lozinka',
      });
    }

    // Generisanje tokena
    const token = generateToken(user._id);

    res.status(200).json({
      success: true,
      message: 'Uspešno logovanje',
      data: {
        user: {
          id: user._id,
          name: user.name,
          email: user.email,
          phone: user.phone,
          address: user.address,
          role: user.role,
        },
        token,
      },
    });
  } catch (error) {
    console.error('Login error:', error);
    res.status(500).json({
      success: false,
      message: 'Greška pri logovanju',
      error: error.message,
    });
  }
};

// @desc    Preuzimanje profila trenutnog korisnika
// @route   GET /api/auth/profile
// @access  Private (zahteva token)
const getProfile = async (req, res) => {
  try {
    const user = await User.findById(req.user.id);

    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'Korisnik nije pronađen',
      });
    }

    res.status(200).json({
      success: true,
      data: {
        user: {
          id: user._id,
          name: user.name,
          email: user.email,
          phone: user.phone,
          address: user.address,
          role: user.role,
        },
      },
    });
  } catch (error) {
    console.error('Get profile error:', error);
    res.status(500).json({
      success: false,
      message: 'Greška pri preuzimanju profila',
      error: error.message,
    });
  }
};

module.exports = {
  register,
  login,
  getProfile,
};
