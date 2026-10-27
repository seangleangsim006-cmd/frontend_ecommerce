import 'package:flutter/material.dart';
import 'package:widget_flutter/models/address.dart';
import 'package:widget_flutter/services/address_service.dart';

class AddressProvider extends ChangeNotifier {
  List<Address> _addresses = [];
  Address? _selectedAddress;
  bool _loading = false;

  List<Address> get addresses => _addresses;
  Address? get selectedAddress => _selectedAddress;
  bool get loading => _loading;

  Future<void> loadAddresses(String token) async {
    _loading = true;
    notifyListeners();
    try {
      _addresses = await AddressService.getAddresses(token);
      _selectedAddress = _addresses.isEmpty ? null : _addresses.first;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> addAddress(String token, Address address) async {
    final saved = await AddressService.createAddress(token, address);
    _addresses = [saved, ..._addresses];
    _selectedAddress ??= saved;
    notifyListeners();
  }

  void selectAddress(Address address) {
    _selectedAddress = address;
    notifyListeners();
  }

  Future<void> setDefault(String token, Address address) async {
    final saved = await AddressService.setDefault(token, address.id);
    _addresses = _addresses
        .map((item) => item.id == saved.id ? saved : item)
        .map((item) => item.id == saved.id
            ? item
            : Address(
                id: item.id,
                label: item.label,
                recipientName: item.recipientName,
                phone: item.phone,
                address: item.address,
                lat: item.lat,
                lng: item.lng,
                isDefault: false,
              ))
        .toList();
    _selectedAddress = saved;
    notifyListeners();
  }

  Future<void> deleteAddress(String token, int id) async {
    await AddressService.deleteAddress(token, id);
    _addresses.removeWhere((address) => address.id == id);

    if (_selectedAddress?.id == id) {
      _selectedAddress = _addresses.isNotEmpty ? _addresses.first : null;
    }

    notifyListeners();
  }
}