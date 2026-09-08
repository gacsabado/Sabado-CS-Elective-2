import 'package:flutter/material.dart';
import '../models/featured_banner.dart';
import '../models/product.dart';

final List<FeaturedBanner> featuredBanners = [
  const FeaturedBanner(
    title: 'AFTER DARK',
    subtitle: 'Hirono After Dark Series Plush Doll Pendant',
    imageUrl: 'assets/afterdark.jpeg',
    targetProductId: 'h1',
    alignment: Alignment(0.0, 0.5),
  ),
  const FeaturedBanner(
    title: 'ROAD JOURNAL',
    subtitle: 'Hirono Road Journal Series Figurine Collection',
    imageUrl: 'assets/roadjournal.jpeg',
    targetProductId: 'h2',
  ),
  const FeaturedBanner(
    title: 'SHELTER',
    subtitle: 'Hirono Shelter Series Blind Box Figures',
    imageUrl: 'assets/shelter.jpg',
    targetProductId: 'h3',
  ),
  const FeaturedBanner(
    title: 'LITTLE MISCHIEF',
    subtitle: 'Hirono Little Mischief Series Plush Companion',
    imageUrl: 'assets/littlemischief.jpg',
    targetProductId: 'h4',
  ),
  const FeaturedBanner(
    title: 'PLUSH DOLL',
    subtitle: 'Hirono Bear Vinyl Plush Doll Collection',
    imageUrl: 'assets/plush.jpg',
    targetProductId: 'h5',
  ),
  const FeaturedBanner(
    title: 'RESHAPE',
    subtitle: 'Hirono Reshape Series Artistic Figurine',
    imageUrl: 'assets/reshape.jpg',
    targetProductId: 'h6',
  ),
];

final List<Product> hironoProducts = [
  const Product(
    id: 'h1',
    name: 'Hirono After Dark Pendant',
    series: 'After Dark',
    price: 29.99,
    imageUrl: 'assets/afterdark.jpeg',
    description: 'Embrace the eerie mystery of nightfall with the Hirono After Dark Plush Doll Pendant.',
  ),
  const Product(
    id: 'h2',
    name: 'Hirono Road Journal Figure',
    series: 'Road Journal Series',
    price: 19.99,
    imageUrl: 'assets/roadjournal.jpeg',
    description: 'Documenting wanderlust, solitude, and quiet reflections along forgotten paths.',
  ),
  const Product(
    id: 'h3',
    name: 'Hirono Shelter Figurine',
    series: 'Shelter Series',
    price: 19.99,
    imageUrl: 'assets/shelter.jpg',
    description: 'Find solace in solitude. Explores inner protection and emotional sanctuaries.',
  ),
  const Product(
    id: 'h4',
    name: 'Hirono Mischief Bear',
    series: 'Little Mischief',
    price: 24.99,
    imageUrl: 'assets/littlemischief.jpg',
    description: 'Playful rebellions and raw unfiltered emotions captured in detailed collectible figures.',
  ),
  const Product(
    id: 'h5',
    name: 'Hirono Bear Vinyl Plush',
    series: 'Plush Doll Collection',
    price: 99.99,
    imageUrl: 'assets/plush.jpg',
    description: 'A premium oversized vinyl and plush companion showcasing Hirono in moody bear attire.',
  ),
  const Product(
    id: 'h6',
    name: 'Hirono Reshape Figure',
    series: 'Reshape Series',
    price: 19.99,
    imageUrl: 'assets/reshape.jpg',
    description: 'Accepting flaws and reshaping one’s personal narrative through artistic expression.',
  ),
];