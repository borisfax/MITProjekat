const express = require('express');
const router = express.Router();
const orderController = require('../controllers/order.controller');
const { protect, admin } = require('../middleware/auth.middleware');

// Create new order (protected)
router.post('/', protect, orderController.createOrder);

// Get all orders (admin only)
router.get('/', protect, admin, orderController.getAllOrders);

// Get user's orders (protected)
router.get('/user/:userId', protect, orderController.getUserOrders);

// Update order status (admin only)
router.put('/:id/status', protect, admin, orderController.updateOrderStatus);

// Get single order (protected)
router.get('/:id', protect, orderController.getOrderById);

module.exports = router;
