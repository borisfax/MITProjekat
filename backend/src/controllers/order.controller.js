const Order = require('../models/Order.model');
const User = require('../models/User.model');

// Helper function to check if user is owner or admin
const isOwnerOrAdmin = (userId, reqUserId, userRole) => {
  return userRole === 'admin' || userId === reqUserId;
};

// @desc    Create new order
// @route   POST /api/orders
// @access  Private (authenticated users)
exports.createOrder = async (req, res, next) => {
  try {
    const { items, totalPrice, shippingAddress, shippingPhone, paymentMethod } = req.body;

    // Validate required fields
    if (!items || !Array.isArray(items) || items.length === 0) {
      return res.status(400).json({
        success: false,
        message: 'Наруџбина мора имати најмање један артикал',
      });
    }

    if (!shippingAddress) {
      return res.status(400).json({
        success: false,
        message: 'Адреса је обавезна',
      });
    }

    if (!shippingPhone) {
      return res.status(400).json({
        success: false,
        message: 'Телефон је обавезан',
      });
    }

    if (!paymentMethod) {
      return res.status(400).json({
        success: false,
        message: 'Начин плаћања је обавезан',
      });
    }

    // Create order
    const order = await Order.create({
      userId: req.user.id,
      items,
      totalPrice: totalPrice || 0,
      status: 'pending',
      shippingAddress,
      shippingPhone,
      paymentMethod,
    });

    // Convert to client format
    const orderData = order.toClientJSON();

    res.status(201).json({
      success: true,
      message: 'Наруџбина успешно креирана',
      data: orderData,
    });
  } catch (error) {
    console.error('Error creating order:', error);
    res.status(500).json({
      success: false,
      message: 'Грешка при креирању наруџбине',
      error: error.message,
    });
  }
};

// @desc    Get user's orders
// @route   GET /api/orders/user/:userId
// @access  Private (owner or admin)
exports.getUserOrders = async (req, res, next) => {
  try {
    const { userId } = req.params;

    // Check permission
    if (!isOwnerOrAdmin(userId, req.user.id, req.user.role)) {
      return res.status(403).json({
        success: false,
        message: 'Немате приступ овим наруџбинама',
      });
    }

    // Get orders
    const orders = await Order.find({ userId }).sort({ createdAt: -1 });

    // Convert to client format
    const ordersData = orders.map((order) => order.toClientJSON());

    res.status(200).json({
      success: true,
      data: ordersData,
    });
  } catch (error) {
    console.error('Error fetching orders:', error);
    res.status(500).json({
      success: false,
      message: 'Грешка при учитавању наруџбина',
      error: error.message,
    });
  }
};

// @desc    Get single order
// @route   GET /api/orders/:id
// @access  Private (owner or admin)
exports.getOrderById = async (req, res, next) => {
  try {
    const { id } = req.params;

    // Get order
    const order = await Order.findById(id);

    if (!order) {
      return res.status(404).json({
        success: false,
        message: 'Наруџбина није пронађена',
      });
    }

    // Check permission
    if (!isOwnerOrAdmin(order.userId.toString(), req.user.id, req.user.role)) {
      return res.status(403).json({
        success: false,
        message: 'Немате приступ овој наруџбини',
      });
    }

    // Convert to client format
    const orderData = order.toClientJSON();

    res.status(200).json({
      success: true,
      data: orderData,
    });
  } catch (error) {
    console.error('Error fetching order:', error);
    res.status(500).json({
      success: false,
      message: 'Грешка при учитавању наруџбине',
      error: error.message,
    });
  }
};
