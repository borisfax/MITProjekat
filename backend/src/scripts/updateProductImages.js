// Skripta za ažuriranje slika proizvoda sa pravim URL-ovima
require('dotenv').config();
const mongoose = require('mongoose');
const Product = require('../models/Product.model');
const { connectDB } = require('../config/db');

const updateProductImages = async () => {
  try {
    // Konektuj se na bazu
    await connectDB();
    console.log('Povezan sa MongoDB');

    // Uzmi sve proizvode
    const products = await Product.find({});
    console.log(`Pronađeno ${products.length} proizvoda za ažuriranje`);

    // Ažuriraj svaki proizvod sa novim URL-om slike
    for (let i = 0; i < products.length; i++) {
      const product = products[i];
      // Koristi picsum.photos sa različitim seed brojevima za različite slike
      const newImageUrl = `https://picsum.photos/seed/${product._id}/300/300`;
      
      product.imageUrl = newImageUrl;
      await product.save();
      
      console.log(`✅ Ažuriran proizvod: ${product.name} - ${newImageUrl}`);
    }

    console.log(`\n🎉 Uspešno ažurirano ${products.length} proizvoda sa novim slikama!`);
    process.exit(0);
  } catch (error) {
    console.error('❌ Greška pri ažuriranju slika:', error);
    process.exit(1);
  }
};

updateProductImages();
