class Staff {
  final String name;

  Staff({required this.name});

  Map<String, dynamic> toMap() {
    return {
      'name': name,
    };
  }

  static Staff fromMap(Map<String, dynamic> map) {
    return Staff(
      name: map['name'],
    );
  }
}
