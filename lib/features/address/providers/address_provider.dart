import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/address.dart';

class AddressNotifier extends Notifier<List<Address>> {
  @override
  List<Address> build() => [
    const Address(
      id: 'seed-1',
      titleAr: 'أحمد عبد الله',
      titleEn: 'Ahmed Abdullah',
      line1Ar: 'شارع التحلية، مبنى 45، شقة 16',
      line1En: 'Tahlia Street, Building 45, Apt 16',
      line2Ar: 'الرياض، المملكة العربية السعودية',
      line2En: 'Riyadh, Kingdom of Saudi Arabia',
      phone: '+966 2667990',
    ),
    const Address(
      id: 'seed-2',
      titleAr: 'أحمد عبد الله (العمل)',
      titleEn: 'Ahmed Abdullah (Work)',
      line1Ar: 'طريق الملك فهد، برج الفيصلية، الطابق 15',
      line1En: 'King Fahd Road, Al Faisaliah Tower, Floor 15',
      line2Ar: 'الرياض، المملكة العربية السعودية',
      line2En: 'Riyadh, Kingdom of Saudi Arabia',
      phone: '+966 2667990',
    ),
  ];

  void addAddress(Address address) {
    state = [...state, address];
  }

  void updateAddress(Address address) {
    state = [
      for (final existing in state)
        if (existing.id == address.id) address else existing,
    ];
  }

  void removeAddress(String id) {
    state = state.where((address) => address.id != id).toList();
  }
}

final addressProvider = NotifierProvider<AddressNotifier, List<Address>>(
  AddressNotifier.new,
);
