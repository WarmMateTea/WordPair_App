import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Namer App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();

  void getNext() {
    current = WordPair.random();
    notifyListeners();
  }

  var favorites = <WordPair>[];

  void toggleFavorite() {
    if (favorites.contains(current)) {
      favorites.remove(current);
    } else {
      favorites.add(current);
    }
    notifyListeners();
  }

  void removeFavorite(WordPair toggle) {
    if (favorites.contains(toggle)) {
      favorites.remove(toggle);
    }
    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = GeneratorPage();
        break;
      case 1:
        page = FavoritesPage();
        break;
      default:
        throw UnimplementedError('no widget 4 $selectedIndex :D');
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          body: Row(
            children: [
              SafeArea(
                child: NavigationRail(
                  extended: constraints.maxWidth >= 600,
                  destinations: [
                    NavigationRailDestination(
                      icon: Icon(Icons.home),
                      label: Text('Home'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.favorite),
                      label: Text('Favorites'),
                    ),
                  ],
                  selectedIndex: selectedIndex,
                  onDestinationSelected: (value) {
                    setState(() {
                      selectedIndex = value;
                    });
                  },
                ),
              ),
              Expanded(
                child: Container(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: page,
                ),
              ),
            ],
          ),
        );
      }
    );
  }
}

class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var favorites = appState.favorites;

    final theme = Theme.of(context);
    final style = theme.textTheme.bodyLarge!.copyWith(
      color: theme.colorScheme.onSecondary,
    );

    final favInfo = (favorites.isEmpty) ? "Não haveis adicionado favoritos 😢": "Estes são vossos favoritos ✨:";

    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text(favInfo),
        ),
        for (var wordpair in favorites)
          ListTile(
            leading: IconButton(
              onPressed: () {
                appState.removeFavorite(wordpair);
              },
              icon: Icon(Icons.favorite, color: Colors.pink),
            ),
            title: Text(wordpair.asLowerCase),
          ),
      ],
    );
/*    return Center(
      child: Column(
        children: [
          Text('Favorites:'),
          for (var wordpair in favorites)
            Column( // Hmm. O ideal seria que todos os cards tivessem o mesmo tamanho - da maior palavra... mas não sei se isso é possível.
              children: [
                Card(
                  color: theme.colorScheme.secondary,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(15,5,5,5),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          wordpair.asLowerCase,
                          style: style,
                          semanticsLabel: "${wordpair.first} ${wordpair.second}",
                        ),
                        IconButton(
                          onPressed: () {
                            appState.toggleFavoriteInFav(wordpair);
                          },
                          icon: Icon(
                              (favorites.contains(wordpair)) ? // tf ou eu mudo o jeito do databinding ou eu mudo pra ser só um hard remove :D
                              Icons.close:
                              Icons.favorite_border
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 5),
              ],
            ),
        ],
      ),
    );*/
  }
}


class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;

    IconData icon;
    var textFav = "Like";
    if (appState.favorites.contains(pair)) {
      textFav = "Unlike";
      icon = Icons.favorite;
    } else {
      textFav = "Like";
      icon = Icons.favorite_border;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BigCard(pair: pair),
          SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  appState.toggleFavorite();
                },
                icon:Icon(icon),
                label: Text(textFav),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  appState.getNext();
                },
                child: Text('Next'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );

    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Text(
            pair.asLowerCase,
            style: style,
            semanticsLabel: "${pair.first} ${pair.second}",
        ),
      ),
    );
  }
}