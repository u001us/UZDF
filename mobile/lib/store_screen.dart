import 'package:flutter/material.dart';

class StoreScreen extends StatelessWidget {
  const StoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Магазин DJI")),
      body: GridView.builder(
        padding: const EdgeInsets.all(15),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
        ),
        itemCount: 6,
        itemBuilder: (context, index) => _buildProductCard(context, index),
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, int index) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ProductDetail())),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
        ),
        child: Column(
          children: [
            Expanded(child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: Image.network("https://picsum.photos/200/200?drone=$index", fit: BoxFit.cover),
            )),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  const Text("DJI Mavic 3 Pro", style: TextStyle(fontWeight: FontWeight.bold)),
                  const Text("Запчасти, винты", style: TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 5),
                  const Text("2 500 \$", style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class ProductDetail extends StatelessWidget {
  const ProductDetail({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Детали товара")),
      body: Column(
        children: [
          Image.network("https://picsum.photos/500/400?drone=1"),
          const Padding(
            padding: EdgeInsets.all(20.0),
            child: Text("DJI Mavic 3 Pro\n\nЛучший дрон для видеосъемки. В комплекте запасные винты, механизм сброса и усиленный аккумулятор.", style: TextStyle(fontSize: 18)),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(color: Colors.white),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("2 500 \$", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                ElevatedButton(onPressed: () {}, child: const Text("В корзину"))
              ],
            ),
          )
        ],
      ),
    );
  }
}