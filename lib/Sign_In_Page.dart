import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'Movie_Page.dart';
import 'Tools.dart';

// * Represents the Sign In Page where users can sign in using Google authentication.

final GoogleSignIn _googleSignIn = GoogleSignIn();

Future<UserCredential> signInWithGoogle() async {
  final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

  if (googleUser == null) {
    throw "❌ User cancelled Google sign-in";
  }

  final GoogleSignInAuthentication? googleAuth =
      await googleUser.authentication;

  final credential = GoogleAuthProvider.credential(
    accessToken: googleAuth?.accessToken,
    idToken: googleAuth?.idToken,
  );

  return await FirebaseAuth.instance.signInWithCredential(credential);
}

class SignInPage extends StatelessWidget {
  const SignInPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/Wallpaper.png',
              fit: BoxFit.cover,
              alignment: Alignment.centerRight,
            ),
          ),
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(
                  0.4), 
            ),
          ),
          // Welcome message
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: HexColor("#1ed760"),
                        width: 3, 
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: AssetImage('assets/App_Icon.png'),
                      backgroundColor: Colors.transparent,
                    ),
                  ),
                  SizedBox(height: 30),
                  Text(
                    "Welcome to",
                    style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.w600),
                  ),
                  Text(
                    "Movie Diary!",
                    style: TextStyle(
                        fontSize: 30,
                        color: HexColor("#1ed760"),
                        fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 50),
                  Text(
                    "Sign in to continue your adventure :D",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.white70,
                        fontSize: 15,
                        fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: 30),
                  // Sign In button
                  ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black.withOpacity(0.5),
                        elevation: 0,
                        padding:
                            EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                        minimumSize: Size(0, 0),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        side: BorderSide(
                          color: HexColor("#1ed760").withOpacity(0.9),
                          width: 1.5,
                        ),
                      ),
                      icon: Icon(Icons.login,
                          color: HexColor("#1ed760").withOpacity(0.9),
                          size: 25),
                      label: Text("Sign in with Google",
                          style: TextStyle(
                              color: HexColor("#1ed760").withOpacity(0.9),
                              fontSize: 18)),
                      onPressed: () async {
                        try {
                          print("Starting Google sign-in...");
                          await _googleSignIn.signOut();

                          final userCredential = await signInWithGoogle();

                          if (userCredential.user != null &&
                              userCredential.user!.uid.isNotEmpty) {
                            print(
                                "✅ Logged in as: ${userCredential.user!.displayName}");
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (_) => MovieHome()),
                            );
                          } else {
                            print("❌ No user found after sign-in.");
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      "❌ Sign-in failed. Please try again."),
                                  duration: Duration(milliseconds: 1200)),
                            );
                          }
                        } catch (e) {
                          print("❌ Sign-in failed: $e");
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content:
                                    Text("❌ Sign-in failed. Please try again."),
                                duration: Duration(milliseconds: 1200)),
                          );
                        }
                      })
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
