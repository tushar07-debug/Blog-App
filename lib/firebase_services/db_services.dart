import 'package:flutter/cupertino.dart';

class DbServices with ChangeNotifier{
  bool _realtimeDb = true;
  bool get realtimeDb => _realtimeDb;

  setRealtimeDb(bool value){
    _realtimeDb = value;
    notifyListeners();
  }

}