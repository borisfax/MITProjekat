const express = require('express');
const router = express.Router();
const orderController = require('../controllers/order.controller');
const { protect } = require('../middleware/auth.middleware');

// Create new order (protected)
router.post('/', protect, orderController.createOrder);

// Get user's orders (protected)
router.get('/user/:userId', protect, orderController.getUserOrders);

// Get single order (protected)
router.get('/:id', protect, orderController.getOrderById);

module.exports = router;
