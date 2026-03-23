class Department {
  final int id;
  final String name;
  Department({required this.id, required this.name});
  factory Department.fromJson(Map<String, dynamic> j) => Department(id: j['id']??0, name: j['name']??'');
}
