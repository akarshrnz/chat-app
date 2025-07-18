# Flutter Firebase App

A real-time Product view ,mirroring,chat app using Flutter and Firebase with email/password authentication, Clean Architecture, BLoC, and TDD principles.

---

## 📐 Architecture Overview

The app follows **Clean Architecture** with layers:

- **Presentation** – Flutter UI + BLoC (Business Logic Component)
- **Domain** – Use Cases, Repositories (interfaces), Entities
- **Data** – Firebase datasources, models, and concrete repositories

Technologies used:
- Flutter (3.32.7)
- Firebase (Firestore & Auth)
- BLoC for state management
- TDD for business logic
- Firestore for real-time messaging

---

Setup Instructions

clone the repo
install flutter
install android studio
install java

Flutter Setup
--- bash
flutter clean
flutter pub get
flutter run