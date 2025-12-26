# Chat Tizimini Tuzatish va Yaxshilash

Chevar oynasida chat ko'rinmasligi muammosini hal qilish, bildirish tovushini qo'shish va qo'shimcha foydali funksiyalar qo'shish.

## Muammo Tahlili

Rasmda ko'rsatilgan xatolik:
```
[cloud_firestore/failed-precondition] The query requires multiple indexes.
```

**Sababi**: `ChatService.getUserChats` metodida `Filter.or` (clientId YOKI tailorId) bilan `orderBy('lastMessageAt')` kombinatsiyasi ishlatilmoqda. Firestore bu turdagi so'rov uchun maxsus kompozit indeks talab qiladi.

## Taklif Qilinadigan O'zgarishlar

---

### 1. Chat Modelini Yangilash

#### [MODIFY] [message_model.dart](file:///c:/Users/User_204-3/Desktop/Dilnozaxon/seamstress/lib/models/message_model.dart)

`ChatModel` klasiga `participants` maydoni qo'shiladi - bu foydalanuvchi ID larini o'z ichiga oladi va so'rovni soddalashtiradi:
- `participants`: `List<String>` - [clientId, tailorId] ro'yxati
- `toFirestore()` va `fromFirestore()` metodlarini yangilash

---

### 2. Chat Serviceini Yangilash

#### [MODIFY] [chat_service.dart](file:///c:/Users/User_204-3/Desktop/Dilnozaxon/seamstress/lib/services/chat_service.dart)

**O'zgarishlar:**
- `getUserChats` metodini `Filter.or` o'rniga `array-contains` ishlatadigan qilib o'zgartirish
- Ya'ni: `.where('participants', arrayContains: userId)`
- Bu Firestore indeks xatosini hal qiladi

**Yangi metodlar:**
- `getUnreadCount(userId)` - o'qilmagan xabarlar soni
- Stream subscription uchun bildirish tovushi integratsiyasi

---

### 3. Bildirish Tovushi Qo'shish

#### [MODIFY] [pubspec.yaml](file:///c:/Users/User_204-3/Desktop/Dilnozaxon/seamstress/pubspec.yaml)

`audioplayers` paketi qo'shiladi:
```yaml
audioplayers: ^5.2.1
```

#### [NEW] [notification_service.dart](file:///c:/Users/User_204-3/Desktop/Dilnozaxon/seamstress/lib/services/notification_service.dart)

Yangi xabar kelganda tovush chiqarish uchun xizmat:
- `playMessageSound()` - xabar tovushi
- Asset papkasiga tovush fayli qo'shish

#### [NEW] [assets/sounds/message.mp3](file:///c:/Users/User_204-3/Desktop/Dilnozaxon/seamstress/assets/sounds/message.mp3)

Yangi xabar bildirish tovushi fayli

---

### 4. Chat Ekranlarini Yaxshilash

#### [MODIFY] [chat_screen.dart](file:///c:/Users/User_204-3/Desktop/Dilnozaxon/seamstress/lib/screens/chat/chat_screen.dart)

**Yangi xususiyatlar:**
- Yangi xabar kelganda bildirish tovushi
- Xabar yozayotganda typing indikatori
- Xabar o'qilganligi holati (✓ va ✓✓)
- Rasmlar va media yuborish imkoniyati

#### [MODIFY] [chats_list_screen.dart](file:///c:/Users/User_204-3/Desktop/Dilnozaxon/seamstress/lib/screens/chat/chats_list_screen.dart)

**Yangi xususiyatlar:**
- O'qilmagan xabarlar soni badge ko'rsatish
- Chat o'chirish funksiyasi
- Xabar xatoliklarini ko'rsatish

#### [MODIFY] [tailor_home.dart](file:///c:/Users/User_204-3/Desktop/Dilnozaxon/seamstress/lib/screens/tailor/tailor_home.dart)

**`_TailorChatsPage` o'zgarishlari:**
- Xatolik holatini to'g'ri ko'rsatish
- O'qilmagan xabarlar badge

---

### 5. Mavjud Chatlarni Yangilash (Migratsiya)

Agar mavjud chatlar bo'lsa, ularga `participants` maydonini qo'shish uchun bir martalik skript yozish kerak.

---

## Verification Plan

### Avtomatik Testlar

Loyihada hozircha faqat `widget_test.dart` mavjud, chat uchun maxsus test yo'q.

### Qo'lda Tekshirish

1. **Chat ro'yxatini ko'rish:**
   - Ilovani ishga tushiring: `flutter run`
   - Chevar sifatida kiring
   - "Xabarlar" bo'limiga o'ting
   - Chatlar ro'yxati xatosiz ko'rinishi kerak

2. **Xabar yuborish:**
   - Biror chat oching
   - Xabar yozing va yuboring
   - Xabar ko'rinishi va tovush eshitilishi kerak

3. **Mijoz tomondan sinab ko'rish:**
   - Mijoz sifatida kiring
   - Chevar profilidan xabar yozing
   - Chevar oynasida yangi xabar ko'rinishi kerak

> [!IMPORTANT]
> Firebase Console'da yangi indekslarni yaratish talab qilinishi mumkin. Xatolik xabaridagi link orqali indeksni yarating.
