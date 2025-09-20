import 'package:json_annotation/json_annotation.dart';
import 'user_model.dart';

part 'auth_response_model.g.dart';

@JsonSerializable()
class AuthResponseModel {
  @JsonKey(name: 'access_token')
  final String accessToken;
  final UserModel user;

  const AuthResponseModel({
    required this.accessToken,
    required this.user,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    print('📥 AuthResponseModel: Parsing JSON response: $json');
    print('📥 AuthResponseModel: Access token: ${json['access_token']}');
    print('📥 AuthResponseModel: User object: ${json['user']}');
    print('📥 AuthResponseModel: User type: ${json['user'].runtimeType}');

    try {
      print('📥 AuthResponseModel: About to parse...');
      final model = _$AuthResponseModelFromJson(json);
      print(
          '📥 AuthResponseModel: Parsed successfully - User: ${model.user.email}');
      return model;
    } catch (e, stackTrace) {
      print('❌ AuthResponseModel: Error during parsing: $e');
      print('❌ AuthResponseModel: Stack trace: $stackTrace');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() => _$AuthResponseModelToJson(this);
}
