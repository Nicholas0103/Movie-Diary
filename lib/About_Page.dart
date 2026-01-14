import 'package:flutter/material.dart';
import 'Tools.dart';

// * Represents the About page of the application.
// * This page provides information about the app, its developer, and contact details.

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HexColor("#121212"),
      // AppBar
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: HexColor("#121212"),
        title: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: "About",
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
      // Body of the About Page
      body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
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
              ),
              SizedBox(height: 16),
              Center(
                child: Text(
                  "Movie Diary",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: HexColor("#1ed760"),
                    fontSize: 30,
                  ),
                ),
              ),
              Center(
                child: Text(
                  "Version 1.0.0",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
              ),
              SizedBox(height: 40),
              Row(
                children: [
                  Icon(
                    Icons.info,
                    color: HexColor("#1ed760"),
                    size: 25,
                  ),
                  SizedBox(width: 10),
                  Text(
                    "About This App:",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: HexColor("#1ed760"),
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Text(
                "This app lets you track, favorite, and mark movies as watched. Designed with love by Nicholas.",
                textAlign: TextAlign.justify,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.white70,
                  fontSize: 15,
                  height: 1.7,
                ),
              ),
              SizedBox(height: 30),
              Row(
                children: [
                  Icon(
                    Icons.person,
                    color: HexColor("#1ed760"),
                    size: 25,
                  ),
                  SizedBox(width: 10),
                  Text(
                    "Developer:",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: HexColor("#1ed760"),
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Text(
                "✦  Nicholas  -  10101\n✦  ABC University",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.white70,
                  fontSize: 15,
                  height: 2.5,
                ),
              ),
              SizedBox(height: 30),
              Row(
                children: [
                  Icon(
                    Icons.phone,
                    color: HexColor("#1ed760"),
                    size: 25,
                  ),
                  SizedBox(width: 10),
                  Text(
                    "Contact:",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: HexColor("#1ed760"),
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Text(
                "✦  Gmail:   nicholas0103@gmail.com \n✦  Facebook:   Nicholas",
                textAlign: TextAlign.justify,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.white70,
                  fontSize: 15,
                  height: 2.5,
                ),
              ),
              SizedBox(height: 30),
              // API Information
              Row(
                children: [
                  Icon(
                    Icons.thumb_up,
                    color: HexColor("#1ed760"),
                    size: 25,
                  ),
                  SizedBox(width: 10),
                  Text(
                    "Powered by:",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: HexColor("#1ed760"),
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 15),
              Center(
                child: Text(
                  "The Movie Database (TMDB)",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.white70,
                    fontSize: 20,
                    height: 1.7,
                  ),
                ),
              ),
              SizedBox(height: 20),
              Center(
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: HexColor("#1ed760"),
                      width: 3,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: AssetImage('assets/TMDB.png'),
                    backgroundColor: Colors.white10,
                  ),
                ),
              ),
              SizedBox(height: 20),
              Center(
                child: Text(
                  "© 2023 Nicholas. All rights reserved.",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.white70,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          )),
    );
  }
}
