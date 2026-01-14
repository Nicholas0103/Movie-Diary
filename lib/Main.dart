import 'package:flutter/material.dart';
import 'Firebase_Options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'Tools.dart';
import 'Movie_Page.dart';
import 'Movie_Details_Page.dart';

// * Represents the main entry point of the Movie Diary application.

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Movie Diary',
      theme: ThemeData(
        fontFamily: 'Poppins',
        colorScheme: ColorScheme.fromSeed(seedColor: HexColor("#1ed760")),
        useMaterial3: true,
      ),
      home: MovieHome(),
      onGenerateRoute: (settings) {
        if (settings.name == '/movieDetails') {
          final movie = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => MovieDetailPage(movie: movie),
          );
        }
        return null;
      },
    );
  }
}
