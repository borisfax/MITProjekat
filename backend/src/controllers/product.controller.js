const Product = require('../models/Product.model');

// @desc    Get all products
// @route   GET /api/products
// @access  Public
exports.getAllProducts = async (req, res) => {
  try {
    const { category, available } = req.query;
    
    // Build filter
    const filter = {};
    if (category) {
      filter.category = category;
    }
    if (available !== undefined) {
      filter.isAvailable = available === 'true';
    }

    const products = await Product.find(filter).sort({ createdAt: -1 });
    const productsData = products.map(product => product.toClientJSON());

    res.status(200).json({
      success: true,
      message: 'Proizvodi uspješno preuzeti',
      data: productsData
    });
  } catch (error) {
    console.error('Error in getAllProducts:', error);
    res.status(500).json({
      success: false,
      message: 'Greška pri preuzimanju proizvoda',
      error: error.message
    });
  }
};

// @desc    Get single product by ID
// @route   GET /api/products/:id
// @access  Public
exports.getProductById = async (req, res) => {
  try {
    const { id } = req.params;

    const product = await Product.findById(id);

    if (!product) {
      return res.status(404).json({
        success: false,
        message: 'Proizvod nije pronađen'
      });
    }

    res.status(200).json({
      success: true,
      message: 'Proizvod uspješno preuzet',
      data: product.toClientJSON()
    });
  } catch (error) {
    console.error('Error in getProductById:', error);
    
    // Handle invalid ObjectId
    if (error.name === 'CastError') {
      return res.status(400).json({
        success: false,
        message: 'Nevažeći ID proizvoda'
      });
    }

    res.status(500).json({
      success: false,
      message: 'Greška pri preuzimanju proizvoda',
      error: error.message
    });
  }
};

// @desc    Get products by category
// @route   GET /api/products/category/:category
// @access  Public
exports.getProductsByCategory = async (req, res) => {
  try {
    const { category } = req.params;

    const products = await Product.find({ category }).sort({ createdAt: -1 });
    const productsData = products.map(product => product.toClientJSON());

    res.status(200).json({
      success: true,
      message: `Proizvodi iz kategorije "${category}" uspješno preuzeti`,
      data: productsData
    });
  } catch (error) {
    console.error('Error in getProductsByCategory:', error);
    res.status(500).json({
      success: false,
      message: 'Greška pri preuzimanju proizvoda',
      error: error.message
    });
  }
};

// @desc    Create new product
// @route   POST /api/products
// @access  Private/Admin
exports.createProduct = async (req, res) => {
  try {
    const { name, description, price, oldPrice, category, imageUrl, stock, isAvailable } = req.body;

    // Validation
    if (!name || !description || !price || !category || !imageUrl) {
      return res.status(400).json({
        success: false,
        message: 'Sva obavezna polja moraju biti popunjena'
      });
    }

    if (price < 0) {
      return res.status(400).json({
        success: false,
        message: 'Cijena ne može biti negativna'
      });
    }

    if (oldPrice && oldPrice < 0) {
      return res.status(400).json({
        success: false,
        message: 'Stara cijena ne može biti negativna'
      });
    }

    if (stock !== undefined && stock < 0) {
      return res.status(400).json({
        success: false,
        message: 'Količina ne može biti negativna'
      });
    }

    // Create product
    const product = await Product.create({
      name,
      description,
      price,
      oldPrice: oldPrice || null,
      category,
      imageUrl,
      stock: stock || 0,
      isAvailable: isAvailable !== undefined ? isAvailable : true
    });

    res.status(201).json({
      success: true,
      message: 'Proizvod uspješno kreiran',
      data: product.toClientJSON()
    });
  } catch (error) {
    console.error('Error in createProduct:', error);

    // Handle validation errors
    if (error.name === 'ValidationError') {
      const messages = Object.values(error.errors).map(err => err.message);
      return res.status(400).json({
        success: false,
        message: messages.join(', ')
      });
    }

    res.status(500).json({
      success: false,
      message: 'Greška pri kreiranju proizvoda',
      error: error.message
    });
  }
};

// @desc    Update product
// @route   PUT /api/products/:id
// @access  Private/Admin
exports.updateProduct = async (req, res) => {
  try {
    const { id } = req.params;
    const { name, description, price, oldPrice, category, imageUrl, stock, isAvailable } = req.body;

    // Find product
    const product = await Product.findById(id);

    if (!product) {
      return res.status(404).json({
        success: false,
        message: 'Proizvod nije pronađen'
      });
    }

    // Validation
    if (price !== undefined && price < 0) {
      return res.status(400).json({
        success: false,
        message: 'Cijena ne može biti negativna'
      });
    }

    if (oldPrice !== undefined && oldPrice < 0) {
      return res.status(400).json({
        success: false,
        message: 'Stara cijena ne može biti negativna'
      });
    }

    if (stock !== undefined && stock < 0) {
      return res.status(400).json({
        success: false,
        message: 'Količina ne može biti negativna'
      });
    }

    // Update fields
    if (name !== undefined) product.name = name;
    if (description !== undefined) product.description = description;
    if (price !== undefined) product.price = price;
    if (oldPrice !== undefined) product.oldPrice = oldPrice;
    if (category !== undefined) product.category = category;
    if (imageUrl !== undefined) product.imageUrl = imageUrl;
    if (stock !== undefined) product.stock = stock;
    if (isAvailable !== undefined) product.isAvailable = isAvailable;

    await product.save();

    res.status(200).json({
      success: true,
      message: 'Proizvod uspješno ažuriran',
      data: product.toClientJSON()
    });
  } catch (error) {
    console.error('Error in updateProduct:', error);

    // Handle invalid ObjectId
    if (error.name === 'CastError') {
      return res.status(400).json({
        success: false,
        message: 'Nevažeći ID proizvoda'
      });
    }

    // Handle validation errors
    if (error.name === 'ValidationError') {
      const messages = Object.values(error.errors).map(err => err.message);
      return res.status(400).json({
        success: false,
        message: messages.join(', ')
      });
    }

    res.status(500).json({
      success: false,
      message: 'Greška pri ažuriranju proizvoda',
      error: error.message
    });
  }
};

// @desc    Delete product
// @route   DELETE /api/products/:id
// @access  Private/Admin
exports.deleteProduct = async (req, res) => {
  try {
    const { id } = req.params;

    const product = await Product.findById(id);

    if (!product) {
      return res.status(404).json({
        success: false,
        message: 'Proizvod nije pronađen'
      });
    }

    await Product.findByIdAndDelete(id);

    res.status(200).json({
      success: true,
      message: 'Proizvod uspješno obrisan'
    });
  } catch (error) {
    console.error('Error in deleteProduct:', error);

    // Handle invalid ObjectId
    if (error.name === 'CastError') {
      return res.status(400).json({
        success: false,
        message: 'Nevažeći ID proizvoda'
      });
    }

    res.status(500).json({
      success: false,
      message: 'Greška pri brisanju proizvoda',
      error: error.message
    });
  }
};
