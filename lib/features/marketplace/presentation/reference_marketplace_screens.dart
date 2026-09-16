import 'package:flutter/material.dart';

import '../../../core/reference/reference_demo_data.dart';
import '../../../core/state/app_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/mazraa_widgets.dart';
import '../domain/marketplace_models.dart';
import 'connected_marketplace_screens.dart';

class ReferenceCategoriesScreen extends StatelessWidget {
  const ReferenceCategoriesScreen({super.key});

  static const _categories = <_CategorySpec>[
    _CategorySpec('بذور', '124 منتج', Icons.grass_rounded, 'assets/images/home/date_seedlings.png'),
    _CategorySpec('أسمدة', '98 منتج', Icons.compost_rounded, 'assets/images/home/fresh_herbs.png'),
    _CategorySpec('مبيدات', '78 منتج', Icons.science_rounded, 'assets/images/home/livestock_feed.png'),
    _CategorySpec('أدوات زراعية', '143 منتج', Icons.handyman_rounded, 'assets/images/home/date_seedlings.png'),
    _CategorySpec('أعلاف', '97 منتج', Icons.agriculture_rounded, 'assets/images/home/livestock_feed.png'),
    _CategorySpec('أدوية بيطرية', '83 منتج', Icons.medication_rounded, 'assets/images/home/local_calf.png'),
    _CategorySpec('مستلزمات حيوانية', '72 منتج', Icons.pets_rounded, 'assets/images/home/najdi_sheep.png'),
    _CategorySpec('ري ومضخات', '56 منتج', Icons.water_drop_rounded, 'assets/images/home/fresh_herbs.png'),
    _CategorySpec('مستلزمات النحل', '34 منتج', Icons.hive_rounded, 'assets/images/home/sidr_honey.png'),
    _CategorySpec('معدات زراعية', '61 منتج', Icons.precision_manufacturing_rounded, 'assets/images/home/date_seedlings.png'),
    _CategorySpec('حيوانات', '48 منتج', Icons.pets_rounded, 'assets/images/home/local_calf.png'),
    _CategorySpec('منتجات زراعية', '93 منتج', Icons.eco_rounded, 'assets/images/home/dates.png'),
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: const MazraaAppBar(title: 'الأقسام'),
        body: AppPage(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'تصفح حسب القسم',
                style: TextStyle(
                  color: AppColors.forestDark,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'اختر القسم المناسب واكتشف أفضل المنتجات الزراعية والبيطرية',
                style: TextStyle(color: AppColors.muted, fontSize: 12),
              ),
              const SizedBox(height: 14),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _categories.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.34,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemBuilder: (context, index) => _CategoryCard(spec: _categories[index]),
              ),
            ],
          ),
        ),
      );
}

class _CategorySpec {
  const _CategorySpec(this.name, this.count, this.icon, this.image);
  final String name;
  final String count;
  final IconData icon;
  final String image;
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({required this.spec});
  final _CategorySpec spec;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ReferenceProductListScreen(title: spec.name),
          ),
        ),
        borderRadius: BorderRadius.circular(17),
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(17),
            border: Border.all(color: AppColors.border),
            boxShadow: const [
              BoxShadow(color: Color(0x0D0D4328), blurRadius: 10, offset: Offset(0, 3)),
            ],
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              AppDataImage(spec.image, fit: BoxFit.cover),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Color(0xD90D4328)],
                    stops: [.30, 1],
                  ),
                ),
              ),
              PositionedDirectional(
                top: 8,
                end: 8,
                child: Container(
                  width: 31,
                  height: 31,
                  decoration: const BoxDecoration(
                    color: Color(0xEEFCFAF2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(spec.icon, color: AppColors.forestDark, size: 18),
                ),
              ),
              PositionedDirectional(
                start: 10,
                end: 10,
                bottom: 9,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(spec.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w900)),
                          Text(spec.count,
                              style: const TextStyle(color: Colors.white70, fontSize: 9.5)),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 13),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}

class ReferenceSearchScreen extends StatefulWidget {
  const ReferenceSearchScreen({super.key});

  @override
  State<ReferenceSearchScreen> createState() => _ReferenceSearchScreenState();
}

