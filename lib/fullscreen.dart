import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_wallpaper_manager/flutter_wallpaper_manager.dart';

class Fullscreen extends StatelessWidget {
  final String imageUrl;

  const Fullscreen({super.key, required this.imageUrl});

  Future<void> _setWallpaper(BuildContext context, int location) async {
    try {
      var file = await DefaultCacheManager().getSingleFile(imageUrl);
      await WallpaperManager.setWallpaperFromFile(file.path, location);
      Navigator.pop(context); // Dismiss the bottom sheet
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(location == WallpaperManager.HOME_SCREEN
              ? "Wallpaper set on Home Screen!"
              : "Wallpaper set on Lock Screen!"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to set wallpaper: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showWallpaperOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Set Wallpaper",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.home),
                title: const Text("Home Screen"),
                onTap: () => _setWallpaper(context, WallpaperManager.HOME_SCREEN),
              ),
              ListTile(
                leading: const Icon(Icons.lock),
                title: const Text("Lock Screen"),
                onTap: () => _setWallpaper(context, WallpaperManager.LOCK_SCREEN),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onVerticalDragEnd: (details) {
          if (details.primaryVelocity! > 0) Navigator.pop(context); // Swipe down to go back
        },
        child: Stack(
          children: [
            Positioned.fill(
              child: Hero(
                tag: imageUrl,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return const Center(child: CircularProgressIndicator());
                  },
                ),
              ),
            ),
            Positioned(
              bottom: 20,
              right: 20,
              child: FloatingActionButton(
                onPressed: () => _showWallpaperOptions(context),
                child: const Icon(Icons.wallpaper),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
