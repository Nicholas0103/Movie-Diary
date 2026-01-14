import 'package:flutter/material.dart';
import 'Favourite_Page.dart';
import 'Watched_Page.dart';
import 'Movie_Details_Page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'Api.dart';
import 'Profile_Page.dart';
import 'Sign_In_Page.dart';
import 'Search_Page.dart';
import 'Tools.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:typicons_flutter/typicons_flutter.dart';
import 'Watch_Later_Page.dart';
import 'Genre_Page.dart';
import 'Movie_Diary_Page.dart';

// * Represents the main entry point of the application (Home Page).

class YourWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () async {
        try {
          print("Signing out with Google...");
          await signOutWithGoogle();
          await Future.delayed(Duration(milliseconds: 200));

          if (context.mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => SignInPage()),
            );
          }
        } catch (e) {
          print("❌ Error during sign out: $e");
        }
      },
      icon: Icon(Icons.logout),
      label: Text("Sign out with Google"),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasData) {
          return MovieHome();
        } else {
          return const SignInPage();
        }
      },
    );
  }
}

// The page that can be navigated to from the home page.
Widget getPage(int index) {
  switch (index) {
    case 0:
      return MovieList();
    case 1:
      return FavoritePage();
    case 2:
      return WatchLaterPage();
    case 3:
      return GenrePage();
    case 4:
      return WatchedPage();
    default:
      return MovieList();
  }
}

final List<String> _titles = [
  "Movie List",
  "Your Favorites",
  "Watch List",
  "Genres",
  "Watched Movies",
];

class MovieHome extends StatefulWidget {
  @override
  _MovieHomeState createState() => _MovieHomeState();
}

