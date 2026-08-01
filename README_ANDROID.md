# Membangun APK Android untuk Dashboard Admin

Panduan singkat untuk membuat APK yang membungkus dashboard admin (WebView).

Prasyarat:
- Java JDK (11+)
- Android SDK & platform-tools
- Node.js & npm
- Cordova CLI: `npm install -g cordova`

Langkah singkat (di mesin pengembangan yang sudah terpasang prasyarat):

1. Jalankan skrip build-apk.sh:

```bash
chmod +x scripts/build-apk.sh
./scripts/build-apk.sh
```

2. Setelah build selesai, APK akan ada di:
`mobile-admin/admin/platforms/android/app/build/outputs/apk/`

Catatan:
- Membangun APK membutuhkan Android SDK dan variable lingkungan `ANDROID_HOME`/`ANDROID_SDK_ROOT` yang benar.
- Jika Anda lebih suka pendekatan modern, pertimbangkan Capacitor (Ionic) yang memiliki integrasi lebih baik dengan aplikasi web modern.
- Skrip di sini hanya scaffolding otomatis; silakan tambahkan icon, splash screen, dan konfigurasi ke `config.xml` Cordova untuk menyesuaikan aplikasi.
