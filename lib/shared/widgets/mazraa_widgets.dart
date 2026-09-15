import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/state/app_controller.dart';
import '../../core/theme/app_theme.dart';
import '../../features/marketplace/domain/marketplace_models.dart';

String formatPrice(num value) =>
    '${value.toStringAsFixed(value % 1 == 0 ? 0 : 2)} ر.س';

class AppDataImage extends StatelessWidget {
  const AppDataImage(
    this.source, {
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  final String source;
  final double? width;
  final double? height;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    if (source.startsWith('http://') || source.startsWith('https://')) {
      return Image.network(
        source,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, _, _) => _placeholder(context),
      );
    }
    if (source.isNotEmpty) {
      return Image.asset(
        source,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, _, _) => _placeholder(context),
      );
    }
    return _placeholder(context);
  }

  Widget _placeholder(BuildContext context) => Container(
        width: width,
        height: height,
        color: Theme.of(context).colorScheme.primaryContainer,
        alignment: Alignment.center,
        child: Icon(
          Icons.image_outlined,
          color: Theme.of(context).colorScheme.primary,
        ),
      );
}

class AppPage extends StatelessWidget {
  const AppPage({
    super.key,
    required this.child,
    this.padding = const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 24),
    this.scrollable = true,
  });
  final Widget child;
  final EdgeInsetsGeometry padding;
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    final content = Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Padding(padding: padding, child: child),
      ),
    );
    return BotanicalBackdrop(
      child: scrollable ? SingleChildScrollView(child: content) : content,
    );
  }
}

class BotanicalBackdrop extends StatelessWidget {
  const BotanicalBackdrop({super.key, required this.child, this.dense = false});
  final Widget child;
  final bool dense;

  @override
  Widget build(BuildContext context) => CustomPaint(
    painter: _LeafPainter(
      color: Theme.of(
        context,
      ).colorScheme.primary.withValues(alpha: dense ? .10 : .055),
    ),
    child: child,
  );
}

class _LeafPainter extends CustomPainter {
  const _LeafPainter({required this.color});
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    void sprig(Offset origin, double direction) {
      final path = Path()
        ..moveTo(origin.dx, origin.dy)
        ..quadraticBezierTo(
          origin.dx + 20 * direction,
          origin.dy - 35,
          origin.dx + 10 * direction,
          origin.dy - 78,
        );
      canvas.drawPath(
        path,
        paint
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
      paint.style = PaintingStyle.fill;
      for (var i = 0; i < 4; i++) {
        final y = origin.dy - 18.0 * i - 12;
        canvas.save();
        canvas.translate(origin.dx + (4 + i * 2) * direction, y);
        canvas.rotate(direction * .55);
        canvas.drawOval(
          Rect.fromCenter(center: Offset.zero, width: 13, height: 25),
          paint,
        );
        canvas.restore();
      }
    }

    sprig(Offset(5, size.height - 2), 1);
    sprig(Offset(size.width - 5, size.height - 2), -1);
  }

  @override
  bool shouldRepaint(covariant _LeafPainter oldDelegate) =>
      oldDelegate.color != color;
}

class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 50, this.showName = false});
  final double size;
  final bool showName;

  @override
  Widget build(BuildContext context) {
    final logo = ClipRRect(
      borderRadius: BorderRadius.circular(size * .16),
      child: Image.asset(
        'assets/logos/app_logo_crop.png',
        width: size,
        height: size,
        fit: BoxFit.cover,
      ),
    );
    if (!showName) return logo;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        logo,
        const SizedBox(height: 7),
        Text(
          'مزرعتي',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }
}

class MazraaAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MazraaAppBar({
    super.key,
    this.title,
    this.actions,
    this.showLogo = true,
    this.leading,
  });
  final String? title;
  final List<Widget>? actions;
  final bool showLogo;
  final Widget? leading;

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) => AppBar(
    toolbarHeight: 64,
    leading:
        leading ??
        (Navigator.canPop(context)
            ? IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_forward_rounded),
              )
            : null),
    title: title == null
        ? (showLogo ? const AppLogo(size: 46) : null)
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showLogo) ...[
                const AppLogo(size: 36),
                const SizedBox(width: 8),
              ],
              Flexible(child: Text(title!)),
            ],
          ),
    actions: actions,
  );
}

class AppSurfaceCard extends StatelessWidget {
  const AppSurfaceCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(12),
    this.color,
  });
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;
  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<MazraaTheme>()!;
    return Material(
      color: color ?? Theme.of(context).colorScheme.surface,
      elevation: 1,
      shadowColor: Theme.of(context).colorScheme.shadow,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(tokens.cardRadius),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: .78),
        ),
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.icon,
    this.onAll,
    this.trailing,
  });
  final String title;
  final IconData? icon;
  final VoidCallback? onAll;
  final Widget? trailing;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      if (icon != null) ...[
        Icon(icon, size: 21, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 7),
      ],
      Expanded(
        child: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
      ?trailing,
      if (onAll != null)
        TextButton(onPressed: onAll, child: const Text('عرض الكل')),
    ],
  );
}

