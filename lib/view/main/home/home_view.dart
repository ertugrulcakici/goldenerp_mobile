import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:goldenerp/product/widgets/custom_pages/main/main_landing_page.dart';

class HomeView extends ConsumerStatefulWidget {
  const HomeView({super.key});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<HomeView> {
  // ChangeNotifierProvider<MainLandingPage> _mainLandingPage = ChangeNotifierProvider((ref) => MainLandingPage());

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(pageTitle: "Home", activeBack: false, body: _body());
  }

  Widget _body() {
    // if (condition) {

    // }
    // return ;
    return const Center(
      child: Text("Home"),
    );
  }
}
