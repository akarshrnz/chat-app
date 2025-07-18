import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';

class ProductRemoteDataSource {
  final FirebaseFirestore firestore;

  ProductRemoteDataSource(this.firestore);

  Stream<List<ProductModel>> getProducts() {
    return firestore.collection('products').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return ProductModel.fromJson(doc.data(), doc.id);
      }).toList();
    });
  }
}
