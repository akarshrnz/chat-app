import 'package:flutter/material.dart';
import '../../../domain/entites/product_entity.dart';

class ProductTile extends StatelessWidget {
  final ProductEntity product;

  const ProductTile({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(product.name),
      subtitle: Text(product.description),
      trailing: Text("₹${product.price}"),
    );
  }
}
