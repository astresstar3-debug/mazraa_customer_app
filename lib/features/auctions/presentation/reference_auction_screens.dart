import 'package:flutter/material.dart';

import '../../../core/reference/reference_demo_data.dart';
import '../../../core/state/app_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/mazraa_widgets.dart';
import '../../marketplace/domain/marketplace_models.dart';

enum ReferenceAuctionResultKind { bidSuccess, won, ended }

class ReferenceAuctionListScreen extends StatefulWidget {
  const ReferenceAuctionListScreen({super.key, this.embedded = false});
  final bool embedded;

  @override
  State<ReferenceAuctionListScreen> createState() => _ReferenceAuctionListScreenState();
}

class _ReferenceAuctionListScreenState extends State<ReferenceAuctionListScreen> {
  int tab = 0;
  final labels = const ['الكل', 'مباشر', 'قادمة', 'منتهية'];

  @override
  Widget build(BuildContext context) {
    final all = AppScope.of(context).auctions;
    final items = all.isEmpty ? ReferenceDemoData.auctions : all;
    final body = AppPage(
      padding: const EdgeInsetsDirectional.fromSTEB(14, 8, 14, 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(color: AppColors.surface, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(14)),
                  child: const Row(children: [Icon(Icons.search_rounded, color: AppColors.muted), SizedBox(width: 7), Expanded(child: Text('ابحث في المزادات...', style: TextStyle(color: AppColors.muted, fontSize: 12)))]),
                ),
              ),
              const SizedBox(width: 7),
              IconButton.filledTonal(onPressed: () => Navigator.pushNamed(context, '/auction-filter'), icon: const Icon(Icons.tune_rounded)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: List.generate(labels.length, (i) => Expanded(child: Padding(
              padding: EdgeInsetsDirectional.only(end: i == labels.length - 1 ? 0 : 5),
              child: ChoiceChip(label: SizedBox(width: double.infinity, child: Text(labels[i], textAlign: TextAlign.center)), selected: tab == i, onSelected: (_) => setState(() => tab = i)),
            ))),
          ),
          const SizedBox(height: 12),
          Row(children: [const Text('المزادات المتاحة', style: TextStyle(color: AppColors.forestDark, fontSize: 17, fontWeight: FontWeight.w900)), const Spacer(), Text('${items.length} مزاد', style: const TextStyle(color: AppColors.muted, fontSize: 11))]),
          const SizedBox(height: 9),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: .65, crossAxisSpacing: 9, mainAxisSpacing: 9),
            itemBuilder: (_, index) => _AuctionCard(auction: items[index]),
          ),
        ],
      ),
    );
    if (widget.embedded) return body;
    return Scaffold(appBar: const MazraaAppBar(title: 'المزادات'), body: body);
  }
}

class _AuctionCard extends StatelessWidget {
  const _AuctionCard({required this.auction});
  final Auction auction;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ReferenceAuctionDetailsScreen(auction: auction))),
    borderRadius: BorderRadius.circular(16),
    child: Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Expanded(child: Stack(fit: StackFit.expand, children: [
          AppDataImage(auction.image, fit: BoxFit.cover),
          PositionedDirectional(top: 7, end: 7, child: Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4), decoration: BoxDecoration(color: auction.state == AuctionState.live ? AppColors.error : AppColors.forest, borderRadius: BorderRadius.circular(8)), child: Text(auction.state == AuctionState.live ? '● مباشر' : 'قادم', style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w900)))),
          const PositionedDirectional(top: 7, start: 7, child: CircleAvatar(radius: 14, backgroundColor: Colors.white, child: Icon(Icons.favorite_border_rounded, size: 16, color: AppColors.terracotta))),
        ])),
        Padding(padding: const EdgeInsets.all(8), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(auction.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          Row(children: [const Icon(Icons.location_on_outlined, size: 13, color: AppColors.muted), const Text('الرياض', style: TextStyle(fontSize: 9, color: AppColors.muted)), const Spacer(), const Icon(Icons.people_outline_rounded, size: 13, color: AppColors.muted), Text(' ${auction.bidCount == 0 ? 24 : auction.bidCount}', style: const TextStyle(fontSize: 9, color: AppColors.muted))]),
          const SizedBox(height: 6),
          Row(children: [const Text('السعر الحالي', style: TextStyle(fontSize: 9, color: AppColors.muted)), const Spacer(), Text(formatPrice(auction.currentBid), style: const TextStyle(color: AppColors.forest, fontSize: 13, fontWeight: FontWeight.w900))]),
          const SizedBox(height: 5),
          Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5), decoration: BoxDecoration(color: AppColors.terracottaSoft, borderRadius: BorderRadius.circular(8)), child: Row(children: [const Icon(Icons.schedule_rounded, size: 13, color: AppColors.terracotta), const SizedBox(width: 4), Text(_duration(auction.remaining), style: const TextStyle(color: AppColors.terracotta, fontSize: 10, fontWeight: FontWeight.w900))])),
          const SizedBox(height: 7),
          SizedBox(width: double.infinity, height: 34, child: FilledButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ReferenceAuctionDetailsScreen(auction: auction))), child: const Text('عرض المزاد', style: TextStyle(fontSize: 10)))),
        ])),
      ]),
    ),
  );
}

