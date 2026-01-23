Flutter Architecture & Widget System

Flutter is a UI toolkit by Google used to build cross-platform applications from a single codebase using Dart.

Flutter has three layers:

Framework Layer (Dart widgets and UI)

Engine Layer (Rendering using Skia in C++)

Embedder Layer (Platform-specific integration)
2
Flutter does not rely on native UI elements. Instead, it renders everything using its own engine, which ensures consistent design across devices.

Stateless vs Stateful Widgets

StatelessWidget:

UI remains constant

No internal state changes

Used for static components like text and icons

StatefulWidget:

UI updates dynamically when state changes

Uses setState() to rebuild UI

Used in counters, forms, interactive apps

Widget Tree & Reactive UI

Flutter builds UI using a widget tree. When setState() is called, Flutter rebuilds only the necessary widgets instead of refreshing the whole screen. This makes Flutter very fast and efficient.

Dart Features Used

Object-oriented structure

Classes and methods

Variables with type inference

Null safety

Reactive state updates


“First, I installed the Flutter SDK and added it to my system PATH.
Then I verified the installation using flutter doctor, which showed all checks passed.

Next, I installed Android Studio and added the Flutter and Dart plugins.
I created an Android emulator using AVD Manager and started it successfully.

After that, I created a Flutter project and ran the default counter app on the emulator.
The app ran successfully, confirming that my Flutter environment is set up correctly.

This setup prepares me to build, test, and run Flutter applications in future sprints.”

## Sprint-2: Responsive Flutter UI – Artisan Connect

### 📌 Overview

This sprint focuses on building a **responsive Flutter UI** that adapts smoothly across different screen sizes and orientations.
The goal is to ensure the app looks clean and usable on **mobile phones, tablets, and desktop screens**.

The responsive design was implemented using **MediaQuery** and adaptive layout widgets.

---

### 🧩 Screen Implemented

* **File:** `lib/screens/responsive_home.dart`
* **Features included:**

  * Header section with title
  * Main content area with buttons and cards
  * Footer / action section
  * Responsive layout switching based on screen width

---

### 📐 Responsiveness Logic

MediaQuery is used to detect screen size and adjust the layout dynamically.

```dart
double screenWidth = MediaQuery.of(context).size.width;
bool isTablet = screenWidth > 600;
```

* 📱 **Mobile view (width ≤ 600px)**
  → Single-column layout
* 💻 **Tablet / Desktop view (width > 600px)**
  → Wider layout with better spacing (row-like appearance)

---

### 🛠 Widgets Used for Responsiveness

* `MediaQuery`
* `Column` and `Row`
* `Expanded` and `Flexible`
* `Padding` and `SizedBox`

These ensure:

* No overflow or clipping
* Proper resizing of text and buttons
* Smooth adaptation in portrait and landscape modes

---

### 🧪 Testing Performed

The UI was tested using:

* Chrome DevTools (Responsive Mode)
* Mobile screen size (approx. 360×640)
* Laptop/Desktop screen size (1000px+ width)

Screenshots were captured for documentation.

---

### 📸 Screenshots

#### Mobile View (Portrait)
Responsive single-column layout optimized for mobile devices (357×642px)

![Mobile View](screenshots/mobile_view.png)

#### Laptop / Desktop View
Expanded responsive layout for larger screens (1000×684px)

![Laptop View](screenshots/laptop_view.png)


### 🧠 Reflection

While implementing responsiveness, the main challenge was maintaining proper spacing and alignment across screen sizes.
Using MediaQuery and flexible widgets helped create a clean and adaptive layout.
This responsive approach improves real-world usability by ensuring the app works well on all devices.

---
