# فجوات الخادم المطلوبة لإكمال واجهات تطبيق العميل

> هذا الملف هو عقد العمل بين واجهات Flutter والصورة المرجعية. يتم تحديثه أثناء المطابقة البصرية. الهدف أن تكتمل واجهات التطبيق الآن حتى عند غياب بعض واجهات API، ثم يُعدّل الخادم لاحقًا ليغذي نفس العناصر دون إعادة تصميم الواجهات.

## قواعد التكامل

- بيانات الخادم الحقيقية لها الأولوية في التشغيل العادي.
- بيانات `ReferenceDemoData` وfixtures تستخدم فقط لإكمال الواجهة عندما تكون البيانات/الـendpoint غير متاحة أو أثناء اختبار المطابقة البصرية.
- لا يجب تغيير بنية الشاشة عند استبدال fixture ببيانات الخادم؛ المطلوب فقط استبدال مصدر البيانات.
- كل صور المنتجات/المزادات يجب أن تعود كروابط صالحة أو قائمة صور، وليس اسم ملف فقط.

## السوق والرئيسية

| الشاشة | الموجود حاليًا | الفجوة المطلوبة من الخادم |
|---|---|---|
| الرئيسية | `/api/search`, `/api/Products`, `/api/product-variants`, `/api/Auctions/discover`, `/api/Coupons` | Endpoint مركب اختياري للرئيسية لتقليل عدد الطلبات، مع أقسام سريعة، عروض مميزة، الأكثر مبيعًا، كوبون مميز، مزادات حية وصور كاملة. |
| الأقسام | `GET /api/Categories` | صورة/أيقونة لكل قسم، عدد المنتجات، slug/id ثابت، لون/ترتيب اختياري. |
| البحث | `/api/search?q=&sort=&page=&perPage=` | سجل البحث للمستخدم، الكلمات الشائعة، اقتراحات فورية، دعم categoryId/brandId/minPrice/maxPrice/rating/inStock/discountOnly. |
| نتائج البحث/الفلترة | بحث أساسي | Filters كاملة: القسم، الفئة الفرعية، النوع، الماركة، التقييم، السعر، التوفر، الخصم، الموقع، ترتيب حسب السعر/الأحدث/الأكثر مبيعًا. |
| العروض | بيانات السعر والخصم مشتقة جزئيًا | تاريخ بداية/انتهاء العرض، badge/label، نسبة الخصم المؤكدة، banner اختياري. |
| تفاصيل المنتج | `/api/Products`, variants، specs/related/questions موجودة في الخادم | brand، type، condition، stockStatus، selectedVariant، SKU، seller/store، shareUrl، warranty، returnPolicy، deliveryEstimate، full gallery. |
| فيديو المنتج | `GET /api/products/{id}/videos` موجود | يجب أن يعيد `id,title,videoUrl,thumbnailUrl,sortOrder` بقيم فعلية. |
| المواصفات | `GET /api/products/{id}/specs` موجود | توحيد العقد إلى `name,value,unit,group,sortOrder`. |
| المنتجات المشابهة | `GET /api/products/{id}/related` موجود | إعادة ProductCard DTO كامل بدل IDs فقط. |
| الأسئلة | `GET/POST /api/products/{id}/questions` موجود | `answer,answeredAt,askedByDisplayName,isMine,status` ودعم pagination. |
| التقييمات | متوفر جزئيًا حسب المنتج | Endpoint واضح للتقييمات: `GET /api/products/{id}/reviews`, pagination, rating distribution, verified purchase, images. |
| المفضلة | `/api/Wishlists` موجود | DTO المنتج الكامل أو productId + variantId بشكل ثابت، وحالة التوفر الحالية. |

## الكوبونات

| الشاشة | الموجود حاليًا | الفجوة المطلوبة |
|---|---|---|
| قائمة الكوبونات | `GET /api/Coupons` | `id,code,name,description,discountType,discountValue,minimumOrderAmount,maximumDiscountAmount,validFrom,validTo,imageUrl,isActive,usageLimit,remainingUses`. |
| تفاصيل كوبون | `GET /api/Coupons/{id}` مستخدم في التطبيق | نفس العقد السابق + eligibleCategories/eligibleProducts/excludedProducts/terms. |
| تطبيق الكوبون | `POST /api/cart/apply-coupon` | نتيجة موحدة: `valid,message,discountAmount,newSubtotal,newTotal,coupon`. |

## السلة وإتمام الشراء

