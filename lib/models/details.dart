class Details {
  final int id;
  final String name;
  final String gender;
  final String email;

  Details({required this.id, required this.name, required this.email, required this.gender});

  factory Details.fromJson(Map<String, dynamic> json) {
    return Details(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      gender: json['gender'],
    );
  }
}
