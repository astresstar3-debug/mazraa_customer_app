import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../domain/home_models.dart';

abstract final class HomeMockData {
  static const categories = <HomeCategory>[
    HomeCategory(
      title: 'المزادات',
      icon: Icons.gavel_rounded,
      color: AppColors.green,
    ),
    HomeCategory(
      title: 'التسوق',
      icon: Icons.shopping_cart_outlined,
      color: AppColors.orange,
    ),
    HomeCategory(
      title: 'حيوانات',
      icon: Icons.pets_rounded,
      color: Color(0xFFF9F7F0),
      emoji: '🐄',
    ),
    HomeCategory(
      title: 'زراعة',
      icon: Icons.local_florist_rounded,
      color: Color(0xFF176232),
    ),
  ];

  static const auctions = <AuctionItem>[
    AuctionItem(
      id: 'auction-honey',
      title: 'عسل سدر طبيعي',
      category: 'منتجات زراعية',
      imagePath: 'assets/images/home/sidr_honey.png',
      remaining: '06:21:03',
      categoryIcon: Icons.local_florist_rounded,
    ),
    AuctionItem(
      id: 'auction-palms',
      title: 'شتلات نخيل التمر',
      category: 'زراعة',
      imagePath: 'assets/images/home/date_seedlings.png',
      remaining: '04:32:17',
      categoryIcon: Icons.spa_rounded,
    ),
    AuctionItem(
      id: 'auction-sheep',
      title: 'خروف نجدي فاخر',
      category: 'حيوانات',
      imagePath: 'assets/images/home/najdi_sheep.png',
      remaining: '02:14:36',
      categoryIcon: Icons.pets_rounded,
    ),
  ];

  static const featured = <ProductItem>[
    ProductItem(
      id: 'calf',
      title: 'عجل بلدي',
      imagePath: 'assets/images/home/local_calf.png',
      price: '4,500 ر.س',
      oldPrice: '5,500 ر.س',
      discount: 'خصم 25%',
    ),
    ProductItem(
      id: 'dates',
      title: 'تمر فاخر',
      imagePath: 'assets/images/home/dates.png',
      price: '85 ر.س',
      oldPrice: '100 ر.س',
      discount: 'خصم 15%',
    ),
    ProductItem(
      id: 'feed',
      title: 'علف مواشي عالي الجودة',
      imagePath: 'assets/images/home/livestock_feed.png',
      price: '120 ر.س',
      oldPrice: '150 ر.س',
      discount: 'خصم 20%',
    ),
  ];

  static const popular = <ProductItem>[
    ProductItem(
      id: 'herbs',
      title: 'أعشاب زراعية طازجة',
      imagePath: 'assets/images/home/fresh_herbs.png',
      price: '25 ر.س',
    ),
    ProductItem(
      id: 'honey',
      title: 'عسل سدر طبيعي',
      imagePath: 'assets/images/home/sidr_honey.png',
      price: '140 ر.س',
    ),
    ProductItem(
      id: 'dates-popular',
      title: 'تمر سكري فاخر',
      imagePath: 'assets/images/home/dates.png',
      price: '85 ر.س',
    ),
    ProductItem(
      id: 'sheep-popular',
      title: 'خروف نجدي',
      imagePath: 'assets/images/home/najdi_sheep.png',
      price: '1,850 ر.س',
    ),
  ];
}
