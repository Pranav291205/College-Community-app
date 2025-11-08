import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  static Future<Map<String, dynamic>> getCurrentLocation() async {
    try {
      print('📍 Requesting location permission...');

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        print('❌ Permission denied, requesting...');
        permission = await Geolocator.requestPermission();

        if (permission == LocationPermission.denied) {
          return {
            'success': false,
            'message': 'Location permission denied',
            'location': null,
          };
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return {
          'success': false,
          'message': 'Location permission permanently denied',
          'location': null,
        };
      }

      print('✅ Permission granted, fetching location...');
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      print('📍 Location found:');
      print('   Lat: ${position.latitude}');
      print('   Lon: ${position.longitude}');
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      String address = 'Unknown Location';
      if (placemarks.isNotEmpty) {
        final place = placemarks[0];
        address =
            '${place.street ?? ''}, ${place.locality ?? ''}, ${place.administrativeArea ?? ''}, ${place.postalCode ?? ''}';
      }

      print('📌 Address: $address');

      return {
        'success': true,
        'message': 'Location fetched successfully',
        'location': {
          'latitude': position.latitude,
          'longitude': position.longitude,
          'address': address,
          'accuracy': position.accuracy,
          'timestamp': DateTime.now().toString(),
        },
      };
    } catch (e) {
      print('❌ Error: $e');
      return {
        'success': false,
        'message': 'Error: $e',
        'location': null,
      };
    }
  }
  static Future<String> getAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);

      if (placemarks.isNotEmpty) {
        final place = placemarks[0];
        return '${place.street ?? ''}, ${place.locality ?? ''}, ${place.administrativeArea ?? ''}, ${place.postalCode ?? ''}';
      }
      return 'Unknown Location';
    } catch (e) {
      print('❌ Error getting address: $e');
      return 'Could not get address';
    }
  }

  static Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  static Future<void> openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }
}