class ReferenceAuctionFilterScreen extends StatefulWidget {
  const ReferenceAuctionFilterScreen({super.key});
  @override
  State<ReferenceAuctionFilterScreen> createState() => _ReferenceAuctionFilterScreenState();
}

class _ReferenceAuctionFilterScreenState extends State<ReferenceAuctionFilterScreen> {
  RangeValues price = const RangeValues(500, 10000);
  String category = 'الكل';
  String ending = 'الكل';
  bool delivery = true;
  bool guarantee = false;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: const MazraaAppBar(title: 'تصفية المزادات'),
    body: AppPage(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      const _Title('القسم', Icons.category_outlined),
      const SizedBox(height: 8),
      Wrap(spacing: 7, runSpacing: 7, children: ['الكل','حيوانات','منتجات زراعية','معدات','أعلاف'].map((e) => ChoiceChip(label: Text(e), selected: category == e, onSelected: (_) => setState(() => category=e))).toList()),
      const SizedBox(height: 20),
      const _Title('نطاق السعر', Icons.payments_outlined),
      RangeSlider(values: price, min: 0, max: 30000, divisions: 30, onChanged: (v) => setState(() => price=v)),
      Row(children: [Text('${price.start.toInt()} ر.س'), const Spacer(), Text('${price.end.toInt()} ر.س')]),
      const SizedBox(height: 20),
      const _Title('وقت الانتهاء', Icons.schedule_outlined),
      const SizedBox(height: 8),
      Wrap(spacing: 7, runSpacing: 7, children: ['الكل','خلال ساعة','اليوم','هذا الأسبوع'].map((e) => ChoiceChip(label: Text(e), selected: ending == e, onSelected: (_) => setState(() => ending=e))).toList()),
      const SizedBox(height: 15),
      SwitchListTile(contentPadding: EdgeInsets.zero, value: delivery, onChanged: (v)=>setState(()=>delivery=v), title: const Text('يتوفر توصيل'), secondary: const Icon(Icons.local_shipping_outlined)),
      SwitchListTile(contentPadding: EdgeInsets.zero, value: guarantee, onChanged: (v)=>setState(()=>guarantee=v), title: const Text('مزادات بضمان فقط'), secondary: const Icon(Icons.verified_user_outlined)),
      const SizedBox(height: 17),
      FilledButton(onPressed: ()=>Navigator.maybePop(context), child: const Text('عرض النتائج')),
      TextButton(onPressed: (){}, child: const Text('إعادة تعيين')),
    ])),
  );
}

