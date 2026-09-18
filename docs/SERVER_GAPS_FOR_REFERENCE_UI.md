# فجوات الخادم المطلوبة لإكمال واجهات تطبيق العميل — بعد التدقيق الفعلي

> **تاريخ التدقيق:** 2026-09-19  
> **تطبيق العميل:** `astresstar3-debug/mazraa_customer_app` — الفرع `chatgpt/ci-emulator`  
> **الخادم:** `astresstar3-debug/Ecommerce_Api` — الفرع `main`  
> **حالة هذه الوثيقة:** تحليل ومتطلبات فقط. لم يتم تعديل أي Controller أو Model أو Migration أو قاعدة بيانات في الخادم.

## هدف الوثيقة

هذه النسخة تستبدل التقديرات السابقة بمقارنة فعلية بين:

- جميع المسارات المسجلة في `lib/core/navigation/app_router.dart`.
- شاشات المرجع والمطابقة الفعلية في `home / marketplace / cart / auctions / account / auth`.
- repositories المتصلة بالـAPI في تطبيق Flutter.
- Controllers وDTOs وEntities وDbContext وModelSnapshot في `Ecommerce_Api/main`.

الهدف هو عدم إضافة API أو جدول جديد إذا كان الخادم يملك البيانات أصلًا، وعدم اعتبار اختلاف شكل DTO فجوة قاعدة بيانات.

## مفتاح التصنيف

| التصنيف | المعنى |
|---|---|
| ✅ جاهز | الخادم يملك endpoint والبيانات المطلوبة بصورة كافية حاليًا. |
| 🟡 تعديل API فقط | نحتاج Controller/DTO/Service أو query إضافي، **بدون Migration**. |
| 🔴 يحتاج قاعدة بيانات | يلزم Model/Entity أو حقول/علاقات جديدة ثم EF Migration. |
| ⚪ اختياري | ليس مطلوبًا لمطابقة الواجهات الحالية، ويمكن تأجيله. |
| 📱 عميل فقط | شاشة/سلوك لا يحتاج endpoint جديدًا. |

---

# 1. تصحيحات مهمة على ملف الفجوات السابق

البنود التالية **ليست فجوات خادم** بعد مراجعة الكود الحالي:

| البند | الحالة الفعلية |
|---|---|
| سجل البحث | ✅ موجود: `GET /api/search/history` و`DELETE /api/search/history` مع جدول `SearchHistories`. |
| اقتراحات البحث الفورية | ✅ موجود: `GET /api/search/suggestions`. |
| خيارات الفلترة الأساسية | ✅ موجود: category/subCategory/brand/store/minPrice/maxPrice/inStock + sort + pagination في `SearchController`. |
| صور الأقسام | ✅ موجودة عبر `ImageService` و`ImageType.Category`. |
| إحداثيات العناوين | ✅ `Address` يحفظ `Latitude/Longitude` وCRUD الحالي يتعامل معها. |
| معرض صور المنتج | ✅ موجود عبر `Images` و`Media`، وتفاصيل المنتج تجمع الصور والفيديو. |
| variants للمنتج | ✅ موجودة في `/api/product-variants` و`/api/product-variants/by-product/{productId}`. |
| مواصفات المنتج | ✅ `GET /api/products/{id}/specs`. |
| أسئلة المنتج | ✅ `GET/POST /api/products/{id}/questions`. |
| تقييمات المنتج | ✅ `GET /api/products/{id}/reviews` إضافة إلى `/api/Reviews`. |
| المنتجات المشابهة | ✅ endpoint موجود، لكن DTO يحتاج إثراء فقط. |
| معاينة checkout | ✅ `POST /api/checkout/preview` ويعيد subtotal/discount/tax/deliveryFee/total/items. |
| طرق الشحن الأساسية | ✅ `GET /api/checkout/shipping-methods` موجود، لكنه يحتاج ETA/type إذا أردنا standard/express/scheduled. |
| طرق الدفع المتاحة | ✅ `GET /api/checkout/payment-methods`. |
| تتبع السائق والموقع | ✅ `GET /api/orders/{id}/tracking` يعيد بيانات السائق وآخر lat/lng/heading/speed/time. |
| إنشاء الإرجاع | ✅ `POST /api/orders/{id}/return`. |
| قائمة/تفاصيل الإرجاع | ✅ `GET /api/returns` و`GET /api/returns/{id}`. |
| تنفيذ الاسترداد | ✅ الخادم يملك `Refunds` ويدعم Stripe/Wallet/manual refund. |
| مزاداتي/مزايداتي | ✅ `GET /api/AuctionBids/mine`. |
| تسوية المزاد للفائز | ✅ موجودة فعليًا في `AuctionWinnersController`: mine/detail/checkout preview/checkout. |
| المحفظة والشحن والسجل | ✅ `/api/wallets/me`, `/top-up`, `/transactions` وجدول `WalletTopUps`. |
| الملف الشخصي والجلسات | ✅ `/api/users/me`, sessions, revoke session, avatar, password. |
| الدعم والتذاكر والمحادثة | ✅ FAQ/tickets/messages/live-chat/chats/attachments موجودة بالفعل. |

---

# 2. الشاشات التي لا تحتاج أي تعديل خادم

هذه الشاشات يجب ألا تدفعنا لإنشاء endpoints غير ضرورية:

