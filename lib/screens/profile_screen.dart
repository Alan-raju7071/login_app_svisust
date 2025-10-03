import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:login_app_svisust/models/product_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? name;
  String? email;
  String? imagePath; // store profile image path
  late Future<List<Product>> productsFuture;

  @override
  void initState() {
    super.initState();
    _loadUser();
    productsFuture = fetchProducts();
  }

  Future<void> _loadUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      name = prefs.getString("name") ?? "User";
      email = prefs.getString("email") ?? "example@email.com";
      imagePath = prefs.getString("profileImage"); // load saved image
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString("profileImage", pickedFile.path);

      setState(() {
        imagePath = pickedFile.path;
      });
    }
  }

  Future<List<Product>> fetchProducts() async {
    final response = await http.get(Uri.parse("https://fakestoreapi.com/products"));

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((json) => Product.fromJson(json)).toList();
    } else {
      throw Exception("Failed to load products");
    }
  }

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profile")),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),

          // 👤 Profile Image
        GestureDetector(
  onTap: _pickImage, // tap to change image
  child: CircleAvatar(
    radius: 50,
    backgroundImage: imagePath != null ? FileImage(File(imagePath!)) : null,
    child: imagePath == null
        ? const Icon(Icons.person, size: 50)
        : null,
  ),
),

          const SizedBox(height: 10),

          // Name & Email
          Text(name ?? "",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          Text(email ?? "",
              style: const TextStyle(fontSize: 16, color: Colors.grey)),

          const SizedBox(height: 20),

          ElevatedButton(
            onPressed: _logout,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Logout"),
          ),

          const Divider(height: 30, thickness: 1),

          // Products List
          Expanded(
            child: FutureBuilder<List<Product>>(
              future: productsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("No products found"));
                }

                final products = snapshot.data!;
                return ListView.separated(
                  itemCount: products.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return ListTile(
                      leading: Image.network(product.image,
                          width: 50, height: 50, fit: BoxFit.cover),
                      title: Text(product.title,
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                      subtitle: Text("\$${product.price.toStringAsFixed(2)}"),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
