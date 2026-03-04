const User = require('../models/User.model');
const Order = require('../models/Order.model');

// @desc    Get all users (ADMIN ONLY)
// @route   GET /api/users
// @access  Private/Admin
exports.getAllUsers = async (req, res) => {
  try {
    const users = await User.find()
      .select('-password')
      .sort({ createdAt: -1 });

    res.status(200).json({
      success: true,
      count: users.length,
      data: users,
    });
  } catch (error) {
    console.error('Error fetching users:', error);
    res.status(500).json({
      success: false,
      message: 'Грешка при учитавању корисника',
      error: error.message,
    });
  }
};

// @desc    Get user by ID
// @route   GET /api/users/:id
// @access  Private/Admin
exports.getUserById = async (req, res) => {
  try {
    const { id } = req.params;

    const user = await User.findById(id).select('-password');

    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'Корисник није пронађен',
      });
    }

    res.status(200).json({
      success: true,
      data: user,
    });
  } catch (error) {
    console.error('Error fetching user:', error);

    if (error.name === 'CastError') {
      return res.status(400).json({
        success: false,
        message: 'Невважећи ID корисника',
      });
    }

    res.status(500).json({
      success: false,
      message: 'Грешка при учитавању корисника',
      error: error.message,
    });
  }
};

// @desc    Update user (ADMIN ONLY)
// @route   PUT /api/users/:id
// @access  Private/Admin
exports.updateUser = async (req, res) => {
  try {
    const { id } = req.params;
    const { name, email, role, phone, address } = req.body;

    console.log('🔵 UPDATE USER REQUEST');
    console.log('User ID:', id);
    console.log('Body:', { name, email, role, phone, address });
    console.log('Admin role:', req.user.role);

    // Validate role
    if (role && !['user', 'admin'].includes(role)) {
      return res.status(400).json({
        success: false,
        message: 'Улога мора бити "user" или "admin"',
      });
    }

    const updateData = {};
    if (name) updateData.name = name;
    if (email) updateData.email = email;
    if (role) updateData.role = role;
    if (phone !== undefined) updateData.phone = phone;
    if (address !== undefined) updateData.address = address;

    console.log('Update data:', updateData);

    const user = await User.findByIdAndUpdate(id, updateData, {
      new: true,
      runValidators: true,
    }).select('-password');

    if (!user) {
      console.log('❌ User not found:', id);
      return res.status(404).json({
        success: false,
        message: 'Корисник није пронађен',
      });
    }

    console.log('✅ User updated successfully');
    res.status(200).json({
      success: true,
      message: 'Корисник је ажуриран',
      data: user,
    });
  } catch (error) {
    console.error('Error updating user:', error);
    res.status(500).json({
      success: false,
      message: 'Грешка при ажурирању корисника',
      error: error.message,
    });
  }
};

// @desc    Delete user (ADMIN ONLY)
// @route   DELETE /api/users/:id
// @access  Private/Admin
exports.deleteUser = async (req, res) => {
  try {
    const { id } = req.params;

    console.log('� DELETE USER REQUEST');
    console.log('👤 User ID to delete:', id);
    console.log('🔐 Admin email:', req.user?.email);
    console.log('🔐 Admin role:', req.user?.role);
    console.log('📍 Full req.user:', req.user);

    // Provera da li je ID validan
    if (!id || id.length !== 24) {
      console.log('❌ Invalid ID format:', id);
      return res.status(400).json({
        success: false,
        message: 'Невважећи формат ID-а',
      });
    }

    // Prvo obriši sve narudžbe korisnika (cascade delete)
    console.log('🗑️  Deleting all orders for user:', id);
    const deleteOrdersResult = await Order.deleteMany({ userId: id });
    console.log(`✅ Deleted ${deleteOrdersResult.deletedCount} orders`);

    const user = await User.findByIdAndDelete(id);

    if (!user) {
      console.log('❌ User not found in database:', id);
      return res.status(404).json({
        success: false,
        message: 'Корисник није пронађен',
      });
    }

    console.log('✅ User deleted successfully:', user.email);
    res.status(200).json({
      success: true,
      message: 'Корисник је обрисан',
    });
  } catch (error) {
    console.error('❌ Error in deleteUser:', error.message);
    console.error('Stack:', error.stack);
    res.status(500).json({
      success: false,
      message: 'Грешка при брисању корисника',
      error: error.message,
    });
  }
};

// @desc    Get admin statistics
// @route   GET /api/users/stats/admin
// @access  Private/Admin
exports.getAdminStats = async (req, res) => {
  try {
    const totalUsers = await User.countDocuments();
    const adminCount = await User.countDocuments({ role: 'admin' });
    const userCount = await User.countDocuments({ role: 'user' });

    res.status(200).json({
      success: true,
      data: {
        totalUsers,
        adminCount,
        userCount,
      },
    });
  } catch (error) {
    console.error('Error fetching stats:', error);
    res.status(500).json({
      success: false,
      message: 'Грешка при учитавању статистике',
      error: error.message,
    });
  }
};
