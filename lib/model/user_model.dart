class UserModel {
  String name;
  String email;
  String phoneNumber;
  String password;
  String? profileImagePath; // Nullable for when the image is not set

  UserModel({
    this.name = '',
    this.email = '',
    this.phoneNumber = '',
    this.password = '',
    this.profileImagePath,
  });
}
