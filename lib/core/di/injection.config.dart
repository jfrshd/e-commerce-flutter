// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:flutter_shop_app/core/network/api_client.dart' as _i425;
import 'package:flutter_shop_app/core/network/network_info.dart' as _i205;
import 'package:flutter_shop_app/core/storage/token_storage.dart' as _i990;
import 'package:flutter_shop_app/features/auth/data/datasources/auth_local_datasource.dart'
    as _i718;
import 'package:flutter_shop_app/features/auth/data/datasources/auth_remote_datasource.dart'
    as _i947;
import 'package:flutter_shop_app/features/auth/data/repositories/auth_repository_impl.dart'
    as _i566;
import 'package:flutter_shop_app/features/auth/domain/repositories/auth_repository.dart'
    as _i237;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

extension GetItInjectableX on _i174.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    gh.lazySingleton<_i425.ApiClient>(() => _i425.ApiClient());
    gh.lazySingleton<_i990.TokenStorage>(() => _i990.TokenStorage());
    gh.lazySingleton<_i205.NetworkInfo>(() => _i205.NetworkInfoImpl());
    gh.lazySingleton<_i718.AuthLocalDataSource>(() =>
        _i718.AuthLocalDataSourceImpl(tokenStorage: gh<_i990.TokenStorage>()));
    gh.lazySingleton<_i947.AuthRemoteDataSource>(
        () => _i947.AuthRemoteDataSourceImpl(apiClient: gh<_i425.ApiClient>()));
    gh.lazySingleton<_i237.AuthRepository>(() => _i566.AuthRepositoryImpl(
          remoteDataSource: gh<_i947.AuthRemoteDataSource>(),
          localDataSource: gh<_i718.AuthLocalDataSource>(),
          networkInfo: gh<_i205.NetworkInfo>(),
        ));
    return this;
  }
}
