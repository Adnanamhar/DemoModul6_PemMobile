import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hive/hive.dart';

import '../service/settings_service.dart';
import '../service/api_service.dart';
import '../model/location_model.dart';
import '../routes/app_pages.dart';

class HomeController extends GetxController {
  final ApiService apiService;
  final SettingsService settingsService;

  HomeController(this.apiService, this.settingsService);

  // State Lama
  var isLoading = false.obs;
  var locationList = <Location>[].obs;
  var experimentLog = 'Siap tracking...'.obs;
  final TextEditingController searchController = TextEditingController();
  final Box<List> locationCacheBox = Hive.box<List>('locationCache');
  final String _cacheKey = 'last_search';

  // === STATE BARU (GEOLOCATION) ===
  var currentLat = 0.0.obs;
  var currentLong = 0.0.obs;
  var accuracy = 0.0.obs;
  var timestamp = "-".obs;

  // Status Tracking: 'GPS', 'NETWORK', atau 'OFF'
  var activeProvider = 'OFF'.obs;

  final MapController mapController = MapController();
  Timer? _positionTimer;

  // Variabel internal untuk menyimpan akurasi yang dipilih
  LocationAccuracy _selectedAccuracy = LocationAccuracy.high;

  @override
  void onInit() {
    super.onInit();
    searchController.text = 'Kost UMM';
    loadFromCache();
  }

  @override
  void onClose() {
    stopLiveLocation();
    searchController.dispose();
    mapController.dispose();
    super.onClose();
  }

  // === TOMBOL 1: START GPS (High Accuracy) ===
  void startGPSMode() {
    if (activeProvider.value == 'GPS') {
      stopLiveLocation(); // Jika sedang on, matikan
    } else {
      _startTracking(LocationAccuracy.high, 'GPS');
    }
  }

  // === TOMBOL 2: START NETWORK (Balanced Accuracy) ===
  void startNetworkMode() {
    if (activeProvider.value == 'NETWORK') {
      stopLiveLocation(); // Jika sedang on, matikan
    } else {
      _startTracking(LocationAccuracy.medium, 'NETWORK');
    }
  }

  // === LOGIKA UTAMA TRACKING ===
  Future<void> _startTracking(
      LocationAccuracy accuracyLevel, String providerName) async {
    // 1. Matikan timer lama jika ada (ganti mode on-the-fly)
    stopLiveLocation();

    // 2. Cek Permission
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Get.snackbar("Error", "Layanan Lokasi (GPS) mati.");
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    if (permission == LocationPermission.deniedForever) return;

    // 3. Set State
    _selectedAccuracy = accuracyLevel;
    activeProvider.value = providerName;
    experimentLog.value = "Tracking: $providerName Mode (10s interval)";

    // 4. Update Pertama
    _updatePosition();

    // 5. Jalankan Timer Loop
    _positionTimer = Timer.periodic(Duration(seconds: 10), (timer) {
      _updatePosition();
    });
  }

  Future<void> _updatePosition() async {
    try {
      // Gunakan akurasi sesuai tombol yang ditekan
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: _selectedAccuracy,
      );

      currentLat.value = position.latitude;
      currentLong.value = position.longitude;
      accuracy.value = position.accuracy;
      timestamp.value = DateFormat('HH:mm:ss').format(DateTime.now());

      mapController.move(LatLng(position.latitude, position.longitude), 15.0);
    } catch (e) {
      experimentLog.value = "Error ambil lokasi: $e";
    }
  }

  void stopLiveLocation() {
    activeProvider.value = 'OFF';
    _positionTimer?.cancel();
    experimentLog.value = "Tracking Dihentikan.";
  }

  // ... (Fungsi-fungsi lama: searchWithHttp, addToFavorites, dll tetap sama) ...

  void loadFromCache() {
    if (locationCacheBox.containsKey(_cacheKey)) {
      final cachedData = locationCacheBox.get(_cacheKey)!.cast<Location>();
      locationList.value = cachedData;
    }
  }

  Future<void> _saveToCache(List<Location> locations) async {
    await locationCacheBox.put(_cacheKey, locations);
  }

  void searchWithHttp() async {
    if (searchController.text.isEmpty) return;
    try {
      isLoading(true);
      locationList.clear();
      List<Location> locations =
          await apiService.searchHttp(searchController.text);
      locationList.value = locations;
      await _saveToCache(locations);
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading(false);
    }
  }

  void toggleTheme() => settingsService.toggleTheme();
  void logout() async {
    await Supabase.instance.client.auth.signOut();
    Get.offAllNamed(Routes.LOGIN);
  }

  void goToNotes() => Get.toNamed(Routes.NOTES);
}
