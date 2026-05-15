import 'package:flutter/material.dart' hide MenuController;
import 'package:get/get.dart';
import 'package:ipot_pos/components/cart_badge.dart';
import 'package:ipot_pos/components/connectivity_banner.dart';
import 'package:ipot_pos/utils/constant.dart';
import 'package:ipot_pos/utils/formatter.dart';
import '../../components/menu_item_card.dart';
import '../../navigation/app_routes.dart';
import 'package:ipot_pos/l10n/app_localizations.dart';
import '../../state/cart_controller.dart';
import '../../state/menu_controller.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tableId = Get.arguments as String? ?? 'T001';
    final menuCtrl = Get.put(MenuController());
    final cartCtrl = Get.find<CartController>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      menuCtrl.loadMenu(tableId);
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Obx(() => Text(
              menuCtrl.restaurant.value?.name ??
                  AppLocalizations.of(context)!.menu,
              style: const TextStyle(fontWeight: FontWeight.w800),
            )),
        leading: IconButton(
          icon: const Icon(Icons.qr_code_scanner),
          onPressed: () => Get.offAllNamed(AppRoutes.scanner),
        ),
        actions: const [CartBadge()],
      ),
      body: ConnectivityBanner(
        child: Obx(() {
          if (menuCtrl.isLoading.value) return const _LoadingView();
          if (menuCtrl.error.value != null) {
            return _ErrorView(
              message: menuCtrl.error.value!,
              onRetry: () => menuCtrl.loadMenu(tableId),
            );
          }
          return _MenuContent(
            menuCtrl: menuCtrl,
            tableId: tableId,
          );
        }),
      ),
      bottomNavigationBar: Obx(() {
        if (cartCtrl.itemCount == 0) return const SizedBox.shrink();
        return _CartBar(cart: cartCtrl);
      }),
    );
  }
}

class _MenuContent extends StatelessWidget {
  final MenuController menuCtrl;
  final String tableId;
  const _MenuContent({required this.tableId, required this.menuCtrl});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.md, AppSpacing.md, AppSpacing.md, 0),
          child: TextField(
            onChanged: menuCtrl.setSearch,
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.searchMenu,
              prefixIcon:
                  const Icon(Icons.search, color: AppColors.textSecondary),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        // Category tabs
        Obx(() => SizedBox(
              height: 54,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md, vertical: 8),
                itemCount: menuCtrl.categories.length,
                itemBuilder: (_, i) {
                  final cat = menuCtrl.categories[i];
                  return Obx(
                    () {
                      final isSelected =
                          menuCtrl.selectedCategoryId.value == cat.id;
                      return GestureDetector(
                        onTap: () => menuCtrl.selectCategory(cat.id),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(right: 8),
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color:
                                isSelected ? AppColors.primary : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              if (isSelected)
                                BoxShadow(
                                  color:
                                      AppColors.primary.withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                            ],
                          ),
                          child: Text(
                            cat.name,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.textSecondary,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.normal,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            )),
        // Item list
        Expanded(
          child: Obx(() {
            final items = menuCtrl.filteredItems;
            if (items.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.search_off, size: 64, color: Colors.grey),
                    const SizedBox(height: 12),
                    Text(AppLocalizations.of(context)!.noItems,
                        style: const TextStyle(color: AppColors.textSecondary)),
                  ],
                ),
              );
            }
            return RefreshIndicator(
              onRefresh: () {
                menuCtrl.loadMenu(tableId);
                return Future.delayed(const Duration(milliseconds: 500));
              },
              child: ListView.builder(
                padding: const EdgeInsets.only( bottom: 100),
                itemCount: items.length,
                itemBuilder: (_, i) => MenuItemCard(
                  item: items[i],
                  onTap: () => Get.toNamed(
                    AppRoutes.itemDetail,
                    arguments: items[i].id,
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _CartBar extends StatelessWidget {
  final CartController cart;
  const _CartBar({required this.cart});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: GestureDetector(
        onTap: () => Get.toNamed(AppRoutes.cart),
        child: Container(
          margin: const EdgeInsets.all(AppSpacing.md),
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.4),
                blurRadius: 12,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${cart.itemCount}',
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w800),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  AppLocalizations.of(context)!.viewCart,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 15),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                Formatters.price(cart.subtotal),
                textAlign: TextAlign.right,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 16),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: AppColors.accent),
          const SizedBox(height: 16),
          Text(AppLocalizations.of(context)!.loadingMenu,
              style: const TextStyle(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(AppLocalizations.of(context)!.retry),
            ),
          ],
        ),
      ),
    );
  }
}
