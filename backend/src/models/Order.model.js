const mongoose = require('mongoose');

// Order Item Schema (embedded subdocument)
const orderItemSchema = new mongoose.Schema(
  {
    productId: {
      type: String,
      required: [true, 'Product ID je obavezno'],
    },
    productName: {
      type: String,
      required: [true, 'Product name je obavezno'],
    },
    price: {
      type: Number,
      required: [true, 'Price je obavezna'],
      min: [0, 'Price ne može biti negativna'],
    },
    quantity: {
      type: Number,
      required: [true, 'Quantity je obavezna'],
      min: [1, 'Quantity mora biti najmanje 1'],
    },
  },
  { _id: false }
);

// Order Schema
const orderSchema = new mongoose.Schema(
  {
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: [true, 'User ID je obavezno'],
    },
    items: {
      type: [orderItemSchema],
      validate: {
        validator: (items) => Array.isArray(items) && items.length > 0,
        message: 'Narudžbina mora imati najmanje jedan artikal',
      },
      required: [true, 'Items su obavezni'],
    },
    totalPrice: {
      type: Number,
      required: [true, 'Total price je obavezna'],
      min: [0, 'Total price ne može biti negativna'],
    },
    status: {
      type: String,
      enum: {
        values: ['pending', 'confirmed', 'shipped', 'delivered'],
        message: 'Invalid order status',
      },
      default: 'pending',
    },
    shippingAddress: {
      type: String,
      required: [true, 'Shipping address je obavezna'],
    },
    shippingPhone: {
      type: String,
      required: [true, 'Shipping phone je obavezan'],
    },
    paymentMethod: {
      type: String,
      enum: {
        values: ['cash', 'card'],
        message: 'Invalid payment method',
      },
      required: [true, 'Payment method je obavezan'],
    },
  },
  {
    timestamps: true,
  }
);

// Convert MongoDB response to client format
orderSchema.methods.toClientJSON = function () {
  return {
    id: this._id.toString(),
    userId: this.userId.toString(),
    items: this.items,
    totalPrice: this.totalPrice,
    status: this.status,
    shippingAddress: this.shippingAddress,
    shippingPhone: this.shippingPhone,
    paymentMethod: this.paymentMethod,
    createdAt: this.createdAt?.toISOString(),
    updatedAt: this.updatedAt?.toISOString(),
  };
};

module.exports = mongoose.model('Order', orderSchema);
