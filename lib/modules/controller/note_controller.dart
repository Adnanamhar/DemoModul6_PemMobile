import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/location_model.dart';

class FavoritesController extends GetxController {
  final supabase = Supabase.instance.client;
  final favorites = <Location>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchFavorites();
  }

  Future<void> fetchFavorites() async {
    try {
      isLoading.value = true;
      final userId = supabase.auth.currentUser!.id;
      final response = await supabase
          .from('favorites')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      List<dynamic> data = response;
      favorites.value = data
          .map((item) => Location(
                placeId: item['place_id'] ?? 0,
                displayName: item['display_name'] ?? '',
                lat: item['lat'] ?? '0.0',
                lon: item['lon'] ?? '0.0',
              ))
          .toList();
    } catch (e) {
      Get.snackbar("Error", "Gagal memuat favorit: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addToFavorites(Location location) async {
    try {
      isLoading.value = true;
      final userId = supabase.auth.currentUser!.id;

      final check = await supabase
          .from('favorites')
          .select()
          .eq('user_id', userId)
          .eq('place_id', location.placeId);

      if (check.isNotEmpty) {
        Get.snackbar("Info", "Lokasi ini sudah ada di favoritmu.");
        return;
      }

      await supabase.from('favorites').insert({
        'user_id': userId,
        'place_id': location.placeId,
        'display_name': location.displayName,
        'lat': location.lat,
        'lon': location.lon,
      });

      Get.snackbar("Sukses", "Berhasil ditambahkan ke Kost Favorit");
      fetchFavorites();
    } catch (e) {
      Get.snackbar("Error", "Gagal menyimpan: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteFavorite(int placeId) async {
    try {
      await supabase
          .from('favorites')
          .delete()
          .eq('user_id', supabase.auth.currentUser!.id)
          .eq('place_id', placeId);

      fetchFavorites();
      Get.snackbar("Dihapus", "Lokasi dihapus dari favorit.");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }
}
