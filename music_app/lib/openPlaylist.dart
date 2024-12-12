import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class OpenPlaylist extends StatefulWidget {
  final String playlistName;
  final String playlistDescription;
  final List<dynamic> songs;

  OpenPlaylist({
    required this.playlistName,
    required this.playlistDescription,
    required this.songs,
  });

  @override
  _OpenPlaylistState createState() => _OpenPlaylistState();
}

class _OpenPlaylistState extends State<OpenPlaylist> {
  int _selectedIndex = 2;

  void _onItemTapped(int index) {
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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 29, 26, 57),
              Color.fromARGB(255, 29, 26, 57),
              Color.fromARGB(255, 29, 26, 57),
              Color.fromARGB(255, 0, 0, 0),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            AppBar(
              backgroundColor: Colors.transparent,
              title: Text(
                widget.playlistName,
                style: const TextStyle(
                  fontFamily: 'KumbhSans',
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 243, 159, 89),
                ),
              ),
              centerTitle: true,
              elevation: 0,
              iconTheme: const IconThemeData(color: Color.fromARGB(255, 233, 188, 185)),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.playlistDescription.isNotEmpty
                          ? widget.playlistDescription
                          : 'No description available',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                        fontFamily: 'KumbhSans',
                      ),
                    ),
                    const SizedBox(height: 10),
                    widget.songs.isEmpty
                        ? const Center(
                      child: Text(
                        'No songs in this playlist',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 18,
                          fontFamily: 'KumbhSans',
                        ),
                      ),
                    )
                        : Expanded(
                      child: ListView.builder(
                        itemCount: widget.songs.length,
                        itemBuilder: (context, index) {
                          final song = widget.songs[index];
                          return Dismissible(
                            key: Key(song['id'].toString()),
                            direction: DismissDirection.endToStart,
                            onDismissed: (direction) async {
                              final songId = song['id'];
                              final playlistId = widget.playlistName;

                              final response = await http.delete(
                                Uri.parse('https://task-4-0pfy.onrender.com/remove-song'),
                                headers: {
                                  'Content-Type': 'application/json',
                                },
                                body: jsonEncode({
                                  'SongId': songId,
                                  'PlaylistId': playlistId,
                                }),
                              );

                              if (response.statusCode == 200) {
                                setState(() {
                                  widget.songs.removeAt(index);
                                });

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('${song['title'] ?? 'Song'} removed successfully'),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Failed to remove ${song['title'] ?? 'Song'}'),
                                  ),
                                );
                              }
                            },
                            background: Container(
                              color: Colors.red,
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: const Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                            ),
                            child: Card(
                              color: Colors.transparent,
                              elevation: 0,
                              margin: const EdgeInsets.symmetric(vertical: 1.0),
                              child: ListTile(
                                leading: Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: NetworkImage(song['image']),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  song['title'] ?? 'Unknown Song',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'KumbhSans',
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                subtitle: Text(
                                  song['artist'] ?? 'Unknown Artist',
                                  style: const TextStyle(
                                    color: Color.fromARGB(255, 243, 159, 89),
                                    fontFamily: 'KumbhSans',
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                trailing: Text(
                                  _formatDuration(song['duration']),
                                  style: const TextStyle(
                                    color: Color.fromARGB(255, 233, 188, 185),
                                    fontFamily: 'KumbhSans',
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                onTap: () {
                                  /*print('Playing song: ${song['title']}')*/;
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Color.fromARGB(255, 233, 188, 185),
        selectedItemColor: Color.fromARGB(255, 0, 0, 0),
        unselectedItemColor: Color.fromARGB(255, 158, 106, 106),
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
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
      ),
    );
  }

  String _formatDuration(dynamic duration) {
    if (duration is int) {
      final minutes = duration ~/ 60;
      final seconds = duration % 60;
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else if (duration is String) {
      return duration;
    } else {
      return '0:00';
    }
  }
}