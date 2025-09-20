import 'package:json_annotation/json_annotation.dart';

part 'signup_response_model.g.dart';

@JsonSerializable()
class SignupResponseModel {
  final String message;
  final String userId;
  final String email;

  const SignupResponseModel({
    required this.message,
    required this.userId,
    required this.email,
  });

  factory SignupResponseModel.fromJson(Map<String, dynamic> json) {
    print('📥 SignupResponseModel: Parsing JSON response: $json');
    print('📥 SignupResponseModel: Message: ${json['message']}');
    print('📥 SignupResponseModel: User ID: ${json['userId']}');
    print('📥 SignupResponseModel: Email: ${json['email']}');

    try {
      print('📥 SignupResponseModel: About to parse...');
      final model = _$SignupResponseModelFromJson(json);
      print('📥 SignupResponseModel: Parsed successfully');
      return model;
    } catch (e, stackTrace) {
      print('❌ SignupResponseModel: Error during parsing: $e');
      print('❌ SignupResponseModel: Stack trace: $stackTrace');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() => _$SignupResponseModelToJson(this);
}
