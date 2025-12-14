import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../service/settings_service.dart';
import '../controller/home_controller.dart';
import '../controller/note_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final SettingsService settings = Get.find<SettingsService>();

    return Scaffold(
      appBar: AppBar(
        title: Text('pkukostkontrakan'),
        backgroundColor: Colors.indigo,
        actions: [
          Obx(() => IconButton(
                icon: Icon(settings.isDarkMode.value
                    ? Icons.light_mode
                    : Icons.dark_mode),
                onPressed: () => controller.toggleTheme(),
              )),
          IconButton(
              icon: Icon(Icons.logout), onPressed: () => controller.logout()),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildExperimentControls(),
            SizedBox(height: 10),
            _buildMapSection(),
            SizedBox(height: 10),
            Divider(thickness: 2),
            Obx(() => Text(
                  'Status: ${controller.experimentLog.value}',
                  style: TextStyle(fontStyle: FontStyle.italic, fontSize: 12),
                )),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return Center(child: CircularProgressIndicator());
                }
                if (controller.locationList.isEmpty) {
                  return Center(
                      child: Text(
                          'Cari alamat di atas atau aktifkan Live Location.'));
                }
                return ListView.builder(
                  itemCount: controller.locationList.length,
                  itemBuilder: (context, index) {
                    final location = controller.locationList[index];
                    return Card(
                      elevation: 2,
                      margin: EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        leading: Icon(Icons.place, color: Colors.indigo),
                        title: Text(location.displayName),
                        subtitle: Text('${location.lat}, ${location.lon}'),
                        onTap: () {
                          Get.defaultDialog(
                              title: "Simpan Favorit?",
                              middleText: "Simpan lokasi ini ke database?",
                              textConfirm: "Ya",
                              textCancel: "Batal",
                              onConfirm: () {
                                final favController =
                                    Get.put(FavoritesController());
                                favController.addToFavorites(location);
                                Get.back();
                              });
                        },
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapSection() {
    return Container(
      height: 280,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.indigo),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          FlutterMap(
            mapController: controller.mapController,
            options: MapOptions(
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
                              // Warna merah jika GPS, Biru jika Network
                              color: controller.activeProvider.value == 'GPS'
                                  ? Colors.red
                                  : Colors.blue,
                              size: 40),
                        ),
                    ],
                  )),
            ],
          ),

          // B. Panel Data & Tombol (Di Bawah)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.black.withOpacity(0.7),
              padding: EdgeInsets.all(8),
              child: Column(
                children: [
                  // Data Display
                  Obx(() => Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text(
                              "Lat: ${controller.currentLat.value.toStringAsFixed(4)}",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 11)),
                          Text(
                              "Lon: ${controller.currentLong.value.toStringAsFixed(4)}",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 11)),
                          Text(
                              "Acc: ${controller.accuracy.value.toStringAsFixed(0)}m",
                              style: TextStyle(
                                  color: Colors.yellow, fontSize: 11)),
                        ],
                      )),
                  SizedBox(height: 6),

                  // DUA TOMBOL PILIHAN PROVIDER
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Tombol 1: GPS Provider
                      Obx(() => ElevatedButton.icon(
                            icon: Icon(Icons.satellite_alt, size: 14),
                            label: Text(controller.activeProvider.value == 'GPS'
                                ? "Stop GPS"
                                : "GPS (High)"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  controller.activeProvider.value == 'GPS'
                                      ? Colors.red
                                      : Colors.grey[800],
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              minimumSize: Size(100, 30),
                            ),
                            onPressed: () => controller.startGPSMode(),
                          )),

                      // Tombol 2: Network Provider
                      Obx(() => ElevatedButton.icon(
                            icon: Icon(Icons.wifi, size: 14),
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
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              minimumSize: Size(100, 30),
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

  Widget _buildExperimentControls() {
    return Column(
      children: [
        TextField(
          controller: controller.searchController,
          decoration: InputDecoration(
            labelText: 'Cari Alamat Kost',
            hintText: 'Misal: Kost UMM',
            isDense: true, // Biar lebih ramping
            border: OutlineInputBorder(),
            suffixIcon: IconButton(
              icon: Icon(Icons.search),
              onPressed: controller.searchWithHttp,
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
                onPressed: controller.searchWithHttp,
                child: Text("Cari (HTTP)")),
            TextButton(
                onPressed: controller.goToNotes, child: Text("Lihat Favorit")),
          ],
        )
      ],
    );
  }
}
