const mongoose = require('mongoose');

const productSchema = new mongoose.Schema({
  name: {
    type: String,
    required: [true, 'Naziv proizvoda je obavezan'],
    trim: true
  },
  description: {
    type: String,
    required: [true, 'Opis proizvoda je obavezan']
  },
  price: {
    type: Number,
    required: [true, 'Cijena je obavezna'],
    min: [0, 'Cijena ne može biti negativna']
  },
  oldPrice: {
    type: Number,
    min: [0, 'Stara cijena ne može biti negativna'],
    default: null
  },
  category: {
    type: String,
    required: [true, 'Kategorija je obavezna'],
    enum: ['Bombone', 'Čokolada', 'Mafini'],
    default: 'Bombone'
  },
  imageUrl: {
    type: String,
    required: [true, 'Slika proizvoda je obavezna']
  },
  stock: {
    type: Number,
    default: 0,
    min: [0, 'Količina ne može biti negativna']
  },
  isAvailable: {
    type: Boolean,
    default: true
  }
}, {
  timestamps: true
});

// Metoda za konverziju u format za frontend
productSchema.methods.toClientJSON = function() {
  return {
    id: this._id.toString(),
    name: this.name,
    description: this.description,
    price: this.price,
    oldPrice: this.oldPrice,
    category: this.category,
    imageUrl: this.imageUrl,
    stock: this.stock,
    isAvailable: this.isAvailable,
    createdAt: this.createdAt.toISOString(),
    updatedAt: this.updatedAt.toISOString()
  };
};

const Product = mongoose.model('Product', productSchema);

module.exports = Product;
