import 'package:flutter/material.dart';

import '../../../core/state/app_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/mazraa_widgets.dart';
import '../domain/marketplace_models.dart';
import 'connected_marketplace_screens.dart';
import 'reference_marketplace_screens.dart';

class MatchedCategoriesScreen extends StatelessWidget {
  const MatchedCategoriesScreen({super.key});

  static const _items = <_CategoryVisual>[
    _CategoryVisual('بذور', '124 منتج', Icons.grass_rounded, 'assets/images/home/date_seedlings.png', false),
    _CategoryVisual('أسمدة', '98 منتج', Icons.inventory_2_outlined, 'assets/images/home/fresh_herbs.png', true),
    _CategoryVisual('مبيدات', '78 منتج', Icons.science_outlined, 'assets/images/home/livestock_feed.png', false),
    _CategoryVisual('أدوات زراعية', '143 منتج', Icons.handyman_outlined, 'assets/images/home/date_seedlings.png', true),
    _CategoryVisual('أعلاف', '97 منتج', Icons.agriculture_rounded, 'assets/images/home/livestock_feed.png', false),
    _CategoryVisual('أدوية بيطرية', '83 منتج', Icons.vaccines_outlined, 'assets/images/home/local_calf.png', true),
    _CategoryVisual('مستلزمات حيوانية', '72 منتج', Icons.home_work_outlined, 'assets/images/home/najdi_sheep.png', false),
    _CategoryVisual('ري ومضخات', '56 منتج', Icons.water_drop_outlined, 'assets/images/home/fresh_herbs.png', true),
    _CategoryVisual('مستلزمات النحل', '34 منتج', Icons.hive_outlined, 'assets/images/home/sidr_honey.png', false),
    _CategoryVisual('معدات زراعية', '61 منتج', Icons.agriculture_outlined, 'assets/images/home/date_seedlings.png', true),
    _CategoryVisual('حيوانات', '48 منتج', Icons.pets_outlined, 'assets/images/home/najdi_sheep.png', false),
    _CategoryVisual('منتجات زراعية', '93 منتج', Icons.local_florist_outlined, 'assets/images/home/dates.png', true),
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: MazraaAppBar(
          title: 'الأقسام',
          actions: [
            IconButton(
              onPressed: () => Navigator.pushNamed(context, '/search'),
              icon: const Icon(Icons.search_rounded),
            ),
          ],
        ),
        body: AppPage(
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _items.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.72,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemBuilder: (context, index) => _CompactCategoryCard(item: _items[index]),
          ),
        ),
        bottomNavigationBar: const _ReferenceBottomNav(selected: 2),
      );
}

class _CategoryVisual {
  const _CategoryVisual(this.name, this.count, this.icon, this.image, this.terracotta);
  final String name;
  final String count;
  final IconData icon;
  final String image;
  final bool terracotta;
}

class _CompactCategoryCard extends StatelessWidget {
  const _CompactCategoryCard({required this.item});
  final _CategoryVisual item;

  @override
  Widget build(BuildContext context) => InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ReferenceProductListScreen(title: item.name)),
        ),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
            boxShadow: const [
              BoxShadow(color: Color(0x0A173D28), blurRadius: 10, offset: Offset(0, 3)),
            ],
          ),
          child: Row(
            textDirection: TextDirection.rtl,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 44,
                      height: 39,
                      decoration: BoxDecoration(
                        color: item.terracotta ? AppColors.terracotta : AppColors.forestDark,
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: Icon(item.icon, color: Colors.white, size: 23),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      item.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.forestDark,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.forestSoft,
                            borderRadius: BorderRadius.circular(9),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.eco_rounded, color: AppColors.forest, size: 12),
                              const SizedBox(width: 3),
                              Text(item.count, style: const TextStyle(fontSize: 8.5, color: AppColors.forestDark)),
                            ],
                          ),
                        ),
                        const Spacer(),
                        const CircleAvatar(
                          radius: 11,
                          backgroundColor: AppColors.forestSoft,
                          child: Icon(Icons.arrow_back_ios_new_rounded, size: 10, color: AppColors.forest),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 7),
              ClipRRect(
                borderRadius: BorderRadius.circular(13),
                child: SizedBox(
                  width: 72,
                  height: double.infinity,
                  child: AppDataImage(item.image, fit: BoxFit.cover),
                ),
              ),
            ],
          ),
        ),
      );
}

class MatchedSearchScreen extends StatefulWidget {
  const MatchedSearchScreen({super.key});

