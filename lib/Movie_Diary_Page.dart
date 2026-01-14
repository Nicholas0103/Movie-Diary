import 'package:flutter/material.dart';
import 'Tools.dart';
import 'Movie_Details_Page.dart';
import 'package:google_sign_in/google_sign_in.dart';

// * Represents the Movie Diary Page where users can view their movie statistics.
// * It displays the user's profile, favorite movie counts, watch later movie counts and watched movie counts.

class MovieDiaryPage extends StatefulWidget {
  const MovieDiaryPage({super.key});

  @override
  _MovieDiaryPageState createState() => _MovieDiaryPageState();
}

class _MovieDiaryPageState extends State<MovieDiaryPage> {
  int favoriteCount = 0;
  int watchedCount = 0;
  int watchLaterCount = 0;
  GoogleSignInAccount? _user;

  // The photo was blurry, so we are using a higher resolution photo URL.
  String? getHighResPhotoUrl(String? url) {
    if (url == null) return null;
    return url.replaceAll(RegExp(r's\d+-c'), 's400-c');
  }

  @override
  void initState() {
    super.initState();
    fetchUserMediaCounts().then((counts) {
      setState(() {
        favoriteCount = counts["favorites"] ?? 0;
        watchedCount = counts["watched"] ?? 0;
        watchLaterCount = counts["watch later"] ?? 0;
      });
    });
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
      backgroundColor: HexColor("#121212"),
      // AppBar
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: HexColor("#121212"),
        title: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: "Your Movie Diary",
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
          SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20),
                Center(
                  child: Container(
                    padding: EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: HexColor("#1ed760"),
                        width: 3,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 60,
                      backgroundImage: (_user != null &&
                              _user!.photoUrl != null &&
                              getHighResPhotoUrl(_user!.photoUrl!) != null)
                          ? NetworkImage(getHighResPhotoUrl(_user!.photoUrl!)!)
                          : AssetImage('assets/Profile.png') as ImageProvider,
                    ),
                  ),
                ),
                SizedBox(height: 15),
                Center(
                  child: Text(
                    _user?.displayName ?? "(No Name)",
                    style: TextStyle(
                      fontSize: 22,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(height: 20),
                Center(
                  child: Text(
                    "✦  My Movie Diary Stats  ✦",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 30),
                // Displaying the user's movie statistics
                _buildStatTile("Favorited", favoriteCount.toString()),
                _buildStatTile("Watch Later", watchLaterCount.toString()),
                _buildStatTile("Watched", watchedCount.toString()),
                SizedBox(height: 70),
                Center(
                  child: Text(
                    "✦  Keep exploring, keep glowing  ✦",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Creates a tile for displaying movie statistics
  Widget _buildStatTile(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 25),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: HexColor("#1ed760"),
          width: 2,
        ),
        color: HexColor("#1ed760").withOpacity(0.2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(
            label == "Favorited"
                ? Icons.favorite
                : label == "Watch Later"
                    ? Icons.bookmark
                    : Icons.movie_filter,
            color: HexColor("#1ed760"),
            size: 30,
          ),
          SizedBox(width: 20),
          Text(label,
              style: TextStyle(
                fontSize: 20,
                color: Colors.white70,
                fontWeight: FontWeight.w500,
              )),
          Spacer(),
          Text(value,
              style: TextStyle(
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              )),
          SizedBox(width: 20),
        ],
      ),
    );
  }
}
