import 'package:battery_plus/battery_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:geolocator/geolocator.dart';

class DeviceInfo {
  final int battery;
  final String network;
  final Position? location;

  const DeviceInfo({
    required this.battery,
    required this.network,
    required this.location,
  });
}

class DeviceInfoService {
  final Battery _battery = Battery();
  final Connectivity _connectivity = Connectivity();

  Future<DeviceInfo> getDeviceInfo() async {
    final battery = await _battery.batteryLevel;

    final connectivity = await _connectivity.checkConnectivity();

    final network = _getNetworkName(connectivity);

    Position? position;

    final locationEnabled =
    await Geolocator.isLocationServiceEnabled();

    if (locationEnabled) {
      var permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission != LocationPermission.denied &&
          permission != LocationPermission.deniedForever) {
        position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
          ),
        );
      }
    }

    return DeviceInfo(
      battery: battery,
      network: network,
      location: position,
    );
  }

  String _getNetworkName(List<ConnectivityResult> results) {
    if (results.contains(ConnectivityResult.wifi)) {
      return 'Wi-Fi';
    }

    if (results.contains(ConnectivityResult.mobile)) {
      return 'Mobile data';
    }

    if (results.contains(ConnectivityResult.ethernet)) {
      return 'Ethernet';
    }

    if (results.contains(ConnectivityResult.bluetooth)) {
      return 'Bluetooth';
    }

    return 'No connection';
  }
}