  @override
  State<MatchedSearchScreen> createState() => _MatchedSearchScreenState();
}

class _MatchedSearchScreenState extends State<MatchedSearchScreen> {
  final controller = TextEditingController(text: 'بذور طماطم');

  static const _recent = <_RecentSearch>[
    _RecentSearch('بذور قمح', '🌾'),
    _RecentSearch('علف مواشي', '🐂'),
    _RecentSearch('أدوية بيطرية', '🧴'),
  ];

  static const _trending = <_RecentSearch>[
    _RecentSearch('بذور طماطم', '🍅'),
    _RecentSearch('علف مواشي', '🐄'),
    _RecentSearch('أسمدة زراعية', '🌱'),
    _RecentSearch('بذور قمح', '🌾'),
    _RecentSearch('أدوية بيطرية', '🧴'),
  ];

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _search(String text) {
    final query = text.trim().isEmpty ? 'عسل' : text.trim();
    Navigator.push(context, MaterialPageRoute(builder: (_) => ReferenceSearchResultsScreen(query: query)));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: const MazraaAppBar(title: 'البحث'),
        body: AppPage(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: controller,
                onSubmitted: _search,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'ابحث عن منتج أو قسم',
                  prefixIcon: const Icon(Icons.search_rounded, color: AppColors.forestDark),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        decoration: const BoxDecoration(color: AppColors.forestSoft, shape: BoxShape.circle),
                        child: IconButton(
                          visualDensity: VisualDensity.compact,
                          onPressed: () {},
                          icon: const Icon(Icons.mic_none_rounded, color: AppColors.forestDark),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        margin: const EdgeInsetsDirectional.only(end: 6, top: 6, bottom: 6),
                        decoration: BoxDecoration(color: AppColors.forestDark, borderRadius: BorderRadius.circular(10)),
                        child: IconButton(
                          visualDensity: VisualDensity.compact,
                          onPressed: () {},
                          icon: const Icon(Icons.photo_camera_outlined, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 22),
              const _MatchedSectionTitle('عمليات البحث الأخيرة', Icons.history_rounded),
              const SizedBox(height: 11),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _recent
                    .map((item) => InputChip(
                          label: Text('${item.emoji}  ${item.text}'),
                          onDeleted: () {},
                          deleteIcon: const Icon(Icons.close_rounded, size: 16),
                          onPressed: () => _search(item.text),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 24),
              const _MatchedSectionTitle('الأكثر بحثًا', Icons.trending_up_rounded),
              const SizedBox(height: 10),
              ...List.generate(
                _trending.length,
                (index) => Padding(
                  padding: const EdgeInsets.only(bottom: 7),
                  child: InkWell(
                    onTap: () => _search(_trending[index].text),
                    borderRadius: BorderRadius.circular(13),
                    child: Container(
                      height: 52,
                      padding: const EdgeInsets.symmetric(horizontal: 11),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(13),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 17,
                            backgroundColor: AppColors.forestSoft,
                            child: Text(_trending[index].emoji, style: const TextStyle(fontSize: 17)),
                          ),
                          const SizedBox(width: 9),
                          Expanded(
                            child: Text(
                              _trending[index].text,
                              style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.forestDark),
                            ),
                          ),
                          CircleAvatar(
                            radius: 14,
                            backgroundColor: AppColors.terracotta,
                            child: Text(
                              '${index + 1}',
                              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900),
                            ),
                          ),
                          const SizedBox(width: 7),
                          const Icon(Icons.arrow_back_ios_new_rounded, size: 14, color: AppColors.muted),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              const _MatchedSectionTitle('تصفح حسب الفئات', Icons.grid_view_rounded),
              const SizedBox(height: 10),
              SizedBox(
                height: 128,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: const [
                    _SearchImageCategory('بذور', Icons.grass_rounded, 'assets/images/home/date_seedlings.png'),
                    _SearchImageCategory('أعلاف', Icons.agriculture_rounded, 'assets/images/home/livestock_feed.png'),
                    _SearchImageCategory('أسمدة', Icons.compost_rounded, 'assets/images/home/fresh_herbs.png'),
                    _SearchImageCategory('مستلزمات النحل', Icons.hive_outlined, 'assets/images/home/sidr_honey.png'),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: const _ReferenceBottomNav(selected: 1),
      );
}

class _RecentSearch {
  const _RecentSearch(this.text, this.emoji);
  final String text;
  final String emoji;
}

class _SearchImageCategory extends StatelessWidget {
  const _SearchImageCategory(this.label, this.icon, this.image);
  final String label;
  final IconData icon;
  final String image;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsetsDirectional.only(end: 9),
        child: InkWell(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ReferenceProductListScreen(title: label)),
          ),
          borderRadius: BorderRadius.circular(15),
          child: Container(
            width: 104,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                Expanded(child: SizedBox(width: double.infinity, child: AppDataImage(image, fit: BoxFit.cover))),
                Transform.translate(
                  offset: const Offset(0, -12),
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColors.forest,
                    child: Icon(icon, size: 18, color: Colors.white),
                  ),
                ),
                Transform.translate(
                  offset: const Offset(0, -8),
                  child: Text(label, style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w900)),
                ),
              ],
            ),
          ),
        ),
      );
}

