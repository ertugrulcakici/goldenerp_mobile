import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:goldenerp/product/widgets/custom_pages/main/main_landing_page.dart';

class HomeView extends ConsumerStatefulWidget {
  const HomeView({super.key});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<HomeView> {
  // Map<String, Widget Function(BuildContext)> routes = {
  //   "Stok Kartları": (context) => const StokKartlariView(),
  //   "Malzeme Fişleri": (context) => const MalzemeFisleriView()
  // };

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(pageTitle: "Home", activeBack: false, body: _body());
  }

  Widget _body() {
    return Center(
        child: TextButton(
      onPressed: () {},
      child: const Text("Main"),
    ));
  }

  // Padding _body() {
  //   return Padding(
  //       padding: EdgeInsets.symmetric(horizontal: 20.smw, vertical: 20.smh),
  //       child: GridView.custom(
  //         childrenDelegate: SliverChildBuilderDelegate(
  //             (context, index) => InkWell(
  //                   onTap: () {
  //                     NavigationService.instance.navigateToPage(
  //                         routes[routes.keys.toList()[index]]!(context));
  //                   },
  //                   child: Container(
  //                     decoration: BoxDecoration(
  //                       color: CustomColors.secondaryColor,
  //                       borderRadius: BorderRadius.circular(30),
  //                     ),
  //                     child: Column(
  //                       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //                       children: [
  //                         Image.asset("assets/images/home_page_box.png"),
  //                         Text(
  //                           routes.keys.toList()[index],
  //                           style: const TextStyle(
  //                             color: Colors.white,
  //                             fontSize: 20,
  //                             fontWeight: FontWeight.bold,
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //                   ),
  //                 ),
  //             childCount: routes.length),
  //         gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
  //           mainAxisSpacing: 20.smh,
  //           childAspectRatio: 1,
  //           crossAxisSpacing: 20.smh,
  //           crossAxisCount: 2,
  //         ),
  //       ),
  //     );
  // }
}
