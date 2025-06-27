class ClientModel {
  final String id;
  final String name;
  final String email;
  final String phone;

  ClientModel({required this.id, required this.name, required this.email, required this.phone});

  factory ClientModel.fromMap(Map<String, dynamic> data, String id) {
    return ClientModel(
      id: id,
      name: data['name'],
      email: data['email'],
      phone: data['phone'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
    };
  }
}
