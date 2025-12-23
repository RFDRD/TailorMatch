// =============================================================
// APP LOCALIZATIONS - Ko'p tilli qo'llab-quvvatlash
// =============================================================

import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {
    'uz': {
      // Auth
      'app_name': 'TailorMatch',
      'login': 'Kirish',
      'register': 'Ro\'yxatdan o\'tish',
      'email': 'Email',
      'password': 'Parol',
      'name': 'Ism',
      'phone': 'Telefon',
      'address': 'Manzil',
      'experience': 'Tajriba (yil)',
      'no_account': 'Hisobingiz yo\'qmi?',
      'have_account': 'Hisobingiz bormi?',
      'google_signin': 'Google bilan kirish',
      'or': 'yoki',
      'continue_btn': 'Davom etish',
      'cancel': 'Bekor',
      
      // Roles
      'client': 'Mijoz',
      'tailor': 'Chevar',
      'select_role': 'Rolni tanlang',
      'who_are_you': 'Siz kimsiz?',
      
      // Navigation
      'tailors': 'Chevarlar',
      'favorites': 'Sevimlilar',
      'messages': 'Xabarlar',
      'orders': 'Buyurtmalar',
      'my_orders': 'Buyurtmalarim',
      'profile': 'Profil',
      'services': 'Xizmatlar',
      'portfolio': 'Portfolio',
      'calendar': 'Kalendar',
      
      // Actions
      'add': 'Qo\'shish',
      'delete': 'O\'chirish',
      'edit': 'Tahrirlash',
      'save': 'Saqlash',
      'send': 'Yuborish',
      'logout': 'Chiqish',
      'book': 'Buyurtma',
      'rate': 'Baho berish',
      
      // Status
      'pending': 'Kutilmoqda',
      'meeting_scheduled': 'Uchrashuv belgilangan',
      'in_progress': 'Jarayonda',
      'fitting_scheduled': 'Primerka belgilangan',
      'ready': 'Tayyor',
      'completed': 'Yakunlangan',
      'cancelled': 'Bekor qilingan',
      
      // Messages
      'no_tailors': 'Chevarlar topilmadi',
      'no_favorites': 'Sevimli chevarlar yo\'q',
      'no_messages': 'Hali xabarlar yo\'q',
      'no_orders': 'Hali buyurtmalar yo\'q',
      'no_services': 'Xizmatlar qo\'shing',
      'no_portfolio': 'Portfolio rasmlarini yuklang',
      'max_images': 'Maksimum 10 ta rasm',
      'order_sent': 'Buyurtma yuborildi!',
      'rating_sent': 'Rahmat! Bahoyingiz qabul qilindi',
      'image_uploaded': 'Rasm yuklandi!',
      'write_message': 'Xabar yozing...',
      'say_hello': 'Salomlashishdan boshlang!',
      
      // Calendar
      'busy_day': 'Band kun',
      'tap_to_toggle': 'Kunni bosing - band/bo\'sh qilish',
      
      // Settings
      'language': 'Til',
      'settings': 'Sozlamalar',
      'cancel': 'Bekor',
      'logoutConfirmation': 'Haqiqatan ham hisobingizdan chiqmoqchimisiz?',
      'yesLogout': 'Ha, chiqish',
    },
    'ru': {
      // Auth
      'app_name': 'TailorMatch',
      'login': 'Войти',
      'register': 'Регистрация',
      'email': 'Эл. почта',
      'password': 'Пароль',
      'name': 'Имя',
      'phone': 'Телефон',
      'address': 'Адрес',
      'experience': 'Опыт (лет)',
      'no_account': 'Нет аккаунта?',
      'have_account': 'Уже есть аккаунт?',
      'google_signin': 'Войти через Google',
      'or': 'или',
      'continue_btn': 'Продолжить',
      'cancel': 'Отмена',
      
      // Roles
      'client': 'Клиент',
      'tailor': 'Портной',
      'select_role': 'Выберите роль',
      'who_are_you': 'Кто вы?',
      
      // Navigation
      'tailors': 'Портные',
      'favorites': 'Избранное',
      'messages': 'Сообщения',
      'orders': 'Заказы',
      'my_orders': 'Мои заказы',
      'profile': 'Профиль',
      'services': 'Услуги',
      'portfolio': 'Портфолио',
      'calendar': 'Календарь',
      
      // Actions
      'add': 'Добавить',
      'delete': 'Удалить',
      'edit': 'Изменить',
      'save': 'Сохранить',
      'send': 'Отправить',
      'logout': 'Выйти',
      'book': 'Заказать',
      'rate': 'Оценить',
      
      // Status
      'pending': 'Ожидание',
      'meeting_scheduled': 'Встреча назначена',
      'in_progress': 'В работе',
      'fitting_scheduled': 'Примерка назначена',
      'ready': 'Готово',
      'completed': 'Завершён',
      'cancelled': 'Отменён',
      
      // Messages
      'no_tailors': 'Портные не найдены',
      'no_favorites': 'Нет избранных',
      'no_messages': 'Нет сообщений',
      'no_orders': 'Нет заказов',
      'no_services': 'Добавьте услуги',
      'no_portfolio': 'Загрузите фото',
      'max_images': 'Максимум 10 фото',
      'order_sent': 'Заказ отправлен!',
      'rating_sent': 'Спасибо за оценку!',
      'image_uploaded': 'Фото загружено!',
      'write_message': 'Написать сообщение...',
      'say_hello': 'Поздоровайтесь!',
      
      // Calendar
      'busy_day': 'Занятый день',
      'tap_to_toggle': 'Нажмите для изменения',
      
      // Settings
      'language': 'Язык',
      'settings': 'Настройки',
      'cancel': 'Отмена',
      'logoutConfirmation': 'Вы действительно хотите выйти из аккаунта?',
      'yesLogout': 'Да, выйти',
    },
    'en': {
      // Auth
      'app_name': 'TailorMatch',
      'login': 'Login',
      'register': 'Register',
      'email': 'Email',
      'password': 'Password',
      'name': 'Name',
      'phone': 'Phone',
      'address': 'Address',
      'experience': 'Experience (years)',
      'no_account': 'Don\'t have an account?',
      'have_account': 'Already have an account?',
      'google_signin': 'Sign in with Google',
      'or': 'or',
      'continue_btn': 'Continue',
      'cancel': 'Cancel',
      
      // Roles
      'client': 'Client',
      'tailor': 'Tailor',
      'select_role': 'Select role',
      'who_are_you': 'Who are you?',
      
      // Navigation
      'tailors': 'Tailors',
      'favorites': 'Favorites',
      'messages': 'Messages',
      'orders': 'Orders',
      'my_orders': 'My Orders',
      'profile': 'Profile',
      'services': 'Services',
      'portfolio': 'Portfolio',
      'calendar': 'Calendar',
      
      // Actions
      'add': 'Add',
      'delete': 'Delete',
      'edit': 'Edit',
      'save': 'Save',
      'send': 'Send',
      'logout': 'Logout',
      'book': 'Book',
      'rate': 'Rate',
      
      // Status
      'pending': 'Pending',
      'meeting_scheduled': 'Meeting Scheduled',
      'in_progress': 'In Progress',
      'fitting_scheduled': 'Fitting Scheduled',
      'ready': 'Ready',
      'completed': 'Completed',
      'cancelled': 'Cancelled',
      
      // Messages
      'no_tailors': 'No tailors found',
      'no_favorites': 'No favorites yet',
      'no_messages': 'No messages yet',
      'no_orders': 'No orders yet',
      'no_services': 'Add services',
      'no_portfolio': 'Upload portfolio photos',
      'max_images': 'Maximum 10 images',
      'order_sent': 'Order sent!',
      'rating_sent': 'Thanks for your rating!',
      'image_uploaded': 'Image uploaded!',
      'write_message': 'Write a message...',
      'say_hello': 'Say hello!',
      
      // Calendar
      'busy_day': 'Busy day',
      'tap_to_toggle': 'Tap to toggle availability',
      
      // Settings
      'language': 'Language',
      'settings': 'Settings',
      'logoutConfirmation': 'Are you sure you want to logout?',
      'yesLogout': 'Yes, logout',
    },
  };

  String get(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? 
           _localizedValues['uz']?[key] ?? 
           key;
  }

  // Qisqa qilib olish uchun
  String tr(String key) => get(key);
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['uz', 'ru', 'en'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

// Til o'zgartirish uchun provider
class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('uz');

  Locale get locale => _locale;

  void setLocale(Locale locale) {
    if (!['uz', 'ru', 'en'].contains(locale.languageCode)) return;
    _locale = locale;
    notifyListeners();
  }

  void setLanguage(String languageCode) {
    setLocale(Locale(languageCode));
  }
}
