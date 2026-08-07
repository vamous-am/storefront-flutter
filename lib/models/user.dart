class User {
  const User({
    required this.id,
    required this.email,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.city,
    required this.street,
    required this.phone,
  });

  final int id;
  final String email;
  final String username;
  final String firstName;
  final String lastName;
  final String city;
  final String street;
  final String phone;

  factory User.fromJson(Map<String, dynamic> json) {
    final name = json['name'] as Map<String, dynamic>? ?? {};
    final address = json['address'] as Map<String, dynamic>? ?? {};

    return User(
      id: json['id'] as int,
      email: json['email'] as String,
      username: json['username'] as String,
      firstName: name['firstname'] as String? ?? '',
      lastName: name['lastname'] as String? ?? '',
      city: address['city'] as String? ?? '',
      street: address['street'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'username': username,
    'name': {'firstname': firstName, 'lastname': lastName},
    'address': {'city': city, 'street': street},
    'phone': phone,
  };
}