class _ReferenceSearchScreenState extends State<ReferenceSearchScreen> {
  final controller = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _search([String? value]) {
    final query = (value ?? controller.text).trim();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReferenceSearchResultsScreen(query: query.isEmpty ? 'عسل' : query),
      ),
    );
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
                autofocus: false,
                textInputAction: TextInputAction.search,
                onSubmitted: _search,
                decoration: InputDecoration(
                  hintText: 'ما الذي تبحث عنه؟',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(onPressed: () {}, icon: const Icon(Icons.mic_none_rounded)),
                      IconButton(onPressed: () {}, icon: const Icon(Icons.photo_camera_outlined)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const _ReferenceSectionTitle(title: 'عمليات البحث الأخيرة', icon: Icons.history_rounded),
              const SizedBox(height: 8),
              ...['عسل سدر', 'أعلاف مواشي', 'خروف نعيمي'].map(
                (item) => ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.history_rounded, color: AppColors.muted, size: 20),
                  title: Text(item),
                  trailing: const Icon(Icons.north_west_rounded, size: 17, color: AppColors.muted),
                  onTap: () => _search(item),
                ),
              ),
              const Divider(),
              const SizedBox(height: 10),
              const _ReferenceSectionTitle(title: 'الأكثر بحثًا', icon: Icons.local_fire_department_rounded),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ['بذور', 'أسمدة', 'مبيدات', 'أدوية بيطرية', 'أعلاف', 'معدات زراعية']
                    .map((item) => ActionChip(
                          label: Text(item),
                          avatar: const Icon(Icons.trending_up_rounded, size: 16),
                          onPressed: () => _search(item),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 20),
              const _ReferenceSectionTitle(title: 'تصفح الأقسام', icon: Icons.grid_view_rounded),
              const SizedBox(height: 10),
              SizedBox(
                height: 105,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: const [
                    _SearchCategory('زراعة', Icons.eco_rounded),
                    _SearchCategory('حيوانات', Icons.pets_rounded),
                    _SearchCategory('أعلاف', Icons.agriculture_rounded),
                    _SearchCategory('بيطري', Icons.medication_rounded),
                    _SearchCategory('معدات', Icons.handyman_rounded),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}

class _SearchCategory extends StatelessWidget {
  const _SearchCategory(this.label, this.icon);
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 82,
        child: InkWell(
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => ReferenceProductListScreen(title: label))),
          child: Column(
            children: [
              CircleAvatar(
                radius: 29,
                backgroundColor: AppColors.forestSoft,
                child: Icon(icon, color: AppColors.forestDark, size: 28),
              ),
              const SizedBox(height: 7),
              Text(label,
                  maxLines: 1,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
            ],
          ),
        ),
      );
}

class ReferenceSearchResultsScreen extends StatelessWidget {
  const ReferenceSearchResultsScreen({super.key, this.query = 'عسل'});
  final String query;

  @override
  Widget build(BuildContext context) {
    final products = AppScope.of(context).products;
    return ReferenceProductListScreen(
      title: 'نتائج البحث',
      subtitle: 'نتائج البحث عن «$query»',
      products: products,
      showSearch: true,
    );
  }
}

class ReferenceEmptySearchScreen extends StatelessWidget {
  const ReferenceEmptySearchScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: const MazraaAppBar(title: 'نتائج البحث'),
        body: AppPage(
          child: Column(
            children: [
              const _StaticSearchBox(text: 'منتج غير موجود'),
              const SizedBox(height: 54),
              Container(
                width: 104,
                height: 104,
                decoration: const BoxDecoration(color: AppColors.forestSoft, shape: BoxShape.circle),
                child: const Icon(Icons.search_off_rounded, size: 53, color: AppColors.forest),
              ),
              const SizedBox(height: 20),
              const Text('لم نجد نتائج مطابقة',
                  style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900, color: AppColors.forestDark)),
              const SizedBox(height: 7),
              const Text(
                'جرّب كلمات بحث أخرى أو تصفح أحد الأقسام المقترحة',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.muted),
              ),
              const SizedBox(height: 28),
              const _ReferenceSectionTitle(title: 'أقسام قد تهمك', icon: Icons.grid_view_rounded),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: ['البذور', 'الأعلاف', 'الحيوانات', 'الأدوية البيطرية']
                    .map((item) => ActionChip(label: Text(item), onPressed: () => Navigator.pushNamed(context, '/categories')))
                    .toList(),
              ),
            ],
          ),
        ),
      );
}

class ReferenceProductListScreen extends StatefulWidget {
  const ReferenceProductListScreen({
    super.key,
    this.title = 'المنتجات',
    this.subtitle,
    this.products,
    this.forceList = false,
    this.showSearch = false,
  });

  final String title;
  final String? subtitle;
  final List<Product>? products;
  final bool forceList;
  final bool showSearch;

