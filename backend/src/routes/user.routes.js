const express = require('express');
const router = express.Router();
const userController = require('../controllers/user.controller');
const { protect, admin } = require('../middleware/auth.middleware');

// Get admin statistics (admin only) - MORA biti PRVO pre :id ruta
router.get('/stats/admin', protect, admin, userController.getAdminStats);

// Get all users (admin only)
router.get('/', protect, admin, userController.getAllUsers);

// Get user by ID (admin only)
router.get('/:id', protect, admin, userController.getUserById);

// Update user (admin only)
router.put('/:id', protect, admin, userController.updateUser);

// Delete user (admin only)
router.delete('/:id', protect, admin, userController.deleteUser);

module.exports = router;
