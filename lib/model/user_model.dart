// user_model.dart
class UserModel {
  String fullName;
  String email;
  String phoneNumber;
  String password;
  String confirmPassword;

  UserModel({
    this.fullName = '',
    this.email = '',
    this.phoneNumber = '',
    this.password = '',
    this.confirmPassword = '',
  });
}
