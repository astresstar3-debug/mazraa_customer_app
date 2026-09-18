import 'package:flutter/material.dart';

import '../../../core/state/app_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/mazraa_widgets.dart';
import '../domain/marketplace_models.dart';
import 'unified_product_details_screen.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final categories = AppScope.of(context).repository.categories;
    final icons = [
      Icons.gavel_rounded,
      Icons.shopping_basket_rounded,
      Icons.pets_rounded,
      Icons.eco_rounded,
      Icons.grass_rounded,
      Icons.compost_rounded,
      Icons.agriculture_rounded,
      Icons.medication_liquid_rounded,
      Icons.inventory_2_rounded,
      Icons.hive_rounded,
    ];
    return Scaffold(
      appBar: const MazraaAppBar(title: 'الأقسام'),
      body: AppPage(
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.55,
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) => AppSurfaceCard(
            padding: EdgeInsets.zero,
            child: InkWell(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProductListScreen(title: categories[index]),
                ),
              ),
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: index.isOdd
                            ? AppColors.terracottaSoft
                            : AppColors.forestSoft,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        icons[index],
                        color: index.isOdd
                            ? AppColors.terracotta
                            : AppColors.forest,
                      ),
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            categories[index],
                            maxLines: 2,
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                          Text(
                            '${12 + index * 7} منتج',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: AppColors.muted),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final controller = TextEditingController();
  String query = '';
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final results = app.products
        .where((p) => p.name.contains(query) || p.category.contains(query))
        .toList();
    return Scaffold(
      appBar: const MazraaAppBar(title: 'البحث'),
      body: AppPage(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppSearchField(
              controller: controller,
              onChanged: (value) => setState(() => query = value),
            ),
            const SizedBox(height: 18),
            if (query.isEmpty) ...[
              const SectionHeader(
                title: 'عمليات البحث الأخيرة',
                icon: Icons.history_rounded,
              ),
              Wrap(
                spacing: 7,
                runSpacing: 7,
                children:
                    ['بذور طماطم', 'خروف نعيمي', 'عسل سدر', 'أدوية بيطرية']
                        .map(
                          (e) => InputChip(
                            label: Text(e),
                            onPressed: () {
                              controller.text = e;
                              setState(() => query = e);
                            },
                          ),
                        )
                        .toList(),
              ),
              const SizedBox(height: 20),
              const SectionHeader(
                title: 'الأكثر بحثًا',
                icon: Icons.trending_up_rounded,
              ),
              ...[
                'بذور طماطم',
                'علف مواشي',
                'أسمدة عضوية',
                'جرار صغير',
                'خلية نحل',
              ].asMap().entries.map(
                (entry) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: AppColors.terracottaSoft,
                    child: Text(
                      '${entry.key + 1}',
                      style: const TextStyle(color: AppColors.terracotta),
                    ),
                  ),
                  title: Text(entry.value),
                  trailing: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 15,
                  ),
                  onTap: () {
                    controller.text = entry.value;
                    setState(() => query = entry.value);
                  },
                ),
              ),
              const SizedBox(height: 12),
              const SectionHeader(
                title: 'تصفح حسب الفئات',
                icon: Icons.grid_view_rounded,
              ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: app.repository.categories
                    .skip(2)
                    .take(6)
                    .map(
                      (e) => ActionChip(
                        avatar: const Icon(Icons.eco_rounded, size: 17),
                        label: Text(e),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ProductListScreen(title: e),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ] else if (results.isEmpty)
              SizedBox(
                height: MediaQuery.sizeOf(context).height * .62,
                child: ResultStateView(
                  kind: ResultKind.empty,
                  title: 'لم نجد نتائج مطابقة',
                  message: 'جرّب كلمات أخرى أو تصفح الأقسام المقترحة',
                  primaryLabel: 'عرض كل المنتجات',
                  onPrimary: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ProductListScreen(),
                    ),
                  ),
                ),
              )
            else ...[
              SectionHeader(
                title: 'نتائج البحث عن $query',
                icon: Icons.eco_rounded,
                trailing: Text('${results.length} نتيجة'),
              ),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: .62,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                ),
                itemCount: results.length,
                itemBuilder: (_, i) => ProductCard(
                  product: results[i],
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProductDetailsScreen(product: results[i]),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key, this.title = 'جميع المنتجات'});
  final String title;
  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  bool grid = true;
  String sort = 'الأكثر مبيعًا';
  @override
  Widget build(BuildContext context) {
    final all = AppScope.of(context).products;
    final products = all
        .where(
          (p) =>
              widget.title == 'جميع المنتجات' ||
              widget.title == 'التسوق' ||
              p.category.contains(widget.title) ||
              (widget.title == 'حيوانات' && p.kind == ProductKind.animal),
        )
        .toList();
    final visible = products.isEmpty ? all : products;
    return Scaffold(
      appBar: MazraaAppBar(
        title: widget.title,
        actions: [
          IconButton(
            onPressed: () => Navigator.pushNamed(context, '/search'),
            icon: const Icon(Icons.search_rounded),
          ),
        ],
      ),
      body: AppPage(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _showFilters,
                    icon: const Icon(Icons.tune_rounded),
                    label: const Text('فلترة'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: sort,
                    decoration: const InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsetsDirectional.symmetric(
                        horizontal: 10,
                        vertical: 10,
                      ),
                    ),
                    items: ['الأكثر مبيعًا', 'الأعلى تقييمًا', 'السعر: الأقل']
                        .map(
                          (e) => DropdownMenuItem(
                            value: e,
                            child: Text(
                              e,
                              style: const TextStyle(fontSize: 11),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) => setState(() => sort = value!),
                  ),
                ),
                const SizedBox(width: 8),
                SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment(
                      value: true,
                      icon: Icon(Icons.grid_view_rounded),
                    ),
                    ButtonSegment(
                      value: false,
                      icon: Icon(Icons.view_list_rounded),
                    ),
                  ],
                  selected: {grid},
                  showSelectedIcon: false,
                  onSelectionChanged: (value) =>
                      setState(() => grid = value.first),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'تم العثور على ${visible.length * 12} منتج',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.muted),
            ),
            const SizedBox(height: 8),
            if (grid)
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: .62,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                ),
                itemCount: visible.length,
                itemBuilder: (_, i) => ProductCard(
                  product: visible[i],
                  onTap: () => _open(visible[i]),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: visible.length,
                separatorBuilder: (_, _) => const SizedBox(height: 9),
                itemBuilder: (_, i) => ProductCard(
                  product: visible[i],
                  compact: true,
                  onTap: () => _open(visible[i]),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _open(Product product) => Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => ProductDetailsScreen(product: product)),
  );
  void _showFilters() => showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => const ProductFilterSheet(),
  );
}

