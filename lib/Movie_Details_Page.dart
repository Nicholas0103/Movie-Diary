import 'package:flutter/material.dart';
import 'Tools.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// * Represents the Movie Details Page where users can view detailed information about a movie.
// * It fetches movie details, cast, trailer, and allows users to mark movies as watched, favorite, or watch later.
// * It also displays the genres of the movie and provides a way to navigate back to the previous page.

// Fetch movie cast by ID
Future<List<dynamic>> fetchMovieCast(int movieId) async {
  final response = await http.get(Uri.parse(
      "https://api.themoviedb.org/3/movie/$movieId/credits?api_key=204e096677c6aaa875e4a8dc7e6e1e1e"));
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data['cast'];
  } else {
    throw Exception("❌ Failed to load cast");
  }
}

// Fetch movie trailer by ID
Future<String?> fetchMovieTrailer(int movieId) async {
  final response = await http.get(Uri.parse(
      "https://api.themoviedb.org/3/movie/$movieId/videos?api_key=204e096677c6aaa875e4a8dc7e6e1e1e"));
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    final trailers = data['results'].where(
        (video) => video['type'] == 'Trailer' && video['site'] == 'YouTube');
    if (trailers.isNotEmpty) {
      return trailers.first['key'];
    }
    return null;
  } else {
    throw Exception("❌ Failed to load trailer");
  }
}

// Fetch user media counts from Firestore
Future<Map<String, int>> fetchUserMediaCounts() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return {"favorites": 0, "watched": 0, "watch later": 0};

  final doc =
      await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

  final data = doc.data() ?? {};
  final favorites = data['favorites'] as List<dynamic>? ?? [];
  final watched = data['watched'] as List<dynamic>? ?? [];
  final watchLater = data['watch later'] as List<dynamic>? ?? [];

  return {
    "favorites": favorites.length,
    "watched": watched.length,
    "watch later": watchLater.length,
  };
}

class MovieDetailPage extends StatefulWidget {
  final Map movie;
  MovieDetailPage({required this.movie});

  @override
  _MovieDetailPageState createState() => _MovieDetailPageState();
}

