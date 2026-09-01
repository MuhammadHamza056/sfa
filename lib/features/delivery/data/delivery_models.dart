class DeliveryAddress {
  final String name;
  final double lat;
  final double lng;

  const DeliveryAddress({required this.name, required this.lat, required this.lng});

  Map<String, dynamic> toJson() => {'name': name, 'lat': lat, 'lng': lng};
}

class DeliveryParty {
  final String phoneNumber;
  final String name;
  final String governorate;
  final String area;
  final DeliveryAddress address;

  const DeliveryParty({
    required this.phoneNumber,
    required this.name,
    required this.governorate,
    required this.area,
    required this.address,
  });

  Map<String, dynamic> toJson() => {
        'phoneNumber': phoneNumber,
        'name': name,
        'governorate': governorate,
        'area': area,
        'address': address.toJson(),
      };
}

class DeliveryRecipient extends DeliveryParty {
  final String productName;

  const DeliveryRecipient({
    required super.phoneNumber,
    required super.name,
    required super.governorate,
    required super.area,
    required super.address,
    required this.productName,
  });

  @override
  Map<String, dynamic> toJson() => {...super.toJson(), 'productName': productName};
}

/// Section 16 — matches the guide's request example exactly. No dedicated
/// screen consumes this yet (no existing "send a package" feature in the
/// app); this is the repository/model layer ready for one.
class CourierDeliveryRequest {
  final String shipmentType;
  final String deliveryType;
  final DeliveryParty sender;
  final List<DeliveryRecipient> recipients;

  const CourierDeliveryRequest({
    this.shipmentType = 'SMALL',
    this.deliveryType = 'SINGLE',
    required this.sender,
    required this.recipients,
  });

  Map<String, dynamic> toJson() => {
        'shipmentType': shipmentType,
        'deliveryType': deliveryType,
        'sender': sender.toJson(),
        'recipients': recipients.map((r) => r.toJson()).toList(),
      };
}