class ReferenceAuctionDetailsScreen extends StatelessWidget {
  const ReferenceAuctionDetailsScreen({super.key, required this.auction, this.galleryMode = false});
  final Auction auction;
  final bool galleryMode;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: MazraaAppBar(actions: [IconButton(onPressed: (){}, icon: const Icon(Icons.favorite_border_rounded)), IconButton(onPressed: (){}, icon: const Icon(Icons.ios_share_rounded))]),
    bottomNavigationBar: SafeArea(top: false, child: Container(color: AppColors.surface, padding: const EdgeInsets.all(12), child: FilledButton.icon(onPressed: () => Navigator.pushNamed(context, '/auction-bid'), icon: const Icon(Icons.gavel_rounded), label: const Text('قدم مزايدتك')))),
    body: AppPage(padding: const EdgeInsetsDirectional.fromSTEB(14, 4, 14, 22), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      AspectRatio(aspectRatio: galleryMode ? 1.08 : 1.35, child: ClipRRect(borderRadius: BorderRadius.circular(18), child: Stack(fit: StackFit.expand, children: [AppDataImage(auction.image, fit: BoxFit.cover), PositionedDirectional(top: 10,end: 10,child: Container(padding: const EdgeInsets.symmetric(horizontal: 8,vertical: 5),decoration: BoxDecoration(color: AppColors.error,borderRadius: BorderRadius.circular(8)),child: const Text('● مزاد مباشر',style: TextStyle(color:Colors.white,fontSize:9,fontWeight:FontWeight.w900))))]))),
      const SizedBox(height: 8),
      SizedBox(height: 60, child: ListView.separated(scrollDirection: Axis.horizontal, itemCount: 4, separatorBuilder: (_,__)=>const SizedBox(width:7), itemBuilder: (_,i)=>ClipRRect(borderRadius: BorderRadius.circular(10), child: SizedBox(width:78, child: AppDataImage(i.isEven ? auction.image : 'assets/images/home/najdi_sheep.png', fit:BoxFit.cover))))),
      const SizedBox(height: 13),
      Text(auction.title, style: const TextStyle(color:AppColors.forestDark,fontSize:20,fontWeight:FontWeight.w900)),
      const SizedBox(height: 5),
      Row(children:[const Icon(Icons.location_on_outlined,size:16,color:AppColors.muted),const Text(' الرياض • مزرعة موثقة',style:TextStyle(color:AppColors.muted,fontSize:11)),const Spacer(),const Icon(Icons.verified_rounded,color:AppColors.forest,size:18)]),
      const SizedBox(height: 12),
      AppSurfaceCard(color: const Color(0xFFF8F0DC), child: Column(children:[Row(children:[const Expanded(child:_AuctionMetric('السعر الحالي','4,200 ر.س',Icons.payments_rounded)),Container(width:1,height:44,color:AppColors.border),const Expanded(child:_AuctionMetric('عدد المزايدات','24',Icons.people_outline_rounded)),Container(width:1,height:44,color:AppColors.border),Expanded(child:_AuctionMetric('الوقت المتبقي',_duration(auction.remaining),Icons.schedule_rounded,color:AppColors.terracotta))]),const SizedBox(height:10),const LinearProgressIndicator(value:.63,minHeight:5,borderRadius:BorderRadius.all(Radius.circular(5)))])),
      const SizedBox(height: 11),
      const AppSurfaceCard(child: Column(children:[_Meta(Icons.info_outline_rounded,'حالة المنتج','ممتازة'),Divider(height:16),_Meta(Icons.category_outlined,'القسم','حيوانات ومواشي'),Divider(height:16),_Meta(Icons.local_shipping_outlined,'التوصيل','متوفر داخل المملكة'),Divider(height:16),_Meta(Icons.verified_user_outlined,'الضمان','يتطلب حجز ضمان قبل المزايدة')])),
      const SizedBox(height: 13),
      const _Title('وصف المزاد', Icons.description_outlined),
      const SizedBox(height: 7),
      Text(auction.description.isEmpty ? 'مزاد موثق على منتج مختار بعناية. جميع البيانات والصور مرفقة، ويمكن التواصل مع الدعم عند الحاجة.' : auction.description, style: const TextStyle(height:1.7,fontSize:12)),
      const SizedBox(height: 14),
      const AppSurfaceCard(color: AppColors.forestSoft, child: Row(children:[CircleAvatar(backgroundColor:Colors.white,child:Icon(Icons.storefront_rounded,color:AppColors.forest)),SizedBox(width:9),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('مزرعة الخير',style:TextStyle(fontWeight:FontWeight.w900)),Text('بائع موثق • 4.9 ★',style:TextStyle(color:AppColors.muted,fontSize:10))])),Icon(Icons.chevron_left_rounded)])),
      const SizedBox(height: 14),
      OutlinedButton.icon(onPressed: ()=>Navigator.pushNamed(context,'/guarantee-details'),icon:const Icon(Icons.shield_outlined),label:const Text('عرض تفاصيل الضمان')),
    ])),
  );
}

class ReferenceBidScreen extends StatefulWidget {
  const ReferenceBidScreen({super.key, required this.auction});
  final Auction auction;
  @override
  State<ReferenceBidScreen> createState()=>_ReferenceBidScreenState();
}

