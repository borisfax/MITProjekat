import p1_img from "./product_1.jpg";
import p2_img from "./product_2.jpg";
import p3_img from "./product_3.jpg";
import p4_img from "./product_4.jpg";
import p5_img from "./product_5.jpg";
import p6_img from "./product_6.jpg";
import p7_img from "./product_7.jpg";
import p8_img from "./product_8.jpg";
import p9_img from "./product_9.jpg";
import p10_img from "./product_10.jpg";
import p11_img from "./product_11.jpg";
import p12_img from "./product_12.jpg";
import p13_img from "./product_13.jpg";
import p14_img from "./product_14.jpg";
import p15_img from "./product_15.jpg";
import p16_img from "./product_16.jpg";
import p17_img from "./product_17.jpg";
import p18_img from "./product_18.jpg";
import p19_img from "./product_19.jpg";
import p20_img from "./product_20.jpg";
import p21_img from "./product_21.jpg";
import p22_img from "./product_22.jpg";
import p23_img from "./product_23.jpg";
import p24_img from "./product_24.jpg";
import p25_img from "./product_25.jpg";
import p26_img from "./product_26.jpg";
import p27_img from "./product_27.jpg";
import p28_img from "./product_28.jpg";
import p29_img from "./product_29.jpg";
import p30_img from "./product_30.jpg";
import p31_img from "./product_31.jpg";
import p32_img from "./product_32.jpg";
import p33_img from "./product_33.jpg";
import p34_img from "./product_34.jpg";
import p35_img from "./product_35.jpg";
import p36_img from "./product_36.jpg";