class ProductFilterSheet extends StatefulWidget {
  const ProductFilterSheet({super.key});
  @override
  State<ProductFilterSheet> createState() => _ProductFilterSheetState();
}

class _ProductFilterSheetState extends State<ProductFilterSheet> {
  RangeValues prices = const RangeValues(100, 7000);
  int rating = 4;
  @override
  Widget build(BuildContext context) => SafeArea(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(
                'تصفية وترتيب',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const Spacer(),
              TextButton(
                onPressed: () => setState(() {
                  prices = const RangeValues(100, 7000);
                  rating = 4;
                }),
                child: const Text('مسح الكل'),
              ),
            ],
          ),
          const SectionHeader(title: 'نطاق السعر', icon: Icons.sell_outlined),
          RangeSlider(
            values: prices,
            min: 0,
            max: 10000,
            divisions: 20,
            labels: RangeLabels(
              formatPrice(prices.start),
              formatPrice(prices.end),
            ),
            onChanged: (value) => setState(() => prices = value),
          ),
          const SectionHeader(
            title: 'التقييم',
            icon: Icons.star_outline_rounded,
          ),
          SegmentedButton<int>(
            segments: List.generate(
              5,
              (i) => ButtonSegment(value: i + 1, label: Text('${i + 1}+')),
            ),
            selected: {rating},
            onSelectionChanged: (value) => setState(() => rating = value.first),
          ),
          const SizedBox(height: 16),
          const SectionHeader(title: 'التصنيف', icon: Icons.category_outlined),
          const Wrap(
            spacing: 7,
            runSpacing: 7,
            children: [
              FilterChip(
                label: Text('زراعة'),
                selected: true,
                onSelected: null,
              ),
              FilterChip(
                label: Text('حيوانات'),
                selected: false,
                onSelected: null,
              ),
              FilterChip(
                label: Text('أعلاف'),
                selected: false,
                onSelected: null,
              ),
              FilterChip(
                label: Text('معدات'),
                selected: false,
                onSelected: null,
              ),
            ],
          ),
          const SizedBox(height: 22),
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('عرض النتائج'),
          ),
        ],
      ),
    ),
  );
}

