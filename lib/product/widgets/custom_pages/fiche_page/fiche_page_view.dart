import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:goldenerp/core/services/network/network_service.dart';
import 'package:goldenerp/core/utils/extensions/ui_extensions.dart';
import 'package:goldenerp/product/constants/app_constants.dart';
import 'package:goldenerp/product/enums/request_action_enum.dart';
import 'package:goldenerp/product/models/api/structure/menu_item_model.dart';
import 'package:goldenerp/product/models/api/structure/request_scheme_model.dart';
import 'package:goldenerp/product/widgets/custom_pages/fiche_page/fiche_page_notifier.dart';
import 'package:goldenerp/product/widgets/custom_pages/main/main_landing_page.dart';

class FichePageView extends ConsumerStatefulWidget {
  final MenuItemModel menuItemModel;
  final String apiUrl;
  final RequestSchemeModel apiParams;
  const FichePageView(
      {super.key,
      required this.menuItemModel,
      required this.apiUrl,
      required this.apiParams});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _FichePageViewState();
}

class _FichePageViewState extends ConsumerState<FichePageView> {
  late final ChangeNotifierProvider<FichePageNotifier> provider;

  @override
  void initState() {
    provider = ChangeNotifierProvider((ref) => FichePageNotifier(
        menuItemModel: widget.menuItemModel,
        apiUrl: widget.apiUrl,
        apiParams: widget.apiParams));
    Future.delayed(Duration.zero, () {
      ref.read(provider).getFicheData();
    });
    super.initState();
  }

  @override
  void dispose() {
    // if (ref.read(provider).box != null && ref.read(provider).box!.isOpen) {
    //   ref.read(provider).box!.close();

    // }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      resizeToAvoidBottomInset: true,
      floatingActionButton: _fab(),
      activeBack: true,
      pageTitle: widget.menuItemModel.title,
      body: _body(),
    );
  }

  Widget? _fab() {
    if (ref.watch(provider).isLoading) {
      return const CircularProgressIndicator();
    }

    if (ref.watch(provider).isError) {
      return null;
    }

    if (ref.watch(provider).genericPageCreator!.context_menu == null) {
      return null;
    }
    return FloatingActionButton(
      onPressed: _showMenuPopup,
      child: const Icon(Icons.arrow_drop_up),
    );
  }

  Widget _body() {
    if (ref.watch(provider).isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (ref.watch(provider).isError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(ref.watch(provider).errorMessage),
        ),
      );
    }
    return _content();
  }

  Widget _content() {
    return ref.watch(provider).genericPageCreator!.createPage();
  }

  Widget _pageView() {
    return SizedBox(
      height: 700.smh,
      width: AppConstants.designWidth.smw,
      child: ref.watch(provider).genericPageCreator!.createPage(),
    );
  }

  Future<void> _showMenuPopup() async {
    if (kDebugMode) {
      ref.watch(provider).genericPageCreator!.submit_data.forEach((key, value) {
        for (var element in value) {
          log("submit field key: $key value: $element");
        }
      });
      log("submit fields temps${ref.read(provider).genericPageCreator!.submit_data_temps}");
    }

    await showDialog(
        context: context,
        builder: (context) {
          List<MenuItemModel> menuItems =
              ref.watch(provider).genericPageCreator!.context_menu!;
          return Dialog(
            child: ListView.builder(
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return _menuItemWidget(menuItems[index]);
              },
              itemCount: menuItems.length,
            ),
          );
        });
  }

  Widget _menuItemWidget(MenuItemModel menuItemModel, {int tabSize = 0}) {
    if (menuItemModel.subMenus != null && menuItemModel.subMenus!.isNotEmpty) {
      final returnData = ExpansionTile(
        title: Text(("\t" * tabSize * 4) + menuItemModel.title),
        children: menuItemModel.subMenus!
            .map((e) => _menuItemWidget(e, tabSize: tabSize + 1))
            .toList(),
      );
      tabSize++;
      return returnData;
    } else {
      return ListTile(
        title: Text(("\t" * tabSize * 4) + menuItemModel.title),
        onTap: () {
          if (menuItemModel.apiParams!.requestAction ==
              RequestActionEnum.Action) {
            ref
                .read(provider)
                .genericPageCreator!
                .submitToServer(menuItemModel.apiUrl!);
          } else if (menuItemModel.apiParams!.requestAction ==
              RequestActionEnum.GetRow) {
            NetworkService.post(menuItemModel.apiUrl!,
                body: RequestSchemeModel(
                    requestAction: RequestActionEnum.GetRow,
                    parameters: ref
                        .watch(provider)
                        .genericPageCreator!
                        .submit_data_temps));
          }
        },
      );
    }
  }
}

class KeepAlivePage extends StatefulWidget {
  final Widget child;
  const KeepAlivePage({super.key, required this.child});

  @override
  State<KeepAlivePage> createState() => _KeepAlivePageState();
}

class _KeepAlivePageState extends State<KeepAlivePage>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
