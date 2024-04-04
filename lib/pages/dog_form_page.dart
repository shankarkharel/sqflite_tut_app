import 'package:flutter/material.dart';

import '../common_widgets/age_slider.dart';
import '../common_widgets/breed_selector.dart';
import '../common_widgets/color_picker.dart';
import '../models/breed.dart';
import '../models/dog.dart';
import '../services/database_service.dart';

class DogFormPage extends StatefulWidget {
  const DogFormPage({super.key, this.dog});
  final Dog? dog;

  @override
  _DogFormPageState createState() => _DogFormPageState();
}

class _DogFormPageState extends State<DogFormPage> {
  final TextEditingController _nameController = TextEditingController();
  static final List<Color> _colors = [
    const Color(0xFF000000),
    const Color(0xFFFFFFFF),
    const Color(0xFF947867),
    const Color(0xFFC89234),
    const Color(0xFF862F07),
    const Color(0xFF2F1B15),
  ];
  static final List<Breed> _breeds = [];

  final DatabaseService _databaseService = DatabaseService();

  int _selectedAge = 0;
  int _selectedColor = 0;
  int _selectedBreed = 0;

  @override
  void initState() {
    super.initState();
    if (widget.dog != null) {
      _nameController.text = widget.dog!.name;
      _selectedAge = widget.dog!.age;
      _selectedColor = _colors.indexOf(widget.dog!.color);
    }
  }

  Future<List<Breed>> _getBreeds() async {
    final breeds = await _databaseService.breeds();
    if (_breeds.isEmpty) _breeds.addAll(breeds);
    if (widget.dog != null) {
      _selectedBreed = _breeds.indexWhere((e) => e.id == widget.dog!.breedId);
    }
    return _breeds;
  }

  Future<void> _onSave() async {
    final name = _nameController.text;
    final age = _selectedAge;
    final color = _colors[_selectedColor];
    final breed = _breeds[_selectedBreed];

    // Add save code here
    widget.dog == null
        ? await _databaseService.insertDog(
            Dog(name: name, age: age, color: color, breedId: breed.id!),
          )
        : await _databaseService.updateDog(
            Dog(
              id: widget.dog!.id,
              name: name,
              age: age,
              color: color,
              breedId: breed.id!,
            ),
          );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Dog Record'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter name of the dog here',
              ),
            ),
            const SizedBox(height: 16.0),
            // Age Slider
            AgeSlider(
              max: 30.0,
              selectedAge: _selectedAge.toDouble(),
              onChanged: (value) {
                setState(() {
                  _selectedAge = value.toInt();
                });
              },
            ),
            const SizedBox(height: 16.0),
            // Color Picker
            ColorPicker(
              colors: _colors,
              selectedIndex: _selectedColor,
              onChanged: (value) {
                setState(() {
                  _selectedColor = value;
                });
              },
            ),
            const SizedBox(height: 24.0),
            // Breed Selector
            FutureBuilder<List<Breed>>(
              future: _getBreeds(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Text("Loading breeds...");
                }
                return BreedSelector(
                  breeds: _breeds.map((e) => e.name).toList(),
                  selectedIndex: _selectedBreed,
                  onChanged: (value) {
                    setState(() {
                      _selectedBreed = value;
                    });
                  },
                );
              },
            ),
            const SizedBox(height: 24.0),
            SizedBox(
              height: 45.0,
              child: ElevatedButton(
                onPressed: _onSave,
                child: const Text(
                  'Save the Dog data',
                  style: TextStyle(
                    fontSize: 16.0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
