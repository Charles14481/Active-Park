
import 'package:active_park/src/markers.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// State manager for global user variables
class UserModel extends ChangeNotifier {
  String _username = '';
  String _password = '';
  int _credits = 0;
  int _taken = 12;
  int _given = 6;
  final List<String> _transactions = <String>[];
  final List<DateTime> _transactionDates = <DateTime>[];
  static const List<int> milestones = <int>[3,5,10,15,25,50];
  bool _posUpdated = false;
  ParkSpot? _reservation;

  LatLng _pos = const LatLng(0, 0); 

  String get username => _username;
  String get password => _password;
  int get credits => _credits;
  LatLng get pos => _pos;
  int get taken => _taken;
  int get given => _given;
  List<String> get transactions => _transactions;
  List<DateTime> get transactionDates => _transactionDates;
  bool get posUpdated => _posUpdated;
  ParkSpot? get reservation => _reservation;

  
  void setName(final String str) {
    _username = str;
    notifyListeners();
  }

  void setPassword(final String str) {
    _password = str;
    notifyListeners();
  }

  void setPos(final LatLng pos) {
    _pos = pos;
    _posUpdated = true;
    notifyListeners();
  }

  Future<void> initLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (kDebugMode) {
          print('Location permissions denied');
        }
        return;
      }
    }
    final Position pos = await Geolocator.getCurrentPosition();
    setPos(LatLng(pos.latitude, pos.longitude));
  }

  int nextMilestone(final int n) {
    for (final int ms in milestones) {
      if (ms > n) {
        return ms;
      }
    }
    return -1;
  }

  void changeCreds(final int n) {
    _credits += n;
    _transactions.add('Bought $n');
    _transactionDates.add(DateTime.now());
    notifyListeners();
  }

  void posted(final int n) {
    _given++;
    _credits += n;
    _transactions.add('Posted for $n');
    _transactionDates.add(DateTime.now());
  }

  int makeReservation(final ParkSpot ps, final int n) {
    _reservation = ps;
    _taken++;
    _credits -= n;
    _transactions.add('Reserved for $n');
    _transactionDates.add(DateTime.now());
    if (kDebugMode) {
      print('Reservation made');
    }
    notifyListeners();
    return _credits;
  }

  // Reward for milestone, type = taken: 0, given: 1
  int reward (final int type, final int milestone) => (type+1) * milestone + 5;
}