| الشاشة | الموجود حاليًا | الفجوة المطلوبة |
|---|---|---|
| السلة | `/api/Carts` وعمليات العناصر موجودة | صورة المنتج، variantName، stock، maxQuantity، seller/store، oldPrice/discount، estimatedDelivery لكل عنصر. |
| إتمام الشراء | إنشاء الطلب متوفر | Checkout summary موحد يعيد subtotal/discount/shipping/tax/walletApplied/total + العنوان + slot + payment method قبل التأكيد. |
| موعد التوصيل | **لا يوجد endpoint مستقل** | `GET /api/delivery/slots?addressId=&date=` يعيد الأيام والفترات المتاحة والسعر/الرسوم لكل فترة. |
| تفضيلات التوصيل | **لا يوجد endpoint مستقل** | `GET/PUT /api/users/me/delivery-preferences` للـcontactless، الاتصال قبل الوصول، مكان الترك، ملاحظات السائق. |
| أسعار/خيارات الشحن | غير كافية للمرجع | خيارات standard/express/scheduled مع السعر وETA. |

## الدفع

| الشاشة | الموجود حاليًا | الفجوة المطلوبة |
|---|---|---|
| طرق الدفع | الخادم يعلن الطرق المتاحة؛ `supportsSavedCard=false` | saved cards CRUD: `GET/POST/PUT/DELETE /api/users/me/payment-methods/cards`. |
| إضافة/تعديل بطاقة | **لا يوجد CRUD لبطاقات محفوظة** | tokenized card contract فقط، دون حفظ PAN/CVV الخام في API الخاص بنا. |
| الدفع عند الاستلام | مدعوم كطريقة دفع | رسوم COD، حدود الاستخدام، eligibility ورسالة الشروط. |
| التحويل البنكي | متوفر جزئيًا كخيار | bank account DTO + `POST /api/payments/bank-transfer-receipt` multipart + status. |
| تفاصيل الدفع | غير موحد | `GET /api/payments/{paymentId}` يعيد reference, amount, method, status, paidAt, orderId, fees. |

## الطلبات والتتبع والإرجاع

| الشاشة | الموجود حاليًا | الفجوة المطلوبة |
|---|---|---|
| طلباتي | `GET /api/Orders` | status enum موحد، item thumbnails، tracking summary، canCancel/canReturn/canRate. |
| تفاصيل الطلب | endpoint مستخدم حسب orderId | Timeline كامل، address snapshot، delivery slot، payment snapshot، totals، seller/store data. |
| تتبع الطلب | بيانات غير كافية للمرجع | `GET /api/orders/{id}/tracking` يعيد driver name/phone/photo، lat/lng، route polyline اختياري، ETA، timeline. |
| إلغاء الطلب | عملية موجودة/جزئية | `GET /api/orders/{id}/cancel-options` + `POST .../cancel` مع reasonId/note/refundMethod. |
| تقييم الطلب | جزئي | `POST /api/orders/{id}/rating` يدعم product/driver/delivery ratings + comment + image URLs. |
| الإرجاع | جزئي | reasons endpoint، request multipart، return items/quantities، pickup method، images. |
| نجاح الإرجاع | لا يحتاج endpoint مستقل | نتيجة create return يجب أن تعيد returnId/status/estimatedReviewAt/refundAmount. |
| حالة الاسترداد | بيانات غير كافية | `GET /api/returns/{id}/refund-status` يعيد timeline, amount, method, reference, expectedAt. |
| الفاتورة | `GET /api/checkout/orders/{id}/invoice` موجود | DTO/PDF يجب أن يتضمن بيانات البائع/العميل/الضريبة/العناصر/الخصم/الشحن/الدفع ورابط تنزيل. |

## المزادات

| الشاشة | الموجود حاليًا | الفجوة المطلوبة |
|---|---|---|
| قائمة المزادات | `GET /api/Auctions/discover` | category, location, seller, startPrice, reserve, startAt/endAt, status، صورة/معرض. |
| تصفية المزادات | غير مكتمل | filters: categoryId, status, minPrice, maxPrice, location, endingWithin, deliveryAvailable, sort. |
| تفاصيل المزاد | متوفر جزئيًا | seller profile، location، gallery، condition، delivery/pickup، bid increment، reserve state، guarantee/deposit. |
| سجل المزايدات | متوفر جزئيًا | `GET /api/auctions/{id}/bids` مع anonymized bidder, amount, createdAt, isMine، pagination. |
| مزاداتي | متوفر جزئيًا | حالة مشاركتي، أعلى مزايدة لي، outbid flag، won/lost، payment due. |
| تذكير المزاد | **لا يوجد endpoint** | `POST/DELETE /api/auctions/{id}/reminder` + `GET /api/users/me/auction-reminders`. |
| ضمان/عربون المزاد | **لا يوجد endpoint مستقل** | `GET /api/auctions/{id}/guarantee` و`POST /api/auctions/{id}/guarantee/pay` يعيدان amount/status/paymentMethod/refundPolicy. |
| تأكيد المزايدة | غير موحد | quote قبل التأكيد: amount, increment, guarantee, wallet/cash impact، ثم endpoint confirm. |
| الفوز بالمزاد | بيانات غير كافية | settlement endpoint يعيد remainingAmount, paymentDeadline, delivery/pickup options. |

## العناوين والموقع