- Onboarding: يمكن استخدام `GET /api/app/onboarding` أو assets محلية.
- Login/Register/Forgot/Reset/OTP: endpoints موجودة.
- Permission screens والموقع الأولي: 📱 من صلاحيات الجهاز/مزود الخرائط.
- حالات Empty / Success / Failed / Offline: 📱 تعتمد على نتيجة العمليات الموجودة.
- تغيير كلمة المرور: endpoint موجود.
- حذف الحساب: endpoint موجود.
- الشروط والخصوصية الأساسية: endpoints موجودة.
- تسجيل/حذف device token: endpoints موجودة.

---

# 3. الرئيسية، الأقسام، البحث والعروض

| المطلوب من الواجهة | الموجود فعليًا | التعديل الحقيقي | المكان المقترح | DB |
|---|---|---|---|---|
| الرئيسية: منتجات + مزادات + كوبونات + أقسام | APIs منفصلة موجودة | ⚪ endpoint مركب `GET /api/home` لتحسين الأداء فقط | Controller/Service جديد أو `AppController` | لا |
| الأقسام: صورة + عدد المنتجات | الصورة موجودة | إضافة `productCount` محسوب من SubCategories/Products | `CategoriesController` + DTO | لا |
| ترتيب الأقسام من الخادم | لا يوجد `SortOrder` | ⚪ فقط إذا كان التحكم من لوحة الإدارة مطلوبًا | `Category` | **نعم** |
| سجل البحث | موجود | لا شيء | — | لا |
| الاقتراحات الفورية | موجودة | لا شيء | — | لا |
| الأكثر بحثًا | لا يوجد endpoint مباشر | إضافة `GET /api/search/popular` من `SearchHistories` مجمعة | `SearchController` | لا |
| filter حسب نوع المنتج | Product.TypeId موجود | إضافة `TypeId` إلى `ProductSearchRequest` | `SearchController` | لا |
| filter حسب التقييم | Reviews موجودة | إضافة `MinRating` | `SearchController` | لا |
| خصومات فقط | Price/SalePrice موجودان | إضافة `DiscountOnly` | `SearchController` | لا |
| الموقع/القرب | Stores لديها Latitude/Longitude | إضافة `lat,lng,radiusKm` عند الحاجة | `SearchController` | لا |
| نتائج البحث ProductCard كاملة | معظم البيانات موجودة | توحيد card DTO ليشمل image/price/oldPrice/discount/rating/stock/store | DTO/query | لا |
| صفحة العروض مع عداد انتهاء | يوجد SalePrice لكن لا توجد مدة عرض | إذا كانت العروض موسمية/مؤقتة من الخادم: إنشاء Promotion + PromotionItem أو حقول مدة عرض | Domain + Controller + Admin | **نعم** |
| banners ديناميكية | `GET /api/app/banners` يعيد قائمة فارغة | ⚪ إن أريد التحكم من لوحة الإدارة: Banner entity؛ وإلا تبقى assets محلية | App/Home | **نعم فقط إذا ديناميكية** |

**ملاحظة:** لا حاجة إلى `slug` أو `color` للقسم لمطابقة الواجهات الحالية. لا تضاف للقاعدة إلا إذا أصبحت متطلبًا إداريًا مستقلًا.

---

# 4. تفاصيل المنتج والـVariants

الخادم الحالي يملك بيانات أكثر مما كان موثقًا سابقًا.  
`ProductVariant` يملك بالفعل SKU, Price, SalePrice, stock-related data, dimensions, Unit, Manufacturer, StoreId, CountryOfOrigin, ProductionDate, ExpiryDate, Formula, UsageMethod.

| المطلوب | الحالة | التعديل | المكان | DB |
|---|---|---|---|---|
| brand/type/category | ✅ موجود | توحيد DTO فقط | Product DTO | لا |
| variant المختار + SKU + السعر | ✅ موجود | التطبيق يختار variant، ويمكن endpoint التفاصيل إرجاع variants اختياريًا | Product details query | لا |
| stock/status/max quantity | المخزون موجود في Inventories | إرجاع `availableQuantity/stockStatus` بوضوح | Product/Variant DTO | لا |
| store/seller | العلاقات موجودة | إرجاع Store summary في ProductCard/Details | Product DTO | لا |
| gallery كاملة | ✅ موجود | توحيد URL إلى روابط صالحة فقط | Image/Media service | لا |
| بلد المنشأ/الاستخدام/التركيبة | ✅ موجودة في Variant | إظهارها في DTO | Variant DTO | لا |
| التخزين/تحذيرات مرنة | يمكن تمثيلها في ProductSpecifications | استخدم specs بدل إنشاء أعمدة متخصصة | Product specs | لا |
| delivery estimate | لا يوجد في المنتج، ويجب أن يعتمد على الشحن | يحسب من shipping option/address وليس من Product | Checkout/Delivery service | لا |
| shareUrl | لا يحتاج تخزينًا | يبنى من route/deep link | API/app config | لا |
| warranty/return policy خاصة بكل منتج | غير موجودة وغير لازمة لكل الواجهات الحالية | ⚪ أضفها فقط إذا أصبحت سياسة مختلفة لكل منتج | Product/Policy | **نعم إذا كانت per-product** |

## الفيديو