class AppSearchField extends StatelessWidget {
  const AppSearchField({
    super.key,
    this.controller,
    this.onChanged,
    this.onTap,
    this.hint = 'ابحث عن منتجات، حيوانات، ومزادات...',
    this.readOnly = false,
  });
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final String hint;
  final bool readOnly;
  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    onChanged: onChanged,
    onTap: onTap,
    readOnly: readOnly,
    decoration: InputDecoration(
      hintText: hint,
      prefixIcon: const Icon(Icons.search_rounded),
      suffixIcon: const Icon(Icons.mic_none_rounded),
      isDense: true,
    ),
  );
}

class StatusPill extends StatelessWidget {
  const StatusPill({
    super.key,
    required this.label,
    this.color = AppColors.forest,
    this.icon,
  });
  final String label;
  final Color color;
  final IconData? icon;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsetsDirectional.symmetric(horizontal: 9, vertical: 5),
    decoration: BoxDecoration(
      color: color.withValues(alpha: .12),
      borderRadius: BorderRadius.circular(30),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
        ],
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.labelMedium?.copyWith(color: color),
        ),
      ],
    ),
  );
}

class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
    this.compact = false,
  });
  final Product product;
  final VoidCallback onTap;
  final bool compact;
  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    if (compact) {
      return AppSurfaceCard(
        padding: const EdgeInsets.all(8),
        child: InkWell(
          onTap: onTap,
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: AppDataImage(
                  product.image,
                  width: 100,
                  height: 92,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(child: _ProductInfo(product: product)),
              IconButton(
                onPressed: () => controller.toggleFavorite(product.id),
                icon: Icon(
                  controller.isFavorite(product.id)
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: AppColors.terracotta,
                ),
              ),
            ],
          ),
        ),
      );
    }
    return AppSurfaceCard(
      padding: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(15),
                    ),
                    child: AppDataImage(product.image, fit: BoxFit.cover),
                  ),
                  if (product.discount != null)
                    PositionedDirectional(
                      top: 7,
                      start: 7,
                      child: StatusPill(
                        label: 'خصم ${product.discount}%',
                        color: AppColors.terracotta,
                      ),
                    ),
                  PositionedDirectional(
                    top: 5,
                    end: 5,
                    child: IconButton.filledTonal(
                      visualDensity: VisualDensity.compact,
                      onPressed: () => controller.toggleFavorite(product.id),
                      icon: Icon(
                        controller.isFavorite(product.id)
                            ? Icons.favorite
                            : Icons.favorite_border,
                        size: 18,
                        color: AppColors.terracotta,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(9),
              child: _ProductInfo(product: product),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(8, 0, 8, 9),
              child: SizedBox(
                height: 36,
                child: FilledButton.icon(
                  onPressed: () async {
                    try {
                      await controller.addToCart(product);
                    } catch (_) {
                      if (!context.mounted) return;
                      if (!controller.isAuthenticated) {
                        Navigator.pushNamed(context, '/login');
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              controller.errorMessage ?? 'تعذر إضافة المنتج للسلة',
                            ),
                          ),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.add_shopping_cart_rounded, size: 16),
                  label: const Text(
                    'أضف للسلة',
                    style: TextStyle(fontSize: 11),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductInfo extends StatelessWidget {
  const _ProductInfo({required this.product});
  final Product product;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        product.name,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
      const SizedBox(height: 3),
      FittedBox(
        fit: BoxFit.scaleDown,
        alignment: AlignmentDirectional.centerStart,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.star_rounded, color: Color(0xFFE5A72D), size: 15),
            Text(
              ' ${product.rating} (${product.reviews})',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.muted),
            ),
          ],
        ),
      ),
      const SizedBox(height: 5),
      Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 6,
        children: [
          Text(
            formatPrice(product.price),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          if (product.oldPrice != null)
            Text(
              formatPrice(product.oldPrice!),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.muted,
                decoration: TextDecoration.lineThrough,
              ),
            ),
        ],
      ),
    ],
  );
}

