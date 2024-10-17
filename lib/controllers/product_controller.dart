import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_mongo_lab1/controllers/auth_controller.dart';
import 'package:flutter_mongo_lab1/providers/user_provider.dart';
import 'package:flutter_mongo_lab1/varibles.dart';
import 'package:flutter_mongo_lab1/models/product_model.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class ProductController {
  final _authController = AuthController();
  static int retryCount = 0; // นับจำนวนการพยายามรีเฟรช token

  Future<List<ProductModel>> getProducts(BuildContext context) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    var accessToken = userProvider.accessToken;

    try {
      final response = await http.get(
        Uri.parse('$apiURL/api/products'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $accessToken", // ใส่ accessToken ใน header
        },
      );
      if (response.statusCode == 200) {
        // Decode the response and map it to ProductModel objects
        List<dynamic> jsonResponse = json.decode(response.body);
        return jsonResponse
            .map((product) => ProductModel.fromJson(product))
            .toList();
      } else if (response.statusCode == 401) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
        throw Exception(
            'Wrong Token. Please login again.'); // เพิ่ม throw Exception
      } else if (response.statusCode == 403 && retryCount <= 1) {
        // Refresh token and retry
        await _authController.refreshToken(context);
        accessToken = userProvider.accessToken;
        retryCount++;

        return await getProducts(context);
      } else if (response.statusCode == 403 && retryCount > 1) {
        // ข้อความเมื่อ token หมดอายุ
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
        throw Exception(
            'Token expired. Please login again.'); // เพิ่ม throw Exception
      } else {
        throw Exception(
            'Failed to load products with status code: ${response.statusCode}');
      }
    } catch (err) {
      // If the request failed, throw an error
      throw Exception('Failed to load products');
    }
  }

  Future<void> InsertProduct(BuildContext context, String productName,
      String productType, double price, String unit) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    var accessToken = userProvider.accessToken;
    final Map<String, dynamic> InsertData = {
      "product_name": productName,
      "product_type": productType,
      "price": price,
      "unit": unit,
    };
    try {
      // Make POST request to insert the product
      final response = await http.post(
        Uri.parse(
            "$apiURL/api/product"), // Replace with the correct API endpoint
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $accessToken" // Attach accessToken
        },
        body: jsonEncode(InsertData),
      );
      // Handle successful product insertion
      if (response.statusCode == 201) {
        print("Product inserted successfully!");
      } else if (response.statusCode == 401) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
        throw Exception(
            'Wrong Token. Please login again.'); // เพิ่ม throw Exception
      }
      // If accessToken is expired or unauthorized, refresh the token
      else if (response.statusCode == 403 && retryCount <= 1) {
        print("Access token expired. Refreshing token...");

        // Refresh the accessToken
        await _authController.refreshToken(context);
        accessToken =
            userProvider.accessToken; // Update the accessToken after refresh
        retryCount++;

        return await InsertProduct(
            context, productName, productType, price, unit);
      } else if (response.statusCode == 403 && retryCount > 1) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
        throw Exception(
            'Token expired. Please login again.'); // เพิ่ม throw Exception
      } else {
        print("Failed to insert product. Status code: ${response.statusCode}");

        throw Exception(
            'Failed to insert product. Server response: ${response.body}');
      }
    } catch (error) {
      // Catch and print any errors during the request
      print('Error inserting product: $error');
      throw Exception('Failed to insert product due to error: $error');
    }
  }

  Future<void> updateProduct(BuildContext context, String productId,
      String productName, String productType, double price, String unit) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    var accessToken = userProvider.accessToken;

    final Map<String, dynamic> updateData = {
      "product_name": productName,
      "product_type": productType,
      "price": price,
      "unit": unit,
    };

    try {
      // Make PUT request to update the product
      final response = await http.put(
        Uri.parse(
            "$apiURL/api/product/$productId"), // Replace with the correct API endpoint
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $accessToken" // Attach accessToken
        },
        body: jsonEncode(updateData),
      );
      // Handle successful product update
      if (response.statusCode == 200) {
        print("Product updated successfully!");
      } else if (response.statusCode == 401) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
        throw Exception(
            'Wrong Token. Please login again.'); // เพิ่ม throw Exception
      }
      // If accessToken is expired or unauthorized, refresh the token
      else if (response.statusCode == 403 && retryCount <= 1) {
        print("Access token expired. Refreshing token...");

        // Refresh the accessToken
        await _authController.refreshToken(context);
        accessToken =
            userProvider.accessToken; // Update the accessToken after refresh
        retryCount++;

        // Retry updating the product with the new accessToken
        return await updateProduct(
            context, productId, productName, productType, price, unit);
      } else if (response.statusCode == 403 && retryCount > 1) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
        throw Exception(
            'Token expired. Please login again.'); // เพิ่ม throw Exception
      } else {
        print("Failed to update product. Status code: ${response.statusCode}");

        throw Exception(
            'Failed to update product. Server response: ${response.body}');
      }
    } catch (error) {
      // Catch and print any errors during the request
      print('Error updating product: $error');
      throw Exception('Failed to update product due to error: $error');
    }
  }

  Future<void> deleteProduct(BuildContext context, String productId) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    var accessToken = userProvider.accessToken;

    try {
      final response = await http.delete(
        Uri.parse("$apiURL/api/product/$productId"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $accessToken"
        },
      );

      if (response.statusCode == 200) {
        print("Product deleted successfully!");
      } else if (response.statusCode == 401) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
        throw Exception(
            'Wrong Token. Please login again.'); // เพิ่ม throw Exception
      } else if (response.statusCode == 403 && retryCount <= 1) {
        print("Access token expired. Refreshing token...");

        // Refresh the accessToken
        await _authController.refreshToken(context);
        accessToken = userProvider.accessToken;
        retryCount++;

        return await deleteProduct(context, productId);
      } else if (response.statusCode == 403 && retryCount > 1) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
        throw Exception(
            'Token expired. Please login again.'); // เพิ่ม throw Exception
      } else {
        print("Failed to delete product. Status code: ${response.statusCode}");
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
        throw Exception(
            'Failed to delete product. Server response: ${response.body}');
      }
    } catch (error) {
      print('Error deleting product: $error');
      throw Exception('Failed to delete product due to error: $error');
    }
  }
}