  @override
  State<ReferenceProductListScreen> createState() => _ReferenceProductListScreenState();
}

class _ReferenceProductListScreenState extends State<ReferenceProductListScreen> {
  bool list = false;
  String sort = 'الأكثر مبيعًا';

  @override
  void initState() {
    super.initState();
    list = widget.forceList;
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.products ?? AppScope.of(context).products;
    return Scaffold(
      appBar: MazraaAppBar(
        title: widget.title,
        actions: [
          IconButton(onPressed: () => Navigator.pushNamed(context, '/favorites'), icon: const Icon(Icons.favorite_border_rounded)),
        ],
      ),
      body: AppPage(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.showSearch) ...[
              const _StaticSearchBox(text: 'عسل'),
              const SizedBox(height: 11),
            ],
            if (widget.subtitle != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(widget.subtitle!, style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.forestDark)),
              ),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => const ReferenceProductFilterSheet(),
                    ),
                    icon: const Icon(Icons.tune_rounded, size: 18),
                    label: const Text('فلترة'),
                  ),
                ),
                const SizedBox(width: 7),
                Expanded(
                  flex: 2,
                  child: PopupMenuButton<String>(
                    onSelected: (value) => setState(() => sort = value),
                    itemBuilder: (_) => ['الأكثر مبيعًا', 'الأحدث', 'السعر: الأقل', 'السعر: الأعلى']
                        .map((item) => PopupMenuItem(value: item, child: Text(item)))
                        .toList(),
                    child: Container(
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: 11),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.sort_rounded, size: 19),
                          const SizedBox(width: 5),
                          Expanded(child: Text(sort, maxLines: 1, overflow: TextOverflow.ellipsis)),
                          const Icon(Icons.keyboard_arrow_down_rounded),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 7),
                _ViewToggle(list: list, onChanged: (value) => setState(() => list = value)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text('${items.length} منتج', style: const TextStyle(color: AppColors.muted, fontWeight: FontWeight.w700)),
                const Spacer(),
                const Text('متوفر الآن', style: TextStyle(color: AppColors.success, fontSize: 11, fontWeight: FontWeight.w800)),
              ],
            ),
            const SizedBox(height: 9),
            if (list)
              ...items.map((product) => Padding(
                    padding: const EdgeInsets.only(bottom: 9),
                    child: _ReferenceProductListCard(product: product),
                  ))
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: items.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: .71,
                  crossAxisSpacing: 9,
                  mainAxisSpacing: 9,
                ),
                itemBuilder: (_, index) => _ReferenceProductGridCard(product: items[index]),
              ),
          ],
        ),
      ),
    );
  }
}

class ReferenceOffersScreen extends StatelessWidget {
  const ReferenceOffersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final products = AppScope.of(context).products;
    return Scaffold(
      appBar: const MazraaAppBar(title: 'العروض'),
      body: AppPage(
        child: Column(
          children: [
            Container(
              height: 132,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                image: const DecorationImage(
                  image: AssetImage('assets/images/home/livestock_feed.png'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: const LinearGradient(
                    colors: [Color(0xE60D4328), Color(0x66155A37), Colors.transparent],
                  ),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('عروض الموسم', style: TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.w900)),
                    SizedBox(height: 5),
                    Text('خصومات تصل إلى 30%', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800)),
                    Spacer(),
                    Row(children: [Icon(Icons.schedule_rounded, color: Colors.white, size: 17), SizedBox(width: 5), Text('ينتهي خلال 02 : 14 : 35', style: TextStyle(color: Colors.white, fontSize: 11))]),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            const _ReferenceSectionTitle(title: 'أفضل العروض', icon: Icons.local_offer_rounded),
            const SizedBox(height: 9),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: products.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: .71,
                crossAxisSpacing: 9,
                mainAxisSpacing: 9,
              ),
              itemBuilder: (_, index) => _ReferenceProductGridCard(product: products[index]),
            ),
          ],
        ),
      ),
    );
  }
}

class ReferenceFavoritesScreen extends StatelessWidget {
  const ReferenceFavoritesScreen({super.key, this.empty = false, this.plantEmpty = false});
  final bool empty;
  final bool plantEmpty;

