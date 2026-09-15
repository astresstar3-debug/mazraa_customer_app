import 'package:flutter/material.dart';

enum HomeDisplayMode { grid, compact, list }

class HomeCategory {
  const HomeCategory({
    required this.title,
    required this.icon,
    required this.color,
    this.emoji,
  });

  final String title;
  final IconData icon;
  final Color color;
  final String? emoji;
}

class AuctionItem {
  const AuctionItem({
    required this.id,
    required this.title,
    required this.category,
    required this.imagePath,
    required this.remaining,
    required this.categoryIcon,
  });

  final String id;
  final String title;
  final String category;
  final String imagePath;
  final String remaining;
  final IconData categoryIcon;
}

class ProductItem {
  const ProductItem({
    required this.id,
    required this.title,
    required this.imagePath,
    required this.price,
    this.oldPrice,
    this.discount,
  });

  final String id;
  final String title;
  final String imagePath;
  final String price;
  final String? oldPrice;
  final String? discount;
}
