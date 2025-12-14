import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kostkontrakanmod5/modules/model/location_model.dart';
import '../controller/home_controller.dart';
import 'package:kostkontrakanmod5/modules/controller/note_controller.dart';

class DetailKostView extends StatelessWidget {
  final Location location;
  final String randomImage =
      "https://picsum.photos/id/${10 + (DateTime.now().second % 10)}/400/500";
  final String price = "1.200.000";

  DetailKostView({required this.location, super.key});

  @override
  Widget build(BuildContext context) {
    final FavoritesController favController = Get.put(FavoritesController());

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.45,
            child: Image.network(
              randomImage,
              fit: BoxFit.cover,
              errorBuilder: (c, e, s) => Container(color: Colors.grey[300]),
            ),
          ),

          Positioned(
            top: 40,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildCircleButton(Icons.arrow_back_ios_new, () => Get.back()),
                _buildCircleButton(Icons.share, () {}),
              ],
            ),
          ),

          Positioned(
            top: MediaQuery.of(context).size.height * 0.35,
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(
                  24, 30, 24, 80), 
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.purple.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text("Kost / Kontrakan",
                              style: TextStyle(
                                  color: Color(0xFF8B5FBF),
                                  fontWeight: FontWeight.bold)),
                        ),
                        const Row(
                          children: [
                            Icon(Icons.star, color: Colors.amber, size: 20),
                            SizedBox(width: 4),
                            Text("4.5 (532 reviews)",
                                style: TextStyle(fontWeight: FontWeight.w600)),
                          ],
                        )
                      ],
                    ),
                    const SizedBox(height: 16),

                    Text(
                      location.displayName
                          .split(",")[0], 
                      style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87),
                    ),
                    const SizedBox(height: 8),

                    Text(
                      location.displayName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                    const SizedBox(height: 24),

                    Row(
                      children: [
                        _buildTabItem("About", isActive: true),
                        _buildTabItem("Gallery"),
                        _buildTabItem("Review"),
                      ],
                    ),
                    const SizedBox(height: 24),

                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _FeatureItem(icon: Icons.bed, label: "1 Kasur"),
                        _FeatureItem(
                            icon: Icons.bathtub_outlined, label: "1 Mandi"),
                        _FeatureItem(icon: Icons.wifi, label: "Wifi"),
                        _FeatureItem(icon: Icons.square_foot, label: "3x4 m"),
                      ],
                    ),
                    const SizedBox(height: 24),

                    const Text("Description",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(
                      "Kost nyaman dan strategis dengan fasilitas lengkap. Cocok untuk mahasiswa dan karyawan. Lokasi dekat dengan kampus dan pusat perbelanjaan. "
                      "Lingkungan aman dan bersih.",
                      style: TextStyle(color: Colors.grey[600], height: 1.5),
                    ),
                    const SizedBox(height: 24),

                    // Agent Profile
                    const Text("Listing Agent",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const CircleAvatar(
                          backgroundImage:
                              NetworkImage("https://i.pravatar.cc/150?img=12"),
                          radius: 24,
                        ),
                        const SizedBox(width: 12),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Admin Kost",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16)),
                            Text("Pemilik",
                                style: TextStyle(
                                    color: Colors.grey, fontSize: 12)),
                          ],
                        ),
                        const Spacer(),
                        _buildCircleButton(Icons.message, () {},
                            size: 40,
                            color: Colors.purple.withOpacity(0.1),
                            iconColor: const Color(0xFF8B5FBF)),
                        const SizedBox(width: 8),
                        _buildCircleButton(Icons.call, () {},
                            size: 40,
                            color: Colors.purple.withOpacity(0.1),
                            iconColor: const Color(0xFF8B5FBF)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 4. Bottom Bar (Harga & Tombol Book)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: const Offset(0, -5))
                ],
              ),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Total Price",
                          style: TextStyle(color: Colors.grey)),
                      RichText(
                        text: TextSpan(
                          children: [
                            const TextSpan(
                                text: "Rp ",
                                style: TextStyle(
                                    color: Color(0xFF8B5FBF),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18)),
                            TextSpan(
                                text: price,
                                style: TextStyle(
                                    color: Color(0xFF8B5FBF),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18)),
                            const TextSpan(
                                text: " /bulan",
                                style: TextStyle(
                                    color: Colors.grey, fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () {
                      // FITUR: Simpan ke Favorit (Database Supabase)
                      favController.addToFavorites(location);
                      Get.snackbar("Disimpan",
                          "Kost dimasukkan ke favorit untuk dibooking nanti.",
                          backgroundColor: Colors.green,
                          colorText: Colors.white,
                          snackPosition: SnackPosition.TOP);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8B5FBF),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 16),
                    ),
                    child: const Text("Book Now",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircleButton(IconData icon, VoidCallback onTap,
      {double size = 45,
      Color color = Colors.white,
      Color iconColor = Colors.black}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              if (color == Colors.white)
                const BoxShadow(color: Colors.black12, blurRadius: 5)
            ]),
        child: Icon(icon, color: iconColor, size: 20),
      ),
    );
  }

  Widget _buildTabItem(String text, {bool isActive = false}) {
    return Padding(
      padding: const EdgeInsets.only(right: 20),
      child: Column(
        children: [
          Text(text,
              style: TextStyle(
                  color: isActive ? const Color(0xFF8B5FBF) : Colors.grey,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  fontSize: 16)),
          if (isActive)
            Container(
                margin: const EdgeInsets.only(top: 6),
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                    color: Color(0xFF8B5FBF), shape: BoxShape.circle))
        ],
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String label;
  const _FeatureItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey[500], size: 20),
        const SizedBox(width: 6),
        Text(label,
            style: TextStyle(
                color: Colors.grey[600], fontWeight: FontWeight.w500)),
      ],
    );
  }
}
