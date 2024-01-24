import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:devio/constants/db_constants.dart';

class UserModel {
  final String firstName;
  final String lastName;
  final String username;
  final String uid;
  String? dpUrl;
  final String gender;
  Timestamp? dob;

  UserModel({
    required this.firstName,
    required this.lastName,
    required this.uid,
    required this.username,
    required this.gender,
    this.dob,
    this.dpUrl
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      firstName: json[UsersCollection.firstNameKey],
      lastName: json[UsersCollection.lastNameKey],
      username: json[UsersCollection.usernameKey],
      uid: json[UsersCollection.uidKey],
      dpUrl: json[UsersCollection.profilePicUriKey],
      gender: json[UsersCollection.genderKey],
      dob: json[UsersCollection.dateOfBirthKey]
    );
  }

  Map<String, dynamic> toJson() {
    return {
        UsersCollection.firstNameKey: firstName,
        UsersCollection.lastNameKey: lastName,
        UsersCollection.usernameKey: username,
        UsersCollection.uidKey: uid,
        UsersCollection.profilePicUriKey: dpUrl,
        UsersCollection.genderKey: gender,
        UsersCollection.dateOfBirthKey: dob
      };
  }
}