class CustomerModel {
  final String name;
  final String phone;
  final String address;
  final String? notes;
  final bool isRegular;

  CustomerModel({
    required this.name,
    required this.phone,
    required this.address,
    this.notes,
    this.isRegular = false,
  });
}
