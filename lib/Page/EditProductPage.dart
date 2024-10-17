import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter_mongo_lab1/Widget/customCliper.dart'; // Assuming you already have customClipper
import 'package:flutter_mongo_lab1/controllers/product_controller.dart';
import 'package:flutter_mongo_lab1/models/product_model.dart';

class EditProductPage extends StatefulWidget {
  final ProductModel product; // รับ ProductModel ที่จะทำการแก้ไข

  const EditProductPage({super.key, required this.product});

  @override
  _EditProductPageState createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage> {
  final _formKey = GlobalKey<FormState>();
  late String productName;
  late String productType;
  late double price;
  late String unit;

  @override
  void initState() {
    super.initState();
    // ดึงข้อมูลจาก ProductModel มาแสดงในฟอร์ม
    productName = widget.product.productName;
    productType = widget.product.productType;
    price = widget.product.price;
    unit = widget.product.unit;
  }

  // Function to update the product
  Future<void> _updateProduct(BuildContext context, String productId) async {
    final productController = ProductController();
    try {
      await productController.updateProduct(
        context,
        productId,
        productName,
        productType,
        price,
        unit,
      );
      // If the update is successful, navigate back to the previous screen
      Navigator.pushReplacementNamed(context, '/admin');
      // You can also show a success message if needed
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('แก้ไขสินค้าเรียบร้อยแล้ว')),
      );
    } catch (error) {
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาดในการแก้ไขสินค้า: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SizedBox(
        height: height,
        child: Stack(
          children: [
            // Background
            Positioned(
              top: -height * .15,
              right: -width * .4,
              child: Transform.rotate(
                angle: -pi / 3.5,
                child: ClipPath(
                  clipper: ClipPainter(),
                  child: Container(
                    height: height * .5,
                    width: width,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xffE9EFEC),
                          Color(0xffFABC3F),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Form content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: height * .1),
                    RichText(
                      textAlign: TextAlign.center,
                      text: const TextSpan(
                        text: 'แก้ไข',
                        style: TextStyle(
                          fontSize: 35,
                          fontWeight: FontWeight.w900,
                          color: Color(0xffC7253E),
                        ),
                        children: [
                          TextSpan(
                            text: 'สินค้า',
                            style: TextStyle(
                                color: Color(0xffE85C0D), fontSize: 35),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: <Widget>[
                          _buildTextField(
                            label: 'ชื่อสินค้า',
                            initialValue: productName,
                            onSaved: (value) => productName = value!,
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            label: 'ประเภทสินค้า',
                            initialValue: productType,
                            onSaved: (value) => productType = value!,
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            label: 'ราคา',
                            initialValue: price.toString(),
                            keyboardType: TextInputType.number,
                            onSaved: (value) => price = double.parse(value!),
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            label: 'หน่วย',
                            initialValue: unit,
                            onSaved: (value) => unit = value!,
                          ),
                          const SizedBox(height: 30),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    _formKey.currentState!.save();
                                    // Call the update function
                                    _updateProduct(context, widget.product.id);
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xff821131),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 24.0, vertical: 12.0),
                                  child: Text(
                                    'แก้ไข้',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pushReplacementNamed(context,
                                      '/admin'); // เปลี่ยนไปยังหน้าแสดงสินค้า
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color.fromRGBO(103, 103, 103, 1),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 24.0, vertical: 12.0),
                                  child: Text(
                                    'ยกเลิก',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ฟังก์ชันสร้าง TextField สำหรับฟอร์มแก้ไขสินค้า
  Widget _buildTextField({
    required String label,
    required String initialValue,
    TextInputType? keyboardType,
    required FormFieldSetter<String> onSaved,
  }) {
    return TextFormField(
      decoration: InputDecoration(labelText: label),
      initialValue: initialValue,
      keyboardType: keyboardType,
      onSaved: onSaved,
    );
  }
}
