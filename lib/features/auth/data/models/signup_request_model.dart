class SignupRequestModel {
  final String email;
  final String password;
  final String? firstName;
  final String? lastName;
  final String? phone;
  final bool acceptTerms;

  const SignupRequestModel({
    required this.email,
    required this.password,
    this.firstName,
    this.lastName,
    this.phone,
    required this.acceptTerms,
  });

  Map<String, dynamic> toJson() {
    print('🔍 SignupRequestModel.toJson: Converting to JSON');
    print('🔍 SignupRequestModel.toJson: Email: $email');
    print('🔍 SignupRequestModel.toJson: Password: [HIDDEN]');
    print('🔍 SignupRequestModel.toJson: FirstName: $firstName');
    print('🔍 SignupRequestModel.toJson: LastName: $lastName');
    print('🔍 SignupRequestModel.toJson: Phone: $phone');
    print('🔍 SignupRequestModel.toJson: AcceptTerms: $acceptTerms');

    return {
      'email': email,
      'password': password,
      if (firstName != null) 'firstName': firstName,
      if (lastName != null) 'lastName': lastName,
      if (phone != null) 'phone': phone,
      'acceptTerms': acceptTerms,
    };
  }
}
