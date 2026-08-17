# ✈️ JomTravel (Explore Malaysia)

[![Flutter](https://img.shields.io/badge/Flutter-v3.10.4-blue.svg?logo=flutter&logoColor=white)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-v4.3.0-orange.svg?logo=firebase&logoColor=white)](https://firebase.google.com)
[![Material3](https://img.shields.io/badge/UI-Material%203-purple.svg)](https://m3.material.io/)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web%20%7C%20Windows-lightgrey.svg)](#)

**JomTravel** is a modern, high-performance mobile application built using **Flutter** and powered by **Firebase**. The app is specifically designed to promote domestic tourism in Malaysia ("Jom" meaning "let's go" in Malay), allowing users to discover beautiful local destinations, book personalized tour packages, and participate in an engaging loyalty rewards system.

---

## 🎯 Goal of the Application

The primary goal of **JomTravel** is to streamline and gamify the domestic travel booking experience in Malaysia. It bridges the gap between travelers and local package operators by providing:
1. **Curated Tourism Discovery:** Categorized packages (Heritage, Beach, Waterparks, Food, Family) that highlight the best experiences in Malaysia.
2. **Loyalty-Driven Travel:** A robust rewards program (JomClub) that awards points for bookings, motivating users to explore more local spots.
3. **Frictionless Customization:** Enabling travelers to easily tailor their packages with add-ons like tour guides, transportation options, and insurance.

---

## ✨ Core Features

### 👤 User Features
*   **Authentication & Secure Sign-In:** 
    *   Traditional Email & Password sign-up and login.
    *   One-click **Google Sign-In** integration.
    *   Secure token storage using `flutter_secure_storage`.
*   **Dynamic Explorer Dashboard:**
    *   Time-based personalized greetings (e.g., Good Morning, Good Afternoon).
    *   Horizontal carousel showcasing featured "Featured Escapes".
    *   Search bar supporting real-time filtering by destinations, activities, and keywords.
    *   Filter pills to sort packages by category (Heritage, Beach, Waterpark, Food, Family).
*   **JomClub Rewards & Loyalty:**
    *   Points accrual system based on booking actions.
    *   Point history log and rewards store to redeem points for discount vouchers.
    *   Integration of voucher discounts directly at the checkout step.
*   **Interactive Booking Engine:**
    *   Detailed package pages with location, description, price, available slots, and ratings.
    *   Custom booking forms allowing selection of travel dates, number of guests, and add-ons (Tour Guide, Private Transport, Travel Insurance).
    *   Checkout summaries with breakdown of prices, applied vouchers, and points to be earned.
*   **Offline Support:**
    *   Real-time cloud caching configured via Firestore disk persistence so packages and user data load instantly, even without internet.

### 🔑 Admin Features
*   **Unified Admin Dashboard:**
    *   Overview of platform metrics (Total active packages, bookings, registered users, and active vouchers).
    *   Action grid for quick access to various management modules.
*   **Package Management:** Add, edit, or toggle visibility (`is_active`) of travel packages.
*   **Booking Monitor:** View all reservation details submitted by users.
*   **User Management:** Audit registered users, points balances, and profile states.
*   **Reviews & Feedback Hub:** Read reviews and ratings submitted by travelers to ensure high quality service.

---

## 🛠️ Tech Stack & Architecture

*   **Frontend Framework:** Flutter (Dart) using Material Design 3.
*   **Backend Services:** Firebase Suite
    *   **Firebase Authentication:** Handles authentication and identity provider integrations.
    *   **Cloud Firestore:** Real-time database storing users, packages, bookings, and vouchers with offline cache enabled.
*   **State & Cache Management:** Combined use of standard `StatefulWidget` states, `FutureBuilder`/`StreamBuilder`, and device storage (`shared_preferences`, `flutter_secure_storage`).

---

## 🚀 Getting Started

To run the project locally, follow these steps:

### Prerequisites
*   [Flutter SDK](https://docs.flutter.dev/get-started/install) (v3.10.4 or higher recommended)
*   [Firebase CLI](https://firebase.google.com/docs/cli) (for configuring Firebase projects)
*   Java Development Kit (JDK) and Android SDK (for Android builds)

### Installation
1.  **Clone the Repository:**
    ```bash
    git clone https://github.com/aliffirfan4523/muc_jomtravel.git
    cd muc_jomtravel
    ```

2.  **Install Dependencies:**
    ```bash
    flutter pub get
    ```

3.  **Firebase Setup:**
    *   Run `flutterfire configure` to generate the `firebase_options.dart` file for your Firebase project.
    *   Ensure that Authentication (Email/Password & Google), Firestore Database, and Storage are enabled on your Firebase console.

4.  **Run the App:**
    ```bash
    flutter run
    ```

---

## 🔮 Future Roadmap (What will be added)

As the application moves out of its initial MVP phase, the following enhancements are planned:

1.  **💳 Integration of Payment Gateways:**
    *   Replace the current simulated checkout flow with real payment processors such as **Stripe**, **Billplz**, or **ToyyibPay** to process actual financial transactions securely.
2.  **🔔 Push Notifications:**
    *   Implement **Firebase Cloud Messaging (FCM)** to alert users about upcoming trips, voucher expiry dates, and exclusive flash sales.
3.  **🗺️ Live Route & Map Itinerary:**
    *   Integrate the **Google Maps SDK** to show destination pins and provide travelers with interactive, day-by-day routing.
4.  **🗣️ Multi-Language Support (Localization):**
    *   Provide language toggles between **English** and **Bahasa Melayu** to make the app accessible to more domestic travelers.
5.  **💬 Operator Support Chat:**
    *   A live chat feature allowing users to converse directly with travel admins or operators to ask questions about package details.
6.  **🔄 Streamlining Admin Loyalty Config:**
    *   Refactor and relocate administrative voucher/point creations to a web-based portal to clean up the client admin app code (aligning with project code plans to disable localized admin voucher tools).
