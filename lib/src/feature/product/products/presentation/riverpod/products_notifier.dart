import 'dart:developer';
import 'package:fake_commerce/src/core/state/base_state.dart';
import 'package:fake_commerce/src/feature/category/presentation/provider/category_list_provider.dart';
import 'package:fake_commerce/src/feature/product/products/domain/entities/product_entity.dart';
import 'package:fake_commerce/src/feature/product/products/domain/use_cases/products_use_case.dart';
import 'package:fake_commerce/src/feature/product/products/presentation/riverpod/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProductsNotifier extends StateNotifier<BaseState> {
  ProductsNotifier({
    required this.ref,
    required this.useCase,
  }) : super(InitialState()) {
    ref.listen(selectedCategoryProvider, (previous, next) {
      productList(hasFilter: previous != next);
    });
  }

  final Ref ref;
  final ProductsUseCase useCase;

  List<ProductEntity> _products = [];

  Future<void> productList({
    bool hasFilter = false,
  }) async {
    if (hasFilter) {
      if (state is SuccessState) {
        String category = ref.read(selectedCategoryProvider);

        if (category.isNotEmpty) {
          List<ProductEntity> filteredProducts = _products
              .where((element) => element.category == category.toLowerCase())
              .toList();

          state = const LoadingState();
          await Future.delayed(const Duration(milliseconds: 100));

          state = SuccessState(
            data: filteredProducts.isEmpty ? _products : filteredProducts,
          );
        }

        return;
      }
    }

    state = const LoadingState();

    try {
      final result = await useCase.productList(
        ref.watch(sortingMethodProvider.notifier).state
            ? SortedMethod.desc.name
            : SortedMethod.asc.name,
        // sortingMethod ?? SortedMethod.asc.name,
        ref.watch(selectedRangeProvider.notifier).state,
      );
      result.fold(
        (l) {
          log(
            'ProductsNotifier.productList',
            error: l,
          );
          return state = ErrorState(data: l.toString());
        },
        (r) {
          _products = r;
          return state = SuccessState(data: r);
        },
      );
    } catch (e, stacktrace) {
      log(
        'ProductsNotifier.productList',
        error: e,
        stackTrace: stacktrace,
      );
      state = ErrorState(data: e.toString());
    }
  }
}
