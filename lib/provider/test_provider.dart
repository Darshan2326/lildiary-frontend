// import 'package:flutter/cupertino.dart';
// import 'package:lildairy/screens/bottom_bar_screen/add_new_note.dart';

// class test_provider extends ChangeNotifier {
//   final List<Map<String, dynamic>> _selectedMedia = [];

//   void _removeMedia(int index) {
//     _selectedMedia.removeAt(index);
//   }

// }

import 'package:flutter/foundation.dart';

class test_provider extends ChangeNotifier {
  List<Map<String, dynamic>> selectedMedia = [];

  void setSelectedMedia(List<Map<String, dynamic>> media) {
    selectedMedia = media;
    notifyListeners();
  }

  void removeMedia(int index) {
    if (index >= 0 && index < selectedMedia.length) {
      selectedMedia.removeAt(index);
      notifyListeners();
    }
  }
}
