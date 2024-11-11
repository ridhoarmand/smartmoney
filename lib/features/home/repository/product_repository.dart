import '../model/product_model.dart';
import '../service/product_service.dart';

class ProductRepository {
  final ProductService _service;

  ProductRepository({ProductService? service})
      : _service = service ?? ProductService();

  Stream<List<Product>> getProducts() {
    return _service.getProducts();
  }

  Future<bool> createOrUpdateProduct(Product product,
      {bool isUpdate = false}) async {
    try {
      if (isUpdate) {
        return await _service.updateProduct(product);
      } else {
        final id = await _service.addProduct(product);
        return id != null;
      }
    } catch (e) {
      print('Error in createOrUpdateProduct: $e');
      return false;
    }
  }

  Future<bool> deleteProduct(String productId) async {
    return await _service.deleteProduct(productId);
  }
}