| الشاشة | الموجود حاليًا | الفجوة المطلوبة |
|---|---|---|
| العناوين | `/api/Addresses/my` موجود | `name/type(home/work/farm)`, recipientName, phone, city, district, street, details, landmark, latitude, longitude, isDefault. |
| إضافة/تعديل عنوان | CRUD موجود جزئيًا | حفظ الإحداثيات ونوع العنوان وتعليمات التوصيل. |
| تحديد الموقع | لا يوجد عقد موحد للموقع | reverse geocoding اختياري أو قبول lat/lng مع النص القادم من مزود الخرائط. |

## المحفظة

| الشاشة | الموجود حاليًا | الفجوة المطلوبة |
|---|---|---|
| المحفظة | `GET /api/wallets/me` و`/api/wallets/transactions` | monthly credits/debits summary اختياري، pendingBalance، currencyCode ثابت، transaction status. |
| شحن المحفظة | `POST /api/wallets/top-up` | amount limits، methods، fee، session/payment id، status callback. |
| تحويل الأموال | **لا يوجد endpoint مطابق للمرجع** | إذا كانت الميزة مطلوبة: beneficiary/phone/account + amount + OTP/confirmation. |
| سجل العمليات | endpoint موجود | filters by type/status/date، pagination، reference، description، status. |
| طلب الشحن قيد المراجعة | غير موحد | top-up status endpoint مع pending/approved/rejected + receipt/reference. |

## الحساب والإعدادات والإشعارات

| الشاشة | الموجود حاليًا | الفجوة المطلوبة |
|---|---|---|
| الملف الشخصي | `GET/PUT /api/users/me` موجود | displayName, firstName, lastName, phone, email, avatar, gender, birthDate, level, loyaltyPoints. |
| الصورة الشخصية | multipart `/api/users/me/avatar` موجود | إعادة `profileImageUrl` النهائي بالحجمين thumbnail/full. |
| تغيير الهاتف | OTP endpoints موجودة | endpoint واضح لتغيير رقم مستخدم مسجل مع verify + conflict handling. |
| جلسات الدخول | `GET /api/users/me/sessions`, `DELETE .../{sessionId}` موجود | UI لاحقًا إذا أضيف مرجع بصري؛ الجهاز، IP التقريبي، lastActiveAt، current. |
| الإشعارات | endpoints موجودة | payload موحد `eventType,title,message,createdAt,isRead,deepLink,imageUrl`. |
| تفضيلات الإشعارات | موجودة | فصل orders/auctions/offers/wallet/support إضافة إلى push/email/sms. |
| الشروط/الخصوصية | `/api/content/terms`, `/api/content/privacy` موجودان | إضافة returnPolicy وربما version/effectiveDate/lastUpdated. |

## الدعم

| الشاشة | الموجود حاليًا | الفجوة المطلوبة |
|---|---|---|
| مركز الدعم | موجود جزئيًا حسب التطبيق | FAQ categories/search + contact channels + working hours. |
| تذكرة الدعم | يلزم عقد موحد | `POST /api/support/tickets` multipart مع subject/category/priority/orderId/message/attachments. |
| قائمة التذاكر | غير ممثلة بوضوح | `GET /api/support/tickets` مع status/updatedAt/unreadCount. |
| محادثة الدعم | يلزم realtime/polling contract | `GET/POST /api/support/tickets/{id}/messages` مع attachments، sender، createdAt، orderCard payload اختياري. |

## صور وبيانات ثابتة مطلوبة من الخادم لاحقًا

- `imageUrl` و`thumbnailUrl` لكل منتج/مزاد/قسم/كوبون عندما تكون الصورة ديناميكية.
- `sortOrder` للأقسام والبنرات.
- banner للرئيسية والعروض إن أريد التحكم بهما من لوحة الإدارة.
- صور/أيقونات الأقسام يمكن أن تبقى assets محلية إذا كانت هوية ثابتة.
- شعار التطبيق والزخارف النباتية assets محلية وليست مسؤولية API.

## Endpoints مؤكدة لا نعتبرها فجوات

- Auth login/register/refresh/logout.
- Phone OTP request/verify.
- Products/Categories/variants/search.
- Product specs/questions/related/videos.
- Cart operations وتطبيق coupon.
- Coupons list/detail.
- Orders الأساسية والفاتورة.
- Wishlist.
- Auctions discovery والمزايدة الأساسية.
- User profile/settings/avatar.
- Notifications + preferences.
- Addresses الأساسية.
- Wallet summary/transactions/top-up.
- Device token register/delete.
- Terms/privacy.

## الأولوية عند تعديل السيرفر لاحقًا

1. عقود المنتجات/البحث/الفلترة والصور.
2. checkout + delivery slots/preferences + payment methods.
3. order tracking/returns/refunds.
4. auction filters/reminders/guarantee/settlement.
5. addresses coordinates + map data.
6. support tickets/chat.
7. wallet transfer/top-up status والتقارير الإضافية.
