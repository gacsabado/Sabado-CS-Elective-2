import 'package:flutter/material.dart';

class FeaturedBanner {
  final String title;
  final String subtitle;
  final String imageUrl;
  final String targetProductId;
  final Alignment alignment;

  const FeaturedBanner({
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.targetProductId,
    this.alignment = Alignment.center,
  });
}