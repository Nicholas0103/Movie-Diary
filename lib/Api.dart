import 'dart:convert';
import 'package:http/http.dart' as http;

// * This file contains the API service for fetching movie data from The Movie Database (TMDB).
// * It includes methods to get popular movies, movie details by ID, movies by genre, and search functionality.

class ApiService {
  static const String apiKey = '204e096677c6aaa875e4a8dc7e6e1e1e';
  static const String baseUrl = 'https://api.themoviedb.org/3';

  static Future<List<dynamic>> getPopularMovies() async {
    final url = Uri.parse('$baseUrl/movie/popular?api_key=$apiKey');

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['results'];
    } else {
      print("API FAILED: ${response.statusCode}");
      throw Exception('Failed to load movies');
    }
  }

  static Future<Map<String, dynamic>?> getMovieById(int id) async {
    final response = await http.get(Uri.parse(
        'https://api.themoviedb.org/3/movie/$id?api_key=$apiKey&language=en-US'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    return null;
  }

  static Future<List<dynamic>> getMoviesByGenre(int genreId,
      {int page = 1}) async {
    final response = await http.get(
      Uri.parse(
          'https://api.themoviedb.org/3/discover/movie?api_key=$apiKey&with_genres=$genreId&page=$page'),
    );
    final data = json.decode(response.body);
    return data['results'] ?? [];
  }
}

Future<List<dynamic>> searchMovies(String query) async {
  final apiKey = '204e096677c6aaa875e4a8dc7e6e1e1e';
  final url =
      'https://api.themoviedb.org/3/search/movie?api_key=$apiKey&query=$query';

  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data['results'];
  } else {
    throw Exception('❌ Failed to search movies');
  }
}

Future<List<dynamic>> searchMulti(String query) async {
  final response = await http.get(
    Uri.parse(
        'https://api.themoviedb.org/3/search/multi?api_key=204e096677c6aaa875e4a8dc7e6e1e1e&query=$query'),
  );
  final data = json.decode(response.body);
  return data['results'] ?? [];
}
