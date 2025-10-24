import 'dart:math';

// Position class
class Position {
  final double latitude;
  final double longitude;
  final DateTime timestamp;
  final double accuracy;
  final double altitude;
  final double heading;
  final double speed;
  final double speedAccuracy;

  const Position({
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    required this.accuracy,
    required this.altitude,
    required this.heading,
    required this.speed,
    required this.speedAccuracy,
  });
}

// Version simplifiée sans dépendances externes
class LocationService {
  static bool _initialized = false;
  static Position? _lastKnownPosition;
  
  static Future<void> init() async {
    if (_initialized) return;
    
    // Initialize location service
    print('LocationService initialized');
    _initialized = true;
  }
  
  // Get current position
  static Future<Position?> getCurrentPosition() async {
    try {
      // Mock position for testing
      _lastKnownPosition = Position(
        latitude: 48.8566, // Paris coordinates
        longitude: 2.3522,
        timestamp: DateTime.now(),
        accuracy: 10.0,
        altitude: 0.0,
        heading: 0.0,
        speed: 0.0,
        speedAccuracy: 0.0,
      );
      
      return _lastKnownPosition;
    } catch (e) {
      print('Error getting current position: $e');
      return _lastKnownPosition;
    }
  }
  
  // Get position stream
  static Stream<Position> getPositionStream() {
    // In a real app, this would return a stream of positions
    return const Stream.empty();
  }
  
  // Start position tracking
  static void startPositionTracking(Function(Position) onPositionUpdate) {
    print('Start position tracking');
    // In a real app, this would start position tracking
  }
  
  // Stop position tracking
  static void stopPositionTracking() {
    print('Stop position tracking');
    // In a real app, this would stop position tracking
  }
  
  // Get last known position
  static Position? getLastKnownPosition() {
    return _lastKnownPosition;
  }
  
  // Check if location services are enabled
  static Future<bool> isLocationServiceEnabled() async {
    // In a real app, this would check if location services are enabled
    return true;
  }
  
  // Check location permission
  static Future<bool> _checkLocationPermission() async {
    // In a real app, this would check location permission
    return true;
  }
  
  // Request location permission
  static Future<bool> requestLocationPermission() async {
    // In a real app, this would request location permission
    return true;
  }
  
  // Open location settings
  static Future<void> openLocationSettings() async {
    print('Open location settings');
    // In a real app, this would open location settings
  }
  
  // Open app settings
  static Future<void> openAppSettings() async {
    print('Open app settings');
    // In a real app, this would open app settings
  }
  
  // Get address from coordinates
  static Future<String?> getAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      // Mock address for testing
      return 'Paris, France';
    } catch (e) {
      print('Error getting address: $e');
      return null;
    }
  }
  
  // Get coordinates from address
  static Future<Position?> getCoordinatesFromAddress(String address) async {
    try {
      // Mock coordinates for testing
      return Position(
        latitude: 48.8566,
        longitude: 2.3522,
        timestamp: DateTime.now(),
        accuracy: 10.0,
        altitude: 0.0,
        heading: 0.0,
        speed: 0.0,
        speedAccuracy: 0.0,
      );
    } catch (e) {
      print('Error getting coordinates: $e');
      return null;
    }
  }
  
  // Calculate distance between two points
  static double calculateDistance(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    // Simple distance calculation (not accurate for large distances)
    final latDiff = endLatitude - startLatitude;
    final lonDiff = endLongitude - startLongitude;
    return (latDiff * latDiff + lonDiff * lonDiff) * 111000; // Rough conversion to meters
  }
  
  // Calculate bearing between two points
  static double calculateBearing(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    // Simple bearing calculation
    final latDiff = endLatitude - startLatitude;
    final lonDiff = endLongitude - startLongitude;
    return atan(latDiff / lonDiff) * 180 / pi;
  }
  
  // Check if position is within radius
  static bool isWithinRadius(
    double centerLatitude,
    double centerLongitude,
    double targetLatitude,
    double targetLongitude,
    double radiusInMeters,
  ) {
    final distance = calculateDistance(
      centerLatitude,
      centerLongitude,
      targetLatitude,
      targetLongitude,
    );
    return distance <= radiusInMeters;
  }
  
  // Get formatted distance
  static String getFormattedDistance(double distanceInMeters) {
    if (distanceInMeters < 1000) {
      return '${distanceInMeters.toStringAsFixed(0)} m';
    } else {
      return '${(distanceInMeters / 1000).toStringAsFixed(1)} km';
    }
  }
  
  // Get formatted speed
  static String getFormattedSpeed(double speedInMetersPerSecond) {
    final speedInKmh = speedInMetersPerSecond * 3.6;
    return '${speedInKmh.toStringAsFixed(1)} km/h';
  }
  
  // Check if GPS is available
  static Future<bool> isGPSAvailable() async {
    // In a real app, this would check if GPS is available
    return true;
  }
  
  // Get location accuracy
  static String getLocationAccuracy(double accuracy) {
    if (accuracy <= 5) {
      return 'Très précis';
    } else if (accuracy <= 10) {
      return 'Précis';
    } else if (accuracy <= 20) {
      return 'Moyennement précis';
    } else {
      return 'Peu précis';
    }
  }
  
  // Dispose
  static void dispose() {
    print('LocationService disposed');
    // In a real app, this would dispose of resources
  }
}