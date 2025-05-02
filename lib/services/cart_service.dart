import 'package:flutter/material.dart';
import 'package:my_prescription_app/models/medicine_appointment.dart';

class CartService extends ChangeNotifier {
  final List<MedicineAppointment> _items = [];

  List<MedicineAppointment> get items => List.unmodifiable(_items);

  void addItem(MedicineAppointment item) {
    if (!_items.contains(item)) {
      _items.add(item);
      notifyListeners();
    }
  }

  void removeItem(MedicineAppointment item) {
    _items.remove(item);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }

  bool contains(MedicineAppointment item) {
    return _items.contains(item);
  }

  void updateItem(MedicineAppointment oldItem, MedicineAppointment newItem) {
    final index = _items.indexOf(oldItem);
    if (index != -1) {
      _items[index] = newItem;
      notifyListeners();
    }
  }
}