  @override
  Widget build(BuildContext context) {
    final products = AppScope.of(context).products.take(4).toList();
    if (empty || plantEmpty) {
      return Scaffold(
        appBar: const MazraaAppBar(title: 'المفضلة'),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 116,
                  height: 116,
                  decoration: const BoxDecoration(color: AppColors.forestSoft, shape: BoxShape.circle),
                  child: Icon(plantEmpty ? Icons.eco_rounded : Icons.inventory_2_outlined,
                      size: 60, color: AppColors.forest),
                ),
                const SizedBox(height: 22),
                Text(plantEmpty ? 'لا توجد منتجات في المفضلة' : 'المفضلة فارغة',
                    style: const TextStyle(fontSize: 21, color: AppColors.forestDark, fontWeight: FontWeight.w900)),
                const SizedBox(height: 7),
                const Text('احفظ المنتجات التي تعجبك لتصل إليها بسرعة لاحقًا',
                    textAlign: TextAlign.center, style: TextStyle(color: AppColors.muted)),
                const SizedBox(height: 19),
                FilledButton.icon(
                  onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false),
                  icon: const Icon(Icons.shopping_bag_outlined),
                  label: const Text('ابدأ التسوق'),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return Scaffold(
      appBar: const MazraaAppBar(title: 'المفضلة'),
      body: AppPage(
        child: Column(
          children: [
            Row(
              children: [
                Text('${products.length} منتجات محفوظة', style: const TextStyle(color: AppColors.muted)),
                const Spacer(),
                TextButton(onPressed: () {}, child: const Text('إزالة الكل')),
              ],
            ),
            const SizedBox(height: 6),
            ...products.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 9),
                  child: _ReferenceProductListCard(product: item, favorite: true),
                )),
          ],
        ),
      ),
    );
  }
}

class ReferenceProductFilterScreen extends StatelessWidget {
  const ReferenceProductFilterScreen({super.key});

  @override
  Widget build(BuildContext context) => const Scaffold(
        appBar: MazraaAppBar(title: 'الفلترة'),
        body: AppPage(child: ReferenceProductFilterContent()),
      );
}

class ReferenceProductFilterSheet extends StatelessWidget {
  const ReferenceProductFilterSheet({super.key});

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(top: 70),
        decoration: const BoxDecoration(
          color: AppColors.ivory,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: const SafeArea(top: false, child: Padding(padding: EdgeInsets.all(18), child: ReferenceProductFilterContent())),
      );
}

class ReferenceProductFilterContent extends StatefulWidget {
  const ReferenceProductFilterContent({super.key});

  @override
  State<ReferenceProductFilterContent> createState() => _ReferenceProductFilterContentState();
}

class _ReferenceProductFilterContentState extends State<ReferenceProductFilterContent> {
  RangeValues price = const RangeValues(50, 5000);
  int rating = 4;
  bool available = true;
  bool discounts = false;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('تصفية المنتجات', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.forestDark)),
            const SizedBox(height: 18),
            const Text('القسم', style: TextStyle(fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            Wrap(spacing: 7, runSpacing: 7, children: ['الكل', 'زراعة', 'حيوانات', 'أعلاف', 'بيطري'].map((e) => FilterChip(label: Text(e), selected: e == 'الكل', onSelected: (_) {})).toList()),
            const SizedBox(height: 16),
            const Text('نطاق السعر', style: TextStyle(fontWeight: FontWeight.w900)),
            RangeSlider(values: price, min: 0, max: 10000, labels: RangeLabels('${price.start.toInt()}', '${price.end.toInt()}'), onChanged: (value) => setState(() => price = value)),
            Row(children: [Text('${price.start.toInt()} ر.س'), const Spacer(), Text('${price.end.toInt()} ر.س')]),
            const SizedBox(height: 16),
            const Text('التقييم', style: TextStyle(fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            Row(children: List.generate(5, (i) => IconButton(onPressed: () => setState(() => rating = i + 1), icon: Icon(i < rating ? Icons.star_rounded : Icons.star_border_rounded, color: AppColors.warning)))),
            SwitchListTile(contentPadding: EdgeInsets.zero, value: available, onChanged: (v) => setState(() => available = v), title: const Text('المتوفر فقط')),
            SwitchListTile(contentPadding: EdgeInsets.zero, value: discounts, onChanged: (v) => setState(() => discounts = v), title: const Text('العروض والخصومات فقط')),
            const SizedBox(height: 16),
            FilledButton(onPressed: () => Navigator.maybePop(context), child: const Text('عرض النتائج')),
            TextButton(onPressed: () {}, child: const Text('إعادة تعيين الفلاتر')),
          ],
        ),
      );
}