`GET /api/products/{id}/videos` موجود ويعيد MediaDto.

- الواجهة الحالية لا تتطلب title/thumbnail/sortOrder حتى تعمل.
- ⚪ إذا أريد metadata احترافي لكل فيديو (`title,thumbnailUrl,sortOrder`) فيلزم توسيع `Media`.
- **Migration: نعم فقط لهذا التحسين الاختياري.**

## المواصفات

العقد الحالي `id,name,value,unit` كافٍ للواجهة.

- `group` و`sortOrder` تحسين اختياري فقط.
- إذا أضيفا كبيانات مُدارة من السيرفر: **Migration: نعم**.

## المنتجات المشابهة

الـendpoint موجود لكنه يرجع DTO مختصرًا.

**المطلوب:** إعادة ProductCard كاملة: id/name/image/price/oldPrice/discount/rating/inStock/store.  
**المكان:** `ProductsExtrasController.Related` + DTO موحد.  
**Migration:** لا.

## الأسئلة

البيانات الموجودة في DB تشمل `Answer` و`AnsweredAt` و`UserId`.

المطلوب API فقط:

- إرجاع `answeredAt`.
- إرجاع `isMine` للمستخدم المسجل.
- status مشتق: `answered/pending`.
- pagination.

**Migration:** لا.

## التقييمات

يوجد endpointان قابلان للاستخدام: `/api/products/{id}/reviews` و`/api/Reviews?productId=`.

المطلوب:

- اختيار عقد واحد canonical لتطبيق العميل.
- pagination.
- rating distribution محسوب.
- `verifiedPurchase` محسوب من الطلبات المسلمة.
- صور التقييم **غير مستخدمة في الواجهة الحالية**؛ لا ننشئ لها جدولًا الآن.

**Migration:** لا لمتطلبات الشاشة الحالية.

---

# 5. الكوبونات

الـCoupon الحالي يملك بالفعل:

`code,name,description,discountType,discountValue,minimumOrderAmount,maximumDiscountAmount,usageLimit,usedCount,validFrom,validTo,status,imageUrl/images`.

لذلك لا نعيد إنشاء هذه الحقول.

| المطلوب | الإجراء | DB |
|---|---|---|
| remainingUses | يحسب `usageLimit-usedCount` | لا |
| isActive | يشتق من status + dates + usage | لا |
| تطبيق الكوبون | استخدم CheckoutQuote الحالي من `POST /api/cart/apply-coupon` بدل عقد مكرر | لا |
| eligibleCategories/products/exclusions | ⚪ ليست مطلوبة بصريًا حاليًا؛ إذا اعتمدت كقواعد أعمال فعلية نحتاج جداول ربط | **نعم عند تفعيلها** |
| terms نصية خاصة بالكوبون | ⚪ يمكن إضافتها فقط إذا ستظهر فعليًا لكل كوبون | **نعم إذا خزنت لكل كوبون** |

---

# 6. السلة والـCheckout

## السلة

`GET /api/Carts` يعيد حاليًا image/variant/product/price/quantity.

نحتاج إثراء الاستجابة فقط بـ:

- `regularPrice` و`discountAmount/discountPercent` من Price/SalePrice.
- `availableQuantity` و`maxQuantity` من Inventory.
- `storeId/storeName`.
- availability reason إن أصبح variant غير صالح.

**Migration:** لا.

## Checkout

`POST /api/checkout/preview` موجود ويعيد:

subtotal, discount, tax, deliveryFee, total, currency, couponCode, items, warehouse/store/address/zone.

إذن لا نحتاج Checkout summary جديدًا.

### فجوات الشحن الحقيقية

`GET /api/checkout/shipping-methods` يرجع حاليًا zone/name/deliveryFee فقط.

نحتاج أحد المستويين:

1. **MVP بدون جداول جديدة:** إضافة `type` وETA مشتقة من إعدادات config لكل طريقة.  
   **Migration: لا.**

2. **Scheduled delivery الحقيقي:** تواريخ وفترات قابلة للحجز وسعة/رسوم لكل slot.  
   المقترح:
   - `DeliverySlot`
   - وربط الحجز بالـOrder أو `OrderDeliverySlot`
   - endpoint `GET /api/delivery/slots?addressId=&date=&storeId=`
   - إرسال `deliverySlotId` عند preview/create order  
   **Migration: نعم.**

### تفضيلات التوصيل

الواجهة تحتوي contactless / الاتصال قبل الوصول / تعليمات الموصل.

المقترح:

- `GET/PUT /api/users/me/delivery-preferences`.
- Entity `UserDeliveryPreference` أو حقول منظمة في preference مستقل.
- عند إنشاء الطلب، الأفضل أخذ **snapshot** للتفضيلات/الملاحظات المهمة حتى لا تتغير طلبات قديمة إذا غيّر المستخدم إعداداته لاحقًا.

**Migration: نعم.**

---

# 7. الدفع

## طرق الدفع المحفوظة

`GET /api/users/me/payment-methods` يصرح حاليًا صراحة أن `saved=[]` و`supportsSavedCard=false`.

إذا كانت شاشة البطاقات المحفوظة ستعمل فعليًا:

- Entity جديد مثل `UserPaymentMethodToken`:
  - UserId
  - Provider
  - ProviderPaymentMethodId/token reference
  - Brand
  - Last4
  - ExpMonth/ExpYear
  - IsDefault
  - Status
- endpoints CRUD تحت `/api/users/me/payment-methods/cards`.
- **ممنوع حفظ PAN أو CVV الخام في قاعدة التطبيق.**

**Migration: نعم.**

## الدفع عند الاستلام

طريقة الدفع موجودة.

المطلوب فقط إرجاع:

- eligible
- fee
- maxAmount
- message/terms

يمكن وضع القواعد في configuration أولًا.

**Migration: لا** ما لم نرغب بلوحة إدارة لقواعد COD حسب متجر/منطقة.

## التحويل البنكي

Payment الحالي يملك `BankReference` و`ReceiptUrl`.

المطلوب:

- endpoint لرفع/ربط إيصال التحويل بالدفع.
- endpoint/response لبيانات حساب التحويل من configuration.
- تحديث status بعد المراجعة.

**Migration: لا** للنسخة الأولى لأن الحقول موجودة.

## تفاصيل الدفع

إضافة:

`GET /api/payments/{paymentId}`

أو توسيع `GET /api/Payments/order/{orderId}` ليعيد DTO آمنًا موحدًا:

reference, amount, currency, method, status, paidAt, orderId, fees/receiptUrl.

**Migration:** لا.

## العملة

يوجد عدم اتساق حالي: أجزاء من checkout/payment/auction تستخدم `USD` بينما واجهة المرجع تعرض `ر.س`.

المطلوب:

- مصدر Currency واحد من configuration/Store/Currency.
- منع hard-coded USD في checkout وauction winner payment.
- تحديث seed/data إن كانت البيئة المستهدفة SAR.

**Schema Migration:** لا.  
**قد نحتاج Data Update/Seed فقط** حسب البيانات الموجودة.

---

# 8. الطلبات، التفاصيل والتتبع

## قائمة الطلبات

`GET /api/Orders` يعمل، لكن `OrderResponseDto` لا يملأ جميع الحقول الموجودة فيه ولا يعيد الصور.

المطلوب API فقط:

- thumbnail لكل item.
- `variantName`.
- paymentMethod/isPaid.
- totals مختصرة.
- `canCancel/canReturn/canRate` محسوبة من الحالة.
- tracking summary إذا وجدت Shipment.

**Migration:** لا.

## تفاصيل الطلب

بدل إنشاء endpoint جديد، يمكن توسيع `GET /api/Orders/{id}` أو اعتماد `GET /api/checkout/orders/{id}/review` كـdetail DTO.

يجب أن يجمع:

- address snapshot/current address display.
- items + images.
- subtotal/discount/tax/shipping/total.
- payment snapshot.
- shipment/tracking summary.
- store info.
- selected delivery slot إذا تم تنفيذ scheduled delivery.

**Migration:** لا بحد ذاته؛ يتأثر فقط بجداول DeliverySlot إذا اعتمدناها.

## مراحل الطلب

للمطابقة الحالية يمكن إظهار progress من `OrderStatus` و`ShipmentStatus`.

- لا نحتاج جدول history لمجرد إظهار المراحل.
- ⚪ إذا أردنا تاريخ/وقت دقيق لكل انتقال حالة، أنشئ `OrderStatusHistory/ShipmentStatusHistory`.

**Migration:** لا للواجهة الحالية، **نعم** للتاريخ الزمني الكامل.

## تتبع الطلب

الموجود حاليًا جيد: driver + آخر موقع.

المطلوب API فقط:

- driver photo إن وجدت صورة المستخدم/السائق.
- ETA محسوب من آخر موقع + destination/provider.
- destination coordinates من Address.
- route/polyline يمكن إرجاعها من خدمة الخرائط عند الحاجة.

**Migration:** لا.

## إلغاء الطلب

العملية الحالية `POST /api/Orders/{id}/cancel` لا تستقبل السبب.

الواجهة الحالية تطلب سببًا وملاحظة اختيارية، لذلك:

- `GET /api/orders/{id}/cancel-options` يمكن أن يكون static/config — بدون DB.
- تعديل cancel request ليستقبل `reasonCode/reasonText/note`.
- لحفظ سبب الإلغاء كسجل فعلي أضف حقولًا للـOrder أو Entity `OrderCancellation`.

**Migration: نعم** لأن حفظ سبب المستخدم مطلوب لتكامل الشاشة وعدم فقد البيانات.

---

# 9. التقييمات بعد الطلب

`POST /api/orders/{id}/rate` يدعم بالفعل:

- DeliveryRating
- StoreRating
- Comment

أما تقييم المنتج فيتم عبر `/api/Reviews`.

لذلك لا ندمج كل شيء في جدول واحد:

- شاشة تقييم الطلب ترسل store/delivery إلى order rating.
- لكل منتج يتم إرسال Product Review مستقل إذا اختار المستخدم تقييمه.

**Migration:** لا.

---

# 10. الإرجاع والاسترداد

## الإرجاع

الخادم يدعم request + items + quantities + reason + status + refund amount.

الواجهة الحالية تحتاج أيضًا اختيار **طريقة الاسترداد**: المحفظة أو وسيلة الدفع الأصلية.

المطلوب:

- إضافة `RefundPreference` إلى طلب الإرجاع.
- التحقق من صلاحية الخيار حسب PaymentMethod.
- الاحتفاظ بالاختيار حتى معالجة الاسترداد.

**Migration: نعم** لإضافة الحقل إلى `CustomerReturnRequest` أو كيان منفصل.

لا نضيف pickup method أو صور إرجاع الآن لأنها ليست جزءًا ضروريًا من الشاشة المرجعية الحالية.

## نجاح الإرجاع

Create return يعيد أصلًا id/status/refundAmount.

يمكن إضافة `estimatedReviewAt` محسوبًا من SLA في config.

**Migration:** لا.

## حالة الاسترداد

لا يوجد endpoint باسم `refund-status`، لكن جميع البيانات الأساسية موجودة في:

- `CustomerReturnRequest`
- `Refund`
- Payment
- requestedAt/resolvedAt/refundedAt

المطلوب:

`GET /api/returns/{id}/refund-status`

يرجع status, amount, method, reference, requestedAt, resolvedAt, refundedAt, expectedAt.

**Migration:** لا.

---

# 11. الفاتورة

`GET /api/checkout/orders/{id}/invoice` موجود لكنه يعيد حاليًا رأس المستند فقط.

الواجهة تحتاج فاتورة كاملة.

المطلوب توسيع DTO ليعيد:

- seller/store data.
- customer/address.
- items.
- subtotal/discount/tax/shipping/total.
- payment method/status.
- invoice/document number/date.
- downloadUrl إذا تم إنشاء PDF.

البيانات الأساسية موجودة في Order/Document/Payment.

**Migration:** لا.

---

# 12. المزادات

## القائمة والفلترة

`GET /api/Auctions/discover` يرجع حاليًا:

id/title/description/start/end/status/seller/itemCount/bidCount/currentPrice/image.

إذن لا نطلب هذه الحقول مجددًا.

المطلوب للفلتر المرجعي:

- minPrice/maxPrice.
- endingWithin.
- sort الموسع.
- deliveryAvailable إذا تم تعريف التوصيل للمزاد.
- guaranteeRequired بعد تنفيذ نظام الضمان.
- category/type إن قررنا دعم مزادات أنواع غير الحيوان.

### ملاحظة بنيوية مهمة

النموذج الحالي `AuctionItem` مرتبط بـ `AnimalId`، بينما واجهات المرجع تعرض أيضًا:

- منتجات زراعية.
- معدات زراعية.
- محصول/تمور.

إذا كان هذا التنوع **وظيفة حقيقية** وليس مجرد مرجع بصري، فالنموذج الحالي غير كافٍ.

الحل المفضل:

- تحويل AuctionItem إلى subject متعدد الأنواع:
  - `ItemType`
  - `AnimalId?`
  - `ProductVariantId?`
  - أو Asset/Equipment entity حسب نطاق النظام.
- عدم تخزين عناوين/مواصفات المعدات كنصوص وهمية في DTO.

**Migration: نعم** عند تفعيل مزادات المنتجات/المعدات.  
إذا كانت النسخة الأولى مزادات حيوانات فقط: لا Migration لهذه النقطة.

## تفاصيل المزاد

الموجود فعليًا يشمل:

- start/reserve/min increment/current/next minimum.
- bid count.
- current user bid/highest status.
- images.
- seller/store.
- terms + payment window.

المطلوب المتبقي يعتمد على نوع المزاد:

- location: يمكن أخذها من Store coordinates/address.
- delivery/pickup: يحتاج contract واضح.
- condition/quality/model/hours: تأتي من نوع العنصر، وليست حقول Auction عامة.

**Migration:** لا للمزاد الحيواني الحالي؛ يعتمد على توسيع أنواع AuctionItem أعلاه.

## سجل المزايدات

يوجد `GET /api/AuctionBids/auction-item/{auctionItemId}`.

المطلوب فقط:

- pagination.
- إخفاء الهوية أو label آمن بدل كشف bidderUserId.
- isMine موجود بالفعل.

**Migration:** لا.

## مزاداتي

`GET /api/AuctionBids/mine` موجود.

يمكن إثراء DTO بـ:

- outbid.
- winner status.
- paymentDueAt عند الفوز.

توجد `AuctionWinner` بالفعل.

**Migration:** لا.

## تذكير المزاد

لا يوجد Entity أو endpoint.

للتذكير المتزامن مع الحساب وPush:

- `AuctionReminder(UserId,AuctionId/ItemId,RemindAt,Type,IsSent,...)`
- POST/DELETE reminder.
- GET my reminders.
- worker يرسل notification.

**Migration: نعم.**

> إذا كان التذكير Local Notification على نفس الهاتف فقط، يمكن تنفيذه في Flutter بدون خادم. لكن ذلك لا يزامن الأجهزة ولا يضمن push من السيرفر.

## ضمان/عربون المزاد

لا يوجد سجل ضمان يربط المستخدم بالمزاد.

المطلوب:

- `AuctionGuarantee` أو `AuctionDeposit`:
  UserId, AuctionId/ItemId, Amount, Currency, Status, PaymentMethod, Payment/WalletTransaction reference, PaidAt, ReleasedAt/RefundedAt.
- quote.
- pay.
- release/refund حسب نتيجة المزاد.
- ربطه بالـbid validation.
- احتسابه في settlement عند الفوز.

