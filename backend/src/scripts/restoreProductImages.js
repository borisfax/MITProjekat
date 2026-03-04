// Skripta za vraćanje originalnih lokalnih putanja slika
require('dotenv').config();
const mongoose = require('mongoose');
const Product = require('../models/Product.model');
const { connectDB } = require('../config/db');

// Mapiranje naziva proizvoda na originalne putanje slika
const originalImages = {
  'Voćne šećerne trakice': 'assets/images/product_1.jpg',
  'Gumene Coca-Cola bombone': 'assets/images/product_5.jpg',
  'Chupa Chups lizalice': 'assets/images/product_11.jpg',
  'Miješane gumene bombone': 'assets/images/product_12.jpg',
  'Voćne bombone mix': 'assets/images/product_21.jpg',
  'Gumene bombone premium': 'assets/images/product_23.jpg',
  'Šarene žele bombone': 'assets/images/product_3.jpg',
  'Voćni bombon mix': 'assets/images/product_6.jpg',
  'Gumene bombone classic': 'assets/images/product_8.jpg',
  'Bombone sa posipom': 'assets/images/product_13.jpg',
  'Premium voćne bombone': 'assets/images/product_17.jpg',
  'Šarene mini bombone': 'assets/images/product_22.jpg',
  'Bombone deluxe mix': 'assets/images/product_25.jpg',
  'Bombone voćna eksplozija': 'assets/images/product_28.jpg',
  'Bombone premium izbor': 'assets/images/product_31.jpg',
  'Belgijske čoko školjke': 'assets/images/product_9.jpg',
  'Čoko kikiriki štanglica': 'assets/images/product_10.jpg',
  'Čokoladne hrskave kuglice': 'assets/images/product_15.jpg',
  'Čoko karamela štanglica': 'assets/images/product_16.jpg',
  'Čokoladne pločice sa voćem': 'assets/images/product_18.jpg',
  'Mliječna čokolada classic': 'assets/images/product_19.jpg',
  'Čoko praline selection': 'assets/images/product_27.jpg',
  'Premium čoko praline': 'assets/images/product_30.jpg',
  'Tamna čokolada premium': 'assets/images/product_33.jpg',
  'Čokoladni mix specijal': 'assets/images/product_35.jpg',
  'Vanila mafini sa kremom': 'assets/images/product_2.jpg',
  'Čokoladno-vanila mafini': 'assets/images/product_4.jpg',
  'Čokoladne mafin kuglice': 'assets/images/product_7.jpg',
  'Čokoladne mafin kuglice sa posipom': 'assets/images/product_14.jpg',
  'Voćni mafini mix': 'assets/images/product_26.jpg',
  'Čokoladni mafini deluxe': 'assets/images/product_29.jpg',
  'Mafini sa vanila kremom': 'assets/images/product_32.jpg',
  'Premium mafini izbor': 'assets/images/product_36.jpg'
};

const restoreProductImages = async () => {
  try {
    // Konektuj se na bazu
    await connectDB();
    console.log('Povezan sa MongoDB');

    // Uzmi sve proizvode
    const products = await Product.find({});
    console.log(`Pronađeno ${products.length} proizvoda za vraćanje originalnih slika`);

    let updated = 0;
    for (const product of products) {
      const originalPath = originalImages[product.name];
      
      if (originalPath) {
        product.imageUrl = originalPath;
        await product.save();
        console.log(`✅ Vraćen proizvod: ${product.name} - ${originalPath}`);
        updated++;
      } else {
        console.log(`⚠️  Nije pronađena originalna putanja za: ${product.name}`);
      }
    }

    console.log(`\n🎉 Uspešno vraćeno ${updated} proizvoda na originalne slike!`);
    process.exit(0);
  } catch (error) {
    console.error('❌ Greška pri vraćanju slika:', error);
    process.exit(1);
  }
};

restoreProductImages();
