import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pixscape_app/fullscreen.dart';

class Wallpaper extends StatefulWidget {
  const Wallpaper({super.key});

  @override
  State<Wallpaper> createState() => _WallpaperState();
}

class _WallpaperState extends State<Wallpaper> {
  final String _apiKey =
      "PzrwjMFFdssYI6z3sTYrAFpGwUnlnTE0Nft6rnGEsy8O6A0gKvBf6khO";
  List images = [];
  int page = 1;
  bool isLoading = false;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    fetchWallpapers();
  }

  Future<void> fetchWallpapers() async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
      hasError = false;
    });

    try {
      final response = await http.get(
        Uri.parse('https://api.pexels.com/v1/curated?per_page=15&page=$page'),
        headers: {'Authorization': _apiKey},
      );

      if (response.statusCode == 200) {
        final Map result = jsonDecode(response.body);
        setState(() {
          images.addAll(result['photos']);
          page++;
        });
      } else {
        throw Exception("Failed to fetch wallpapers");
      }
    } catch (e) {
      setState(() {
        hasError = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Explore Wallpapers"),
        actions: [
          IconButton(
            icon: Icon(
              Theme.of(context).brightness == Brightness.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: () {
              // Toggle between light and dark themes
              final isDark = Theme.of(context).brightness == Brightness.dark;
              setState(() {
                Theme.of(context).copyWith(
                  brightness: isDark ? Brightness.light : Brightness.dark,
                );
              });
            },
          ),
        ],
      ),
      body: hasError
          ? Center(
              child: ElevatedButton(
                onPressed: fetchWallpapers,
                child: const Text("Retry"),
              ),
            )
          : NotificationListener<ScrollNotification>(
              onNotification: (scrollInfo) {
                if (!isLoading &&
                    scrollInfo.metrics.pixels ==
                        scrollInfo.metrics.maxScrollExtent) {
                  fetchWallpapers();
                  return true;
                }
                return false;
              },
              child: images.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : GridView.builder(
                      padding: const EdgeInsets.all(8.0),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        crossAxisCount: 3,
                        childAspectRatio: 2 / 3,
                      ),
                      itemCount: images.length + (isLoading ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == images.length) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        final imageUrl = images[index]['src']['tiny'];
                        final fullImageUrl = images[index]['src']['large2x'];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    Fullscreen(imageUrl: fullImageUrl),
                              ),
                            );
                          },
                          child: Hero(
                            tag: fullImageUrl,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                                loadingBuilder: (context, child, progress) {
                                  if (progress == null) return child;
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                },
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
