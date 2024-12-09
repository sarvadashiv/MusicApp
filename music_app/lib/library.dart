import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LibraryScreen extends StatefulWidget {
  @override
  _LibraryScreenState createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  int _selectedIndex = 2;
  String? avatarUrl;
  List<dynamic> playlists = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAvatar();
    _fetchPlaylists();
  }

  Future<void> _loadAvatar() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      avatarUrl = prefs.getString('avatar');
    });
  }

  Future<void> _fetchPlaylists() async {
    try {
      final response = await http.get(Uri.parse('https://your-backend.com/api/playlists'));
      if (response.statusCode == 200) {
        setState(() {
          playlists = json.decode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load playlists');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error: $e');
    }
  }

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return;

    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/search');
        break;
      case 2:
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 29, 26, 57),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundImage: avatarUrl != null ? AssetImage(avatarUrl!) : null,
                    child: avatarUrl == null
                        ? Icon(Icons.person, size: 28, color: Colors.grey)
                        : null,
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'Your Library',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 243, 159, 89)),
                  ),
                  Spacer(),
                  IconButton(
                    icon: Icon(Icons.search, size: 28, color: Color.fromARGB(255, 233, 188, 185)),
                    onPressed: () {
                      // Search functionality
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.add, size: 28, color: Color.fromARGB(255, 233, 188, 185)),
                    onPressed: () {
                      // Add playlist functionality
                    },
                  ),
                ],
              ),
            ),
            Expanded(
                child: isLoading
                    ? const Center(
                  child: CircularProgressIndicator(
                    color: Colors.orange,
                  ),
                )
                    : playlists.isEmpty
                    ? const Center(
                  child: Text(
                    'No playlists available',
                    style: TextStyle(color: Colors.grey, fontSize: 18),
                  ),
                )
                    : ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: playlists.length,
                  itemBuilder: (context, index) {
                    final playlist = playlists[index];
                    return Card(
                      color: Color.fromARGB(255, 39, 37, 66),
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(playlist['image']),
                        ),
                        title: Text(
                          playlist['name'],
                          style: const TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          '${playlist['songCount']} songs',
                          style: const TextStyle(color: Colors.grey),
                        ),
                        onTap: () {
                          // Handle playlist tap
                        },
                      ),
                    );
                  },
                )
            ),
          ],
        ),
      ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Color.fromARGB(255, 233, 188, 185),
          selectedItemColor: Colors.black,
          unselectedItemColor: Color.fromARGB(255, 158, 106, 106),
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: 'Search',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.library_music),
              label: 'Library',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        )
    );
  }
}
