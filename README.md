# 🚁 جناح - Janah SAR Complete App

## 📱 نظام البحث والإنقاذ للأطفال المفقودين

تطبيق Flutter متكامل لنظام البحث والإنقاذ باستخدام الطائرات بدون طيار والذكاء الاصطناعي.

---

## ✅ **ما تم إنجازه:**

### 🎨 **Core & Structure**
- ✅ Project Structure (Clean Architecture)
- ✅ App Theme (IBM Plex Sans Arabic)
- ✅ Colors من التصميم بالضبط
- ✅ RTL Support كامل
- ✅ Models (User, Report)

### 🔐 **Authentication**
- ✅ Splash Screen
- ✅ User Type Selection (Guardian/Rescuer)
- ✅ Guardian Login
- ✅ Guardian Register

---

## 🚀 **التشغيل:**

### 1. تثبيت المكتبات:
```bash
flutter pub get
```

### 2. تشغيل التطبيق:
```bash
# على الويب
flutter run -d chrome

# على Android
flutter run

# على iOS
flutter run -d ios
```

---

## 📋 **الشاشات المتبقية:**

### **ولي الأمر (Guardian):**
- [ ] Forgot Password
- [ ] Home Dashboard
- [ ] Create Report
- [ ] Reports List
- [ ] Report Details
- [ ] Map View
- [ ] Profile
- [ ] Notifications
- [ ] Support
- [ ] About

### **فريق الإنقاذ (Rescuer):**
- [ ] Rescuer Login
- [ ] Rescuer Dashboard
- [ ] Active Missions
- [ ] Mission Details
- [ ] Drone Control
- [ ] Evidence Upload
- [ ] Profile

---

## 📁 **هيكل المشروع:**

```
lib/
├── core/
│   ├── theme/
│   │   └── app_theme.dart
│   ├── constants/
│   └── widgets/
├── models/
│   ├── user.dart
│   └── report.dart
├── screens/
│   ├── auth/
│   │   ├── splash_screen.dart
│   │   └── user_type_selection_screen.dart
│   ├── guardian/
│   │   ├── guardian_login_screen.dart
│   │   └── guardian_register_screen.dart
│   └── rescuer/
└── main.dart
```

---

## 🎯 **الخطوات التالية:**

1. **إضافة باقي شاشات ولي الأمر**
2. **إضافة شاشات فريق الإنقاذ**
3. **ربط الـ API**
4. **إضافة Google Maps**
5. **إضافة Push Notifications**

---

## 💡 **ملاحظات:**

- الخط: **IBM Plex Sans Arabic** (يحمل تلقائياً من Google Fonts)
- الألوان: مطابقة للتصميم 100%
- RTL: مدعوم بالكامل
- الحالة: جاهز للتشغيل ✅

---

## 📞 **الدعم:**

للمساعدة أو الاستفسارات، راجع التوثيق أو افتح Issue.

---

**صُنع بـ ❤️ في المملكة العربية السعودية**
