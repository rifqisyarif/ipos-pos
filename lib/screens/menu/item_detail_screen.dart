import 'package:flutter/material.dart' hide MenuController;
import 'package:get/get.dart';
import 'package:ipot_pos/components/connectivity_banner.dart';
import 'package:ipot_pos/utils/constant.dart';
import 'package:ipot_pos/utils/formatter.dart';
import '../../components/customization_sheet.dart';
import 'package:ipot_pos/l10n/app_localizations.dart';
import '../../state/menu_controller.dart';

class ItemDetailScreen extends StatelessWidget {
  const ItemDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final itemId = Get.arguments as int;
    final menuCtrl = Get.find<MenuController>();
    final item = menuCtrl.getById(itemId);

    if (item == null) {
      return Scaffold(
        appBar: AppBar(title: Text(AppLocalizations.of(context)!.itemNotFound)),
        body: Center(child: Text(AppLocalizations.of(context)!.itemNotFound)),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: ConnectivityBanner(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 240,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  color: AppColors.primary.withOpacity(0.08),
                  child: Center(
                    child: Text(
                      item.name[0],
                      style: TextStyle(
                        fontSize: 100,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary.withOpacity(0.15),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            item.name,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            Formatters.price(item.price),
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: AppColors.accent,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item.description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                    if (item.customizationGroups.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      Text(
                        AppLocalizations.of(context)!.customizationsAvailable,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: item.customizationGroups
                            .map((g) => Chip(
                                  label: Text(g.name),
                                  backgroundColor:
                                      AppColors.primary.withOpacity(0.08),
                                  labelStyle: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.primary,
                                  ),
                                ))
                            .toList(),
                      ),
                    ],
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => CustomizationSheet.show(item),
                        icon: const Icon(Icons.add_shopping_cart),
                        label: Text(
                          AppLocalizations.of(context)!.addToCart,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