class _ViewToggle extends StatelessWidget {
  const _ViewToggle({required this.list, required this.onChanged});
  final bool list;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(color: AppColors.surface, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(12)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(onPressed: () => onChanged(false), icon: Icon(Icons.grid_view_rounded, color: !list ? AppColors.forest : AppColors.muted), visualDensity: VisualDensity.compact),
            IconButton(onPressed: () => onChanged(true), icon: Icon(Icons.view_list_rounded, color: list ? AppColors.forest : AppColors.muted), visualDensity: VisualDensity.compact),
          ],
        ),
      );
}

class _ReferenceProductGridCard extends StatelessWidget {
  const _ReferenceProductGridCard({required this.product});
  final Product product;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ConnectedProductDetailsScreen(product: product))),
        borderRadius: BorderRadius.circular(15),
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    AppDataImage(product.image, fit: BoxFit.cover),
                    PositionedDirectional(top: 7, start: 7, child: CircleAvatar(radius: 15, backgroundColor: Colors.white, child: Icon(Icons.favorite_border_rounded, size: 17, color: AppColors.terracotta))),
                    if ((product.discount ?? 0) > 0)
                      PositionedDirectional(top: 7, end: 7, child: Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4), decoration: BoxDecoration(color: AppColors.terracotta, borderRadius: BorderRadius.circular(7)), child: Text('${product.discount}% خصم', style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w900)))),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(9),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12.5)),
                    const SizedBox(height: 3),
                    Row(children: [const Icon(Icons.star_rounded, color: AppColors.warning, size: 15), Text('${product.rating}', style: const TextStyle(fontSize: 10)), const Spacer(), if (product.inStock) const Text('متوفر', style: TextStyle(fontSize: 9, color: AppColors.success, fontWeight: FontWeight.w800))]),
                    const SizedBox(height: 5),
                    Row(children: [Text(formatPrice(product.price), style: const TextStyle(color: AppColors.forest, fontWeight: FontWeight.w900, fontSize: 13)), if (product.oldPrice != null) ...[const SizedBox(width: 5), Flexible(child: Text(formatPrice(product.oldPrice!), style: const TextStyle(fontSize: 9, color: AppColors.muted, decoration: TextDecoration.lineThrough)))]]),
                    const SizedBox(height: 6),
                    SizedBox(width: double.infinity, height: 34, child: FilledButton.icon(onPressed: () {}, icon: const Icon(Icons.add_shopping_cart_rounded, size: 16), label: const Text('أضف للسلة', style: TextStyle(fontSize: 10)))),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}

class _ReferenceProductListCard extends StatelessWidget {
  const _ReferenceProductListCard({required this.product, this.favorite = false});
  final Product product;
  final bool favorite;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ConnectedProductDetailsScreen(product: product))),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 135,
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
          child: Row(
            children: [
              ClipRRect(borderRadius: BorderRadius.circular(12), child: SizedBox(width: 116, height: 116, child: AppDataImage(product.image, fit: BoxFit.cover))),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [Expanded(child: Text(product.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w900))), Icon(favorite ? Icons.favorite_rounded : Icons.favorite_border_rounded, color: AppColors.terracotta, size: 21)]),
                    const SizedBox(height: 3),
                    Text(product.category, style: const TextStyle(color: AppColors.muted, fontSize: 10)),
                    const SizedBox(height: 4),
                    Row(children: [const Icon(Icons.star_rounded, color: AppColors.warning, size: 15), Text('${product.rating}', style: const TextStyle(fontSize: 10)), const Spacer(), Text(formatPrice(product.price), style: const TextStyle(color: AppColors.forest, fontSize: 15, fontWeight: FontWeight.w900))]),
                    const Spacer(),
                    SizedBox(height: 34, width: double.infinity, child: FilledButton.icon(onPressed: () {}, icon: const Icon(Icons.shopping_cart_outlined, size: 15), label: const Text('أضف للسلة', style: TextStyle(fontSize: 10)))),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}

class _StaticSearchBox extends StatelessWidget {
  const _StaticSearchBox({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) => Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(color: AppColors.surface, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(14)),
        child: Row(children: [const Icon(Icons.search_rounded, color: AppColors.muted), const SizedBox(width: 8), Expanded(child: Text(text, style: const TextStyle(color: AppColors.muted)))]),
      );
}

class _ReferenceSectionTitle extends StatelessWidget {
  const _ReferenceSectionTitle({required this.title, required this.icon});
  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Row(children: [Icon(icon, color: AppColors.forestDark, size: 21), const SizedBox(width: 6), Text(title, style: const TextStyle(color: AppColors.forestDark, fontSize: 16, fontWeight: FontWeight.w900))]);
}
