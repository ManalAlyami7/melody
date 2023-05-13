
class UserModel {
  String? uid;
  String? email;
  String? firstName;
  String? role = 'lessor';
  UserModel(
      {this.uid, this.email, this.firstName, this.role});

  // receiving data from server
  factory UserModel.fromMap(map) {
    return UserModel(
      uid: map['uid'],
      email: map['email'],
      firstName: map['firstName'],
      role: map['role'],
    );
  }

  // sending data to our server
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'firstName': firstName,
      'role': role.toString(),
    };
  }
}