class _ReferenceBidScreenState extends State<ReferenceBidScreen>{
  double amount=4500;
  bool accepted=true;
  @override
  Widget build(BuildContext context)=>Scaffold(
    appBar:const MazraaAppBar(title:'تقديم المزايدة'),
    body:AppPage(child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
      _AuctionMiniHeader(auction:widget.auction),
      const SizedBox(height:14),
      AppSurfaceCard(color:const Color(0xFFF8F0DC),child:Column(children:[const Text('المزايدة الحالية',style:TextStyle(color:AppColors.muted)),Text(formatPrice(widget.auction.currentBid),style:const TextStyle(color:AppColors.forestDark,fontSize:26,fontWeight:FontWeight.w900)),const SizedBox(height:4),const Text('الحد الأدنى للمزايدة التالية 4,350 ر.س',style:TextStyle(color:AppColors.terracotta,fontSize:10,fontWeight:FontWeight.w800))])),
      const SizedBox(height:14),
      const Text('حدد قيمة مزايدتك',style:TextStyle(fontWeight:FontWeight.w900,color:AppColors.forestDark)),
      const SizedBox(height:8),
      Container(padding:const EdgeInsets.all(10),decoration:BoxDecoration(color:AppColors.surface,border:Border.all(color:AppColors.border),borderRadius:BorderRadius.circular(14)),child:Row(children:[IconButton.filledTonal(onPressed:()=>setState(()=>amount+=100),icon:const Icon(Icons.add_rounded)),Expanded(child:Column(children:[Text('${amount.toInt()} ر.س',style:const TextStyle(fontSize:23,fontWeight:FontWeight.w900,color:AppColors.forestDark)),const Text('قيمة المزايدة',style:TextStyle(color:AppColors.muted,fontSize:9))])),IconButton.filledTonal(onPressed:()=>setState(()=>amount=(amount-100).clamp(4350,999999)),icon:const Icon(Icons.remove_rounded))])),
      const SizedBox(height:9),
      Row(children:[for(final v in [4500,5000,5500]) Expanded(child:Padding(padding:const EdgeInsetsDirectional.only(end:6),child:OutlinedButton(onPressed:()=>setState(()=>amount=v.toDouble()),child:Text('$v'))))]),
      const SizedBox(height:14),
      const AppSurfaceCard(color:AppColors.terracottaSoft,child:Row(crossAxisAlignment:CrossAxisAlignment.start,children:[Icon(Icons.info_outline_rounded,color:AppColors.terracotta),SizedBox(width:8),Expanded(child:Text('بإرسال المزايدة فأنت تلتزم بالسداد عند الفوز. قد يتطلب المزاد حجز مبلغ ضمان.',style:TextStyle(fontSize:11)))])),
      CheckboxListTile(contentPadding:EdgeInsets.zero,value:accepted,onChanged:(v)=>setState(()=>accepted=v??false),title:const Text('أوافق على شروط وأحكام المزادات',style:TextStyle(fontSize:11))),
      const SizedBox(height:8),
      FilledButton.icon(onPressed:accepted?()=>Navigator.pushNamed(context,'/auction-bid-confirm'):null,icon:const Icon(Icons.gavel_rounded),label:const Text('متابعة وتأكيد المزايدة')),
    ])),
  );
}

class ReferenceBidConfirmScreen extends StatelessWidget {
  const ReferenceBidConfirmScreen({super.key});
  @override
  Widget build(BuildContext context)=>Scaffold(appBar:const MazraaAppBar(title:'تأكيد المزايدة'),body:AppPage(child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
    const SizedBox(height:10),
    const Center(child:CircleAvatar(radius:42,backgroundColor:AppColors.forestSoft,child:Icon(Icons.gavel_rounded,color:AppColors.forest,size:43))),
    const SizedBox(height:14),
    const Text('راجع تفاصيل المزايدة',textAlign:TextAlign.center,style:TextStyle(color:AppColors.forestDark,fontSize:20,fontWeight:FontWeight.w900)),
    const SizedBox(height:15),
    AppSurfaceCard(child:Column(children:[_Meta(Icons.inventory_2_outlined,'المزاد',ReferenceDemoData.auctions.first.title),const Divider(height:16),const _Meta(Icons.payments_outlined,'قيمة المزايدة','4,500 ر.س'),const Divider(height:16),const _Meta(Icons.shield_outlined,'الضمان المحجوز','250 ر.س'),const Divider(height:16),const _Meta(Icons.account_balance_wallet_outlined,'طريقة السداد','المحفظة / وسيلة الدفع المختارة')])),
    const SizedBox(height:13),
    const AppSurfaceCard(color:Color(0xFFF8F0DC),child:Row(children:[Icon(Icons.lock_outline_rounded,color:AppColors.forest),SizedBox(width:8),Expanded(child:Text('لن يتم خصم قيمة المزايدة الآن. يتم السداد فقط عند الفوز بالمزاد.',style:TextStyle(fontSize:11)))])),
    const SizedBox(height:20),
    FilledButton.icon(onPressed:()=>Navigator.pushReplacementNamed(context,'/auction-success'),icon:const Icon(Icons.check_circle_outline_rounded),label:const Text('تأكيد وإرسال المزايدة')),
    OutlinedButton(onPressed:()=>Navigator.pop(context),child:const Text('العودة والتعديل')),
  ])));
}

