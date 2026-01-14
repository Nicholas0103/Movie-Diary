import 'package:flutter/material.dart';
import 'Tools.dart';
import 'Genre_Movie_Page.dart';

// * Represents the Genre Page where users can select a movie genre to view movies.
// * It displays a grid of genres with icons and allows navigation to the GenreMovieListPage.

// Type of the Genre
class GenrePage extends StatelessWidget {
  final Map<int, String> genreMap = {
    28: 'Action',
    12: 'Adventure',
    16: 'Animation',
    35: 'Comedy',
    80: 'Crime',
    99: 'Documentary',
    18: 'Drama',
    10751: 'Family',
    14: 'Fantasy',
    36: 'History',
    27: 'Horror',
    10402: 'Music',
    9648: 'Mystery',
    10749: 'Romance',
    878: 'Sci-Fi',
    10770: 'TV Movie',
    53: 'Thriller',
    10752: 'War',
    37: 'Western',
  };

  // Colors and icons for each genre
  final Map<int, Color> genreborderColors = {
    28: HexColor("#ff2828"),
    12: HexColor("#00fdff"),
    16: HexColor("#57d800"),
    35: HexColor("#ffff00"),
    80: HexColor("#558fab"),
    99: HexColor("#00beac"),
    18: HexColor("#1e88e5"),
    10751: HexColor("#b9ff25"),
    14: Colors.deepPurple,
    36: HexColor("#b17925"),
    27: HexColor("#ff5722"),
    10402: HexColor("#a700ec"),
    9648: HexColor("#86ad00"),
    10749: HexColor("#f30064"),
    878: HexColor("#3a00f3"),
    10770: HexColor("#d3d3d3"),
    53: HexColor("#00baa3"),
    10752: HexColor("#1ed760"),
    37: HexColor("#ffcb26"),
  };

  final Map<int, Color> genreColors = {
    28: HexColor("#ff2828").withOpacity(0.1),
    12: HexColor("#00fdff").withOpacity(0.1),
    16: HexColor("#57d800").withOpacity(0.1),
    35: HexColor("#ffff00").withOpacity(0.1),
    80: HexColor("#558fab").withOpacity(0.1),
    99: HexColor("#00beac").withOpacity(0.1),
    18: HexColor("#1e88e5").withOpacity(0.1),
    10751: HexColor("#b9ff25").withOpacity(0.1),
    14: Colors.deepPurple.withOpacity(0.1),
    36: HexColor("#b17925").withOpacity(0.1),
    27: HexColor("#ff5722").withOpacity(0.1),
    10402: HexColor("#a700ec").withOpacity(0.1),
    9648: HexColor("#86ad00").withOpacity(0.1),
    10749: HexColor("#f30064").withOpacity(0.1),
    878: HexColor("#3a00f3").withOpacity(0.1),
    10770: HexColor("#d3d3d3").withOpacity(0.1),
    53: HexColor("#00baa3").withOpacity(0.1),
    10752: HexColor("#1ed760").withOpacity(0.1),
    37: HexColor("#ffcb26").withOpacity(0.1),
  };

  // Icons for each genre
  final Map<int, IconData> genreIcons = {
    28: Icons.sports_martial_arts,
    12: Icons.explore,
    16: Icons.animation,
    35: Icons.emoji_emotions,
    80: Icons.local_police,
    99: Icons.movie_filter,
    18: Icons.theater_comedy,
    10751: Icons.family_restroom,
    14: Icons.auto_awesome,
    36: Icons.history_edu,
    27: Icons.nightlight_round,
    10402: Icons.music_note,
    9648: Icons.help_outline,
    10749: Icons.favorite,
    878: Icons.science,
    10770: Icons.tv,
    53: Icons.flash_on,
    10752: Icons.military_tech,
    37: Icons.terrain,
  };

  // Constructor
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HexColor("#121212"),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.2,
          children: genreMap.entries.map((entry) {
            final genreId = entry.key;
            final genreName = entry.value;

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GenreMovieListPage(
                      genreId: genreId,
                      genreName: genreName,
                    ),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: genreColors[genreId] ??
                      HexColor("#1ed760").withOpacity(0.1),
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(
                    color: genreborderColors[genreId] ?? HexColor("#1ed760"),
                    width: 1.5,
                  ),
                ),
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      genreIcons[genreId] ?? Icons.movie,
                      color: genreborderColors[genreId] ?? HexColor("#1ed760"),
                      size: 32,
                    ),
                    SizedBox(height: 8),
                    Text(
                      genreName,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 17,
                        letterSpacing: 1,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
