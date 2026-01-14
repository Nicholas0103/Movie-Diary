import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'Movie_Details_Page.dart';
import 'Api.dart';
import 'Tools.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

// * Represents the Watched Movies page where users can view movies they have watched.
// * Users can remove movies from this list, and it fetches data from Firestore.

class WatchedPage extends StatefulWidget {
  const WatchedPage({Key? key}) : super(key: key);

  @override
  _WatchedPageState createState() => _WatchedPageState();
}

class _WatchedPageState extends State<WatchedPage> {
  List<dynamic> movies = [];
  Set<int> favoriteMovieIds = {};
  Set<int> watchedMovieIds = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWatched();
  }

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
          watchedMovieIds = Set<int>.from(watched.cast<int>());

          final futures =
              watchedMovieIds.map((id) => ApiService.getMovieById(id)).toList();
          final results = await Future.wait(futures);
          final fetchedMovies =
              results.whereType<Map<String, dynamic>>().toList();

          if (!mounted) return;
          setState(() {
            movies = fetchedMovies;
            isLoading = false;
          });
        } else {
          if (!mounted) return;
          setState(() {
            movies = [];
            isLoading = false;
          });
        }
      } catch (e) {
        print('❌ Error loading watched movies: $e');
        if (!mounted) return;
        setState(() {
          isLoading = false;
        });
      }
    } else {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: HexColor("#121212"),
      child: isLoading
          ? Center(
              child: LoadingAnimationWidget.fourRotatingDots(
                color: HexColor("#1ed760"),
                size: 50,
              ),
            )
          : movies.isEmpty
              ? Center(
                  child: Text("No watched movies yet",
                      style: TextStyle(color: Colors.white60, fontSize: 18)))
              : RefreshIndicator(
                  color: Colors.black,
                  backgroundColor: HexColor("#1ed760"),
                  onRefresh: () async {
                    _loadWatched();
                  },
                  child: ListView.builder(
                    itemCount: movies.length,
                    itemBuilder: (context, index) {
                      final movie = movies[index];
                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    MovieDetailPage(movie: movie)),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(5),
                                child: Image.network(
                                  'https://image.tmdb.org/t/p/w780${movie['poster_path']}',
                                  width: 120,
                                  height: 180,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            movie['title'] ?? 'No title',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 20,
                                            ),
                                          ),
                                        ),
                                        // Remove from Watched button
                                        IconButton(
                                          onPressed: () async {
                                            final user = FirebaseAuth
                                                .instance.currentUser;
                                            if (user == null) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                    content:
                                                        Text("❌ Not logged in"),
                                                    duration: Duration(
                                                        milliseconds: 1200)),
                                              );
                                              return;
                                            }

                                            final movieId = movie['id'];

                                            try {
                                              await FirebaseFirestore.instance
                                                  .collection('users')
                                                  .doc(user.uid)
                                                  .set({
                                                'watched':
                                                    FieldValue.arrayRemove(
                                                        [movieId]),
                                              }, SetOptions(merge: true));

                                              if (!mounted) return;
                                              setState(() {
                                                watchedMovieIds.remove(movieId);
                                                movies.removeWhere(
                                                    (m) => m['id'] == movieId);
                                              });

                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                    content: Text(
                                                        "🗑️ Removed from watched"),
                                                    duration: Duration(
                                                        milliseconds: 1200)),
                                              );
                                            } catch (e) {
                                              print(
                                                  "❌ Error removing movie: $e");
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                    content: Text(
                                                        "❌ Failed to remove\n$e"),
                                                    duration: Duration(
                                                        milliseconds: 1200)),
                                              );
                                            }
                                          },
                                          icon: Icon(Icons.delete, size: 25),
                                          color: const Color.fromARGB(
                                              255, 137, 137, 137),
                                          padding: EdgeInsets.zero,
                                          constraints: BoxConstraints(),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: HexColor("#1ed760")
                                                .withOpacity(0.2),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            " ${(movie['vote_average'] as num?)?.toStringAsFixed(1) ?? 'N/A'} ",
                                            style: TextStyle(
                                              color: HexColor("#1ed760"),
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 5, vertical: 1),
                                          decoration: BoxDecoration(
                                            color: Colors.transparent,
                                            borderRadius:
                                                BorderRadius.circular(0),
                                            border: Border.all(
                                              color: Colors.white30,
                                              width: 1,
                                            ),
                                          ),
                                          child: Text(
                                            "${movie['original_language']?.toString().toUpperCase() ?? 'N/A'}",
                                            style: TextStyle(
                                              color: Colors.white60,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 5, vertical: 2),
                                          decoration: BoxDecoration(
                                            color:
                                                Colors.white30.withOpacity(0.2),
                                            borderRadius:
                                                BorderRadius.circular(5),
                                          ),
                                          child: Text(
                                            " ${(movie['release_date'] == null || movie['release_date'].toString().isEmpty) ? '--' : movie['release_date'].toString().toUpperCase()} ",
                                            style: TextStyle(
                                              color: Colors.white60,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                      movie['overview']?.isNotEmpty == true
                                          ? movie['overview']
                                          : "No description available.",
                                      textAlign: TextAlign.justify,
                                      style: TextStyle(
                                        color: Colors.white54,
                                        fontSize: 12,
                                        height: 1.6,
                                      ),
                                      maxLines: 4,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
