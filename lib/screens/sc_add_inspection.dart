import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:app_inspector/db/db_helper.dart';
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
  double latitude = 0.0;
  double longitude = 0.0;

  final DatabaseHelper db = DatabaseHelper();
  final ImagePicker picker = ImagePicker();

  // ================================
  // LOCATION PERMISSION HANDLER
  // ================================
  Future<void> ensureLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception("Location permission permanently denied");
    }
  }

  // ================================
  // IMAGE PICKER
  // ================================
  Future<void> pickImage() async {
    final XFile? img = await picker.pickImage(source: ImageSource.camera);
    if (img != null && mounted) {
      setState(() => images.add(img.path));
    }
  }

  // ================================
  // SAVE INSPECTION
  // ================================
  Future<void> saveInspection() async {
    if (propertyController.text.trim().isEmpty ||
        descController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("All fields are required")));
      return;
    }

    if (images.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Minimum 3 photos required")),
      );
      return;
    }

    try {
      // 🔑 Permission check BEFORE GPS access
      await ensureLocationPermission();

      Position pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      latitude = pos.latitude;
      longitude = pos.longitude;

      final inspection = Inspection(
        propertyName: propertyController.text,
        description: descController.text,
        rating: rating,
        latitude: latitude,
        longitude: longitude,
        dateCreated: DateTime.now().toString(),
        photos: images,
      );

      await db.insertInspection(inspection);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Inspection saved successfully")),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Location permission is required to save inspection"),
        ),
      );
    }
  }

  // ================================
  // UI
  // ================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Inspection")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: propertyController,
              decoration: const InputDecoration(
                labelText: "Property Name / Address",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descController,
              decoration: const InputDecoration(
                labelText: "Description",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField(
              initialValue: rating,
              items: const [
                DropdownMenuItem(value: "Excellent", child: Text("Excellent")),
                DropdownMenuItem(value: "Good", child: Text("Good")),
                DropdownMenuItem(value: "Fair", child: Text("Fair")),
                DropdownMenuItem(value: "Poor", child: Text("Poor")),
              ],
              onChanged: (val) => setState(() => rating = val!),
              decoration: const InputDecoration(
                labelText: "Rating",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: pickImage,
              icon: const Icon(Icons.camera_alt),
              label: const Text("Capture Photo"),
            ),
            const SizedBox(height: 10),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: images.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 6,
                mainAxisSpacing: 6,
              ),
              itemBuilder: (_, i) =>
                  Image.file(File(images[i]), fit: BoxFit.cover),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: saveInspection,
              child: const Text("Save Inspection"),
            ),
          ],
        ),
      ),
    );
  }
}
