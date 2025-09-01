class AppStrings {
  // ===========================================
  // APP GENERAL
  // ===========================================
  static const String appName = "QR Panda";
  static const String loading = "Loading...";
  static const String retry = "Retry";
  static const String cancel = "Cancel";
  static const String ok = "OK";
  static const String save = "Save";

  // ===========================================
  // HOME SCREEN
  // ===========================================
  static const String welcomeTitle = "Welcome to QR Panda";
  static const String welcomeSubtitle = "Your all-in-one QR code solution";
  static const String featuresTitle = "Features";
  static const String scannerTitle = "QR Code Scanner";
  static const String scannerSubtitle = "Scan QR codes with your camera or from gallery images";
  static const String generatorTitle = "QR Code Generator";
  static const String generatorSubtitle = "Create QR codes for URLs, text, contacts, and WiFi";
  static const String historyTitle = "QR History";
  static const String historySubtitle = "View your scanned and generated QR codes";

  // ===========================================
  // QR SCANNER SCREEN
  // ===========================================
  static const String scanQRCode = "Scan QR Code";
  static const String scan = "Scan";
  static const String cameraPermissionRequired = "Camera Permission Required";
  static const String cameraPermissionDescription = "This app needs camera access to scan QR codes";
  static const String grantPermission = "Grant Permission";
  static const String scanInstructions = "Point your camera at a QR code";
  static const String galleryInstructions = "Or tap the gallery icon to scan from an image";
  static const String scanFromGallery = "Scan from Gallery";
  
  // QR Code types
  static const String urlQRCode = "URL QR Code";
  static const String phoneQRCode = "Phone QR Code";
  static const String wifiQRCode = "WiFi QR Code";
  static const String contactQRCode = "Contact QR Code";
  static const String textQRCode = "Text QR Code";
  
  // WiFi specific
  static const String wifiNetwork = "WiFi Network";
  static const String wifiPrefix = "WiFi: ";
  
  // Contact specific
  static const String contactInformation = "Contact Information";
  static const String contactPrefix = "Contact: ";
  
  // Messages
  static const String scanSuccess = "QR Code scanned successfully!";
  static const String scanError = "Failed to scan QR Code.";

  // ===========================================
  // QR GENERATOR SCREEN
  // ===========================================
  static const String generateQRCode = "Generate QR Code";
  static const String generate = "Generate";
  static const String qrCodeType = "QR Code Type";
  static const String inputData = "Input Data";
  
  // QR Code types
  static const String textType = "Text";
  static const String urlType = "URL";
  static const String phoneType = "Phone";
  static const String wifiType = "WiFi";
  static const String contactType = "Contact";
  
  // Text input
  static const String textContentLabel = "Text Content";
  static const String textContentHint = "Enter text to encode in QR code";
  static const String textValidationError = "Please enter some text";
  
  // URL input
  static const String urlLabel = "URL";
  static const String urlHint = "https://example.com";
  static const String urlValidationError = "Please enter a URL";
  static const String urlFormatError = "Please enter a valid URL";
  
  // Phone input
  static const String phoneNumberLabel = "Phone Number";
  static const String phoneNumberHint = "+1234567890";
  static const String phoneValidationError = "Please enter a phone number";
  
  // WiFi input
  static const String wifiNetworkNameLabel = "WiFi Network Name (SSID)";
  static const String wifiNetworkNameHint = "MyWiFi";
  static const String wifiPasswordLabel = "Password (Optional)";
  static const String wifiPasswordHint = "Leave empty for open networks";
  static const String wifiSecurityTypeLabel = "Security Type";
  static const String wifiNetworkNameValidationError = "Please enter WiFi network name";
  
  // WiFi security types
  static const String wifiWpa = "WPA/WPA2/WPA3";
  static const String wifiWep = "WEP";
  static const String wifiNoPassword = "No Password";
  
  // Contact input
  static const String fullNameLabel = "Full Name";
  static const String fullNameHint = "John Doe";
  static const String contactPhoneLabel = "Phone Number";
  static const String contactPhoneHint = "+1234567890";
  static const String emailLabel = "Email (Optional)";
  static const String emailHint = "john@example.com";
  static const String nameValidationError = "Please enter a name";
  
  // Generate button
  static const String generating = "Generating...";
  
  // Messages
  static const String generateSuccess = "QR Code generated successfully!";
  static const String generateError = "Error generating QR code: ";

  // ===========================================
  // HISTORY SCREEN
  // ===========================================
  static const String qrHistory = "QR History";
  
  // Search
  static const String searchHint = "Search QR codes...";
  static const String noResultsFound = "No results found";
  static const String tryAdjustingSearch = "Try adjusting your search terms";
  
  // Filter
  static const String scanned = "Scanned";
  static const String generated = "Generated";
  
  // Empty state
  static const String noQrCodesYet = "No QR codes yet";
  static const String startByScanning = "Start by scanning or generating QR codes";
  static const String startScanning = "Start Scanning";
  static const String emptyHistory = "No QR history available.";
  
  // Actions
  static const String clearAllHistory = "Clear All History";
  static const String deleteAll = "Delete All";
  
  // Confirmation dialog
  static const String clearHistoryConfirmation = "Are you sure you want to delete all QR code history? This action cannot be undone.";
  
  // Messages
  static const String itemDeletedSuccess = "Item deleted successfully";
  static const String deleteItemError = "Failed to delete item: ";
  static const String allHistoryClearedSuccess = "All history cleared successfully";
  static const String clearHistoryError = "Failed to clear history: ";
  static const String loadHistoryError = "Failed to load history: ";
  static const String contentCopiedSuccess = "Content copied to clipboard";
  static const String shareError = "Failed to share: ";
  
  // Share
  static const String shareSubject = "QR Code from History";
  static const String shareText = "QR Code Content: ";

  // ===========================================
  // COUNTER SCREEN
  // ===========================================
  static const String yourCount = "Your Count";
}
