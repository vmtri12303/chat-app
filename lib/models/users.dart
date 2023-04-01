class MyUser {
  String id;
  String name;
  String email;
  String password;
  String status;
  MyUser({
    required this.name,
    required this.id,
    required this.email,
    required this.password,
    required this.status,
  });
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'password': password,
        'email': email,
        'status': status
      };
  static MyUser fromJson(Map<String, dynamic> json) => MyUser(
        id: json['id'],
        email: json['email'],
        name: json['name'],
        password: json['password'],
        status: json['status'],
      );
}
