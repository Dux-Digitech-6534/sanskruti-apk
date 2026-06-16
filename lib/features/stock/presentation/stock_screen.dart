import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_drawer.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../l10n/app_localizations.dart';
import '../../../repositories/stock_repository.dart';
import 'stock_controller.dart';

class StockScreen extends ConsumerStatefulWidget {
  const StockScreen({super.key});

  @override
  ConsumerState<StockScreen> createState() => _StockScreenState();
}

class _StockScreenState extends ConsumerState<StockScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      _searchController.clear();
      ref.read(stockControllerProvider.notifier).clearSearchAndRefresh();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(stockControllerProvider);
    final controller = ref.read(stockControllerProvider.notifier);
    final visibleItems = state.visibleItems;

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: CustomAppBar(
        title: context.l10n.t('stock_overview'),
        showMenuButton: true,
      ),
      body: RefreshIndicator(
        onRefresh: controller.load,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            AppTextField(
              controller: _searchController,
              hintText: context.l10n.t('search_item_or_warehouse'),
              prefixIcon: Icons.search,
              textInputAction: TextInputAction.search,
              onChanged: controller.setSearch,
            ),
            const SizedBox(height: 16),
            if (state.isLoading)
              const Padding(
                padding: EdgeInsets.only(top: 100),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (state.errorMessage != null)
              _MessageState(
                message: state.errorMessage!,
                onRetry: controller.load,
              )
            else if (visibleItems.isEmpty)
              _MessageState(
                message: context.l10n.t('no_stock_records_found'),
                onRetry: controller.load,
              )
            else
              ...visibleItems.map(_StockCard.new),
          ],
        ),
      ),
    );
  }
}

class _StockCard extends StatelessWidget {
  const _StockCard(this.item);

  final StockBin item;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.itemCode,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 8),
                Text(
                  item.warehouse,
                  style: const TextStyle(color: AppColors.mutedText),
                ),
              ],
            ),
          ),
          Text(
            _formatQty(item.actualQty),
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w900,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageState extends StatelessWidget {
  const _MessageState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 100),
      child: Column(
        children: [
          Text(context.l10n.message(message), textAlign: TextAlign.center),
          const SizedBox(height: 12),
          TextButton(onPressed: onRetry, child: Text(context.l10n.t('retry'))),
        ],
      ),
    );
  }
}

String _formatQty(double value) {
  if (value == value.roundToDouble()) return value.toStringAsFixed(0);
  return value.toStringAsFixed(2);
}
