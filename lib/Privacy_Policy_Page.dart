import 'package:flutter/material.dart';
import 'Tools.dart';

// * Represents the Privacy Policy page of the application.
// * This page provides information about the app's privacy practices, what data is collected, and how it is used.

class PrivacyPolicyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      // AppBar
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: HexColor("#121212"),
        title: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: "Privacy Policy",
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
      // Body content
      body: Padding(
        padding: EdgeInsets.all(20),
        child: ListView(
          children: [
            SizedBox(height: 20),
            Text(
              "Privacy Policy",
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: HexColor("#1ed760")),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 15),
            Text(
              "We value your privacy and do not collect any personal data from your device. "
              "Your Google account is used only for sign-in purposes and no sensitive information is stored. "
              "We do not share or sell any information to third parties.",
              textAlign: TextAlign.justify,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[300],
                fontWeight: FontWeight.w400,
                height: 1.7,
              ),
            ),
            SizedBox(height: 40),
            Text(
              "What We Collect",
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: HexColor("#1ed760")),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 15),
            Text(
              "✦ Google sign-in name and email (for account display).\n"
              "✦ Favorite movies and watched history (stored privately on your account).\n"
              "✦ No sensitive or private info is tracked or stored.",
              textAlign: TextAlign.justify,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[300],
                fontWeight: FontWeight.w400,
                height: 1.7,
              ),
            ),
            SizedBox(height: 40),
            Text(
              "Contact Us",
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: HexColor("#1ed760")),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 15),
            // Contact information
            Text(
              "If you have any questions about this policy, please contact us at: ",
              textAlign: TextAlign.justify,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[300],
                fontWeight: FontWeight.w400,
                height: 1.7,
              ),
            ),
            SizedBox(height: 15),
            Text(
              "nicholaschay0103@gmail.com",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                color: HexColor("#1ed760"),
                fontWeight: FontWeight.w400,
                height: 1.7,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
