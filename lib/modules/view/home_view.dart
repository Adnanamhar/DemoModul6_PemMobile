import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../service/settings_service.dart';
import '../controller/home_controller.dart';
import 'detail_kost_view.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final SettingsService settings = Get.find<SettingsService>();
    final isDark = settings.isDarkMode.value;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).cardColor,
        title: Text(
          'pkukostkontrakan',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.indigo,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
        actions: [
          Obx(() => IconButton(
                icon: Icon(
                  settings.isDarkMode.value
                      ? Icons.light_mode
                      : Icons.dark_mode_outlined,
                  color: settings.isDarkMode.value
                      ? Colors.amber
                      : Colors.grey[700],
                ),
                onPressed: () => controller.toggleTheme(),
              )),
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
            onPressed: () => controller.logout(),
          ),
        ],
      ),
      // --- PERUBAHAN UTAMA: MENGGUNAKAN CUSTOMSCROLLVIEW ---
      body: CustomScrollView(
        slivers: [
          // 1. BAGIAN ATAS (SEARCH, MAP, LOG) -> Scrollable Header
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5))
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildModernSearchBar(context, settings),
                  const SizedBox(height: 16),
                  _buildMapSection(), // Map Original
                  const SizedBox(height: 8),
                  _buildStatusLog(settings),
                ],
              ),
            ),
          ),

          // 2. JARAK ANTARA HEADER DAN GRID
          const SliverToBoxAdapter(child: SizedBox(height: 16)),

          // 3. BAGIAN GRID HASIL PENCARIAN
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: Obx(() {
              if (controller.isLoading.value) {
                return const SliverToBoxAdapter(
                    child: Center(child: CircularProgressIndicator()));
              }
              if (controller.locationList.isEmpty) {
                return SliverToBoxAdapter(
                  child: Column(
                    children: [
                      Icon(Icons.location_searching,
                          size: 50, color: Colors.grey.withOpacity(0.5)),
                      const SizedBox(height: 10),
                      Text('Belum ada data kost.',
                          style: TextStyle(color: Colors.grey[500])),
                    ],
                  ),
                );
              }

              // --- PERUBAHAN GRID: TAMPILAN 2 KOLOM ---
              return SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // 2 Item per baris (Lebih kecil)
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio:
                      0.75, // Mengatur rasio tinggi vs lebar kartu
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final location = controller.locationList[index];
                    final randomImg =
                        "https://picsum.photos/id/${index + 50}/300/300";

                    return GestureDetector(
                      onTap: () =>
                          Get.to(() => DetailKostView(location: location)),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black
                                    .withOpacity(isDark ? 0.3 : 0.05),
                                blurRadius: 5,
                                offset: const Offset(0, 2))
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Gambar (Ukuran disesuaikan grid)
                            Expanded(
                              flex: 5,
                              child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(12)),
                                child: Image.network(
                                  randomImg,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (c, e, s) =>
                                      Container(color: Colors.grey[300]),
                                ),
                              ),
                            ),
                            // Info Text
                            Expanded(
                              flex: 4,
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          location.displayName.split(",")[0],
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 2),
                                        Row(
                                          children: [
                                            const Icon(Icons.star,
                                                size: 10, color: Colors.amber),
                                            const Text(" 4.5",
                                                style: TextStyle(
                                                    fontSize: 10,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const Text(
                                      "Rp 850rb/bln",
                                      style: TextStyle(
                                          color: Colors.indigo,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  childCount: controller.locationList.length,
                ),
              );
            }),
          ),

          // Padding bawah agar bisa scroll mentok
          const SliverToBoxAdapter(child: SizedBox(height: 30)),
        ],
      ),
    );
  }

  // --- WIDGET MAP (ORIGINAL VERSION - TETAP DIPERTAHANKAN) ---
  Widget _buildMapSection() {
    return Container(
      height: 250, // Tinggi map disesuaikan sedikit
      decoration: BoxDecoration(
        border: Border.all(color: Colors.indigo),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          FlutterMap(
            mapController: controller.mapController,
            options: const MapOptions(
              initialCenter: LatLng(-7.98, 112.62),
              initialZoom: 13.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.koskita.app',
              ),
              Obx(() => MarkerLayer(
                    markers: [
                      if (controller.currentLat.value != 0.0)
                        Marker(
                          point: LatLng(controller.currentLat.value,
                              controller.currentLong.value),
                          width: 60,
                          height: 60,
                          child: Icon(Icons.my_location,
                              color: controller.activeProvider.value == 'GPS'
                                  ? Colors.red
                                  : Colors.blue,
                              size: 40),
                        ),
                    ],
                  )),
            ],
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.black.withOpacity(0.7),
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  Obx(() => Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text(
                              "Lat: ${controller.currentLat.value.toStringAsFixed(4)}",
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 11)),
                          Text(
                              "Lon: ${controller.currentLong.value.toStringAsFixed(4)}",
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 11)),
                          Text(
                              "Acc: ${controller.accuracy.value.toStringAsFixed(0)}m",
                              style: const TextStyle(
                                  color: Colors.yellow, fontSize: 11)),
                        ],
                      )),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Obx(() => ElevatedButton.icon(
                            icon: const Icon(Icons.satellite_alt, size: 14),
                            label: Text(controller.activeProvider.value == 'GPS'
                                ? "Stop GPS"
                                : "GPS (High)"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  controller.activeProvider.value == 'GPS'
                                      ? Colors.red
                                      : Colors.grey[800],
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              minimumSize: const Size(80, 30),
                            ),
                            onPressed: () => controller.startGPSMode(),
                          )),
                      Obx(() => ElevatedButton.icon(
                            icon: const Icon(Icons.wifi, size: 14),
                            label: Text(
                                controller.activeProvider.value == 'NETWORK'
                                    ? "Stop Net"
                                    : "Net (Low)"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  controller.activeProvider.value == 'NETWORK'
                                      ? Colors.blue
                                      : Colors.grey[800],
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              minimumSize: const Size(80, 30),
                            ),
                            onPressed: () => controller.startNetworkMode(),
                          )),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET SEARCH ---
  Widget _buildModernSearchBar(BuildContext context, SettingsService settings) {
    final isDark = settings.isDarkMode.value;
    final fillColor = isDark ? Colors.grey[800] : Colors.grey[100];
    final hintColor = isDark ? Colors.grey[400] : Colors.grey;

    return Row(
      children: [
        Expanded(
          child: Container(
            height: 45,
            decoration: BoxDecoration(
              color: fillColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: controller.searchController,
              decoration: InputDecoration(
                hintText: 'Cari Kost...',
                hintStyle: TextStyle(color: hintColor, fontSize: 14),
                prefixIcon: const Icon(Icons.search_rounded,
                    color: Colors.indigo, size: 20),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onSubmitted: (_) => controller.searchWithHttp(),
            ),
          ),
        ),
        const SizedBox(width: 8),
        InkWell(
          onTap: controller.goToNotes,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: Colors.indigo,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.favorite_rounded,
                color: Colors.white, size: 20),
          ),
        ),
      ],
    );
  }

  // --- WIDGET LOG ---
  Widget _buildStatusLog(SettingsService settings) {
    return Obx(() {
      final isDark = settings.isDarkMode.value;
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.orange.withOpacity(0.2)
              : Colors.orange.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.info_outline_rounded,
                size: 12, color: Colors.orange),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                controller.experimentLog.value,
                style: TextStyle(
                    color: isDark ? Colors.orangeAccent : Colors.orange[900],
                    fontSize: 11,
                    fontStyle: FontStyle.italic),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
    });
  }
}