class _MovieHomeState extends State<MovieHome> {
  int _selectedIndex = 0;
  GoogleSignInAccount? _user;

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
      backgroundColor: HexColor("#121212"),
      extendBody: true,
      // AppBar
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: HexColor("#1ed760"),
        iconTheme: IconThemeData(color: Colors.black),
        title: Text(_titles[_selectedIndex],
            style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
                fontSize: 25,
                color: Colors.white)),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: [
                  HexColor("#121212"),
                  HexColor("#121212"),
                ],
                begin: const FractionalOffset(0.0, 0.0),
                end: const FractionalOffset(1.0, 0.0),
                stops: [0.0, 1.0],
                tileMode: TileMode.clamp),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SearchPage()),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.only(right: 20.0, left: 8.0),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfilePage()),
                );
              },
              child: Container(
                padding: EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: HexColor("#1ed760"),
                    width: 1.5,
                  ),
                ),
                child: CircleAvatar(
                  radius: 15,
                  backgroundImage: _user != null && _user!.photoUrl != null
                      ? NetworkImage(_user!.photoUrl!)
                      : AssetImage('assets/Profile.png') as ImageProvider,
                ),
              ),
            ),
          ),
        ],
      ),
      body: getPage(_selectedIndex),
      // Bottom Navigation Bar
      floatingActionButton: SizedBox(
        height: 65,
        width: 65,
        child: GestureDetector(
          onLongPress: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => MovieDiaryPage()));
          },
          child: FloatingActionButton(
            backgroundColor: HexColor("#1ed760"),
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(27),
            ),
            child: Icon(
              _selectedIndex == 0 ? Typicons.home : Typicons.home_outline,
              size: 30,
              color: Colors.black,
            ),
            onPressed: () {
              if (!mounted) return;
              setState(() => _selectedIndex = 0);
            },
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: HexColor("#202020"),
        shape: CircularNotchedRectangle(),
        notchMargin: 8,
        child: SizedBox(
          height: 10,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    borderRadius: BorderRadius.circular(15),
                    onTap: () => setState(() => _selectedIndex = 1),
                    child: SizedBox(
                      height: 56,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            size: 25,
                            _selectedIndex == 1
                                ? Icons.favorite
                                : Icons.favorite_border_outlined,
                            color: _selectedIndex == 1
                                ? HexColor("#1ed760")
                                : Colors.white,
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Favorited',
                            style: TextStyle(
                              color: _selectedIndex == 1
                                  ? HexColor("#1ed760")
                                  : Colors.white,
                              fontSize: 13,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    borderRadius: BorderRadius.circular(15),
                    onTap: () => setState(() => _selectedIndex = 2),
                    child: SizedBox(
                      height: 56,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            size: 25,
                            _selectedIndex == 2
                                ? Icons.bookmark
                                : Icons.bookmark_border_outlined,
                            color: _selectedIndex == 2
                                ? HexColor("#1ed760")
                                : Colors.white,
                          ),
                          SizedBox(height: 4),
                          Text(
                            'To Watch',
                            style: TextStyle(
                              color: _selectedIndex == 2
                                  ? HexColor("#1ed760")
                                  : Colors.white,
                              fontSize: 13,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 50),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    borderRadius: BorderRadius.circular(15),
                    onTap: () => setState(() => _selectedIndex = 3),
                    child: SizedBox(
                      height: 56,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            size: 25,
                            _selectedIndex == 3
                                ? Icons.local_offer
                                : Icons.local_offer_outlined,
                            color: _selectedIndex == 3
                                ? HexColor("#1ed760")
                                : Colors.white,
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Genres',
                            style: TextStyle(
                              color: _selectedIndex == 3
                                  ? HexColor("#1ed760")
                                  : Colors.white,
                              fontSize: 13,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    borderRadius: BorderRadius.circular(15),
                    onTap: () => setState(() => _selectedIndex = 4),
                    child: SizedBox(
                      height: 56,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            size: 25,
                            _selectedIndex == 4
                                ? Icons.movie_filter
                                : Icons.movie_filter_outlined,
                            color: _selectedIndex == 4
                                ? HexColor("#1ed760")
                                : Colors.white,
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Watched',
                            style: TextStyle(
                              color: _selectedIndex == 4
                                  ? HexColor("#1ed760")
                                  : Colors.white,
                              fontSize: 13,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MovieList extends StatefulWidget {
  const MovieList({super.key});

  @override
  _MovieListState createState() => _MovieListState();
}

class _MovieListState extends State<MovieList> {
  List<dynamic> movies = [];
  Set<int> watchedMovieIds = {};
  Set<int> favoriteMovieIds = {};
  List<dynamic> topratedMovies = [];
  List<dynamic> nowplayingMovies = [];
  List<dynamic> newMovies = [];
  List<dynamic> trendingMovies = [];
  late PageController _pageController;

  int _currentPage = 0;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    fetchFavorites();
    fetchWatched();
    _loadFavorites();
    _loadWatched();
    fetchTopRatedMovies();
    fetchNewMovies();
    fetchNowPlayingMovies();
    fetchTrendingMovies();

    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        print("✅ User already signed in as ${user.displayName}");
      }
    });
    fetchMovies();

    _timer = Timer.periodic(Duration(seconds: 4), (Timer timer) {
      if (!mounted || movies.isEmpty) return;
      if (_currentPage < movies.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  // Fetches favorite movies from Firestore
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

  // Fetches watched movies from Firestore
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

  // Loads favorite movies from Firestore
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
              duration: Duration(milliseconds: 1200)),
        );
      } catch (e) {
        print('❌ Unexpected error: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('❌ Something went wrong: $e'),
              duration: Duration(milliseconds: 1200)),
        );
      }
    }
  }

  // Loads watched movies from Firestore
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
              duration: Duration(milliseconds: 1200)),
        );
      } catch (e) {
        print('❌ Unexpected error: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('❌ Something went wrong: $e'),
              duration: Duration(milliseconds: 1200)),
        );
      }
    }
  }

  // Fetches popular movies from the API
  void fetchMovies() async {
    try {
      final fetchedMovies = await ApiService.getPopularMovies();
      print("Fetched ${fetchedMovies.length} movies");
      if (!mounted) return;
      setState(() {
        movies = fetchedMovies;
      });
    } catch (e) {
      print("Error: $e");
    }
  }

  // Fetches now playing movies from the API
  Future<void> fetchNowPlayingMovies() async {
    try {
      final response = await http.get(
        Uri.parse(
            'https://api.themoviedb.org/3/movie/now_playing?api_key=204e096677c6aaa875e4a8dc7e6e1e1e'),
      );
      print('NowPlayingMovies status: ${response.statusCode}');
      print('NowPlayingMovies body: ${response.body}');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (!mounted) return;
        setState(() {
          nowplayingMovies = data['results'] ?? [];
        });
      } else {
        print('❌ Server error: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Server error: ${response.statusCode}'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('❌ No Internet Connection');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ No Internet Connection'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  // Fetches new movies from the API
  Future<void> fetchNewMovies() async {
    final url =
        'https://api.themoviedb.org/3/movie/upcoming?api_key=204e096677c6aaa875e4a8dc7e6e1e1e';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (!mounted) return;
        setState(() {
          newMovies = data['results'] ?? [];
        });
        for (var movie in newMovies) {
          final imageUrl =
              'https://image.tmdb.org/t/p/w780${movie['backdrop_path']}';
          precacheImage(NetworkImage(imageUrl), context);
        }
      } else {
        print('❌ Server error: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Server error: ${response.statusCode}'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('❌ No Internet Connection');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ No Internet Connection'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  // Fetches top-rated movies from the API
  Future<void> fetchTopRatedMovies() async {
    final response = await http.get(
      Uri.parse(
          'https://api.themoviedb.org/3/movie/top_rated?api_key=204e096677c6aaa875e4a8dc7e6e1e1e'),
    );
    print('Top rated status: ${response.statusCode}');
    print('Top rated body: ${response.body}');
    final data = json.decode(response.body);
    if (!mounted) return;
    setState(() {
      topratedMovies = data['results'] ?? [];
    });
  }

  // Fetches trending movies from the API
  Future<void> fetchTrendingMovies() async {
    final response = await http.get(
      Uri.parse(
          'https://api.themoviedb.org/3/trending/movie/day?api_key=204e096677c6aaa875e4a8dc7e6e1e1e'),
    );
    print('Trending status: ${response.statusCode}');
    print('Trending body: ${response.body}');
    final data = json.decode(response.body);
    if (!mounted) return;
    setState(() {
      trendingMovies = data['results'] ?? [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HexColor("#121212"),
      body: movies.isEmpty
          ? Center(
              child: LoadingAnimationWidget.fourRotatingDots(
                color: HexColor("#1ed760"),
                size: 70,
              ),
            )
          : RefreshIndicator(
              color: Colors.black,
              backgroundColor: HexColor("#1ed760"),
              onRefresh: () async {
                _loadFavorites();
              },
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 250,
                      child: PageView(
                        controller: _pageController,
                        children: newMovies.map((movie) {
                          return Stack(
                            children: [
                              Opacity(
                                opacity: 0.8,
                                child: Image.network(
                                  'https://image.tmdb.org/t/p/w780${movie['backdrop_path']}',
                                  width: double.infinity,
                                  height: 250,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Container(
                                width: double.infinity,
                                height: 250,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      HexColor("#121212")
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                    SizedBox(height: 20),
                    // Display now playing movies
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(Icons.play_circle_filled,
                                  color: HexColor("#1ed760")),
                              SizedBox(width: 8),
                              Text(
                                'Now Playing',
                                style: TextStyle(
                                  color: HexColor("#1ed760"),
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                    SizedBox(
                      height: 250,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: nowplayingMovies.length,
                        itemBuilder: (context, index) {
                          final movie = nowplayingMovies[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          MovieDetailPage(movie: movie)),
                                );
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.network(
                                      'https://image.tmdb.org/t/p/w780${movie['backdrop_path']}',
                                      width: 300,
                                      height: 180,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  SizedBox(height: 6),
                                  SizedBox(
                                    width: 300,
                                    child: Text(
                                      movie['title'] ?? 'No title',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    // Display trending movies
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.thumb_up_off_alt_rounded,
                                      color: HexColor("#1ed760")),
                                  SizedBox(width: 8),
                                  Text(
                                    'Trending',
                                    style: TextStyle(
                                      color: HexColor("#1ed760"),
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 10),
                        SizedBox(
                          height: 250,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: trendingMovies.length,
                            itemBuilder: (context, index) {
                              final movie = trendingMovies[index];
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              MovieDetailPage(movie: movie)),
                                    );
                                  },
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Image.network(
                                          'https://image.tmdb.org/t/p/w780${movie['poster_path']}',
                                          width: 120,
                                          height: 180,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      SizedBox(height: 6),
                                      SizedBox(
                                        width: 120,
                                        child: Text(
                                          movie['title'] ?? 'No title',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        // Display Top Rated movies
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.thumb_up_off_alt_rounded,
                                      color: HexColor("#1ed760")),
                                  SizedBox(width: 8),
                                  Text(
                                    'Top Rated',
                                    style: TextStyle(
                                      color: HexColor("#1ed760"),
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 10),
                        SizedBox(
                          height: 250,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: topratedMovies.length,
                            itemBuilder: (context, index) {
                              final movie = topratedMovies[index];
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              MovieDetailPage(movie: movie)),
                                    );
                                  },
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Image.network(
                                          'https://image.tmdb.org/t/p/w780${movie['poster_path']}',
                                          width: 120,
                                          height: 180,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      SizedBox(height: 6),
                                      SizedBox(
                                        width: 120,
                                        child: Text(
                                          movie['title'] ?? 'No title',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        // Display More movies
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.local_movies_rounded,
                                      color: HexColor("#1ed760")),
                                  SizedBox(width: 8),
                                  Text(
                                    'More Movies',
                                    style: TextStyle(
                                      color: HexColor("#1ed760"),
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: movies.length,
                          itemBuilder: (context, index) {
                            final movie = movies[index];
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            MovieDetailPage(movie: movie)));
                              },
                              child: Container(
                                margin: EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 8),
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white10.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(14),
                                ),
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(height: 8),
                                          Text(
                                            movie['title'] ?? 'No title',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 20,
                                            ),
                                          ),
                                          SizedBox(height: 11),
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
                                                  color: Colors.white30
                                                      .withOpacity(0.2),
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
                                          SizedBox(height: 11),
                                          Text(
                                            movie['overview'] != null &&
                                                    movie['overview']
                                                        .toString()
                                                        .trim()
                                                        .isNotEmpty
                                                ? movie['overview']
                                                : "No description available.",
                                            textAlign: TextAlign.justify,
                                            style: TextStyle(
                                              color: Colors.white54,
                                              fontSize: 12,
                                              height: 1.8,
                                            ),
                                            maxLines: 4,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          SizedBox(height: 8),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