class ReferenceAuctionResultScreen extends StatelessWidget {
  const ReferenceAuctionResultScreen({super.key,required this.kind});
  final ReferenceAuctionResultKind kind;
  @override
  Widget build(BuildContext context){
    final won=kind==ReferenceAuctionResultKind.won;
    final ended=kind==ReferenceAuctionResultKind.ended;
    final title=won?'مبروك! فزت بالمزاد':ended?'انتهى المزاد':'تمت المزايدة بنجاح';
    final message=won?'أصبحت الفائز بهذا المزاد. أكمل الدفع قبل انتهاء المهلة.':ended?'تم إغلاق هذا المزاد ويمكنك استعراض النتيجة النهائية.':'تم تسجيل مزايدتك وسنرسل لك إشعارًا عند وجود مزايدة أعلى.';
    return Scaffold(appBar:const MazraaAppBar(),body:AppPage(child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
      const SizedBox(height:35),
      Center(child:Container(width:118,height:118,decoration:BoxDecoration(color:ended?AppColors.terracottaSoft:AppColors.forestSoft,shape:BoxShape.circle),child:Icon(ended?Icons.eco_rounded:Icons.check_circle_rounded,size:66,color:ended?AppColors.terracotta:AppColors.forest))),
      const SizedBox(height:18),
      Text(title,textAlign:TextAlign.center,style:const TextStyle(color:AppColors.forestDark,fontSize:24,fontWeight:FontWeight.w900)),
      const SizedBox(height:8),Text(message,textAlign:TextAlign.center,style:const TextStyle(color:AppColors.muted,height:1.6)),
      const SizedBox(height:20),
      _AuctionMiniHeader(auction:ReferenceDemoData.auctions.first),
      const SizedBox(height:12),
      AppSurfaceCard(child:Column(children:[const _Meta(Icons.payments_outlined,'قيمة مزايدتك','4,500 ر.س'),const Divider(height:16),_Meta(Icons.schedule_outlined,won?'مهلة الدفع':'الوقت المتبقي',won?'23 ساعة و45 دقيقة':'02:13:58'),const Divider(height:16),_Meta(Icons.info_outline_rounded,'الحالة',won?'بانتظار الدفع':ended?'مغلق':'أنت الأعلى حاليًا')])),
      const SizedBox(height:18),
      FilledButton(onPressed:()=>Navigator.pushNamedAndRemoveUntil(context,'/auctions',(r)=>r.isFirst),child:Text(won?'إكمال الدفع':'العودة إلى المزادات')),
      OutlinedButton(onPressed:()=>Navigator.pushNamed(context,'/my-auctions'),child:const Text('عرض مزاداتي')),
    ])));
  }
}

class ReferenceMyAuctionsScreen extends StatelessWidget {
  const ReferenceMyAuctionsScreen({super.key,this.history=false});
  final bool history;
  @override
  Widget build(BuildContext context){final items=AppScope.of(context).auctions;return Scaffold(appBar:MazraaAppBar(title:history?'سجل المزايدات':'مزاداتي'),body:AppPage(child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
    if(!history)...[const Row(children:[Expanded(child:ChoiceChip(label:SizedBox(width:double.infinity,child:Text('نشطة',textAlign:TextAlign.center)),selected:true,onSelected:null)),SizedBox(width:7),Expanded(child:ChoiceChip(label:SizedBox(width:double.infinity,child:Text('فزت بها',textAlign:TextAlign.center)),selected:false,onSelected:null)),SizedBox(width:7),Expanded(child:ChoiceChip(label:SizedBox(width:double.infinity,child:Text('منتهية',textAlign:TextAlign.center)),selected:false,onSelected:null))]),const SizedBox(height:12)],
    ...items.map((a)=>Padding(padding:const EdgeInsets.only(bottom:9),child:history?_BidHistoryCard(a):_MyAuctionCard(a))),
  ])));
  }
}

