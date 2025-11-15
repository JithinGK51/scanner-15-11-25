# All-in-One Scanner App

A professional, feature-rich Flutter application for scanning QR codes and barcodes with a beautiful Neumorphic UI design.

## 🚀 Features

### Core Functionality
- **QR Code Scanner**: Real-time QR code detection with camera
- **Barcode Scanner**: Support for multiple barcode formats (EAN-13, UPC, Code128, PDF417, etc.)
- **UPI Payment QR**: Automatic detection and handling of UPI payment QR codes
- **QR/Barcode Generator**: Create custom QR codes and barcodes
- **Gallery Scan**: Scan codes from images in your gallery
- **History Management**: Save, search, and manage scan history
- **Export & Share**: Export history and share scanned data

### UI/UX Features
- **Neumorphic Design**: Beautiful 3D neumorphic UI throughout the app
- **Dark/Light Theme**: Seamless theme switching
- **Smooth Animations**: Fluid transitions and animations
- **Modern Navigation**: Convex bottom bar with animated drawer menu
- **Responsive Layout**: Optimized for all screen sizes

## 📦 Packages Used

- `convex_bottom_bar` - Modern bottom navigation
- `awesome_dialog` - Beautiful dialog boxes
- `flutter_spinkit` - Loading animations
- `flutter_neumorphic` - Neumorphic UI components
- `mobile_scanner` - Camera-based scanning
- `qr_flutter` - QR code generation
- `barcode` & `barcode_widget` - Barcode generation
- `image_picker` - Gallery image selection
- `share_plus` - Share functionality
- `hive` & `hive_flutter` - Local data storage
- `permission_handler` - Permission management
- `lottie` - Animations
- `url_launcher` - Open URLs and UPI links

## 🏗️ Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/
│   └── scan_history_item.dart
├── screens/
│   ├── splash_screen.dart
│   ├── onboarding_screen.dart
│   ├── main_screen.dart
│   ├── home_scanner_screen.dart
│   ├── history_screen.dart
│   ├── history_detail_screen.dart
│   ├── generator_screen.dart
│   ├── gallery_scan_screen.dart
│   └── settings_screen.dart
├── services/
│   ├── hive_service.dart
│   └── permission_service.dart
└── utils/
    ├── app_theme.dart
    ├── constants.dart
    └── helpers.dart
```

## 🛠️ Setup & Installation

### Prerequisites
- Flutter SDK (3.7.2 or higher)
- Android Studio / VS Code
- Android NDK 27.0.12077973

### Installation Steps

1. **Clone the repository**
   ```bash
   git clone https://github.com/JithinGK51/scanner-15-11-25.git
   cd scanner-15-11-25
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

### Android Configuration

The project is configured with:
- **NDK Version**: 27.0.12077973
- **Min SDK**: As per Flutter defaults
- **Target SDK**: As per Flutter defaults

Required permissions (already configured in `AndroidManifest.xml`):
- Camera
- Storage (with Android 13+ support)

## 📱 Screens

1. **Splash Screen**: Animated splash with Lottie particles
2. **Onboarding**: 3-step introduction with permission requests
3. **Home Scanner**: Main camera scanner with torch and camera switch
4. **History**: Searchable scan history with sorting options
5. **Generator**: Create QR codes and barcodes
6. **Gallery Scan**: Scan codes from gallery images
7. **Settings**: Theme, sound, vibration, and data management

## 🎨 Design Philosophy

The app follows a **Neumorphic Design** approach with:
- Soft shadows and highlights
- 3D depth effects
- Smooth color transitions
- Modern, minimalist interface
- Blue neon accents for highlights

## 🔧 Technical Details

- **State Management**: StatefulWidget with Hive for persistence
- **Architecture**: Clean architecture with separation of concerns
- **Storage**: Hive for local NoSQL database
- **Permissions**: Runtime permission handling
- **Error Handling**: Comprehensive error handling with user-friendly dialogs

## 📝 Notes

- The app uses Material 2 mode for flutter_neumorphic compatibility
- Package compatibility patches are applied to flutter_neumorphic
- All deprecated APIs have been updated to Material 3 equivalents where possible

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

This project is open source and available for personal and commercial use.

## 👨‍💻 Author

**JithinGK51**

---

**Version**: 1.0.0  
**Last Updated**: November 2025