class MatchedEmptySearchScreen extends StatelessWidget {
  const MatchedEmptySearchScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: const MazraaAppBar(title: 'نتائج البحث'),
        body: AppPage(
          child: Column(
            children: [
              Container(
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.search_rounded, color: AppColors.muted),
                    SizedBox(width: 8),
                    Expanded(child: Text('منتج غير موجود', style: TextStyle(color: AppColors.muted))),
                    Icon(Icons.close_rounded, size: 18, color: AppColors.muted),
                  ],
                ),
              ),
              const SizedBox(height: 42),
              Container(
                width: 150,
                height: 150,
                decoration: const BoxDecoration(color: AppColors.forestSoft, shape: BoxShape.circle),
                child: const Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(Icons.shopping_basket_outlined, size: 78, color: AppColors.terracotta),
                    Positioned(right: 20, bottom: 20, child: CircleAvatar(radius: 25, backgroundColor: AppColors.ivory, child: Icon(Icons.search_rounded, size: 32, color: AppColors.forestDark))),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              const Text(
                'لم نجد نتائج مطابقة',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.forestDark),
              ),
              const SizedBox(height: 7),
              const Text(
                'جرّب كلمات بحث أخرى أو تصفح الأقسام المقترحة',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.muted),
              ),
              const SizedBox(height: 26),
              const Align(alignment: AlignmentDirectional.centerStart, child: _MatchedSectionTitle('الأقسام المقترحة', Icons.grid_view_rounded)),
              const SizedBox(height: 10),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                childAspectRatio: 3.1,
                crossAxisSpacing: 9,
                mainAxisSpacing: 9,
                children: const [
                  _SuggestionTile('بذور', Icons.grass_rounded),
                  _SuggestionTile('أسمدة', Icons.compost_rounded),
                  _SuggestionTile('أعلاف', Icons.agriculture_rounded),
                  _SuggestionTile('أدوية بيطرية', Icons.vaccines_outlined),
                ],
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false),
                  icon: const Icon(Icons.home_outlined),
                  label: const Text('العودة للرئيسية'),
                ),
              ),
            ],
          ),
        ),
      );
}

class _SuggestionTile extends StatelessWidget {
  const _SuggestionTile(this.label, this.icon);
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: () => Navigator.pushNamed(context, '/categories'),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(color: AppColors.forestSoft, borderRadius: BorderRadius.circular(9)),
                child: Icon(icon, size: 18, color: AppColors.forestDark),
              ),
              const SizedBox(width: 8),
              Expanded(child: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800))),
              const Icon(Icons.arrow_back_ios_new_rounded, size: 11, color: AppColors.muted),
            ],
          ),
        ),
      );
}

class MatchedFavoritesScreen extends StatelessWidget {
  const MatchedFavoritesScreen({super.key, this.empty = false, this.plantEmpty = false});
  final bool empty;
  final bool plantEmpty;

  @override
  Widget build(BuildContext context) {
    final products = AppScope.of(context).products.take(4).toList();
    return Scaffold(
      appBar: const MazraaAppBar(title: 'المفضلة'),
      body: empty || plantEmpty ? _empty(context) : _filled(context, products),
      bottomNavigationBar: const _ReferenceBottomNav(selected: 4),
    );
  }

