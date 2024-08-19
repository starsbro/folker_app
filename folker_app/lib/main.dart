import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_input/image_input.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'folker App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();

// ↓ Add this.
void getNext() {
  current = WordPair.random();
  notifyListeners();
}

// ↓ Add the code below.
var favorites = <WordPair>[];

void toggleFavorite() {
  if (favorites.contains(current)) {
    favorites.remove(current);
  } else {
    favorites.add(current);
  }
  notifyListeners();
} 

void removeFavorite(WordPair pair) {
  favorites.remove(pair);
  notifyListeners();
  }
}

class MyHomePage extends StatefulWidget{
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
        //break; // Unnecessary 'break' statement. linter rules
      case 1:
        page = FavoritesPage();
        //break;
      case 2:
        page = ImagePage();
        //break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

   
    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          body: Row(
            children: [
              SafeArea(
                child: NavigationRail(
                  extended: constraints.maxWidth >=600,
                  destinations: [
                    NavigationRailDestination(
                      icon: Icon(Icons.home),
                      label: Text('Home'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.favorite), 
                      label: Text('Favorites'),
                      ),
                      NavigationRailDestination(
                      icon: Icon(Icons.image), 
                      label: Text('Image_input'),
                      ),
                  ],
                  selectedIndex: selectedIndex,
                  onDestinationSelected: (value) {
                    //print('selected: $value');
                    setState(() {
                      selectedIndex = value;
                    });
        
                  },
                 )
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

class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;

    IconData icon;
    if (appState.favorites.contains(pair)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }

    return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            BigCard(pair: pair),
            SizedBox(height: 10),
            // ↓ Add this.
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    appState.toggleFavorite();
                  },
                  icon: Icon(icon),
                  label: Text('Like'),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    appState.getNext();
                    //print('button pressed!');
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

class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var appState = context.watch<MyAppState>();

    if (appState.favorites.isEmpty) {
      return Center (
        child: Text('No favorites yet.'),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(30),
          child: Text('You have ' 
                    '${appState.favorites.length} favorites:'),
        ),
        Expanded(
          child: GridView(
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 400,
              childAspectRatio: 400 / 80,
            ),
            children: [
              for (var pair in appState.favorites)
              ListTile(
                leading: IconButton(
                  icon: Icon(Icons.delete_outline, semanticLabel: 'Delete'),
                  color: theme.colorScheme.primary,
                  onPressed: () {
                    appState.removeFavorite(pair);
                  },
                ),
                title: Text(
                  pair.asLowerCase,
                  semanticsLabel: pair.asPascalCase,
                  ),
              ),    
            ],
          ),
        ),   
      ],
    );
  }
}


class ImagePage extends StatefulWidget {
  const ImagePage({super.key});

  @override
  State<ImagePage> createState() => _ImagePageState();

}

class _ImagePageState extends State<ImagePage> {
  List<XFile> imageInputImages = [];
  bool allowEditImageInput = true;

  @override
  Widget build(BuildContext context) {
    var theme =Theme.of(context);
    
    return Scaffold(
      body: ListView(
        children: [
          const SizedBox(
            height: 50,
          ),
          Center(
            child: Text(
              'Image Input',
              style:TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          Center(
            child: 
              //Image.asset('images/learing_any_programming_language.jpg'),
              ImageInput(
              images: imageInputImages,
              allowEdit: allowEditImageInput,
              allowMaxImage: 5,
              //getPreferredCameraDevice: () async =>
              //  await getPreferredCameraDevice(context),
              //getPreferredCameraDevice: getPreferredCameraDevice,
              getPreferredCameraDevice: () => getPreferredCameraDevice(context),
              getImageSource: () async => getImageSource(context),
              onImageSelected: (image) {
                setState(() {
                  imageInputImages.add(image);
                });
              },
              onImageRemoved: (image, index) {
                setState(() {
                  imageInputImages.remove(image);
               });
              },
              loadingBuilder: (context, progress) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              },
            )
          ),
        ],
      )
    );
  }
}  

var getImageSource = (BuildContext context) {
  return showDialog<ImageSource>(
    context: context,
    builder: (context) {
      return SimpleDialog(
        children: [
          SimpleDialogOption(
            child: const Text("Camera"),
            onPressed: () {
              Navigator.of(context).pop(ImageSource.camera);
            },
          ),
          SimpleDialogOption(
              child: const Text("Gallery"),
              onPressed: () {
                Navigator.of(context).pop(ImageSource.gallery);
              }),
        ],
      );
    },
  ).then((value) {
    return value ?? ImageSource.gallery;
  });
};

typedef GetPreferredCameraDevice = Future<CameraDevice?> Function();

var getPreferredCameraDevice = (BuildContext context) async {
  var status =  await Permission.camera.request();
  if (status.isDenied) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Allow Camera Permission"),
      ),
    );
    return null;
  }
  return showDialog<CameraDevice>(
    context: context,
    builder: (context) {
      return SimpleDialog(
        children: [
          SimpleDialogOption(
            child: const Text("Rear"),
            onPressed: () {
              Navigator.of(context).pop(CameraDevice.rear);
            },
          ),
          SimpleDialogOption(
              child: const Text("Front"),
              onPressed: () {
                Navigator.of(context).pop(CameraDevice.front);
              }),
        ],
      );
    },
  ).then(
    (value) {
      return value ?? CameraDevice.rear;
    },
  );
};


class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Add this
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