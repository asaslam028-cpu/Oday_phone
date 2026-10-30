import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const OdayPhoneApp());
}

class OdayPhoneApp extends StatelessWidget {
  const OdayPhoneApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Oday Phone',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF0F0E17),
      ),
      home: const HomePage(),
    );
  }
}

class Product {
  String name; String price; String image; String type;
  Product({required this.name, required this.price, required this.image, required this.type});
  Map<String, dynamic> toMap() => {'name': name, 'price': price, 'image': image, 'type': type};
  factory Product.fromMap(Map<String, dynamic> m) => Product(name: m['name'], price: m['price'], image: m['image'], type: m['type']);
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late TabController _tabController;
  List<Product> products = [];
  String filter = 'phone';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    loadProducts();
  }

  Future<void> loadProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('products');
    if (data != null) {
      final List decoded = jsonDecode(data);
      setState(() { products = decoded.map((e) => Product.fromMap(e)).toList(); });
    } else {
      setState(() {
        products = [
          Product(name: 'iPhone 15 Pro Max', price: '52000 جنيه', image: 'https://images.unsplash.com/photo-1696446703255-02070d3c4a2d', type: 'phone'),
          Product(name: 'Samsung S24 Ultra', price: '48000 جنيه', image: 'https://images.unsplash.com/photo-1610945415295-d9bbf067e59c', type: 'phone'),
          Product(name: 'سماعة AirPods Pro', price: '1200 جنيه', image: 'https://images.unsplash.com/photo-1600294037681-c80b4a09e1e2', type: 'accessory'),
          Product(name: 'شاحن سريع 65W', price: '450 جنيه', image: 'https://images.unsplash.com/photo-1583394838336-acd977736f90', type: 'accessory'),
        ];
      });
    }
  }

  Future<void> saveProducts() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('products', jsonEncode(products.map((e) => e.toMap()).toList()));
  }

  List<Product> get filteredProducts => products.where((p) => p.type == filter).toList();

  InputDecoration inputDeco(String label) => InputDecoration(
    labelText: label, labelStyle: const TextStyle(color: Colors.white54),
    filled: true, fillColor: const Color(0xFF2F2D44),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
  );

  void addProductDialog() {
    String name = '', price = '', image = ''; String type = 'phone';
    showDialog(context: context, builder: (ctx) => AlertDialog(
      backgroundColor: const Color(0xFF232135),
      title: const Text('اضافة منتج جديد', style: TextStyle(color: Colors.white)),
      content: SingleChildScrollView(child: Column(children: [
        TextField(decoration: inputDeco('اسم المنتج'), style: const TextStyle(color: Colors.white), onChanged: (v) => name = v),
        const SizedBox(height: 10),
        TextField(decoration: inputDeco('السعر'), style: const TextStyle(color: Colors.white), onChanged: (v) => price = v),
        const SizedBox(height: 10),
        TextField(decoration: inputDeco('رابط الصورة'), style: const TextStyle(color: Colors.white), onChanged: (v) => image = v),
      ])),
      actions: [
        ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF8906)), onPressed: () {
          if(name.isNotEmpty && price.isNotEmpty){
            setState(() { products.add(Product(name: name, price: price, image: image.isEmpty ? 'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9' : image, type: type)); });
            saveProducts(); Navigator.pop(ctx);
          }
        }, child: const Text('اضافة', style: TextStyle(color: Colors.white)))
      ],
    ));
  }

  void requestDelegate(Product p) {
    String phone = '', address = '', problem = '';
    showDialog(context: context, builder: (ctx) => AlertDialog(
      backgroundColor: const Color(0xFF232135),
      title: const Text('اطلب مندوب Oday Phone', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        Text('طلب لـ: ${p.name}', style: const TextStyle(color: Color(0xFFFF8906))),
        const SizedBox(height: 12),
        TextField(decoration: inputDeco('رقم تليفونك'), style: const TextStyle(color: Colors.white), onChanged: (v) => phone = v),
        const SizedBox(height: 10),
        TextField(decoration: inputDeco('عنوانك في الاسماعيلية'), style: const TextStyle(color: Colors.white), onChanged: (v) => address = v),
      ]),
      actions: [
        ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF8906)), onPressed: () {
          Navigator.pop(ctx);
          showDialog(context: context, builder: (ctx2) => AlertDialog(
            backgroundColor: const Color(0xFF232135),
            title: const Text('تم استلام طلبك ✅', style: TextStyle(color: Colors.white)),
            content: Text('مندوبنا هيجيلك لحد البيت في الاسماعيلية على ${address.isEmpty ? "عنوانك" : address} يستلم ${p.name} ويصلحه ويرجعهولك تاني ❤️\nللتواصل: 01069068091', style: const TextStyle(color: Colors.white70)),
            actions: [TextButton(onPressed: () => Navigator.pop(ctx2), child: const Text('تمام'))],
          ));
        }, child: const Text('ارسل الطلب 🛵', style: TextStyle(color: Colors.white)))
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(slivers: [
        SliverAppBar(
          backgroundColor: const Color(0xFF0F0E17),
          pinned: true,
          expandedHeight: 230,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF7C4DFF), Color(0xFFFF8906)], begin: Alignment.topLeft, end: Alignment.bottomRight)),
              child: SafeArea(child: Padding(padding: const EdgeInsets.fromLTRB(20, 20, 20, 10), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.end, children: [
                Row(children: [
                  const Text('Oday Phone', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900)),
                  const Spacer(),
                  Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(20)), child: const Row(children: [Icon(Icons.location_on, color: Colors.white, size: 14), SizedBox(width: 4), Text('داخل الإسماعيلية فقط', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))])),
                ]),
                const SizedBox(height: 10),
                Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)), child: const Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.phone, color: Color(0xFF7C4DFF), size: 18), SizedBox(width: 6), Text('01069068091', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1))])),
                const SizedBox(height: 10),
                Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: Colors.black.withOpacity(0.35), borderRadius: BorderRadius.circular(20)), child: const Text('🛵 مندوب يصلك لحد البيت يستلم التليفون و يصلحه و يرجعهولك تاني', style: TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.bold))),
              ]))),
            ),
          ),
          bottom: TabBar(controller: _tabController, indicatorColor: const Color(0xFFFF8906), labelColor: Colors.white, unselectedLabelColor: Colors.white54, tabs: const [Tab(text: 'موبايلات 📱'), Tab(text: 'اكسسوارات 🎧')], onTap: (i) { setState(() { filter = i == 0 ? 'phone' : 'accessory'; }); }),
        ),
        SliverPadding(padding: const EdgeInsets.all(14), sliver: SliverGrid(delegate: SliverChildBuilderDelegate((context, index) {
          final p = filteredProducts[index];
          return Container(decoration: BoxDecoration(color: const Color(0xFF232135), borderRadius: BorderRadius.circular(20)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(child: ClipRRect(borderRadius: const BorderRadius.vertical(top: Radius.circular(20)), child: Image.network(p.image, width: double.infinity, fit: BoxFit.cover, errorBuilder: (c,e,s) => Container(color: Colors.grey, child: const Icon(Icons.phone_android, size: 50))))),
            Padding(padding: const EdgeInsets.all(10), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(p.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 4),
              Text(p.price, style: const TextStyle(color: Color(0xFFFF8906), fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              SizedBox(width: double.infinity, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF7C4DFF), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), padding: const EdgeInsets.symmetric(vertical: 4)), onPressed: () => requestDelegate(p), child: const Text('اطلب مندوب 🛵', style: TextStyle(color: Colors.white, fontSize: 12)))),
            ]))
          ]));
        }, childCount: filteredProducts.length), gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 14, crossAxisSpacing: 14, childAspectRatio: 0.72))),
      ]),
      floatingActionButton: FloatingActionButton.extended(backgroundColor: const Color(0xFFFF8906), onPressed: addProductDialog, icon: const Icon(Icons.add, color: Colors.white), label: const Text('اضف منتج', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
    );
  }
}