  Widget _empty(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 24, 28, 50),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(color: AppColors.forestSoft, borderRadius: BorderRadius.circular(18)),
                child: const Text('الحالة الفارغة  🤎', style: TextStyle(fontSize: 10.5, color: AppColors.forestDark, fontWeight: FontWeight.w800)),
              ),
              const SizedBox(height: 28),
              Container(
                width: 160,
                height: 160,
                decoration: const BoxDecoration(color: AppColors.forestSoft, shape: BoxShape.circle),
                child: Icon(
                  plantEmpty ? Icons.eco_rounded : Icons.inventory_2_outlined,
                  size: 88,
                  color: plantEmpty ? AppColors.forest : AppColors.terracotta,
                ),
              ),
              const SizedBox(height: 28),
              Text(
                plantEmpty ? 'لا توجد منتجات محفوظة' : 'لا توجد منتجات محفوظة',
                style: const TextStyle(fontSize: 22, color: AppColors.forestDark, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 7),
              const Text('احفظ منتجاتك المفضلة لتجدها هنا لاحقًا.', textAlign: TextAlign.center, style: TextStyle(color: AppColors.muted)),
              const SizedBox(height: 24),
              SizedBox(
                width: 230,
                child: FilledButton.icon(
                  onPressed: () => Navigator.pushNamed(context, '/products'),
                  icon: const Icon(Icons.eco_outlined),
                  label: const Text('تصفح المنتجات'),
                ),
              ),
              const SizedBox(height: 6),
              TextButton.icon(
                onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false),
                icon: const Icon(Icons.home_outlined, size: 18),
                label: const Text('العودة للرئيسية'),
              ),
            ],
          ),
        ),
      );

  Widget _filled(BuildContext context, List<Product> products) => AppPage(
        child: Column(
          children: [
            Row(
              children: [
                Text('${products.length} منتجات محفوظة', style: const TextStyle(color: AppColors.muted)),
                const Spacer(),
                TextButton(onPressed: () {}, child: const Text('إزالة الكل')),
              ],
            ),
            const SizedBox(height: 5),
            ...products.map((product) => Padding(
                  padding: const EdgeInsets.only(bottom: 9),
                  child: _MatchedFavoriteCard(product: product),
                )),
          ],
        ),
      );
}

class _MatchedFavoriteCard extends StatelessWidget {
  const _MatchedFavoriteCard({required this.product});
  final Product product;

  @override
  Widget build(BuildContext context) => InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ConnectedProductDetailsScreen(product: product))),
        child: Container(
          height: 128,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            textDirection: TextDirection.rtl,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: Text(product.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w900))),
                        const Icon(Icons.favorite_rounded, size: 19, color: AppColors.terracotta),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(product.category, style: const TextStyle(fontSize: 9.5, color: AppColors.muted)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(formatPrice(product.price), style: const TextStyle(color: AppColors.forest, fontSize: 15, fontWeight: FontWeight.w900)),
                        const Spacer(),
                        const Icon(Icons.star_rounded, size: 14, color: AppColors.warning),
                        Text('${product.rating}', style: const TextStyle(fontSize: 9.5)),
                      ],
                    ),
                    const Spacer(),
                    SizedBox(
                      width: double.infinity,
                      height: 32,
                      child: FilledButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.add_shopping_cart_rounded, size: 15),
                        label: const Text('أضف إلى السلة', style: TextStyle(fontSize: 10)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 9),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(width: 112, height: 112, child: AppDataImage(product.image, fit: BoxFit.cover)),
              ),
            ],
          ),
        ),
      );
}

class MatchedProductFilterScreen extends StatefulWidget {
  const MatchedProductFilterScreen({super.key});

  @override
  State<MatchedProductFilterScreen> createState() => _MatchedProductFilterScreenState();
}

