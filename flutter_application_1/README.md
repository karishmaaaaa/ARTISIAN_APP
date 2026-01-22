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