**Migration: نعم.**

## تأكيد المزايدة

يمكن إضافة preview/quote endpoint يحسب:

- current price.
- min next bid.
- proposed amount.
- guarantee status/amount.

**Migration:** لا للـquote نفسه؛ يعتمد على جدول الضمان إذا كانت الضمانات مفعلة.

## الفوز والتسوية

هذا **موجود** في `AuctionWinnersController`:

- `GET /api/auction-winners/mine`
- `GET /api/auction-winners/{id}`
- `POST /api/auction-winners/{id}/checkout/preview`
- `POST /api/auction-winners/{id}/checkout`

لا ننشئ settlement جديدًا.

المطلوب فقط تعديل الحساب لاحقًا ليطرح العربون المدفوع من remaining amount إذا تم تنفيذ AuctionGuarantee.

---

# 13. العناوين والموقع

الحقول الموجودة الآن:

city, street, details, latitude, longitude, countryId, cityId, isDefault.

الواجهة المرجعية تطلب أيضًا:

- اسم/Label العنوان (المنزل/العمل/المزرعة).
- اسم المستلم.
- رقم هاتف المستلم.
- الحي.
- landmark اختياري.
- تعليمات التوصيل.

هذه بيانات يجب أن تبقى محفوظة وليست مشتقة.

المقترح توسيع `Address` بـ:

- `Label` أو `AddressType`.
- `RecipientName`.
- `RecipientPhone`.
- `District`.
- `Landmark`.
- `DeliveryInstructions`.

وتحديث `AddressRequest` وresponses.

**Migration: نعم.**

## تحديد الموقع

- lat/lng موجودان بالفعل.
- reverse geocoding يبقى في مزود الخرائط أو service منفصل.
- لا نحتاج جدولًا جديدًا.

---

# 14. المحفظة

## الملخص

`GET /api/wallets/me` موجود.

أضف API فقط:

- pendingTopUpBalance محسوب من WalletTopUps pending.
- monthlyCredits/monthlyDebits محسوبة من WalletTransactions.
- limits/methods للـtop-up من config.

**Migration:** لا.

## سجل العمليات

إضافة filters + pagination:

- type.
- date range.
- reference.
- pagination.

**Migration:** لا.

### transaction status

`WalletTransaction` لا يملك Status، لكنه يمثل ledger entries المكتملة في التصميم الحالي.

- لا نضيف Status لمجرد الواجهة.
- حالة الشحن pending/approved/rejected تأتي من `WalletTopUp.Status`.
- إذا أصبح النظام يسجل معاملات محفظة pending داخل نفس الجدول، حينها أضف Status.

**Migration:** لا حاليًا.

## حالة طلب شحن المحفظة

إضافة:

`GET /api/wallets/top-ups/{id}`

ويقرأ من `WalletTopUps`.

**Migration:** لا.

## تحويل الأموال

لا يوجد endpoint حاليًا بينما الواجهة تعرض زر “تحويل الأموال”.

قرار المنتج مطلوب قبل التنفيذ:

- إن لم تكن الميزة مطلوبة في الإصدار الأول: إخفاء الزر وعدم إضافة backend.
- إن كانت مطلوبة: الأفضل إنشاء `WalletTransfer` لتتبع sender/recipient/amount/status/idempotency/OTP ثم إنشاء ledger entries عند النجاح.

**Migration: نعم (موصى بها عند تفعيل الميزة).**

---

# 15. الحساب، الهاتف، الجلسات والإشعارات

## الملف الشخصي

`GET /api/users/me` يعيد بالفعل:

name/firstName/lastName/phone/email/profileImageUrl/gender/dateOfBirth/level/loyaltyPoints وغيرها.

**لا تعديل قاعدة بيانات.**

## الصورة الشخصية

الرفع موجود ويعيد `imageUrl`.

المطلوب فقط توحيد contract إلى:

`profileImageUrl` وربما thumbnail إن احتجناه.

**Migration:** لا.

## تغيير الهاتف

OTP موجود، لكن لا يوجد flow مصادق عليه يغيّر رقم المستخدم الحالي بعد التحقق.

المطلوب:

- request OTP للرقم الجديد مع purpose=`change_phone`.
- verify + uniqueness check.
- commit `User.Phone` بعد نجاح التحقق.
- revoke/notify حسب سياسة الأمان.

الـUser وOtpCode موجودان.

**Migration:** لا.

## الجلسات

موجودة ولا نضيف جدولًا.

يمكن إضافة `current` و`lastActiveAt` إذا أمكن اشتقاقهما؛ وإلا هما تحسين اختياري.

## تفضيلات الإشعارات

الموجود حاليًا عالمي فقط:

push/email/sms/marketing.

الواجهة المرجعية لديها فئات مستقلة:

- orders.
- delivery.
- auctions.
- outbid/reminders.
- offers.
- wallet/payment.
- support/messages.
- newsletters/updates.

لذلك نحتاج تخزينًا تفصيليًا.

المفضل إنشاء جدول normalized مثل:

`UserNotificationPreference(UserId, Category, PushEnabled, EmailEnabled, SmsEnabled)`

بدل إضافة عشرات الأعمدة إلى `UserPreference`.

**Migration: نعم.**

## Notification payload

Notification الحالي يحتوي:

