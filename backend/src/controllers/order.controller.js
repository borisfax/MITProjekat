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

// @desc    Get all orders (ADMIN ONLY)
// @route   GET /api/orders
// @access  Private/Admin
exports.getAllOrders = async (req, res, next) => {
  try {
    const { status } = req.query;
    
    // Build filter
    const filter = {};
    if (status) {
      filter.status = status;
    }

    // Get all orders sorted by newest first
    // Use lean() to avoid populate errors with deleted users
    const orders = await Order.find(filter)
      .lean()
      .sort({ createdAt: -1 });

    // Separately fetch user info for each order
    const ordersData = [];
    for (const order of orders) {
      try {
        const User = require('../models/User.model');
        const userData = await User.findById(order.userId).select('name email phone').lean();
        
        // Convert MongoDB _id to id and add user info as separate fields
        const orderObj = {
          id: order._id.toString(),
          ...order,
          userId: userData ? userData._id.toString() : null,
          userName: userData ? userData.name : null,
          userEmail: userData ? userData.email : null,
          userPhone: userData ? userData.phone : null,
        };
        delete orderObj._id;
        
        ordersData.push(orderObj);
      } catch (err) {
        console.warn('⚠️  Could not fetch user for order:', order._id);
        const orderObj = {
          id: order._id.toString(),
          ...order,
          userId: null,
          userName: null,
          userEmail: null,
          userPhone: null,
        };
        delete orderObj._id;
        ordersData.push(orderObj);
      }
    }

    res.status(200).json({
      success: true,
      count: ordersData.length,
      data: ordersData,
    });
  } catch (error) {
    console.error('Error fetching all orders:', error);
    res.status(500).json({
      success: false,
      message: 'Грешка при учитавању наруџбина',
      error: error.message,
    });
  }
};

// @desc    Update order status (ADMIN ONLY)
// @route   PUT /api/orders/:id/status
// @access  Private/Admin
exports.updateOrderStatus = async (req, res, next) => {
  try {
    const { id } = req.params;
    const { status } = req.body;

    const validStatuses = ['pending', 'processing', 'shipped', 'delivered', 'cancelled'];
    if (!status || !validStatuses.includes(status)) {
      return res.status(400).json({
        success: false,
        message: `Статус мора бити један од: ${validStatuses.join(', ')}`,
      });
    }

    const order = await Order.findByIdAndUpdate(
      id,
      { status },
      { new: true, runValidators: true }
    );

    if (!order) {
      return res.status(404).json({
        success: false,
        message: 'Наруџбина није пронађена',
      });
    }

    const orderData = order.toClientJSON();

    res.status(200).json({
      success: true,
      message: 'Статус наруџбине је ажуриран',
      data: orderData,
    });
  } catch (error) {
    console.error('Error updating order status:', error);
    res.status(500).json({
      success: false,
      message: 'Грешка при ажурирању статуса наруџбине',
      error: error.message,
    });
  }
};
