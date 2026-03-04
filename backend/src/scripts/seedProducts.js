// Seed script za dodavanje proizvoda u bazu
require('dotenv').config();
const mongoose = require('mongoose');
const Product = require('../models/Product.model');
const { connectDB } = require('../config/db');

const products = [
  // Bombone
  {
    name: 'Voćne šećerne trakice',
    description: 'Slatke voćne trakice u raznim ukusima. Savršene za ljubitelje klasičnih bombona sa voćnim ukusima.',
    price: 250,
    category: 'Bombone',
    imageUrl: 'assets/images/product_1.jpg',
    stock: 100,
    isAvailable: true
  },
  {
    name: 'Gumene Coca-Cola bombone',
    description: 'Gumene bombone sa ukusom Coca-Cole. Osvježavajuće i slatke, idealne za ljubitelje ovog omiljenog napitka.',
    price: 230,
    category: 'Bombone',
    imageUrl: 'assets/images/product_5.jpg',
    stock: 100,
    isAvailable: true
  },
  {
    name: 'Chupa Chups lizalice',
    description: 'Kultne Chupa Chups lizalice u različitim voćnim ukusima. Omiljene lizalice generacija!',
    price: 150,
    category: 'Bombone',
    imageUrl: 'assets/images/product_11.jpg',
    stock: 100,
    isAvailable: true
  },
  {
    name: 'Miješane gumene bombone',
    description: 'Šareni mix gumenih bombona sa raznim ukusima. Zabavno pakovanje za sve uzraste.',
    price: 270,
    category: 'Bombone',
    imageUrl: 'assets/images/product_12.jpg',
    stock: 100,
    isAvailable: true
  },
  {
    name: 'Voćne bombone mix',
    description: 'Šareni miks voćnih bombona punog ukusa, idealan za ljubitelje slatkiša svih uzrasta.',
    price: 290,
    category: 'Bombone',
    imageUrl: 'assets/images/product_21.jpg',
    stock: 100,
    isAvailable: true
  },
  {
    name: 'Gumene bombone premium',
    description: 'Mekane gumene bombone raznih oblika i aroma, odličan izbor za svakodnevno uživanje.',
    price: 310,
    category: 'Bombone',
    imageUrl: 'assets/images/product_23.jpg',
    stock: 100,
    isAvailable: true
  },
  {
    name: 'Šarene žele bombone',
    description: 'Mekane žele bombone voćnih ukusa sa šarenim prelivom, odlične za svakodnevno grickanje.',
    price: 260,
    category: 'Bombone',
    imageUrl: 'assets/images/product_3.jpg',
    stock: 100,
    isAvailable: true
  },
  {
    name: 'Voćni bombon mix',
    description: 'Raznovrsni voćni bomboni u jednom pakovanju, idealni za dijeljenje sa društvom.',
    price: 280,
    category: 'Bombone',
    imageUrl: 'assets/images/product_6.jpg',
    stock: 100,
    isAvailable: true
  },
  {
    name: 'Gumene bombone classic',
    description: 'Klasične gumene bombone bogatih aroma i meke teksture, omiljene među svim uzrastima.',
    price: 300,
    category: 'Bombone',
    imageUrl: 'assets/images/product_8.jpg',
    stock: 100,
    isAvailable: true
  },
  {
    name: 'Bombone sa posipom',
    description: 'Slatke bombone sa dekorativnim posipom i intenzivnim voćnim ukusom.',
    price: 295,
    category: 'Bombone',
    imageUrl: 'assets/images/product_13.jpg',
    stock: 100,
    isAvailable: true
  },
  {
    name: 'Premium voćne bombone',
    description: 'Pažljivo odabrani voćni bomboni izraženog ukusa i atraktivnog izgleda.',
    price: 320,
    category: 'Bombone',
    imageUrl: 'assets/images/product_17.jpg',
    stock: 100,
    isAvailable: true
  },
  {
    name: 'Šarene mini bombone',
    description: 'Mini bombone sa raznim voćnim ukusima, praktične i zabavne za grickanje.',
    price: 275,
    category: 'Bombone',
    imageUrl: 'assets/images/product_22.jpg',
    stock: 100,
    isAvailable: true
  },
  {
    name: 'Bombone deluxe mix',
    description: 'Deluxe mix bombona sa bogatim ukusima i finom teksturom, za posebne slatke trenutke.',
    price: 340,
    category: 'Bombone',
    imageUrl: 'assets/images/product_25.jpg',
    stock: 100,
    isAvailable: true
  },
  {
    name: 'Bombone voćna eksplozija',
    description: 'Aromatične bombone intenzivnog voćnog ukusa koje donose pravu slatku eksploziju.',
    price: 330,
    category: 'Bombone',
    imageUrl: 'assets/images/product_28.jpg',
    stock: 100,
    isAvailable: true
  },
  {
    name: 'Bombone premium izbor',
    description: 'Premium izbor bombona različitih ukusa i oblika, idealan za poklon ili uživanje.',
    price: 360,
    category: 'Bombone',
    imageUrl: 'assets/images/product_31.jpg',
    stock: 100,
    isAvailable: true
  },
  // Čokolada
  {
    name: 'Belgijske čoko školjke',
    description: 'Premium belgijske praline u obliku školjki. Ručno pravljene sa najfinijim sastojcima.',
    price: 500,
    category: 'Čokolada',
    imageUrl: 'assets/images/product_9.jpg',
    stock: 100,
    isAvailable: true
  },
  {
    name: 'Čoko kikiriki štanglica',
    description: 'Hrskava čokoladna štanglica punjena kikirikijem. Savršena kombinacija slatkog i slanog.',
    price: 390,
    category: 'Čokolada',
    imageUrl: 'assets/images/product_10.jpg',
    stock: 100,
    isAvailable: true
  },
  {
    name: 'Čokoladne hrskave kuglice',
    description: 'Hrskave čokoladne kuglice obložene mliječnom čokoladom. Idealne za grickanje bilo kada.',
    price: 320,
    category: 'Čokolada',
    imageUrl: 'assets/images/product_15.jpg',
    stock: 0,
    isAvailable: false
  },
  {
    name: 'Čoko karamela štanglica',
    description: 'Čokoladna štanglica sa bogatom karamela punjem. Nezaboravan ukus za prave ljubitelje čokolade.',
    price: 410,
    category: 'Čokolada',
    imageUrl: 'assets/images/product_16.jpg',
    stock: 100,
    isAvailable: true
  },
  {
    name: 'Čokoladne pločice sa voćem',
    description: 'Fina mliječna čokolada sa zasušenim voćnim komadićima.',
    price: 305,
    category: 'Čokolada',
    imageUrl: 'assets/images/product_18.jpg',
    stock: 100,
    isAvailable: true
  },
  {
    name: 'Mliječna čokolada classic',
    description: 'Klasična mliječna čokolada bogatog ukusa i glatke teksture, savršena za svaki dan.',
    price: 420,
    category: 'Čokolada',
    imageUrl: 'assets/images/product_19.jpg',
    stock: 100,
    isAvailable: true
  },
  {
    name: 'Čoko praline selection',
    description: 'Izbor finih čokoladnih pralina sa raznim punjenjima za pravi gurmanski doživljaj.',
    price: 540,
    category: 'Čokolada',
    imageUrl: 'assets/images/product_27.jpg',
    stock: 100,
    isAvailable: true
  },
  {
    name: 'Premium čoko praline',
    description: 'Luksuzne praline sa finom čokoladnom glazurom i punjenjem, odličan izbor za posebne prilike.',
    price: 560,
    category: 'Čokolada',
    imageUrl: 'assets/images/product_30.jpg',
    stock: 100,
    isAvailable: true
  },
  {
    name: 'Tamna čokolada premium',
    description: 'Intenzivna tamna čokolada sa visokim udjelom kakaa za ljubitelje punijeg ukusa.',
    price: 510,
    category: 'Čokolada',
    imageUrl: 'assets/images/product_33.jpg',
    stock: 100,
    isAvailable: true
  },
  {
    name: 'Čokoladni mix specijal',
    description: 'Poseban mix čokoladnih zalogaja različitih aroma, idealan za deljenje i uživanje.',
    price: 570,
    category: 'Čokolada',
    imageUrl: 'assets/images/product_35.jpg',
    stock: 100,
    isAvailable: true
  },
  // Mafini
  {
    name: 'Vanila mafini sa kremom',
    description: 'Mekani vanila mafini sa kremastom punjem. Svježe pečeni i savršeni za jutarnju kafu.',
    price: 400,
    category: 'Mafini',
    imageUrl: 'assets/images/product_2.jpg',
    stock: 100,
    isAvailable: true
  },
  {
    name: 'Čokoladno-vanila mafini',
    description: 'Savršena kombinacija čokolade i vanile u jednom mafinu. Mekani i sočni.',
    price: 450,
    category: 'Mafini',
    imageUrl: 'assets/images/product_4.jpg',
    stock: 100,
    isAvailable: true
  },
  {
    name: 'Čokoladne mafin kuglice',
    description: 'Mini čokoladni mafini u obliku kuglica. Idealni za zabave ili kao desert.',
    price: 380,
    category: 'Mafini',
    imageUrl: 'assets/images/product_7.jpg',
    stock: 100,
    isAvailable: true
  },
  {
    name: 'Čokoladne mafin kuglice sa posipom',
    description: 'Čokoladne mafin kuglice ukrašene šarenim posipom. Savršene za dječje zabave!',
    price: 420,
    category: 'Mafini',
    imageUrl: 'assets/images/product_14.jpg',
    stock: 0,
    isAvailable: false
  },
  {
    name: 'Voćni mafini mix',
    description: 'Mafini sa raznim voćnim punjenjem, laganih i mekanih tekstura za uživanje tokom dana.',
    price: 480,
    category: 'Mafini',
    imageUrl: 'assets/images/product_26.jpg',
    stock: 100,
    isAvailable: true
  },
  {
    name: 'Čokoladni mafini deluxe',
    description: 'Deluxe čokoladni mafini sa bogatim punjenjem, savršeni za posebne trenutke.',
    price: 520,
    category: 'Mafini',
    imageUrl: 'assets/images/product_29.jpg',
    stock: 100,
    isAvailable: true
  },
  {
    name: 'Mafini sa vanila kremom',
    description: 'Mekani mafini sa gustom vanila kremom, idealni za ljubitelje klasičnog ukusa.',
    price: 450,
    category: 'Mafini',
    imageUrl: 'assets/images/product_32.jpg',
    stock: 100,
    isAvailable: true
  },
  {
    name: 'Premium mafini izbor',
    description: 'Premium izbor mafina sa raznim aromatima i punjenjem, za pravi gurmanski doživljaj.',
    price: 530,
    category: 'Mafini',
    imageUrl: 'assets/images/product_36.jpg',
    stock: 100,
    isAvailable: true
  }
];

const seedProducts = async () => {
  try {
    // Connect to database
    await connectDB();
    console.log('Connected to MongoDB');

    // Clear existing products
    await Product.deleteMany({});
    console.log('Cleared existing products');

    // Insert new products
    const createdProducts = await Product.insertMany(products);
    console.log(`✅ Successfully seeded ${createdProducts.length} products`);

    process.exit(0);
  } catch (error) {
    console.error('❌ Error seeding products:', error);
    process.exit(1);
  }
};

seedProducts();