class ProductDetailsScreen extends StatelessWidget {
  const ProductDetailsScreen({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) =>
      UnifiedProductDetailsScreen(product: product);
}

class ReviewsScreen extends StatelessWidget {
  const ReviewsScreen({super.key, required this.product});
  final Product product;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: const MazraaAppBar(title: 'التقييمات والأسئلة'),
    bottomNavigationBar: SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: FilledButton.icon(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AskQuestionScreen(product: product),
            ),
          ),
          icon: const Icon(Icons.chat_bubble_outline_rounded),
          label: const Text('اطرح سؤالًا'),
        ),
      ),
    ),
    body: AppPage(
      child: Column(
        children: [
          AppSurfaceCard(
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    product.image,
                    width: 100,
                    height: 78,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Row(
                        children: [
                          Text(
                            '${product.rating}',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(width: 6),
                          const Icon(
                            Icons.star_rounded,
                            color: Color(0xFFE5A72D),
                          ),
                        ],
                      ),
                      Text('${product.reviews} تقييم'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ...[
            'جودة ممتازة والتغليف أنيق ووصل المنتج في الموعد.',
            'منتج طبيعي ومطابق للوصف، سأكرر الشراء.',
            'تجربة جيدة وخدمة سريعة من البائع.',
          ].asMap().entries.map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: 9),
              child: AppSurfaceCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(child: Text('${e.key + 1}')),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            ['أم محمد', 'سالم المطيري', 'نورة القحطاني'][e.key],
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                        ),
                        const Text(
                          '★★★★★',
                          style: TextStyle(color: Color(0xFFE5A72D)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(e.value),
                    const SizedBox(height: 7),
                    const Row(
                      children: [
                        Icon(Icons.thumb_up_alt_outlined, size: 15),
                        Text(' مفيد'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class AskQuestionScreen extends StatelessWidget {
  const AskQuestionScreen({super.key, required this.product});
  final Product product;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: const MazraaAppBar(title: 'اطرح سؤالًا'),
    body: AppPage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppSurfaceCard(
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    product.image,
                    width: 82,
                    height: 68,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    product.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const TextField(
            maxLines: 7,
            maxLength: 500,
            decoration: InputDecoration(hintText: 'اكتب سؤالك عن المنتج'),
          ),
          CheckboxListTile(
            value: false,
            onChanged: (_) {},
            title: const Text('نشر السؤال بدون اسم'),
            contentPadding: EdgeInsets.zero,
          ),
          const SectionHeader(
            title: 'أسئلة مقترحة',
            icon: Icons.lightbulb_outline_rounded,
          ),
          const Wrap(
            spacing: 7,
            children: [
              Chip(label: Text('ما مدة الصلاحية؟')),
              Chip(label: Text('ما طريقة الاستخدام؟')),
              Chip(label: Text('هل المنتج طبيعي؟')),
            ],
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('تم إرسال سؤالك')));
              Navigator.pop(context);
            },
            icon: const Icon(Icons.send_rounded),
            label: const Text('إرسال السؤال'),
          ),
        ],
      ),
    ),
  );
}

class OffersScreen extends StatelessWidget {
  const OffersScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final products = AppScope.of(
      context,
    ).products.where((p) => p.discount != null).toList();
    return Scaffold(
      appBar: const MazraaAppBar(title: 'العروض'),
      body: AppPage(
        child: Column(
          children: [
            Container(
              height: 138,
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                image: DecorationImage(
                  image: AssetImage(products.first.image),
                  fit: BoxFit.cover,
                  colorFilter: const ColorFilter.mode(
                    Color(0x77552B11),
                    BlendMode.darken,
                  ),
                ),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'عرض موسم الزراعة',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'خصم حتى 30%',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  StatusPill(label: 'ينتهي خلال 02:15:44', color: Colors.white),
                ],
              ),
            ),
            const SizedBox(height: 14),
            const Wrap(
              spacing: 8,
              children: [
                ChoiceChip(label: Text('الكل'), selected: true),
                ChoiceChip(label: Text('ينتهي قريبًا'), selected: false),
                ChoiceChip(label: Text('الأكثر توفيرًا'), selected: false),
              ],
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: .62,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
              ),
              itemCount: products.length,
              itemBuilder: (_, i) => ProductCard(
                product: products[i],
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProductDetailsScreen(product: products[i]),
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

class CouponScreen extends StatelessWidget {
  const CouponScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: const MazraaAppBar(),
    body: AppPage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'كوبون خاص لك',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(color: AppColors.forest),
          ),
          const SizedBox(height: 16),
          Container(
            height: 180,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  AppColors.forestDark,
                  AppColors.forest,
                  AppColors.terracotta,
                ],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  'FARM20',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                VerticalDivider(
                  color: Colors.white54,
                  indent: 30,
                  endIndent: 30,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('خصم', style: TextStyle(color: Colors.white)),
                    Text(
                      '20%',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 42,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const AppSurfaceCard(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.calendar_month_rounded),
                  title: Text('صالح حتى'),
                  trailing: Text('30 سبتمبر 2026'),
                ),
                Divider(),
                ListTile(
                  leading: Icon(Icons.shopping_cart_checkout_rounded),
                  title: Text('الحد الأدنى للطلب'),
                  trailing: Text('150 ر.س'),
                ),
                Divider(),
                ListTile(
                  leading: Icon(Icons.category_outlined),
                  title: Text('الفئات المشمولة'),
                  subtitle: Text('المنتجات الزراعية ومستلزمات النحل'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تم نسخ FARM20')),
                  ),
                  icon: const Icon(Icons.copy_rounded),
                  label: const Text('نسخ الكود'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ProductListScreen(),
                    ),
                  ),
                  icon: const Icon(Icons.shopping_cart_outlined),
                  label: const Text('تسوق الآن'),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
