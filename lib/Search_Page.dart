import 'package:flutter/material.dart';
import 'Api.dart';
import 'Tools.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// * Represents the Search Page where users can search for movies.
// * It allows users to enter a search query, view recent searches, and displays search results.

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List<dynamic> _searchResults = [];
  List<String> _searchHistory = [];
  final TextEditingController _searchController = TextEditingController();

  void _searchMovie(String query) async {
    final results = await searchMovies(query);
    final user = FirebaseAuth.instance.currentUser;

    if (!_searchHistory.contains(query)) {
      if (!mounted) return;
      setState(() {
        _searchHistory.insert(0, query);
      });
    }

    if (user != null) {
      await FirebaseFirestore.instance
          .collection('searchHistory')
          .doc(user.uid)
          .set({
        'queries': FieldValue.arrayUnion([query]),
      }, SetOptions(merge: true));
    }

    if (!mounted) return;
    setState(() {
      _searchResults = results
          .where(
              (movie) => movie['poster_path'] != null && movie['title'] != null)
          .toList();
    });
  }

  // Load search history from Firestore
  void _loadSearchHistory() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('searchHistory')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        if (!mounted) return;
        setState(() {
          _searchHistory = List<String>.from(doc.data()?['queries'] ?? []);
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _loadSearchHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        // AppBar
        appBar: AppBar(
          leading: Builder(
            builder: (context) => Material(
              color: Colors.transparent,
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 23.0, top: 4.0),
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
          backgroundColor: Colors.black,
          title: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: "Search",
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
        ),
        // Search Bar
        body: Column(
          children: [
            SizedBox(height: 25),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                height: 80,
                child: TextField(
                  controller: _searchController,
                  onSubmitted: _searchMovie,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Search...',
                    hintStyle: TextStyle(color: Colors.white70),
                    prefixIcon: Icon(Icons.search, color: Colors.white),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear, color: Colors.white),
                            onPressed: () {
                              if (!mounted) return;
                              setState(() {
                                _searchController.clear();
                                _searchResults.clear();
                              });
                            },
                          )
                        : null,
                    enabledBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: HexColor("#1ed760"), width: 2),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: HexColor("#1ed760"), width: 2),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 20, horizontal: 0),
                  ),
                ),
              ),
            ),
            // Search History
            Expanded(
              child: _searchResults.isEmpty
                  ? ListView(
                      padding: EdgeInsets.all(16),
                      children: [
                        Text("Recent Searches",
                            style: TextStyle(
                                color: Colors.white70,
                                fontWeight: FontWeight.w500,
                                fontSize: 20)),
                        SizedBox(height: 15),
                        _searchHistory.isEmpty
                            ? Text("(No recent searches)",
                                style: TextStyle(
                                    color: Colors.white60,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 15))
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: _searchHistory.reversed.map((query) {
                                  return ListTile(
                                    contentPadding:
                                        EdgeInsets.only(left: 10, right: 10),
                                    leading: Icon(Icons.history,
                                        color: Colors.white70, size: 25),
                                    title: Text(
                                      query,
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 16,
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                    trailing: IconButton(
                                      icon: Icon(Icons.close,
                                          color: Colors.white70, size: 25),
                                      onPressed: () async {
                                        final user =
                                            FirebaseAuth.instance.currentUser;
                                        if (user != null) {
                                          await FirebaseFirestore.instance
                                              .collection('searchHistory')
                                              .doc(user.uid)
                                              .update({
                                            'queries':
                                                FieldValue.arrayRemove([query]),
                                          });
                                        }
                                        if (!mounted) return;
                                        setState(() {
                                          _searchHistory.remove(query);
                                        });
                                      },
                                    ),
                                    onTap: () {
                                      _searchController.text = query;
                                      _searchMovie(query);
                                    },
                                  );
                                }).toList(),
                              ),
                      ],
                    )
                    // Search Results
                  : ListView.builder(
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) {
                        final movie = _searchResults[index];
                        if (movie['poster_path'] == null ||
                            movie['title'] == null) {
                          return SizedBox.shrink();
                        }
                        return GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, '/movieDetails',
                                arguments: movie);
                          },
                          child: Container(
                            margin: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white10,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    'https://image.tmdb.org/t/p/w200${movie['poster_path']}',
                                    width: 100,
                                    height: 150,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            Container(
                                                width: 80,
                                                height: 120,
                                                color: Colors.grey),
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
                                        movie['title'] ?? 'No Title',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      SizedBox(height: 10),
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
                                      SizedBox(height: 13),
                                      Text(
                                        movie['overview'] ??
                                            'No description available.',
                                        maxLines: 3,
                                        textAlign: TextAlign.justify,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 13,
                                          height: 1.5,
                                        ),
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
          ],
        ));
  }
}
