import 'package:flutter/material.dart';
import 'Privacy_Policy_Page.dart';
import 'Sign_In_Page.dart';
import 'Tools.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'About_Page.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'Movie_Diary_Page.dart';
import 'package:firebase_auth/firebase_auth.dart';

// * Represents the Profile Page where users can view and manage their profile settings.
// * It allows users to rate the app, view statistics, privacy policy, and about information.

Future<UserCredential> signInWithGoogle() async {
  final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

  final GoogleSignInAuthentication? googleAuth =
      await googleUser?.authentication;

  final credential = GoogleAuthProvider.credential(
    accessToken: googleAuth?.accessToken,
    idToken: googleAuth?.idToken,
  );

  return await FirebaseAuth.instance.signInWithCredential(credential);
}

// This function is called when the user clicks the logout button on the Profile Page.
Future<void> signOutWithGoogle() async {
  print("👋🏻 Signing out from Firebase...");
  await FirebaseAuth.instance.signOut();

  print("👋🏻 Signing out from Google...");
  await GoogleSignIn().signOut();

  print("✅ Sign-out complete.");
}

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  GoogleSignInAccount? _user;
  int _selectedRating = 0;

  String? getHighResPhotoUrl(String? url) {
    if (url == null) return null;
    return url.replaceAll(RegExp(r's\d+-c'), 's400-c');
  }

  Widget _buildSettingItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(
        title,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: Colors.white.withOpacity(0.8),
          letterSpacing: 0.5,
        ),
      ),
      onTap: onTap,
      trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white),
    );
  }

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  void getUserData() async {
    GoogleSignIn _googleSignIn = GoogleSignIn();
    final user = await _googleSignIn.signInSilently();
    if (!mounted) return;
    setState(() {
      _user = user;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: HexColor("#121212"),
        title: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: "Profile",
                style: TextStyle(
                  fontSize: 25,
                  color: Colors.white,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextSpan(
                text: " .",
                style: TextStyle(
                  fontSize: 30,
                  fontFamily: 'Poppins',
                  color: HexColor("#1ed760"),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        // Back button
        leading: Builder(
          builder: (context) => Material(
            color: Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.only(left: 23.0, top: 4.0),
              child: IconButton(
                icon: Transform.rotate(
                  angle: 136 * (3.1415926535 / 180),
                  child: Icon(
                    Icons.signal_cellular_4_bar_rounded,
                    size: 18,
                    color: HexColor("#1ed760"),
                  ),
                ),
                splashColor: Colors.black12.withOpacity(0.3),
                highlightColor: Colors.black12.withOpacity(0.3),
                onPressed: () {
                  if (Navigator.canPop(context)) Navigator.pop(context);
                },
              ),
            ),
          ),
        ),
      ),
      backgroundColor: HexColor("#121212"),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 10),
                      // User profile section
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: HexColor("#1ed760"),
                                width: 3,
                              ),
                            ),
                            child: CircleAvatar(
                              radius: 40,
                              backgroundImage: (_user != null &&
                                      _user!.photoUrl != null &&
                                      getHighResPhotoUrl(_user!.photoUrl!) !=
                                          null)
                                  ? NetworkImage(
                                      getHighResPhotoUrl(_user!.photoUrl!)!)
                                  : AssetImage('assets/Profile.png')
                                      as ImageProvider,
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _user?.displayName ?? "(No Name)",
                                  style: TextStyle(
                                    fontSize: 22,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  _user?.email ?? "(No Email)",
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      // If user has not signed in, it will show a sign-in button
                      if (_user == null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 20.0),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => SignInPage()),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    HexColor("#1ed760"),
                                    HexColor("#158e41"),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.centerRight,
                                ),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              padding: EdgeInsets.symmetric(
                                  vertical: 14, horizontal: 0),
                              width: double.infinity,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Icon(Icons.login, color: Colors.black),
                                  SizedBox(width: 10),
                                  Text(
                                    "Sign in with Google",
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w600,
                                      fontSize: 17,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Rate Us section
                      _buildSettingItem(Icons.assistant, "Rate Us", () {
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                              side: BorderSide(
                                color: HexColor("#1ed760"),
                                width: 2.5,
                              ),
                            ),
                            backgroundColor: Colors.black,
                            title: Text("Rate This App",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                )),
                            content: StatefulBuilder(
                              builder: (context, setState) {
                                return Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(5, (index) {
                                    return IconButton(
                                      padding: EdgeInsets.zero,
                                      onPressed: () {
                                        setState(() {
                                          _selectedRating = index + 1;
                                        });
                                        print(
                                            "⭐ You gave ${_selectedRating} stars");
                                      },
                                      icon: Icon(
                                        index < _selectedRating
                                            ? Icons.star_rounded
                                            : Icons.star_border_rounded,
                                        color: Colors.amber,
                                        size: 50,
                                      ),
                                    );
                                  }),
                                );
                              },
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop(false);
                                },
                                style: TextButton.styleFrom(
                                  foregroundColor:
                                      const Color.fromARGB(185, 255, 255, 255),
                                  backgroundColor: Colors.grey[700],
                                ),
                                child: Text('  Cancel  '),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop(true);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content:
                                            Text("Thank you for your rating!"),
                                        duration: Duration(milliseconds: 1200)),
                                  );
                                },
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.black,
                                  backgroundColor: HexColor("#1ed760"),
                                ),
                                child: Text('   Submit   '),
                              ),
                            ],
                          ),
                        );
                      }),
                      // Navigate to Movie Diary Page
                      _buildSettingItem(Icons.poll, "Stats", () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => MovieDiaryPage()));
                      }),
                      // Navigate to Privacy Policy Page
                      _buildSettingItem(Icons.account_balance, "Privacy Policy",
                          () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => PrivacyPolicyPage()));
                      }),
                      // Navigate to About Page
                      _buildSettingItem(Icons.info, "About", () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AboutPage()));
                      }),
                    ],
                  ),
                ),
              ),
              // Log Out button
              if (_user != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 20.0, top: 10.0),
                  child: GestureDetector(
                    onTap: () async {
                      final confirmLogout = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: HexColor("#1ed760"),
                              width: 2.5,
                            ),
                          ),
                          backgroundColor: HexColor("#202020"),
                          title: Text(
                            'Are you sure you want to log out?',
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                                fontSize: 18),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop(false);
                              },
                              style: TextButton.styleFrom(
                                foregroundColor:
                                    const Color.fromARGB(185, 255, 255, 255),
                                backgroundColor: Colors.grey[700],
                              ),
                              child: Text('  Cancel  '),
                            ),
                            SizedBox(width: 1),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop(true);
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: HexColor("#cb3a2e"),
                              ),
                              child: Text('   Log Out   '),
                            ),
                          ],
                        ),
                      );
                      if (confirmLogout == true) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text("👋🏻 Signing out with Google..."),
                              duration: Duration(milliseconds: 1200)),
                        );
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) => Center(
                            child: LoadingAnimationWidget.fourRotatingDots(
                              color: HexColor("#1ed760"),
                              size: 50,
                            ),
                          ),
                        );
                        await Future.delayed(Duration(milliseconds: 2000));
                        try {
                          await signOutWithGoogle();
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text("✅ Signed out successfully!"),
                                duration: Duration(milliseconds: 1200)),
                          );
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SignInPage()),
                          );
                        } catch (e) {
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text("❌ Error during sign-out: $e"),
                                duration: Duration(milliseconds: 1200)),
                          );
                        }
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            HexColor("#1ed760"),
                            HexColor("#158e41"),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding:
                          EdgeInsets.symmetric(vertical: 14, horizontal: 0),
                      width: double.infinity,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Icon(Icons.logout, color: Colors.black),
                          SizedBox(width: 10),
                          Text(
                            "Logout",
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w600,
                              fontSize: 17,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
