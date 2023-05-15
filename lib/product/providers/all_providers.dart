import 'package:riverpod/riverpod.dart';

abstract class AllProviders {
  static ProviderContainer get ref => ProviderContainer();

  static final menuDataProvider =
      StateProvider<Map<String, dynamic>>((ref) => {});
}
