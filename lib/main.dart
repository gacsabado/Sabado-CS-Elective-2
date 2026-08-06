import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Instagram Clone UI',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const InstagramFeedScreen(),
    );
  }
}

class InstagramFeedScreen extends StatelessWidget {
  const InstagramFeedScreen({super.key}); 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Status Bar (Time, Dynamic Island, Dual Network & Horizontal Battery)
            const CustomStatusBar(),

            // Instagram App Bar Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset(
                    'build/flutter_assets/logo/instalogo.png',
                    height: 60,
                    errorBuilder: (context, error, stackTrace) => const Text(
                      'Instagram',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Cursive',
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.favorite_border, color: Colors.black, size: 26),
                        onPressed: () {},
                      ),
                      const SizedBox(width: 8),
                      // Message Icon with Red Badge
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.chat_bubble_outline, color: Colors.black, size: 24),
                            onPressed: () {},
                          ),
                          Positioned(
                            right: 6,
                            top: 6,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: const Text(
                                '2',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Divider(height: 1, thickness: 0.5, color: Colors.grey.shade300),

            // Main Feed Content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //User Header
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              //Avatar
                              Container(
                                padding: const EdgeInsets.all(2.0),
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [Colors.amber, Colors.pink, Colors.purple],
                                  ),
                                ),
                                child: Container(
                                  padding: const EdgeInsets.all(2.0),
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const CircleAvatar(
                                    radius: 18,
                                    backgroundColor: Colors.grey,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              
                              const Text(
                                'username',
                                style: TextStyle(
                                  fontWeight: FontWeight.normal,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(Icons.more_vert, color: Colors.black),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ),

                    // Post Image Container
                    Container(
                      height: 380,
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomLeft,
                          end: Alignment.topRight,
                          colors: [
                            Color(0xFFFFC107), // Yellow/Amber bottom
                            Color(0xFFE91E63), // Pink middle
                            Color(0xFF5C6BC0), // Purple/Indigo top
                          ],
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.favorite, color: Colors.red, size: 28),
                              const SizedBox(width: 16),
                              const Icon(Icons.chat_bubble_outline, color: Colors.black, size: 26),
                              const SizedBox(width: 16),
                              Transform.rotate(
                                angle: -0.4,
                                child: const Icon(Icons.send_outlined, color: Colors.black, size: 26),
                              ),
                            ],
                          ),
                          const Icon(Icons.bookmark_border, color: Colors.black, size: 28),
                        ],
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '10547 Likes',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          const SizedBox(height: 6),
                          RichText(
                            text: const TextSpan(
                              style: TextStyle(color: Colors.black, fontSize: 13),
                              children: [
                                // Bold font weight for @username in caption
                                TextSpan(
                                  text: '@username  ',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                TextSpan(
                                  text: 'Lorem ipsum dolor sit amet, consectetur',
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Wrap(
                            spacing: 6,
                            children: [
                              Text('#lorem', style: TextStyle(color: Colors.lightBlue, fontSize: 12)),
                              Text('#ipsum', style: TextStyle(color: Colors.lightBlue, fontSize: 12)),
                              Text('#dolor', style: TextStyle(color: Colors.lightBlue, fontSize: 12)),
                              Text('#sit', style: TextStyle(color: Colors.lightBlue, fontSize: 12)),
                              Text('#amet', style: TextStyle(color: Colors.lightBlue, fontSize: 12)),
                              Text('#concestetur', style: TextStyle(color: Colors.lightBlue, fontSize: 12)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black,
        currentIndex: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_filled, size: 28),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search, size: 28),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_box_outlined, size: 28),
            label: 'Add',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.movie_outlined, size: 28),
            label: 'Reels',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline, size: 28),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class CustomStatusBar extends StatelessWidget {
  const CustomStatusBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            '17:17',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: Colors.black,
            ),
          ),
          
          // Dynamic Island
          Container(
            width: 80,
            height: 22,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          Row(
            children: [
              const Icon(Icons.signal_cellular_alt, size: 14, color: Colors.black),
              const SizedBox(width: 2),
              const Icon(Icons.signal_cellular_alt, size: 14, color: Colors.black),
              const SizedBox(width: 6),
              Row(
                children: [
                  Container(
                    width: 20,
                    height: 10,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 1.2),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    padding: const EdgeInsets.all(1.5),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ),
                  Container(
                    width: 1.5,
                    height: 4,
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(1),
                        bottomRight: Radius.circular(1),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}