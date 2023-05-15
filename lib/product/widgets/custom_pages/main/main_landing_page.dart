import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:goldenerp/core/services/auth/auth_service.dart';
import 'package:goldenerp/core/services/navigation/navigation_service.dart';
import 'package:goldenerp/core/services/theme/custom_colors.dart';
import 'package:goldenerp/core/utils/extensions/ui_extensions.dart';
import 'package:goldenerp/product/cubits/menu_data_cubit/menu_data_cubit.dart';
import 'package:goldenerp/product/enums/request_action_enum.dart';
import 'package:goldenerp/product/models/api/structure/menu_item_model.dart';
import 'package:goldenerp/product/widgets/custom_pages/custom_data_grid_page/custom_data_grid_page_view.dart';
import 'package:goldenerp/product/widgets/custom_pages/custom_safearea.dart';
import 'package:goldenerp/product/widgets/custom_pages/fiche_page/fiche_page_view.dart';
import 'package:goldenerp/product/widgets/custom_widgets/custom_appbar.dart';
import 'package:goldenerp/view/settings/settings_view.dart';

class CustomScaffold extends ConsumerStatefulWidget {
  final bool activeBack;
  final String pageTitle;
  // -------- Scaffold parameters
  final Widget body;
  bool? resizeToAvoidBottomInset;
  Widget? floatingActionButton;

  CustomScaffold({
    super.key,
    required this.pageTitle,
    required this.activeBack,
    // -------- Scaffold parameters
    required this.body,
    this.resizeToAvoidBottomInset,
    this.floatingActionButton,
  });
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CustomScaffoldState();
}

class _CustomScaffoldState extends ConsumerState<CustomScaffold>
    with TickerProviderStateMixin {
  bool menuActive = false;
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    List<MenuItemModel> menuDataList = context.watch<MenuDataCubit>().state;
    return CustomSafeArea(
      child: Scaffold(
        drawerScrimColor: Colors.transparent,
        key: scaffoldKey,
        drawer: Align(
          alignment: Alignment.bottomLeft,
          child: Container(
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(topRight: Radius.circular(20)),
              border: Border.fromBorderSide(BorderSide.none),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  CustomColors.primaryColor,
                  CustomColors.secondaryColor,
                ],
              ),
            ),
            height: 740.smh,
            constraints: BoxConstraints(maxWidth: 300.smw),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ListView.builder(
                    shrinkWrap: true,
                    itemCount: menuDataList.length,
                    itemBuilder: (context, index) {
                      final menuData = menuDataList[index];
                      return _menuDataItemWidget(menuData);
                    }),
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ListTile(
                        trailing:
                            const Icon(Icons.settings, color: Colors.white),
                        title: const Text("Ayarlar",
                            style: TextStyle(color: Colors.white)),
                        onTap: () {
                          NavigationService.instance
                              .navigateToPage(const SettingsView());
                        }),
                    ListTile(
                        trailing: const Icon(Icons.logout, color: Colors.white),
                        title: const Text("Çıkış",
                            style: TextStyle(color: Colors.white)),
                        onTap: () {
                          AuthService.instance.logout();
                        }),
                  ],
                )
              ],
            ),
          ),
        ),
        // scaffold parameters
        resizeToAvoidBottomInset: widget.resizeToAvoidBottomInset,
        floatingActionButton: widget.floatingActionButton,

        //
        appBar: CustomAppBar.appbar(widget.pageTitle, _menuCallback,
            backActive: widget.activeBack),
        body: widget.body,
      ),
    );
  }

  Widget _menuDataItemWidget(MenuItemModel menuData, {int tabSize = 0}) {
    if (menuData.subMenus != null && menuData.subMenus!.isNotEmpty) {
      final returnData = ExpansionTile(
          collapsedBackgroundColor: Colors.transparent,
          backgroundColor: Colors.transparent,
          textColor: Colors.white,
          collapsedTextColor: Colors.white,
          iconColor: Colors.white,
          collapsedIconColor: Colors.white,
          title: Text(("\t" * tabSize * 4) + menuData.title,
              style: const TextStyle(color: Colors.white)),
          children: menuData.subMenus!
              .map((e) => _menuDataItemWidget(e, tabSize: tabSize + 1))
              .toList());
      tabSize++;
      return returnData;
    } else {
      return ListTile(
        title: Text(("\t" * tabSize * 4) + menuData.title,
            style: const TextStyle(color: Colors.white)),
        onTap: () {
          if (menuData.apiUrl != null && menuData.apiParams != null) {
            switch (menuData.apiParams!.requestAction) {
              case RequestActionEnum.List:
                NavigationService.instance.navigateToPage(CustomDataGridPage(
                    menuItemModel: menuData,
                    apiUrl: menuData.apiUrl!,
                    apiParams: menuData.apiParams!));
                break;
              default:
                NavigationService.instance.navigateToPage(FichePageView(
                    menuItemModel: menuData,
                    apiUrl: menuData.apiUrl!,
                    apiParams: menuData.apiParams!));
            }
          }
        },
      );
    }
  }

  _menuCallback() {
    if (menuActive) {
      setState(() {
        menuActive = false;
        scaffoldKey.currentState!.openDrawer();
      });
    } else {
      setState(() {
        scaffoldKey.currentState!.closeDrawer();
        menuActive = true;
      });
    }
  }
}
