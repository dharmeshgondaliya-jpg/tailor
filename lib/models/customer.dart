class Customer {
  final String id;
  final String name;
  final String mobile;
  final String address;
  final String notes;

  Customer({
    required this.id,
    required this.name,
    required this.mobile,
    required this.address,
    required this.notes,
  });

  Customer copyWith({
    String? id,
    String? name,
    String? mobile,
    String? address,
    String? notes,
  }) {
    return Customer(
      id: id ?? this.id,
      name: name ?? this.name,
      mobile: mobile ?? this.mobile,
      address: address ?? this.address,
      notes: notes ?? this.notes,
    );
  }
}
