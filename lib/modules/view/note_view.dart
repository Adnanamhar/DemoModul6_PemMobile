import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/note_controller.dart';

class FavoritesView extends GetView<FavoritesController> {
  const FavoritesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kost Favorit Saya'),
        backgroundColor: Colors.pinkAccent,
      ),
      body: Obx(
        () => controller.isLoading.value
            ? Center(child: CircularProgressIndicator())
            : controller.favorites.isEmpty
                ? Center(child: Text("Belum ada kost favorit."))
                : ListView.builder(
                    itemCount: controller.favorites.length,
                    itemBuilder: (context, index) {
                      final loc = controller.favorites[index];
                      return Card(
                        margin:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        child: ListTile(
                          leading: Icon(Icons.favorite, color: Colors.red),
                          title: Text(
                            loc.displayName,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text("Lat: ${loc.lat}, Lon: ${loc.lon}"),
                          trailing: IconButton(
                            icon: Icon(Icons.delete_outline),
                            onPressed: () =>
                                controller.deleteFavorite(loc.placeId),
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
