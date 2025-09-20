import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_shop_app/components/network_image_with_loader.dart';
import 'package:flutter_shop_app/constants.dart';
import 'package:flutter_shop_app/route/screen_export.dart';
import 'package:flutter_shop_app/route/route_constants.dart';
import 'package:flutter_shop_app/core/di/injection.dart';
import 'package:flutter_shop_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_shop_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_shop_app/core/storage/token_storage.dart';

import 'components/profile_card.dart';
import 'components/profile_menu_item_list_tile.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final AuthBloc _authBloc;
  late final TokenStorage _tokenStorage;

  @override
  void initState() {
    super.initState();
    print('🚀 ProfileScreen: Initializing AuthBloc...');
    _authBloc = AuthBloc(authRepository: getIt<AuthRepository>());
    _tokenStorage = getIt<TokenStorage>();
    print('✅ ProfileScreen: AuthBloc initialized successfully');
  }

  @override
  void dispose() {
    _authBloc.close();
    super.dispose();
  }

  Future<void> _showDeleteAccountDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Account'),
          content: const Text(
            'Are you sure you want to delete your account? This action cannot be undone and all your data will be permanently removed.',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () async {
                Navigator.of(context).pop();
                await _deleteAccount();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteAccount() async {
    try {
      final token = await _tokenStorage.getToken();
      if (token != null) {
        print('🔥 DELETE ACCOUNT BUTTON PRESSED');
        _authBloc.add(DeleteAccountRequested(token: token));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('No authentication token found. Please log in again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('❌ Error getting token for account deletion: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error accessing account. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _authBloc,
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          print('🔄 ProfileScreen BLoC STATE CHANGED: ${state.runtimeType}');
          print('🔄 ProfileScreen: State details: $state');
          if (state is LogoutSuccess) {
            print('✅ Logout successful - navigating to login screen');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('You have been logged out successfully.'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
            Navigator.pushNamedAndRemoveUntil(
              context,
              logInScreenRoute,
              (route) => false,
            );
          } else if (state is DeleteAccountSuccess) {
            print('✅ Account deletion successful - navigating to login screen');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Your account has been deleted successfully.'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
            Navigator.pushNamedAndRemoveUntil(
              context,
              logInScreenRoute,
              (route) => false,
            );
          } else if (state is AuthLoading) {
            print('⏳ ProfileScreen: AuthLoading state received');
          } else {
            print(
                'ℹ️ ProfileScreen: Other state received: ${state.runtimeType}');
          }
        },
        child: Scaffold(
          body: ListView(
            children: [
              ProfileCard(
                name: "Sepide",
                email: "theflutterway@gmail.com",
                imageSrc: "https://i.imgur.com/IXnwbLk.png",
                // proLableText: "Sliver",
                // isPro: true, if the user is pro
                press: () {
                  Navigator.pushNamed(context, userInfoScreenRoute);
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: defaultPadding, vertical: defaultPadding * 1.5),
                child: GestureDetector(
                  onTap: () {},
                  child: const AspectRatio(
                    aspectRatio: 1.8,
                    child: NetworkImageWithLoader(
                        "https://i.imgur.com/dz0BBom.png"),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
                child: Text(
                  "Account",
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              const SizedBox(height: defaultPadding / 2),
              ProfileMenuListTile(
                text: "Profile Information",
                svgSrc: "assets/icons/Profile.svg",
                press: () {
                  Navigator.pushNamed(context, userInfoScreenRoute);
                },
              ),
              ProfileMenuListTile(
                text: "Addresses",
                svgSrc: "assets/icons/Address.svg",
                press: () {
                  Navigator.pushNamed(context, addressesScreenRoute);
                },
              ),
              ProfileMenuListTile(
                text: "Orders",
                svgSrc: "assets/icons/Order.svg",
                press: () {
                  Navigator.pushNamed(context, ordersScreenRoute);
                },
              ),
              ProfileMenuListTile(
                text: "Cards",
                svgSrc: "assets/icons/card.svg",
                press: () {
                  // Navigator.pushNamed(context, cardsScreenRoute);
                },
              ),
              ProfileMenuListTile(
                text: "Notifications",
                svgSrc: "assets/icons/Notification.svg",
                press: () {
                  Navigator.pushNamed(context, notificationsScreenRoute);
                },
              ),
              const SizedBox(height: defaultPadding),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: defaultPadding, vertical: defaultPadding / 2),
                child: Text(
                  "Settings",
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              ProfileMenuListTile(
                text: "Language",
                svgSrc: "assets/icons/Language.svg",
                press: () {
                  Navigator.pushNamed(context, selectLanguageScreenRoute);
                },
              ),
              ProfileMenuListTile(
                text: "Location",
                svgSrc: "assets/icons/Location.svg",
                press: () {},
              ),
              const SizedBox(height: defaultPadding),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: defaultPadding, vertical: defaultPadding / 2),
                child: Text(
                  "Help & Support",
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              ProfileMenuListTile(
                text: "Get Help",
                svgSrc: "assets/icons/Help.svg",
                press: () {
                  Navigator.pushNamed(context, getHelpScreenRoute);
                },
              ),
              ProfileMenuListTile(
                text: "FAQ",
                svgSrc: "assets/icons/FAQ.svg",
                press: () {},
                isShowDivider: false,
              ),
              const SizedBox(height: defaultPadding),

              // Log Out and Delete Account
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  return Column(
                    children: [
                      // Log Out
                      ListTile(
                        onTap: state is AuthLoading
                            ? null
                            : () {
                                print('🔥 LOGOUT BUTTON PRESSED');
                                _authBloc.add(const LogoutRequested());
                              },
                        minLeadingWidth: 24,
                        leading: state is AuthLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : SvgPicture.asset(
                                "assets/icons/Logout.svg",
                                height: 24,
                                width: 24,
                                colorFilter: const ColorFilter.mode(
                                  errorColor,
                                  BlendMode.srcIn,
                                ),
                              ),
                        title: Text(
                          state is AuthLoading ? "Processing..." : "Log Out",
                          style: TextStyle(
                            color:
                                state is AuthLoading ? Colors.grey : errorColor,
                            fontSize: 14,
                            height: 1,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      // Delete Account
                      ListTile(
                        onTap: state is AuthLoading
                            ? null
                            : () {
                                print('🔥 DELETE ACCOUNT BUTTON PRESSED');
                                _showDeleteAccountDialog();
                              },
                        minLeadingWidth: 24,
                        leading: state is AuthLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : SvgPicture.asset(
                                "assets/icons/Logout.svg",
                                height: 24,
                                width: 24,
                                colorFilter: const ColorFilter.mode(
                                  Colors.red,
                                  BlendMode.srcIn,
                                ),
                              ),
                        title: Text(
                          state is AuthLoading
                              ? "Processing..."
                              : "Delete Account",
                          style: TextStyle(
                            color:
                                state is AuthLoading ? Colors.grey : Colors.red,
                            fontSize: 14,
                            height: 1,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
