// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:jhattasamachaar/components/sample_dialog.dart';
import 'package:jhattasamachaar/components/settings_tile.dart';
import 'package:jhattasamachaar/components/tokennotfound.dart';
import 'package:jhattasamachaar/globals/api_link.dart';
import 'package:jhattasamachaar/pages/about_us_page.dart';
import 'package:jhattasamachaar/pages/login_page.dart';
import 'package:jhattasamachaar/pages/preference_page.dart';
import 'package:jhattasamachaar/theme/theme.dart';
import 'package:jhattasamachaar/theme/theme_provider.dart';
import 'package:launch_review/launch_review.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart'; // QR code generation package

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  String name = 'User';
  String email = "user@user.com";
  String photoUrl = "lib/assets/images/user.png"; // Local fallback image
  List<dynamic> likes = [];
  List<dynamic> dislikes = [];
  final String api = Globals.link;

  @override
  void initState() {
    super.initState();
    fetchProfileData();
  }

  Future<void> fetchProfileData() async {
    const FlutterSecureStorage secureStorage = FlutterSecureStorage();
    String? token = await secureStorage.read(key: 'auth_token');
    if (token == null) {
      showDialog(
          barrierDismissible: false,
          context: context,
          builder: (context) {
            return const TokenNotFound();
          });
    } else {
      try {
        final response = await http.get(
          Uri.parse('$api/api/auth/profile/'),
          headers: {
            'Authorization': 'Token $token',
          },
        );

        if (response.statusCode.toString().startsWith("2")) {
          final profileData = jsonDecode(response.body);
          setState(() {
            name = profileData['user']['first_name'] +
                    " " +
                    profileData['user']['last_name'] ??
                'User';
            email = profileData['user']['email'] ?? 'user@user.com';
            photoUrl = profileData['picture'] ?? 'lib/assets/images/user.png';

            likes = profileData['likes']
                    ?.map((like) => {
                          'name': like['name'],
                        })
                    .toList() ??
                [];

            dislikes = profileData['dislikes']
                    ?.map((dislike) => {
                          'name': dislike['name'],
                        })
                    .toList() ??
                [];
          });
        } else if (response.statusCode == 401) {
          secureStorage.delete(key: "auth_token");
          if (context.mounted) {
            showDialog(
                barrierDismissible: false,
                context: context,
                builder: (context) {
                  return const TokenNotFound();
                });
          }
        } else {
          if (context.mounted) {
            showDialog(
                barrierDismissible: false,
                context: context,
                builder: (context) {
                  return SampleDialog(
                      title: "Error",
                      description: "Failed to communicate with server",
                      perform: () {},
                      buttonText: "Ok");
                });
          }
        }
      } catch (e) {
        String message =
            'An error occurred. Please check your internet connection.';
        if (e is SocketException) {
          message = 'No Internet Connection. Please try again later.';
        }

        if (context.mounted) {
          showDialog(
            context: context,
            builder: (context) {
              return SampleDialog(
                title: "Error",
                description: message,
                perform: () {},
                buttonText: "Ok",
              );
            },
          );
        }
      }
    }
  }

  void showQr() async {
    if (context.mounted) {
      showDialog(
          context: context,
          builder: (context) {
            bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
            return Center(
              child: SizedBox(
                width: 100,
                height: 100,
                child: Lottie.asset(
                  isDarkMode
                      ? 'lib/assets/animations/loading_white.json'
                      : 'lib/assets/animations/loading.json',
                ),
              ),
            );
          });
    }

    await Future.delayed(const Duration(seconds: 1)); // Small delay for UX

    final qrData = {
      'name': name,
      'email': email,
      'likes': likes,
      'dislikes': dislikes,
    };

    Navigator.pop(context); // Close loading animation

    if (context.mounted) {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Center(
                child: Text(
              "QR Code",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            )),
            content: SizedBox(
              width: 250,
              height: 250,
              child: QrImageView(
                backgroundColor: Colors.white30,
                data: jsonEncode(qrData),
                version: QrVersions.auto,
                size: 200.0,
              ),
            ),
            actions: [
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 25.0),
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: Theme.of(context)
                              .buttonTheme
                              .colorScheme!
                              .primary),
                      child: const Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                        child: Text(
                          "Close",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      );
    }
  }

  void rateUs() async {
    if (context.mounted) {
      showDialog(
          barrierDismissible: false,
          context: context,
          builder: (context) {
            bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
            return Center(
              child: SizedBox(
                width: 100,
                height: 100,
                child: Lottie.asset(
                  isDarkMode
                      ? 'lib/assets/animations/loading_white.json'
                      : 'lib/assets/animations/loading.json', // Update with your Lottie animation file path
                ),
              ),
            );
          });
    }
    await LaunchReview.launch(androidAppId: "com.example.app", iOSAppId: "");
    Navigator.pop(context);
  }

  void signOut() {
    if (context.mounted) {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return AlertDialog.adaptive(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              "Log Out",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Theme.of(context).dialogTheme.titleTextStyle!.color,
              ),
            ),
            content: Text(
              "Are you sure you want to log out?",
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).dialogTheme.contentTextStyle!.color,
              ),
            ),
            actions: [
              // No Button
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.onSecondary,
                  // Use a grey background to differentiate from "Yes"
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  child: Text(
                    "No",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white, // White text for contrast
                    ),
                  ),
                ),
              ),

              // Yes Button
              ElevatedButton(
                onPressed: () async {
                  // Show loading animation
                  showDialog(
                    barrierColor: Colors.black54,
                    context: context,
                    barrierDismissible: false,
                    builder: (context) {
                      bool isDarkMode =
                          Theme.of(context).brightness == Brightness.dark;
                      return Center(
                        child: SizedBox(
                          height: 100,
                          child: Lottie.asset(isDarkMode
                              ? "lib/assets/animations/loading_white.json"
                              : "lib/assets/animations/loading.json"),
                        ),
                      );
                    },
                  );

                  const FlutterSecureStorage secureStorage =
                      FlutterSecureStorage();
                  String? token = await secureStorage.read(key: 'auth_token');
                  if (token == null) {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return const TokenNotFound();
                        });
                  } else {
                    try {
                      final response = await http.post(
                        Uri.parse('$api/api/auth/logout/'),
                        headers: {
                          'Authorization': 'Token $token',
                          'Content-Type': 'application/json',
                        },
                      );

                      if (response.statusCode.toString().startsWith("2")) {
                        await FirebaseAuth.instance.signOut();
                        await GoogleSignIn().signOut();
                        Navigator.pop(context); // Close loading dialog
                        Navigator.pop(context);
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) {
                            return const Login();
                          }),
                          (Route<dynamic> route) {
                            return false;
                          },
                        );
                      } else {
                        Navigator.pop(context); // Close loading dialog
                        showDialog(
                            context: context,
                            builder: (context) {
                              return SampleDialog(
                                  title: "Error",
                                  description: "Problem logging out, retry",
                                  perform: () {
                                    Navigator.pop(context);
                                  },
                                  buttonText: "Ok");
                            });
                      }
                    } catch (error) {
                      Navigator.pop(context); // Close loading dialog
                      String message =
                          'An error occurred. Please check your internet connection.';
                      if (error is SocketException) {
                        message =
                            'No Internet Connection. Please try again later.';
                      }
                      showDialog(
                        context: context,
                        builder: (context) {
                          return SampleDialog(
                            title: "Error",
                            description: message,
                            perform: () {},
                            buttonText: "Ok",
                          );
                        },
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Theme.of(context).buttonTheme.colorScheme!.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  child: Text(
                    "Yes",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: Consumer<ThemeProvider>(
              builder: (context, themeProvider, _) {
                return GestureDetector(
                  onTap: () {
                    themeProvider.toggleTheme();
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 80,
                    height: 40,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: themeProvider.themeData == lightMode
                            ? Colors.white
                            : Colors.black,
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black38,
                            blurRadius: 2,
                            offset: Offset(0, 3),
                          ),
                        ]),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 7),
                      child: Row(
                        mainAxisAlignment: themeProvider.themeData == lightMode
                            ? MainAxisAlignment.start
                            : MainAxisAlignment.end,
                        children: [
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 600),
                            transitionBuilder: (child, animation) {
                              return ScaleTransition(
                                  scale: animation, child: child);
                            },
                            child: themeProvider.themeData == lightMode
                                ? Icon(
                                    Icons.wb_sunny,
                                    color: Colors.yellow.shade800,
                                    key: const ValueKey("light"),
                                  )
                                : Icon(
                                    Icons.nights_stay,
                                    color: Colors.blue.shade300,
                                    key: const ValueKey("dark"),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 15),
            // Profile picture with shadow
            Center(
              child: ClipOval(
                child: Image.network(photoUrl, // The URL of the network image
                    fit: BoxFit.cover,
                    height: 150,
                    width: 150, errorBuilder: (context, error, stackTrace) {
                  // If the network image fails to load, show the local image
                  return Image.asset(
                    'lib/assets/images/user.png', // Local fallback image
                    height: 150,
                    width: 150,
                  );
                }),
              ),
            ),
            const SizedBox(height: 15),
            // Name and Email
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  email,
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSecondary,
                  ),
                )
              ],
            ),
            const SizedBox(height: 20),
            // Divider
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                  height: 2, color: Theme.of(context).colorScheme.secondary),
            ),
            const SizedBox(height: 20),
            // Settings Tiles
            SettingsTile(
              icon: Icons.qr_code_2_rounded,
              name: "QR",
              ontap: showQr,
            ),
            SettingsTile(
              icon: Icons.monitor_heart,
              name: "Preferences",
              ontap: () {
                Navigator.push(context, MaterialPageRoute(builder: ((context) {
                  return const Preference(isUpdating: true);
                })));
              },
            ),
            SettingsTile(
              icon: Icons.phone,
              name: "Contact Us",
              ontap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return AboutUsPage();
                }));
              },
            ),
            SettingsTile(
              icon: Icons.star,
              name: "Rate Us",
              ontap: rateUs,
            ),
            const SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                  height: 2, color: Theme.of(context).colorScheme.secondary),
            ),
            const SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: GestureDetector(
                onTap: signOut,
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).buttonTheme.colorScheme!.primary,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    child: Row(
                      children: [
                        Icon(
                          Icons.logout,
                          size: 28,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                        const SizedBox(width: 15),
                        Text(
                          "Log Out",
                          style: TextStyle(
                            fontSize: 17,
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 18,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
