import 'dart:convert';
import 'package:http/http.dart' as http;
import 'models.dart';

class ApiService {
  // Cambiar esta URL según donde esté el servidor
  static const String baseUrl = 'http://localhost:3000';
  
  // Para Android emulator usar: 'http://10.0.2.2:3000'
  // Para dispositivo físico usar la IP de tu ordenador

  Future<List<Category>> getCategories() async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/categories'),
      headers: {'Content-Type': 'application/json'},
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success']) {
        return (data['data'] as List)
            .map((item) => Category.fromJson(item))
            .toList();
      }
    }
    throw Exception('Error al cargar categorías');
  }

  Future<List<FoodItem>> getItems(int categoryId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/items'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'categoryId': categoryId}),
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success']) {
        return (data['data'] as List)
            .map((item) => FoodItem.fromJson(item))
            .toList();
      }
    }
    throw Exception('Error al cargar items');
  }

  Future<FoodItem> getItem(int itemId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/item'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'itemId': itemId}),
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success']) {
        return FoodItem.fromJson(data['data']);
      }
    }
    throw Exception('Error al cargar item');
  }

  Future<List<FoodItem>> search(String query) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/search'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'query': query}),
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success']) {
        return (data['data'] as List)
            .map((item) => FoodItem.fromJson(item))
            .toList();
      }
    }
    throw Exception('Error en la búsqueda');
  }

  static String getImageUrl(String imageName) {
    return '$baseUrl/images/$imageName';
  }
}