let all_product = [
  {
    id: 1,
    name: "Voćne šećerne trakice",
    category: "bombone",
    image: p1_img,
    new_price: 2.5,
    old_price: 3.0,
  },
  {
    id: 2,
    name: "Vanila mafini sa kremom",
    category: "mafini",
    image: p2_img,
    new_price: 4.0,
    old_price: 5.0,
  },
  {
    id: 3,
    name: "Candy Corn bombone",
    category: "bombone",
    image: p3_img,
    new_price: 2.2,
    old_price: 3.0,
  },
  {
    id: 4,
    name: "Čokoladno-vanila mafini",
    category: "mafini",
    image: p4_img,
    new_price: 4.5,
    old_price: 5.5,
  },
  {
    id: 5,
    name: "Gumene Coca-Cola bombone",
    category: "bombone",
    image: p5_img,
    new_price: 2.3,
    old_price: 3.0,
  },
  {
    id: 6,
    name: "Lizalice u obliku ruže",
    category: "bombone",
    image: p6_img,
    new_price: 2.8,
    old_price: 3.5,
  },
  {
    id: 7,
    name: "Čokoladne mafin kuglice",
    category: "mafini",
    image: p7_img,
    new_price: 3.8,
    old_price: 5.0,
  },
  {
    id: 8,
    name: "Božićne dekorativne bombone",
    category: "bombone",
    image: p8_img,
    new_price: 3.5,
    old_price: 4.5,
  },
  {
    id: 9,
    name: "Belgijske čoko školjke",
    category: "cokolada",
    image: p9_img,
    new_price: 5.0,
    old_price: 6.5,
  },
  {
    id: 10,
    name: "Čoko kikiriki štanglica",
    category: "cokolada",
    image: p10_img,
    new_price: 3.9,
    old_price: 5.0,
  },
  {
    id: 11,
    name: "Chupa Chups lizalice",
    category: "bombone",
    image: p11_img,
    new_price: 1.5,
    old_price: 2.0,
  },
  {
    id: 12,
    name: "Miješane gumene bombone",
    category: "bombone",
    image: p12_img,
    new_price: 2.7,
    old_price: 3.5,
  },
  {
    id: 13,
    name: "Voćne gumene bombone",
    category: "bombone",
    image: p13_img,
    new_price: 2.6,
    old_price: 3.3,
  },
  {
    id: 14,
    name: "Čokoladne mafin kuglice sa posipom",
    category: "mafini",
    image: p14_img,
    new_price: 4.2,
    old_price: 5.2,
  },
  {
    id: 15,
    name: "Čokoladne hrskave kuglice",
    category: "cokolada",
    image: p15_img,
    new_price: 3.2,
    old_price: 4.0,
  },
  {
    id: 16,
    name: "Čoko karamela štanglica",
    category: "cokolada",
    image: p16_img,
    new_price: 4.1,
    old_price: 5.2,
  },
  {
    id: 17,
    name: "Crvene punjene gumene bombone",
    category: "bombone",
    image: p17_img,
    new_price: 2.9,
    old_price: 3.6,
  },
  {
    id: 18,
    name: "Mini čoko karamele",
    category: "cokolada",
    image: p18_img,
    new_price: 3.4,
    old_price: 4.2,
  },
  {
    id: 19,
    name: "Aero porozna čokolada",
    category: "cokolada",
    image: p19_img,
    new_price: 3.6,
    old_price: 4.5,
  },
  {
    id: 20,
    name: "Čokoladni brownie kolač",
    category: "cokolada",
    image: p20_img,
    new_price: 4.8,
    old_price: 6.0,
  },
  {
    id: 21,
    name: "Gumene bombone medvjedići",
    category: "bombone",
    image: p21_img,
    new_price: 2.4,
    old_price: 3.0,
  },
  {
    id: 22,
    name: "Voćne šećerne kockice",
    category: "bombone",
    image: p22_img,
    new_price: 2.8,
    old_price: 3.4,
  },
  {
    id: 23,
    name: "Gumene bombone srca",
    category: "bombone",
    image: p23_img,
    new_price: 2.9,
    old_price: 3.5,
  },
  {
    id: 24,
    name: "Gumeni medvjedići mix",
    category: "bombone",
    image: p24_img,
    new_price: 2.5,
    old_price: 3.2,
  },
 {
    id: 25,
    name: "Trodijelne gumene bombone",
    category: "bombone",
    image: p25_img,
    new_price: 2.9,
    old_price: 3.6,
  },
  {
    id: 26,
    name: "Krofna sa šarenim posipom",
    category: "mafini",
    image: p26_img,
    new_price: 3.5,
    old_price: 4.5,
  },
  {
    id: 27,
    name: "Čokoladne kuglice sa šarenim posipom",
    category: "cokolada",
    image: p27_img,
    new_price: 4.0,
    old_price: 5.0,
  },
  {
    id: 28,
    name: "Gumene bombone breskva",
    category: "bombone",
    image: p28_img,
    new_price: 2.7,
    old_price: 3.4,
  },
  {
    id: 29,
    name: "Mafini sa borovnicama",
    category: "mafini",
    image: p29_img,
    new_price: 4.3,
    old_price: 5.3,
  },
  {
    id: 30,
    name: "Karamel čoko bombone",
    category: "cokolada",
    image: p30_img,
    new_price: 4.3,
    old_price: 5.3,
  },
  {
    id: 31,
    name: "Šarene bombon dražeje",
    category: "bombone",
    image: p31_img,
    new_price: 2.9,
    old_price: 3.9,
  },
  {
    id: 32,
    name: "Čokoladni puter košarice",
    category: "cokolada",
    image: p32_img,
    new_price: 4.5,
    old_price: 5.5,
  },
  {
    id: 33,
    name: "Čokoladna karamela štanglica",
    category: "cokolada",
    image: p33_img,
    new_price: 3.9,
    old_price: 4.9,
  },
  {
    id: 34,
    name: "Čokoladna štangla sa kikirikijem",
    category: "cokolada",
    image: p34_img,
    new_price: 3.9,
    old_price: 4.9,
  },
  {
    id: 35,
    name: "Čokoladni blokovi",
    category: "cokolada",
    image: p35_img,
    new_price: 4.3,
    old_price: 5.3,
  },
  {
    id: 36,
    name: "Voćni kolačići sa šlagom",
    category: "mafini",
    image: p36_img,
    new_price: 4.3,
    old_price: 5.3,
},
];

export default all_product;