class _MyAuctionCard extends StatelessWidget{const _MyAuctionCard(this.a);final Auction a;@override Widget build(BuildContext c)=>AppSurfaceCard(padding:const EdgeInsets.all(9),child:Row(children:[ClipRRect(borderRadius:BorderRadius.circular(11),child:SizedBox(width:92,height:86,child:AppDataImage(a.image,fit:BoxFit.cover))),const SizedBox(width:10),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(a.title,maxLines:1,style:const TextStyle(fontWeight:FontWeight.w900)),const SizedBox(height:4),const Text('مزايدتك: 4,500 ر.س',style:TextStyle(color:AppColors.forest,fontWeight:FontWeight.w800,fontSize:11)),const Text('أنت صاحب أعلى مزايدة حاليًا',style:TextStyle(color:AppColors.success,fontSize:9)),const SizedBox(height:6),LinearProgressIndicator(value:.6,minHeight:4,borderRadius:BorderRadius.circular(4)),const SizedBox(height:4),Text('متبقي ${_duration(a.remaining)}',style:const TextStyle(color:AppColors.terracotta,fontSize:9))]))]));}

class _BidHistoryCard extends StatelessWidget{const _BidHistoryCard(this.a);final Auction a;@override Widget build(BuildContext c)=>AppSurfaceCard(child:Column(children:[Row(children:[CircleAvatar(backgroundColor:AppColors.forestSoft,child:Icon(Icons.gavel_rounded,color:AppColors.forest)),const SizedBox(width:8),Expanded(child:Text(a.title,style:const TextStyle(fontWeight:FontWeight.w900))),const Text('4,500 ر.س',style:TextStyle(color:AppColors.forest,fontWeight:FontWeight.w900))]),const Divider(),const Row(children:[Text('مزايدتك',style:TextStyle(color:AppColors.muted,fontSize:10)),Spacer(),Text('الأعلى حاليًا',style:TextStyle(color:AppColors.success,fontSize:10,fontWeight:FontWeight.w800))]),const SizedBox(height:5),const Text('16 سبتمبر 2026 • 06:15 ص',style:TextStyle(color:AppColors.muted,fontSize:9))]));}

class ReferenceAuctionReminderScreen extends StatelessWidget{
  const ReferenceAuctionReminderScreen({super.key});
  @override Widget build(BuildContext context)=>Scaffold(appBar:const MazraaAppBar(title:'تذكير المزاد'),body:AppPage(child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
    const SizedBox(height:30),const Center(child:CircleAvatar(radius:48,backgroundColor:AppColors.forestSoft,child:Icon(Icons.notifications_active_rounded,size:48,color:AppColors.forest))),const SizedBox(height:17),const Text('لن يفوتك المزاد',textAlign:TextAlign.center,style:TextStyle(fontSize:22,fontWeight:FontWeight.w900,color:AppColors.forestDark)),const SizedBox(height:7),const Text('اختر متى تريد أن نذكرك قبل بداية المزاد',textAlign:TextAlign.center,style:TextStyle(color:AppColors.muted)),const SizedBox(height:20),_AuctionMiniHeader(auction:ReferenceDemoData.auctions.first),const SizedBox(height:15),...['قبل ساعة','قبل 30 دقيقة','قبل 10 دقائق','عند بدء المزاد'].asMap().entries.map((e)=>RadioListTile<int>(value:e.key,groupValue:1,onChanged:(_){},title:Text(e.value))),const SizedBox(height:12),FilledButton.icon(onPressed:()=>Navigator.pop(context),icon:const Icon(Icons.notifications_active_rounded),label:const Text('حفظ التذكير')),
  ])));
}