eventType/title/message/createdAt/isRead/deepLink/DataJson.

هذا كافٍ للشاشة الحالية.

`imageUrl` اختياري ويمكن وضعه في DataJson إلى أن يصبح متطلبًا ثابتًا.

**Migration:** لا.

---

# 16. الشروط، الخصوصية والسياسات

الموجود:

- `/api/content/terms`
- `/api/content/privacy`
- about/contact/share.

المطلوب للواجهة الحالية: لا شيء إضافي.

⚪ إذا أريد `returnPolicy` مستقلة مع version/effectiveDate/lastUpdated من لوحة إدارة، يمكن لاحقًا إنشاء ContentPage entity أو CMS بسيط.

**Migration:** غير مطلوب الآن.

---

# 17. الدعم والتذاكر والمحادثة

الخادم الحالي أقرب للاكتمال مما كان موثقًا:

- FAQ موجود.
- tickets list/create/detail/reply/close موجود.
- live chat موجود.
- chat messages paged.
- attachment upload للمحادثة موجود.
- SupportTicketMessage يملك AttachmentUrl.

المطلوب فقط:

| المطلوب | التعديل | DB |
|---|---|---|
| بحث FAQ | query على question/answer/category | لا |
| قائمة فئات FAQ | distinct categories | لا |
| contact channels/hours | من config أو `/api/content/contact` | لا |
| unreadCount للتذاكر | يحتاج مفهوم read state غير موجود | ⚪ **نعم فقط إذا نحتاج unread حقيقي** |
| إنشاء ticket مع attachment | يمكن رفع الملف أولًا ثم إرسال URL أو إضافة multipart wrapper | لا |
| ربط ticket بطلب OrderId | غير مطلوب للشاشة الحالية؛ إن فُعّل كعلاقة ثابتة | ⚪ نعم |
| realtime | polling يعمل بالعقد الحالي؛ SignalR تحسين لاحق | لا |

لا ننشئ نظام دعم جديدًا.

---

# 18. المتطلبات التي تحتاج Migration فعليًا

هذه هي قائمة تغييرات قاعدة البيانات التي لها مبرر مباشر من الواجهات/التدفقات الحالية، وليست مجرد تحسين DTO:

1. **العروض المؤقتة/الموسمية** إذا كان عداد الانتهاء ديناميكيًا:
   - Promotion + PromotionItem أو تصميم مكافئ.
2. **Scheduled Delivery**:
   - DeliverySlot + ربط slot بالطلب.
3. **تفضيلات التوصيل**:
   - UserDeliveryPreference + snapshot/fields على الطلب حسب التصميم.
4. **البطاقات المحفوظة المرمّزة**:
   - UserPaymentMethodToken؛ بدون PAN/CVV.
5. **سبب إلغاء الطلب**:
   - OrderCancellation أو حقول reason/note.
6. **تفضيل طريقة الاسترداد**:
   - RefundPreference على CustomerReturnRequest أو كيان منفصل.
7. **تذكيرات المزادات**:
   - AuctionReminder.
8. **عربون/ضمان المزادات**:
   - AuctionGuarantee/AuctionDeposit.
9. **تفاصيل العناوين المطلوبة في UI**:
   - label/type, recipientName, recipientPhone, district, landmark, deliveryInstructions.
10. **تفضيلات الإشعارات حسب الفئة**:
    - UserNotificationPreference.
11. **مزادات المنتجات/المعدات غير الحيوانية**:
    - توسيع AuctionItem subject model، **فقط إذا هذه الأنواع مطلوبة فعليًا في الإصدار الحالي**.

## Migrations اختيارية وليست شرطًا الآن

- Category.SortOrder.
- Media title/thumbnail/sortOrder.
- ProductSpecification group/sortOrder.
- Product-level warranty/return policy.
- Order/Shipment status history بالتوقيت.
- Coupon product/category eligibility.
- WalletTransfer عند تفعيل التحويل.
- CMS/Content pages متقدمة.
- Support unread/order linking.

---

# 19. تعديلات API المطلوبة بدون Migration

هذه الأعمال يجب تنفيذها قبل التفكير في جداول إضافية غير لازمة:

1. توحيد ProductCard DTO في search/related/home/wishlist/orders.
2. Category `productCount`.
3. Search: typeId/minRating/discountOnly/location + popular searches.
4. Related products: السعر/الصورة/المخزون/التقييم.
5. Questions: answeredAt/isMine/status/pagination.
6. Reviews: canonical contract + pagination/distribution/verifiedPurchase.
7. Cart item: regularPrice/discount/stock/maxQuantity/store.
8. Shipping methods: type + ETA للطرق غير المجدولة.
9. COD eligibility/fee/limit من config.
10. Bank transfer receipt endpoint باستخدام Payment.ReceiptUrl/BankReference.
11. Payment detail DTO.
12. Orders list/detail enrichment + item thumbnails + action flags.
13. Tracking: driver photo/ETA/destination/route حسب مزود الخرائط.
14. Refund-status endpoint.
15. Full invoice DTO/PDF response.
16. Auction discover filters الحالية التي لا تحتاج schema.
17. Bid history pagination/privacy.
18. My auctions enrichment من AuctionWinner.
19. Wallet monthly summary/pending topups/filters/top-up status.
20. Authenticated change-phone flow.
21. FAQ search/categories.
22. توحيد Currency وإزالة hard-coded USD من مسارات العميل.

