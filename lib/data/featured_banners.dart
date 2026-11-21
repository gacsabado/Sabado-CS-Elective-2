import 'package:flutter/material.dart';

import '../models/featured_banner.dart';

/// Static marketing banners bundled with the app (not store data).
const List<FeaturedBanner> featuredBanners = [
  FeaturedBanner(
    title: 'AFTER DARK',
    subtitle: 'Hirono After Dark Series Plush Doll Pendant',
    imageUrl: 'assets/afterdark.jpeg',
    targetProductId: '',
    alignment: Alignment(0.0, 0.5),
  ),
  FeaturedBanner(
    title: 'ROAD JOURNAL',
    subtitle: 'Hirono Road Journal Series Figurine Collection',
    imageUrl: 'assets/roadjournal.jpeg',
    targetProductId: '',
  ),
  FeaturedBanner(
    title: 'SHELTER',
    subtitle: 'Hirono Shelter Series Blind Box Figures',
    imageUrl: 'assets/shelter.jpg',
    targetProductId: '',
  ),
  FeaturedBanner(
    title: 'LITTLE MISCHIEF',
    subtitle: 'Hirono Little Mischief Series Plush Companion',
    imageUrl: 'assets/littlemischief.jpg',
    targetProductId: '',
  ),
  FeaturedBanner(
    title: 'PLUSH DOLL',
    subtitle: 'Hirono Bear Vinyl Plush Doll Collection',
    imageUrl: 'assets/plush.jpg',
    targetProductId: '',
  ),
  FeaturedBanner(
    title: 'RESHAPE',
    subtitle: 'Hirono Reshape Series Artistic Figurine',
    imageUrl: 'assets/reshape.jpg',
    targetProductId: '',
  ),
];
