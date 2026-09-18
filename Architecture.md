# Architecture.md: Build a Flutter & Firebase Mobile Application named **LoFo (Lost & Found)**.

Purpose:
Help users easily report, search, and manage lost or found items in real-time. The application collects item reports with images, stores them in Cloud Firestore, and allows direct user contact via WhatsApp launcher.

Use this stack:

* Frontend: Flutter (Dart) + Material 3 UI
* Backend Services: Firebase Authentication, Cloud Firestore, Firebase Storage
* External Integration: url_launcher (WhatsApp Integration)
* Media Package: image_picker

Code rules:

* Do not add comments unless truly necessary.
* Use PascalCase for Widget classes, Screen names, Models, and Enums.
* Local variables and fields may use camelCase.
* Keep UI components modular and isolated inside the widgets directory.
* Use a clean and simple Flutter folder structure.
* Use StreamBuilder for real-time database updates on the main feed.

Main entities:

1. User

* Uid
* Email
* DisplayName
* CreatedAt

2. Item

* Id
* UserId
* Title
* Type ('Hilang' | 'Ditemukan')
* Description
* Location
* PhoneNumber
* ImageUrl
* CreatedAt

Database rules:

* All item reports are stored in the `items` collection in Cloud Firestore.
* Real-time query streams must order items by `createdAt` in descending order by default.
* Item images must be uploaded to Firebase Storage under `items/{userId}_{timestamp}.jpg` before creating a document.
* Deleting an item report must delete both its Firestore document and associated image in Firebase Storage.
* Users can only edit or delete item documents where `userId` matches their authenticated UID.

Backend & Firebase features:

1. Authentication Service

* Email & Password registration and login.
* Auth state listener to persist login sessions automatically.

2. Item CRUD Operations

* Create: Upload image to Firebase Storage, then write item details to Firestore.
* Read: Stream list of reports in real-time for feed display.
* Update: Edit details of existing reports owned by current user.
* Delete: Remove document and image binaries.

3. Search & Filter Engine

* Search by item title directly in memory / Firestore stream.
* Filter reports by type: 'Semua', 'Hilang', or 'Ditemukan'.
* Sort reports by date: 'Terbaru' (Newest) and 'Terlama' (Oldest).

4. External WhatsApp Launcher

* Launch WhatsApp chat directly using `url_launcher` with pre-filled message template.

Frontend pages & widgets:

1. LoginScreen & RegisterScreen

* Authentication forms with input validation.
* Header branding featuring the custom `LofoLogo` widget.

2. HomeScreen (Dashboard Feed)

* Real-time item feed list using `StreamBuilder`.
* Top search bar and category filter action buttons.
* Floating Action Button (FAB) to add a new report.

3. AddItemScreen

* Image picker field with interactive preview.
* Input fields for Title, Type toggle ('Hilang'/'Ditemukan'), Location, Phone Number, and Description.
* Upload indicator on submission.

4. Custom Components

* `LofoLogo`: Custom composite widget combining location pin and magnifying glass graphics.
* `ItemCard`: Feed item card displaying image preview, status badge, title, location, timestamp, and contact action button.
* `FilterBottomSheet`: Bottom sheet dialog for category filtering and sorting.

UI requirements:

* Use Indonesian language for all UI text, labels, buttons, dialogs, and validation messages.
* Theme aesthetics: Terracotta / Warm Earthy palette (`#C85A32`) with clean light backgrounds.
* Status badge colors:
  * Hilang: Terracotta / Dark Red
  * Ditemukan: Forest Green
* Responsive Material 3 cards, bottom sheets, and confirmation dialogs before item deletion.

Project structure:

```text
lofo_app/
assets/
  images/
lib/
  firebase_options.dart
  main.dart
  models/
    item_model.dart
    user_model.dart
  screens/
    add_item_screen.dart
    home_screen.dart
    login_screen.dart
    register_screen.dart
  services/
    auth_service.dart
    firestore_service.dart
  widgets/
    filter_bottom_sheet.dart
    item_card.dart
    lofo_logo.dart
pubspec.yaml