class ReferenceGuaranteeScreen extends StatelessWidget{
  const ReferenceGuaranteeScreen({super.key});
  @override Widget build(BuildContext context)=>Scaffold(appBar:const MazraaAppBar(title:'تفاصيل حجز الضمان'),body:AppPage(child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
    const SizedBox(height:8),const Center(child:CircleAvatar(radius:48,backgroundColor:AppColors.forestSoft,child:Icon(Icons.shield_rounded,size:48,color:AppColors.forest))),const SizedBox(height:14),const Text('ضمان المشاركة في المزاد',textAlign:TextAlign.center,style:TextStyle(color:AppColors.forestDark,fontSize:20,fontWeight:FontWeight.w900)),const SizedBox(height:7),const Text('يتم حجز مبلغ مؤقت لضمان جدية المزايدة ويُعاد تلقائيًا إذا لم تفز.',textAlign:TextAlign.center,style:TextStyle(color:AppColors.muted,height:1.6)),const SizedBox(height:18),const AppSurfaceCard(child:Column(children:[_Meta(Icons.payments_outlined,'قيمة الضمان','250 ر.س'),Divider(height:16),_Meta(Icons.lock_clock_outlined,'نوع العملية','حجز مؤقت'),Divider(height:16),_Meta(Icons.replay_rounded,'الاسترداد','فوري عند انتهاء المشاركة'),Divider(height:16),_Meta(Icons.verified_user_outlined,'الحماية','عملية آمنة ومشفرة')])),const SizedBox(height:13),const AppSurfaceCard(color:Color(0xFFF8F0DC),child:Row(crossAxisAlignment:CrossAxisAlignment.start,children:[Icon(Icons.info_outline_rounded,color:AppColors.terracotta),SizedBox(width:8),Expanded(child:Text('عند الفوز، يمكن احتساب الضمان ضمن المبلغ المطلوب حسب شروط المزاد.',style:TextStyle(fontSize:11)))])),const SizedBox(height:20),FilledButton(onPressed:()=>Navigator.pushNamed(context,'/auction-bid'),child:const Text('المتابعة إلى المزايدة')),
  ])));
}

class _AuctionMiniHeader extends StatelessWidget{const _AuctionMiniHeader({required this.auction});final Auction auction;@override Widget build(BuildContext context)=>AppSurfaceCard(padding:const EdgeInsets.all(9),child:Row(children:[ClipRRect(borderRadius:BorderRadius.circular(11),child:SizedBox(width:94,height:78,child:AppDataImage(auction.image,fit:BoxFit.cover))),const SizedBox(width:10),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(auction.title,maxLines:2,style:const TextStyle(fontWeight:FontWeight.w900)),const SizedBox(height:5),Text(formatPrice(auction.currentBid),style:const TextStyle(color:AppColors.forest,fontWeight:FontWeight.w900)),const SizedBox(height:3),Text('متبقي ${_duration(auction.remaining)}',style:const TextStyle(color:AppColors.terracotta,fontSize:9))]))]));}

class _AuctionMetric extends StatelessWidget{const _AuctionMetric(this.label,this.value,this.icon,{this.color=AppColors.forest});final String label,value;final IconData icon;final Color color;@override Widget build(BuildContext c)=>Column(children:[Icon(icon,color:color,size:19),const SizedBox(height:3),Text(value,textAlign:TextAlign.center,maxLines:1,style:TextStyle(color:color,fontSize:12,fontWeight:FontWeight.w900)),Text(label,textAlign:TextAlign.center,style:const TextStyle(color:AppColors.muted,fontSize:8.5))]);}
class _Meta extends StatelessWidget{const _Meta(this.icon,this.label,this.value);final IconData icon;final String label,value;@override Widget build(BuildContext c)=>Row(children:[Icon(icon,color:AppColors.forest,size:19),const SizedBox(width:7),Text(label,style:const TextStyle(color:AppColors.muted,fontSize:10)),const Spacer(),Flexible(child:Text(value,textAlign:TextAlign.end,style:const TextStyle(fontSize:10.5,fontWeight:FontWeight.w800)))]);}
class _Title extends StatelessWidget{const _Title(this.text,this.icon);final String text;final IconData icon;@override Widget build(BuildContext c)=>Row(children:[Icon(icon,color:AppColors.forestDark,size:20),const SizedBox(width:6),Text(text,style:const TextStyle(color:AppColors.forestDark,fontSize:16,fontWeight:FontWeight.w900))]);}
String _duration(Duration d){final s=d.inSeconds.clamp(0,359999);String t(int v)=>v.toString().padLeft(2,'0');return '${t(s~/3600)}:${t((s%3600)~/60)}:${t(s%60)}';}