class _MatchedProductFilterScreenState extends State<MatchedProductFilterScreen> {
  RangeValues price = const RangeValues(50, 5000);
  String sort = 'الأكثر صلة';
  String category = 'الكل';
  String region = 'كل المناطق';
  int rating = 4;
  bool available = true;
  bool discounts = false;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: const MazraaAppBar(title: 'تصفية وترتيب'),
        body: AppPage(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _filterTitle('ترتيب النتائج', Icons.sort_rounded),
              const SizedBox(height: 8),
              Wrap(
                spacing: 7,
                runSpacing: 7,
                children: ['الأكثر صلة', 'الأحدث', 'الأقل سعرًا', 'الأعلى سعرًا']
                    .map((value) => ChoiceChip(
                          label: Text(value),
                          selected: sort == value,
                          onSelected: (_) => setState(() => sort = value),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 17),
              _filterTitle('نطاق السعر', Icons.sell_outlined),
              RangeSlider(
                values: price,
                min: 0,
                max: 10000,
                labels: RangeLabels('${price.start.toInt()} ر.س', '${price.end.toInt()} ر.س'),
                onChanged: (value) => setState(() => price = value),
              ),
              Row(children: [Text('${price.start.toInt()} ر.س'), const Spacer(), Text('${price.end.toInt()} ر.س')]),
              const Divider(height: 28),
              _filterTitle('القسم', Icons.grid_view_rounded),
              const SizedBox(height: 8),
              Wrap(
                spacing: 7,
                runSpacing: 7,
                children: ['الكل', 'بذور', 'أسمدة', 'أعلاف', 'بيطري', 'حيوانات']
                    .map((value) => ChoiceChip(
                          label: Text(value),
                          selected: category == value,
                          onSelected: (_) => setState(() => category = value),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 17),
              _filterTitle('المنطقة', Icons.location_on_outlined),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: region,
                items: const ['كل المناطق', 'الرياض', 'جدة', 'الدمام', 'مكة']
                    .map((value) => DropdownMenuItem(value: value, child: Text(value)))
                    .toList(),
                onChanged: (value) => setState(() => region = value ?? region),
              ),
              const Divider(height: 28),
              _filterTitle('التوفر', Icons.inventory_2_outlined),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: available,
                onChanged: (value) => setState(() => available = value),
                title: const Text('المتوفر فقط'),
              ),
              const Divider(height: 22),
              _filterTitle('التقييم', Icons.star_outline_rounded),
              Row(
                children: List.generate(
                  5,
                  (index) => IconButton(
                    onPressed: () => setState(() => rating = index + 1),
                    icon: Icon(index < rating ? Icons.star_rounded : Icons.star_border_rounded, color: AppColors.warning),
                  ),
                ),
              ),
              const Divider(height: 22),
              _filterTitle('الخصم', Icons.local_offer_outlined),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: discounts,
                onChanged: (value) => setState(() => discounts = value),
                title: const Text('العروض والخصومات فقط'),
              ),
              const SizedBox(height: 13),
              FilledButton.icon(
                onPressed: () => Navigator.maybePop(context),
                icon: const Icon(Icons.filter_alt_outlined),
                label: const Text('عرض النتائج'),
              ),
              TextButton(
                onPressed: () => setState(() {
                  price = const RangeValues(50, 5000);
                  sort = 'الأكثر صلة';
                  category = 'الكل';
                  region = 'كل المناطق';
                  rating = 4;
                  available = true;
                  discounts = false;
                }),
                child: const Text('إعادة تعيين الفلاتر'),
              ),
            ],
          ),
        ),
      );

  Widget _filterTitle(String text, IconData icon) => Row(
        children: [
          Icon(icon, size: 19, color: AppColors.forestDark),
          const SizedBox(width: 6),
          Text(text, style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.forestDark)),
        ],
      );
}

class _MatchedSectionTitle extends StatelessWidget {
  const _MatchedSectionTitle(this.title, this.icon);
  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Icon(icon, color: AppColors.forestDark, size: 21),
          const SizedBox(width: 6),
          Text(title, style: const TextStyle(color: AppColors.forestDark, fontSize: 16, fontWeight: FontWeight.w900)),
        ],
      );
}

class _ReferenceBottomNav extends StatelessWidget {
  const _ReferenceBottomNav({required this.selected});
  final int selected;

  static const _items = <({String label, IconData icon, String route})>[
    (label: 'الرئيسية', icon: Icons.home_outlined, route: '/'),
    (label: 'البحث', icon: Icons.search_rounded, route: '/search'),
    (label: 'الأقسام', icon: Icons.grid_view_rounded, route: '/categories'),
    (label: 'سلة التسوق', icon: Icons.shopping_cart_outlined, route: '/cart'),
    (label: 'حسابي', icon: Icons.person_outline_rounded, route: '/account'),
  ];

  @override
  Widget build(BuildContext context) => SafeArea(
        top: false,
        child: Container(
          height: 70,
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(top: BorderSide(color: AppColors.border)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_items.length, (index) {
              final item = _items[index];
              final active = index == selected;
              return Expanded(
                child: InkWell(
                  onTap: () {
                    if (active) return;
                    Navigator.pushNamedAndRemoveUntil(context, item.route, (route) => item.route != '/' && route.isFirst);
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(item.icon, color: active ? AppColors.forest : AppColors.muted, size: 23),
                      const SizedBox(height: 4),
                      Text(
                        item.label,
                        style: TextStyle(
                          fontSize: 9.5,
                          color: active ? AppColors.forest : AppColors.muted,
                          fontWeight: active ? FontWeight.w900 : FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 3),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 160),
                        width: active ? 25 : 0,
                        height: 3,
                        decoration: BoxDecoration(color: AppColors.forest, borderRadius: BorderRadius.circular(3)),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      );
}
