import 'package:flutter/material.dart';
import 'Api.dart';
import 'Movie_Details_Page.dart';
import 'Tools.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

// * Represents the Genre Movie List page where users can view movies by genre.
// * It fetches movies based on the selected genre and allows users to navigate to movie details.

class GenreMovieListPage extends StatefulWidget {
  final int genreId;
  final String genreName;

  const GenreMovieListPage({
    Key? key,
    required this.genreId,
    required this.genreName,
  }) : super(key: key);

  @override
  _GenreMovieListPageState createState() => _GenreMovieListPageState();
}

class _GenreMovieListPageState extends State<GenreMovieListPage> {
  List<dynamic> movies = [];
  bool isLoading = true;
  int currentPage = 1;
  bool isLoadingMore = false;
  bool hasMore = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchMovies();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 100 &&
          !isLoadingMore &&
          hasMore) {
        _fetchMoreMovies();
      }
    });
  }
  
  // Fetch initial movies by genre
  void _fetchMovies() async {
    try {
      final data = await ApiService.getMoviesByGenre(widget.genreId);
      if (!mounted) return;
      setState(() {
        movies = data;
        isLoading = false;
        hasMore = data.length == 20;
      });
    } catch (e) {
      print("❌ Error fetching movies by genre: $e");
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    }
  }

  // Fetch more movies when scrolling
  Future<void> _fetchMoreMovies() async {
    if (!mounted) return;
    setState(() => isLoadingMore = true);
    final nextPage = currentPage + 1;
    final data =
        await ApiService.getMoviesByGenre(widget.genreId, page: nextPage);
    if (!mounted) return;
    setState(() {
      movies.addAll(data);
      currentPage = nextPage;
      isLoadingMore = false;
      hasMore = data.length == 20;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HexColor("#121212"),
      // AppBar
      appBar: AppBar(
        backgroundColor: Colors.black,
        automaticallyImplyLeading: false,
        leading: Material(
          color: Colors.transparent,
          child: IconButton(
            icon: Transform.rotate(
              angle: 136 * (3.1415926535 / 180),
              child: Icon(
                Icons.signal_cellular_4_bar_rounded,
                size: 17,
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
        title: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: widget.genreName,
                style: TextStyle(
                  color: HexColor("#1ed760"),
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Poppins',
                  fontSize: 25,
                ),
              ),
              TextSpan(
                text: " Movies",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Poppins',
                  fontSize: 25,
                ),
              ),
            ],
          ),
        ),
        iconTheme: IconThemeData(color: HexColor("#1ed760")),
        titleSpacing: 0,
      ),
      body: isLoading
          ? Center(
              child: LoadingAnimationWidget.fourRotatingDots(
                color: HexColor("#1ed760"),
                size: 50,
              ),
            )
          : movies.isEmpty
              ? Center(
                  child: Text("No ${widget.genreName} movies found",
                      style: TextStyle(color: Colors.white60, fontSize: 16)))
              : ListView.builder(
                  controller: _scrollController,
                  itemCount: movies.length + (isLoadingMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == movies.length) {
                      return Center(
                          child: LoadingAnimationWidget.fourRotatingDots(
                              color: HexColor("#1ed760"), size: 50));
                    }
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
                                  SizedBox(height: 5),
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
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
