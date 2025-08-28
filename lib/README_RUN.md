# Dioko Payment App (Frontend Flutter)

Application Flutter pour la gestion des paiements réguliers. Le frontend communique avec le backend Laravel via une API REST.

- **Repo Frontend:** [https://github.com/rijalseydinaissa/dioko-front-flutter](https://github.com/rijalseydinaissa/dioko-front-flutter)
- **Backend:** Laravel Payment Management API (ex: http://localhost:8000)
- **Lien déployé (Web):** [https://dioko-front-web-build.onrender.com/#/login](https://dioko-front-web-build.onrender.com/#/login)

---

## 🚀 Pré-requis

- Flutter 3.22+
- Dart 3+
- Backend Laravel opérationnel
- Navigateurs modernes pour le web ou émulateur Android/iOS

---

## ⚙️ Variables d'environnement

L’URL de base de l’API est configurable via `--dart-define` :

```bash
# Local
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:8000/api
flutter run -d android --dart-define=API_BASE_URL=http://10.0.2.2:8000/api
Note : Sur Android Emulator, utilisez 10.0.2.2 pour joindre l’hôte local.

Par défaut, dans constants.dart :

dart
Copier le code
defaultValue: 'http://127.0.0.1:8000/api'
💻 Lancer le projet en local
Cloner le repository :

bash
Copier le code
git clone https://github.com/rijalseydinaissa/dioko-front-flutter.git
cd dioko-front-flutter
Installer les dépendances :

bash
Copier le code
flutter pub get
Lancer l’application :

bash
Copier le code
flutter run -d chrome
# ou pour Android
flutter run -d android
📦 Build pour production
Web
bash
Copier le code
flutter build web --release --dart-define=API_BASE_URL=https://dioko-bac-laravel.onrender.com/api
Le dossier build/web peut être hébergé sur Render Static Sites, AWS S3 + CloudFront, OVH, etc.

APK (Android)
bash
Copier le code
flutter build apk --release --dart-define=API_BASE_URL=https://dioko-bac-laravel.onrender.com/api
🔗 Mapping des routes API
Authentification

POST /auth/register → inscription

POST /auth/login → connexion (stocke access/refresh tokens)

POST /auth/refresh → refresh automatique via interceptor

POST /auth/logout → déconnexion

GET /auth/me → informations utilisateur

Dashboard

GET /dashboard/

GET /dashboard/monthly-stats

GET /dashboard/payment-type-stats

Paiements

GET /payments/

POST /payments/

GET /payments/{id}

PATCH /payments/{id}/cancel

PATCH /payments/{id}/retry

Fichiers

GET /files/payments/{id}/download

GET /files/payments/{id}/view

🏗️ Architecture & librairies
State management: Riverpod

Navigation: go_router (web-friendly)

HTTP & JWT: Dio + Interceptor pour refresh automatique

Stockage local: flutter_secure_storage (mobile) / shared_preferences (web)

UI: Material 3, responsive

Filtres: jour/mois/année côté client

✅ Bonnes pratiques
Utiliser --dart-define pour chaque environnement (local, staging, prod)

Tester sur Chrome pour le web et émulateur Android/iOS pour mobile

Configurer correctement le backend Laravel avant de lancer le frontend

🛠️ TODO / améliorations
Ajouter url_launcher pour ouvrir/voir fichiers directement

Ajouter tests unitaires pour les repositories

Mettre en place CI/CD (GitHub Actions) pour build Web + APK

Gérer l’internationalisation complète (arb)

