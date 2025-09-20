class LoginRequestModel {
  final String email;
  final String password;

  const LoginRequestModel({
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    print('🔍 LoginRequestModel.toJson: Converting to JSON');
    print('🔍 LoginRequestModel.toJson: Email: $email');
    print('🔍 LoginRequestModel.toJson: Password: [HIDDEN]');

    return {
      'email': email,
      'password': password,
    };
  }
}
