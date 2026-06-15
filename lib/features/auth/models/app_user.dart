class AppUser {
  final String uid;
  final String name;
  final String? email;
  final String? phone;
  final String role;
  final String? photoUrl;

  AppUser({
    required this.uid,
    required this.name,
    this.email,
    this.phone,
    this.role = 'user',
    this.photoUrl,
  });

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'name': name,
        'email': email,
        'phone': phone,
        'role': role,
        'photoUrl': photoUrl,
      };

  factory AppUser.fromMap(Map<String, dynamic> m) => AppUser(
        uid: m['uid'] ?? '',
        name: m['name'] ?? '',
        email: m['email'],
        phone: m['phone'],
        role: m['role'] ?? 'user',
        photoUrl: m['photoUrl'],
      );
}