class AuctionCard extends StatelessWidget {
  const AuctionCard({
    super.key,
    required this.auction,
    required this.onTap,
    this.compact = false,
  });
  final Auction auction;
  final VoidCallback onTap;
  final bool compact;
  @override
  Widget build(BuildContext context) => AppSurfaceCard(
    padding: EdgeInsets.zero,
    child: InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Stack(
            children: [
              AspectRatio(
                aspectRatio: compact ? 1.7 : 1.4,
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(15),
                  ),
                  child: AppDataImage(auction.image, fit: BoxFit.cover),
                ),
              ),
              PositionedDirectional(
                top: 7,
                start: 7,
                child: StatusPill(
                  label: auction.state == AuctionState.live ? 'مباشر' : 'قادم',
                  color: auction.state == AuctionState.live
                      ? AppColors.terracotta
                      : AppColors.forest,
                  icon: Icons.circle,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(9),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  auction.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                Text(
                  auction.category,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppColors.muted),
                ),
                const SizedBox(height: 6),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: AlignmentDirectional.centerStart,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        formatPrice(auction.currentBid),
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      AuctionTimer(duration: auction.remaining, small: true),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 36,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(15),
                  ),
                ),
              ),
              onPressed: onTap,
              icon: const Icon(Icons.gavel_rounded, size: 16),
              label: const Text('زايد الآن', style: TextStyle(fontSize: 11)),
            ),
          ),
        ],
      ),
    ),
  );
}

class AuctionTimer extends StatefulWidget {
  const AuctionTimer({super.key, required this.duration, this.small = false});
  final Duration duration;
  final bool small;
  @override
  State<AuctionTimer> createState() => _AuctionTimerState();
}

class _AuctionTimerState extends State<AuctionTimer> {
  late Duration remaining = widget.duration;
  Timer? _timer;
  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (remaining.inSeconds > 0 && mounted) {
        setState(() => remaining -= const Duration(seconds: 1));
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final h = remaining.inHours.toString().padLeft(2, '0');
    final m = (remaining.inMinutes % 60).toString().padLeft(2, '0');
    final s = (remaining.inSeconds % 60).toString().padLeft(2, '0');
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.timer_outlined,
            size: widget.small ? 14 : 20,
            color: AppColors.terracotta,
          ),
          const SizedBox(width: 3),
          Text(
            '$h:$m:$s',
            style: TextStyle(
              fontFeatures: const [FontFeature.tabularFigures()],
              color: AppColors.terracotta,
              fontWeight: FontWeight.w700,
              fontSize: widget.small ? 12 : 22,
            ),
          ),
        ],
      ),
    );
  }
}

class QuantityStepper extends StatelessWidget {
  const QuantityStepper({
    super.key,
    required this.value,
    required this.onChanged,
  });
  final int value;
  final ValueChanged<int> onChanged;
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.primaryContainer,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          visualDensity: VisualDensity.compact,
          onPressed: () => onChanged(value - 1),
          icon: const Icon(Icons.remove, size: 17),
        ),
        Text('$value', style: Theme.of(context).textTheme.labelLarge),
        IconButton(
          visualDensity: VisualDensity.compact,
          onPressed: () => onChanged(value + 1),
          icon: const Icon(Icons.add, size: 17),
        ),
      ],
    ),
  );
}

enum ResultKind { success, empty, error, offline, pending }

class ResultStateView extends StatelessWidget {
  const ResultStateView({
    super.key,
    required this.title,
    required this.message,
    required this.kind,
    this.primaryLabel = 'العودة للرئيسية',
    this.onPrimary,
    this.secondaryLabel,
    this.onSecondary,
    this.details,
  });
  final String title;
  final String message;
  final ResultKind kind;
  final String primaryLabel;
  final VoidCallback? onPrimary;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;
  final Widget? details;
  @override
  Widget build(BuildContext context) {
    final (icon, color) = switch (kind) {
      ResultKind.success => (Icons.check_circle_rounded, AppColors.success),
      ResultKind.empty => (Icons.eco_rounded, AppColors.forest),
      ResultKind.error => (Icons.error_rounded, AppColors.error),
      ResultKind.offline => (
        Icons.signal_wifi_connected_no_internet_4_rounded,
        AppColors.terracotta,
      ),
      ResultKind.pending => (Icons.schedule_rounded, AppColors.warning),
    };
    return AppPage(
      scrollable: false,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              color: color.withValues(alpha: .10),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 86),
          ),
          const SizedBox(height: 28),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 9),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: AppColors.muted),
          ),
          if (details != null) ...[const SizedBox(height: 24), details!],
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed:
                  onPrimary ??
                  () =>
                      Navigator.of(context).popUntil((route) => route.isFirst),
              child: Text(primaryLabel),
            ),
          ),
          if (secondaryLabel != null) ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onSecondary,
                child: Text(secondaryLabel!),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class SettingsTile extends StatelessWidget {
  const SettingsTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
    this.trailing,
  });
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;
  @override
  Widget build(BuildContext context) => AppSurfaceCard(
    padding: EdgeInsets.zero,
    child: ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Theme.of(context).colorScheme.primary),
      ),
      title: Text(title),
      subtitle: subtitle == null ? null : Text(subtitle!),
      trailing:
          trailing ?? const Icon(Icons.arrow_back_ios_new_rounded, size: 16),
    ),
  );
}