---

# 20. ترتيب التنفيذ المقترح قبل ربط كل الشاشات نهائيًا

## المرحلة A — بدون Migration أولًا

نفذ تغييرات DTO/queries/endpoints التي تعتمد على البيانات الموجودة:

1. Product/Search/Home cards.
2. Cart + Checkout + currency.
3. Orders/detail/tracking/invoice/refund status.
4. Auctions discover/bids/mine/winner settlement.
5. Wallet summary/top-up status.
6. Change phone.
7. Support refinements.

بعدها يمكن ربط نسبة كبيرة من الشاشات دون لمس schema.

## المرحلة B — Migration واحد منظم للمتطلبات المؤكدة

اجمع التغييرات المؤكدة في تصميم متناسق:

- Address fields.
- UserDeliveryPreference.
- DeliverySlot + Order slot reference.
- UserPaymentMethodToken.
- OrderCancellation.
- Return refund preference.
- AuctionReminder.
- AuctionGuarantee.
- UserNotificationPreference.
- Promotion إن كان العداد/العروض الديناميكية مطلوبة.

## المرحلة C — اختيارات المنتج

لا تنفذ قبل قرار واضح:

- Wallet transfer.
- Multi-type auctions للمنتجات/المعدات.
- Coupon scoped eligibility.
- full status history.
- CMS dynamic content.
- review images/video metadata.

---

# 21. الملفات الرئيسية المتوقع تعديلها لاحقًا

> القائمة توضح أماكن التنفيذ، وليست أمرًا بالتعديل الآن.

### Controllers

- `Controllers/SearchController.cs`
- `Controllers/CategoriesController.cs`
- `Controllers/ProductsController.cs`
- `Controllers/ProductsExtrasController.cs`
- `Controllers/CartsController.cs`
- `Controllers/CartExtrasController.cs`
- `Controllers/CheckoutExtrasController.cs`
- `Controllers/PaymentsController.cs`
- `Controllers/OrdersController.cs`
- `Controllers/OrdersExtrasController.cs`
- `Controllers/ReturnsController.cs`
- `Controllers/AuctionsController.cs`
- `Controllers/AuctionBidsController.cs`
- `Controllers/AuctionWinnersController.cs`
- `Controllers/AddressesController.cs`
- `Controllers/WalletController.cs`
- `Controllers/UsersExtrasController.cs`
- `Controllers/NotificationsExtrasController.cs`
- `Controllers/SupportController.cs`

### Services/DTOs

- Product card/details DTOs.
- `CustomerCheckoutService`.
- Order/Payment/Return DTOs.
- Auction discovery/winner DTOs.
- Wallet DTOs جديدة بدل إعادة entities الخام عند الحاجة.

### Models/DbContext — فقط بعد اعتماد المرحلة B

- `Models/Address.cs`
- models الجديدة المذكورة في قسم Migrations.
- `Data/ApplcationDBContext.cs`
- ثم EF Core Migration واحدة أو migrations منظمة حسب سياسة المشروع.

---

# 22. Endpoints مؤكدة ولا يجب اعتبارها فجوات

- Auth login/register/refresh/logout.
- Social login endpoints الموجودة.
- Phone OTP request/verify.
- Forgot/reset password.
- Products/Categories/variants.
- Search + history + suggestions + filters + sort options.
- Product images/videos/specs/questions/reviews/related/recommended/recently-viewed.
- Cart CRUD + summary + apply coupon.
- Coupons list/detail.
- Checkout preview/shipping methods/payment methods.
- Orders create/list/detail/cancel.
- Order tracking/rating/return.
- Returns list/detail/status/refund.
- Checkout review/confirmation/invoice.
- Wishlist.
- Auctions list/details/discover.
- Auction items/bids/mine.
- Auction winner mine/detail/checkout preview/checkout.
- User profile/settings/avatar/password/sessions/delete.
- Notifications + mark read/count.
- Addresses CRUD/default + coordinates.
- Wallet summary/transactions/top-up.
- Device token register/delete.
- Support FAQ/tickets/live chat/chats/messages/attachments.
- Terms/privacy/about/contact/share.

---

# 23. الخلاصة التنفيذية

لا ينبغي تعديل قاعدة البيانات لكل بند في ملف الفجوات القديم.

القاعدة الحالية تحتوي بالفعل على معظم البنية الأساسية: المنتجات والـvariants والمخزون والصور/الوسائط، البحث وسجله، checkout، payments/refunds، shipment locations، auctions/winners، wallet topups، support/chat وغيرها.

العمل الصحيح هو:

1. **إثراء وتوحيد عقود API أولًا** باستخدام البيانات الموجودة.
2. **إنشاء Migration فقط** للبيانات التي لا يوجد مكان صحيح لتخزينها حاليًا.
3. عدم إنشاء endpoint مكرر عندما يوجد endpoint فعلي يؤدي نفس الوظيفة.
4. عدم إبقاء بيانات مرجعية ثابتة في Flutter بعد توفر العقد النهائي من الخادم.
5. عدم تخزين أي بيانات بطاقة حساسة؛ الخادم يحتفظ فقط بمعرفات/token provider وmetadata آمنة.
