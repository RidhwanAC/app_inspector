// screens/sc_add_inspection.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import '../db/db_helper.dart';
import '../models/inspection.dart';

class AddInspectionScreen extends StatefulWidget {
  const AddInspectionScreen({super.key});

  @override
  State<AddInspectionScreen> createState() => _AddInspectionScreenState();
}

class _AddInspectionScreenState extends State<AddInspectionScreen> {
  final propertyController = TextEditingController();
  final descController = TextEditingController();
  String rating = "Good";
  final List<String> images = [];
  final DatabaseHelper db = DatabaseHelper();
  final ImagePicker picker = ImagePicker();

  // Open Camera
  Future<void> pickImage() async {
    final XFile? img = await picker.pickImage(source: ImageSource.camera);
    if (img != null && mounted) setState(() => images.add(img.path));
  }

  // Save Inspection
  Future<void> saveInspection() async {
    if (propertyController.text.isEmpty ||
        descController.text.isEmpty ||
        images.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Ensure all fields are filled and 3 photos captured"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Get Current Location
    try {
      LocationPermission permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;

      Position pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      final inspection = Inspection(
        propertyName: propertyController.text,
        description: descController.text,
        rating: rating,
        latitude: pos.latitude,
        longitude: pos.longitude,
        dateCreated: DateTime.now().toString(),
        photos: images,
      );

      await db.insertInspection(inspection);
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Inspection Saved."),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("GPS access is required")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: AppBar(
        title: const Text(
          "New Inspection",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: .05),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: Column(
                children: [
                  TextField(
                    controller: propertyController,
                    decoration: const InputDecoration(
                      labelText: "Property Address",
                      prefixIcon: Icon(Icons.home_work_outlined),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: descController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: "Detailed Notes",
                      prefixIcon: Icon(Icons.notes_rounded),
                    ),
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    initialValue: rating,
                    items: ["Excellent", "Good", "Fair", "Poor"]
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (val) => setState(() => rating = val!),
                    decoration: const InputDecoration(
                      labelText: "Overall Rating",
                      prefixIcon: Icon(Icons.stars_outlined),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Photos (Min 3)",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton.icon(
                  onPressed: pickImage,
                  icon: const Icon(Icons.add_a_photo),
                  label: const Text("Capture"),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Image Grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: images.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemBuilder: (_, i) => Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.file(
                      File(images[i]),
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),

                  // Image Deletion Button "x"
                  PositionPoint(
                    onPressed: () => setState(() => images.removeAt(i)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                onPressed: saveInspection,
                child: const Text(
                  "SAVE INSPECTION",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Image Deletion Button "x" Widget
class PositionPoint extends StatelessWidget {
  final VoidCallback onPressed;
  const PositionPoint({super.key, required this.onPressed});
  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 5,
      top: 5,
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: const BoxDecoration(
            color: Colors.red,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.close, color: Colors.white, size: 14),
        ),
      ),
    );
  }
}
