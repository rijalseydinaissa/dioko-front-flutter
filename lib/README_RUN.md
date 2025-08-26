# Lancement & Déploiement

## Pré-requis
- Flutter 3.22+
- Backend Laravel en cours d'exécution (ex: http://localhost:8000)

## Variables d'environnement
Définir l'URL de base de l'API Laravel (préfixée par /api) via `--dart-define` :

```bash
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:8000/api
flutter run -d android --dart-define=API_BASE_URL=http://10.0.2.2:8000/api
```

> Sur Android Emulator, utilisez 10.0.2.2 pour joindre l'hôte.

## Build Web
```bash
flutter build web --release --dart-define=API_BASE_URL=https://votre-domaine.com/api
```

Hébergez le dossier `build/web` sur AWS S3 + CloudFront, Render Static Sites ou OVH.

## Build APK
```bash
flutter build apk --release --dart-define=API_BASE_URL=https://votre-domaine.com/api
```

## Mapping Routes
- POST `/auth/register` → inscription
- POST `/auth/login` → connexion (stocke access/refresh tokens si présents)
- POST `/auth/refresh` → refresh automatique via interceptor
- POST `/auth/logout` → déconnexion
- GET  `/auth/me` → infos utilisateur
- GET  `/dashboard/`, `/dashboard/monthly-stats`, `/dashboard/payment-type-stats`
- GET  `/payments/`, POST `/payments/`, GET `/payments/{id}`, PATCH `/payments/{id}/cancel`, PATCH `/payments/{id}/retry`
- GET  `/files/payments/{id}/download` & `/view` → liens utilisés dans l'écran détail

## Notes d'architecture
- **Riverpod** pour état (simple & testable)
- **go_router** pour navigation (web-friendly)
- **Dio** + Interceptor pour JWT (auto refresh)
- **flutter_secure_storage** (mobile) + **shared_preferences** (web) pour tokens
- UI responsive via widgets Material 3
- Filtres (jour/mois/année) côté client

## TODO (bonus)
- Ajouter `url_launcher` pour ouvrir/voir fichiers proprement
- Ajouter tests unitaires pour les repositories
- Mettre en place CI/CD (GitHub Actions) pour build Web + APK
- Gérer internationalisation complète (arb)
