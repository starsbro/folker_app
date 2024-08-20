import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  List<File> _selectedImages = [];
  Set<int> _favoriteIndices = {};

  Future<void> _pickImages() async {
    // Open a file picker to select multiple images
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,  // Enable multiple selection
    );

    if (result != null) {
      setState(() {
        _selectedImages = result.paths.map((path) => File(path!)).toList();
      });
    }
  }

  void _deleteImage(int index) {
    setState(() {
      _favoriteIndices.remove(index);
      _selectedImages.removeAt(index);
    });
  }

  void _toggleFavorite(int index) {
    setState(() {
      if (_favoriteIndices.contains(index)) {
        _favoriteIndices.remove(index);
      } else {
        _favoriteIndices.add(index);
      }
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  List<Widget> _buildPages() {
    return [
      MainImagePage(
        selectedImages: _selectedImages,
        favoriteIndices: _favoriteIndices,
        onPickImages: _pickImages,
        onDeleteImage: _deleteImage,
        onToggleFavorite: _toggleFavorite,
      ),
      FavoriteImagesPage(
        favoriteImages: _favoriteIndices.map((index) => _selectedImages[index]).toList(),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sigmentation Images Picker'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Row(
            children: [
              NavigationRail(
                selectedIndex: _selectedIndex,
                onDestinationSelected: _onItemTapped,
                labelType: NavigationRailLabelType.all,
                destinations: [
                  NavigationRailDestination(
                    icon: Icon(Icons.image),
                    label: Text('Images'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.favorite),
                    label: Text('Favorites'),
                  ),
                ],
              ),
              VerticalDivider(thickness: 1, width: 1),
              Expanded(
                child: _buildPages()[_selectedIndex],
              ),
            ],
          );
        },
      ),
    );
  }
}

class MainImagePage extends StatelessWidget {
  final List<File> selectedImages;
  final Set<int> favoriteIndices;
  final VoidCallback onPickImages;
  final Function(int) onDeleteImage;
  final Function(int) onToggleFavorite;

  MainImagePage({
    required this.selectedImages,
    required this.favoriteIndices,
    required this.onPickImages,
    required this.onDeleteImage,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: onPickImages,
              child: Text('Select Images'),
            ),
          ],
        ),
        SizedBox(height: 20),
        Expanded(
          child: selectedImages.isNotEmpty
              ? GridView.builder(
                  padding: EdgeInsets.all(10),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,  // Number of images per row
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: selectedImages.length,
                  itemBuilder: (context, index) {
                    bool isFavorite = favoriteIndices.contains(index);
                    return Stack(
                      children: [
                        Image.file(
                          selectedImages[index],
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                        ),
                        Positioned(
                          top: 5,
                          right: 5,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(
                                  isFavorite ? Icons.favorite : Icons.favorite_border,
                                  color: isFavorite ? Colors.red : Colors.white,
                                ),
                                onPressed: () => onToggleFavorite(index),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () => onDeleteImage(index),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                )
              : Center(child: Text('No images selected.')),
        ),
      ],
    );
  }
}

class FavoriteImagesPage extends StatelessWidget {
  final List<File> favoriteImages;

  FavoriteImagesPage({required this.favoriteImages});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favorite Images'),
      ),
      body: favoriteImages.isNotEmpty
          ? GridView.builder(
              padding: EdgeInsets.all(10),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,  // Number of images per row
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: favoriteImages.length,
              itemBuilder: (context, index) {
                return Image.file(
                  favoriteImages[index],
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                );
              },
            )
          : Center(child: Text('No favorite images selected.')),
    );
  }
}