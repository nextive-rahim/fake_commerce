import 'package:dartz/dartz.dart';
import 'package:fake_commerce/src/feature/product/products/domain/entities/product_entity.dart';
import 'package:fake_commerce/src/feature/product/root/data/data_sources/product_data_source.dart';
import 'package:fake_commerce/src/feature/product/root/data/models/product_model.dart';
import 'package:fake_commerce/src/feature/product/root/data/repositories/product_repository_imp.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final productRepositoryProvider = Provider(
  (ref) {
    return ProductRepositoryImpl(
      dataSource: ref.read(productDataSourceProvider),
    );
  },
);

abstract class ProductRepository {
  Future<Either<Exception, List<ProductEntity>>> productList(
    String? sortingMethod,
    String? limit,
  );

  Future<Either<Exception, ProductEntity>> product(int id);
}
