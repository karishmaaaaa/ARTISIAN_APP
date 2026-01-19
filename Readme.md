**Sprint #2 Project Plan**

**Project Title: ArtisanConnect – A Digital Storefront for Local Artisans**

**1. Problem Statement and Solution Overview**

1.1 Local artisans lack an easy and affordable way to showcase their handmade products, manage basic orders, and share updated catalogs with potential buyers. Many existing platforms are complex and not designed for small-scale creators, which limits their reach and growth.
1.2 Our solution is a mobile-first application built using Flutter and Firebase that provides artisans with a simple digital storefront. The app allows artisans to create profiles, upload products, and manage their catalog directly from their mobile devices.
1.3 The target users are local artisans and small handmade-product sellers. A mobile app is ideal because most artisans rely on smartphones for daily business activities, making the solution accessible and easy to use.

**2. Scope and Boundaries**

2.1 The scope of this sprint includes Firebase Authentication, artisan profile creation, product catalog display, Firestore database integration, core Flutter UI screens such as Login, Home, Product List, and Profile, and basic CRUD operations for products.
2.2 The scope of this sprint excludes online payments, push notifications, advanced analytics, multi-language support, and delivery tracking features.

**3. Roles and Responsibilities**

3.1 Manuel will be responsible for UI and UX design, including creating wireframes, implementing Flutter UI screens, and handling navigation.
3.2 Karishma will handle Firebase and backend tasks, including setting up Firebase Authentication, configuring Firestore, and designing data models.
3.3 Devasree will focus on integration and testing, connecting the Flutter UI with Firebase, performing manual and basic automated testing, generating APK builds, and maintaining documentation.

**4. Sprint Timeline (4 Weeks)**

4.1 Week 1 will focus on project planning and setup, including finalizing the app flow, designing UI wireframes, setting up the Firebase project, and creating the Flutter folder structure.
4.2 Week 2 will focus on core development, including implementing authentication screens, developing the product catalog UI, and enabling Firestore read and write operations.
4.3 Week 3 will focus on integration and testing, where the UI will be connected to the Firebase backend, CRUD operations will be tested, and error handling and form validation will be implemented.
4.4 Week 4 will focus on MVP completion and deployment, including UI polish, feature freeze, final testing, APK generation, documentation, and demo preparation.

**5. Minimum Viable Product (MVP)**

5.1 The MVP will include Firebase Authentication with login and logout functionality.
5.2 Artisans will be able to create and manage their profiles.
5.3 Users will be able to add, view, edit, and delete product listings.
5.4 Product catalogs will be displayed in real time using Firestore.
5.5 A responsive Flutter UI and a working APK build will be delivered by the end of the sprint.

**6. Functional Requirements**

6.1 The system shall allow users to register, log in, and log out securely using Firebase Authentication.
6.2 The system shall allow artisans to add, update, and delete product details.
6.3 The system shall store and retrieve user and product data from Cloud Firestore.
6.4 The application shall update the UI in real time when database changes occur.

**7. Non-Functional Requirements**

7.1 The application shall provide smooth UI transitions and acceptable performance.
7.2 The system shall support at least 100 concurrent users.
7.3 The application shall implement secure authentication and Firestore security rules.
7.4 The UI shall be responsive and adapt to different screen sizes on Android and iOS.

**8. Testing and Deployment Plan**

8.1 Testing will include manual testing of authentication flows, product CRUD operations, and navigation, along with basic Flutter widget testing.
8.2 Deployment will involve generating an APK using Flutter build tools, managing version control through GitHub, and sharing the APK via Google Drive for review and demo purposes.

**9. Success Metrics**

9.1 All MVP features are implemented and function as expected.
9.2 Firebase Authentication and Firestore integration are completed successfully.
9.3 The application builds without critical bugs or crashes.
9.4 The project is completed within the sprint timeline and receives positive mentor feedback.

**10. Risks and Mitigation**

10.1 Firebase setup issues may cause backend delays; this will be mitigated by using official Firebase documentation and testing with sample data.
10.2 UI bugs may affect the demo; early and continuous testing will reduce this risk.
10.3 Time constraints may limit feature completion; strict focus on MVP requirements will ensure timely delivery.

**Conclusion**

This project plan provides a clear, realistic roadmap for building a mobile digital storefront for local artisans using Flutter and Firebase. By focusing on essential features and strong backend integration, our team aims to deliver a stable, functional MVP within the 4-week sprint.