class _MovieDetailPageState extends State<MovieDetailPage> {
  List<dynamic> movies = [];
  Set<int> watchedMovieIds = {};
  Set<int> favoriteMovieIds = {};
  Set<int> watchlaterMovieIds = {};
  final genreMap = {
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
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void initState() {
    super.initState();
    fetchFavorites();
    fetchWatched();
    fetchWatchLater();
    _loadFavorites();
    _loadWatched();
    _loadWatchLater();
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        print("✅ User already signed in as ${user.displayName}");
      }
    });
  }

  // Fetch favorites from Firestore
  Future<void> fetchFavorites() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    final data = doc.data();
    final favs = data?['favorites'] ?? [];

    if (!mounted) return;
    setState(() {
      favoriteMovieIds = Set<int>.from(favs);
    });
  }

  // Fetch watched movies from Firestore
  Future<void> fetchWatched() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    final data = doc.data();
    final favs = data?['watched'] ?? [];

    if (!mounted) return;
    setState(() {
      watchedMovieIds = Set<int>.from(favs);
    });
  }

  // Fetch watch later movies from Firestore
  Future<void> fetchWatchLater() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    final data = doc.data();
    final favs = data?['watch later'] ?? [];

    if (!mounted) return;
    setState(() {
      watchlaterMovieIds = Set<int>.from(favs);
    });
  }

  // Load favorites from Firestore
  void _loadFavorites() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        final List<dynamic>? favorites = doc.data()?['favorites'];

        if (favorites != null) {
          if (!mounted) return;
          setState(() {
            favoriteMovieIds = Set<int>.from(favorites.cast<int>());
          });
        }
      } on FirebaseException catch (e) {
        print('❌ Firebase error: ${e.message}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Could not load favorites: ${e.message}'),
            duration: Duration(milliseconds: 1200),
          ),
        );
      } catch (e) {
        print('❌ Unexpected error: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Something went wrong: $e'),
            duration: Duration(milliseconds: 1200),
          ),
        );
      }
    }
  }

  // Load watched movies from Firestore
  void _loadWatched() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        final List<dynamic>? watched = doc.data()?['watched'];

        if (watched != null) {
          if (!mounted) return;
          setState(() {
            watchedMovieIds = Set<int>.from(watched.cast<int>());
          });
        }
      } on FirebaseException catch (e) {
        print('❌ Firebase error: ${e.message}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Could not load watched: ${e.message}'),
            duration: Duration(milliseconds: 1200),
          ),
        );
      } catch (e) {
        print('❌ Unexpected error: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Something went wrong: $e'),
            duration: Duration(milliseconds: 1200),
          ),
        );
      }
    }
  }

  // Load watch later movies from Firestore
  void _loadWatchLater() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        final List<dynamic>? watched = doc.data()?['watch later'];

        if (watched != null) {
          if (!mounted) return;
          setState(() {
            watchlaterMovieIds = Set<int>.from(watched.cast<int>());
          });
        }
      } on FirebaseException catch (e) {
        print('❌ Firebase error: ${e.message}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Could not load watched: ${e.message}'),
            duration: Duration(milliseconds: 1200),
          ),
        );
      } catch (e) {
        print('❌ Unexpected error: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Something went wrong: $e'),
            duration: Duration(milliseconds: 1200),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final movie = widget.movie;
    final List<dynamic> genreList = movie['genres'] ??
        (movie['genre_ids'] != null
            ? (movie['genre_ids'] as List)
                .map((id) => {'id': id, 'name': genreMap[id] ?? 'Unknown'})
                .toList()
            : []);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: ShaderMask(
            shaderCallback: (Rect bounds) {
              return LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.3),
                  Colors.black.withOpacity(0.5),
                  Colors.black.withOpacity(1.0),
                ],
              ).createShader(bounds);
            },
            blendMode: BlendMode.darken,
            child: Image.network(
              'https://image.tmdb.org/t/p/w780${movie['poster_path']}',
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
          ),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
                top: 500, bottom: 0), // Remove extra bottom padding
            child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.0),
                      Colors.black.withOpacity(0.9),
                      Colors.black.withOpacity(0.9),
                      Colors.black.withOpacity(0.9),
                      Colors.black.withOpacity(0.9),
                    ],
                  ),
                ),
                // Main content of the movie details page
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        movie['title'] ?? 'No title',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 35,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: HexColor("#0c4a22").withOpacity(0.7),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              " ${(movie['vote_average'] as num?)?.toStringAsFixed(1) ?? 'N/A'} ",
                              style: TextStyle(
                                color: HexColor("#1ed760"),
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(0),
                              border: Border.all(
                                color: Colors.white30,
                                width: 1,
                              ),
                            ),
                            child: Text(
                              "${movie['original_language']?.toString().toUpperCase() ?? 'N/A'}",
                              style: TextStyle(
                                color: Colors.white60,
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 6, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.white30.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              " ${movie['release_date']?.toString().toUpperCase() ?? 'N/A'} ",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 17,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Divider(
                        color: HexColor("#1ed760"),
                        thickness: 2,
                      ),
                      SizedBox(height: 20),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: genreList.map<Widget>((genre) {
                            return Container(
                              margin: EdgeInsets.only(right: 10),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white30.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color: Colors.white30,
                                  width: 1.5,
                                ),
                              ),
                              child: Text(
                                genre['name'] ?? 'Unknown',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 15),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        movie['overview'] != null &&
                                movie['overview'].toString().trim().isNotEmpty
                            ? movie['overview']
                            : "No description available.",
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                          color: Colors.white60,
                          height: 1.7,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 30),
                      Text(
                        "Cast",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 15),
                      FutureBuilder(
                        future: fetchMovieCast(movie['id']),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(
                                child: LoadingAnimationWidget.fourRotatingDots(
                                    color: HexColor("#1ed760"), size: 30));
                          } else if (snapshot.hasError) {
                            return Center(
                                child: Text(
                              "(No cast available)",
                              style: TextStyle(
                                  color: Colors.redAccent,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16),
                            ));
                          } else {
                            final cast = snapshot.data!;
                            return SizedBox(
                              height: 150,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: cast.length,
                                itemBuilder: (context, index) {
                                  final actor = cast[index];
                                  return Container(
                                    width: 120,
                                    margin: EdgeInsets.only(right: 12),
                                    child: Column(
                                      children: [
                                        CircleAvatar(
                                          backgroundImage: actor[
                                                      'profile_path'] !=
                                                  null
                                              ? NetworkImage(
                                                  "https://image.tmdb.org/t/p/w185${actor['profile_path']}")
                                              : AssetImage("assets/Profile.png")
                                                  as ImageProvider,
                                          radius: 50,
                                        ),
                                        SizedBox(height: 6),
                                        Text(
                                          actor['name'] ?? '(No name)',
                                          style: TextStyle(
                                              color:
                                                  Colors.white.withOpacity(0.8),
                                              fontWeight: FontWeight.w500,
                                              fontSize: 14),
                                          textAlign: TextAlign.center,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            );
                          }
                        },
                      ),
                      SizedBox(height: 40),
                      // Trailer section
                      FutureBuilder(
                        future: fetchMovieTrailer(movie['id']),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(
                              child: LoadingAnimationWidget.fourRotatingDots(
                                color: HexColor("#1ed760"),
                                size: 30,
                              ),
                            );
                          } else if (snapshot.hasError ||
                              snapshot.data == null) {
                            return Center(
                              child: Text(
                                "(No trailer available)",
                                style: TextStyle(
                                    color: Colors.redAccent,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16),
                              ),
                            );
                          } else {
                            final trailerKey = snapshot.data!;
                            return Center(
                              child: GestureDetector(
                                onTap: () {
                                  launchUrl(Uri.parse(
                                      "https://www.youtube.com/watch?v=$trailerKey"));
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
                                      vertical: 12, horizontal: 100),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.play_arrow,
                                          color: Colors.black),
                                      SizedBox(width: 10),
                                      Text(
                                        "Watch Trailer",
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }
                        },
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                )),
          ),
        ),
        // Positioned elements for the header and back button
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 150,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withOpacity(0.7),
                  Colors.black.withOpacity(0.7),
                  Colors.black.withOpacity(0.7),
                  Colors.transparent,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ),
        Positioned(
          top: 50,
          left: 15,
          child: Material(
            color: Colors.transparent,
            child: IconButton(
              icon: Transform.rotate(
                angle: 136 * (3.1415926535 / 180),
                child: Icon(
                  Icons.signal_cellular_4_bar_rounded,
                  size: 20,
                  color: Colors.white.withOpacity(0.9),
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
        Positioned(
          top: 55,
          right: 16,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  // Add to Watched button
                  ElevatedButton.icon(
                    onPressed: () async {
                      final user = FirebaseAuth.instance.currentUser;
                      if (user == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text("❌ Not logged in"),
                              duration: Duration(milliseconds: 1200)),
                        );
                        return;
                      }

                      final movieId = movie['id'];

                      try {
                        final isWatched = watchedMovieIds.contains(movieId);

                        if (isWatched) {
                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(user.uid)
                              .set({
                            'watched': FieldValue.arrayRemove([movieId]),
                          }, SetOptions(merge: true));

                          if (!mounted) return;
                          setState(() {
                            watchedMovieIds.remove(movieId);
                          });

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text("🗑️ Removed from watched"),
                                duration: Duration(milliseconds: 1200)),
                          );
                        } else {
                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(user.uid)
                              .set({
                            'watched': FieldValue.arrayUnion([movieId]),
                          }, SetOptions(merge: true));

                          if (!mounted) return;
                          setState(() {
                            watchedMovieIds.add(movieId);
                          });

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text("✅ Added to watched"),
                                duration: Duration(milliseconds: 1200)),
                          );
                        }
                      } catch (e) {
                        print("Error adding to watched: $e");
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text("❌ Failed to add to Watched\n$e"),
                              duration: Duration(milliseconds: 1200)),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      side: BorderSide(
                        color: watchedMovieIds.contains(movie['id'])
                            ? HexColor("#1ed760")
                            : Colors.white,
                        width: 2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(13),
                      ),
                    ),
                    label: Text(
                      watchedMovieIds.contains(movie['id'])
                          ? 'Watched'
                          : 'Unwatched',
                      style: TextStyle(
                        color: watchedMovieIds.contains(movie['id'])
                            ? HexColor("#1ed760")
                            : Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  // Add to Favorite button
                  ElevatedButton(
                    onPressed: () async {
                      final user = FirebaseAuth.instance.currentUser;
                      if (user == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text("❌ Not logged in"),
                              duration: Duration(milliseconds: 1200)),
                        );
                        return;
                      }

                      final movieId = movie['id'];

                      try {
                        final isFavorite = favoriteMovieIds.contains(movieId);

                        if (isFavorite) {
                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(user.uid)
                              .set({
                            'favorites': FieldValue.arrayRemove([movieId]),
                          }, SetOptions(merge: true));

                          if (!mounted) return;
                          setState(() {
                            favoriteMovieIds.remove(movieId);
                          });

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text("🗑️ Removed from favorites"),
                                duration: Duration(milliseconds: 1200)),
                          );
                        } else {
                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(user.uid)
                              .set({
                            'favorites': FieldValue.arrayUnion([movieId]),
                          }, SetOptions(merge: true));

                          if (!mounted) return;
                          setState(() {
                            favoriteMovieIds.add(movieId);
                          });

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("✅ Added to favorites"),
                              duration: Duration(milliseconds: 1200),
                            ),
                          );
                        }
                      } catch (e) {
                        print("❌ Favorite toggle error: $e");
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text("❌ Failed to add to Favorites\n$e"),
                              duration: Duration(milliseconds: 1200)),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      padding: EdgeInsets.symmetric(horizontal: 7, vertical: 7),
                      minimumSize: Size(0, 0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(17),
                      ),
                    ),
                    child: Icon(
                      favoriteMovieIds.contains(movie['id'])
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: favoriteMovieIds.contains(movie['id'])
                          ? HexColor("#1ed760")
                          : Colors.white,
                      size: 30,
                    ),
                  ),
                  // Add to Watch Later button
                  ElevatedButton(
                    onPressed: () async {
                      final user = FirebaseAuth.instance.currentUser;
                      if (user == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text("❌ Not logged in"),
                              duration: Duration(milliseconds: 1200)),
                        );
                        return;
                      }

                      final movieId = movie['id'];

                      try {
                        final isWatchLater =
                            watchlaterMovieIds.contains(movieId);

                        if (isWatchLater) {
                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(user.uid)
                              .set({
                            'watch later': FieldValue.arrayRemove([movieId]),
                          }, SetOptions(merge: true));

                          if (!mounted) return;
                          setState(() {
                            watchlaterMovieIds.remove(movieId);
                          });

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text("🗑️ Removed from watch later"),
                                duration: Duration(milliseconds: 1200)),
                          );
                        } else {
                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(user.uid)
                              .set({
                            'watch later': FieldValue.arrayUnion([movieId]),
                          }, SetOptions(merge: true));

                          if (!mounted) return;
                          setState(() {
                            watchlaterMovieIds.add(movieId);
                          });

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("✅ Added to watch later"),
                              duration: Duration(milliseconds: 1200),
                            ),
                          );
                        }
                      } catch (e) {
                        print("❌ Favorite toggle error: $e");
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content:
                                  Text("❌ Failed to add to watch later\n$e"),
                              duration: Duration(milliseconds: 1200)),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      padding: EdgeInsets.symmetric(horizontal: 7, vertical: 7),
                      minimumSize: Size(0, 0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(17),
                      ),
                    ),
                    child: Icon(
                      watchlaterMovieIds.contains(movie['id'])
                          ? Icons.bookmark
                          : Icons.bookmark_border,
                      color: watchlaterMovieIds.contains(movie['id'])
                          ? HexColor("#1ed760")
                          : Colors.white,
                      size: 30,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ]),
    );
  }
}
