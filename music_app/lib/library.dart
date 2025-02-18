import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'openPlaylist.dart';

class LibraryScreen extends StatefulWidget {
  final VoidCallback onNavigateToSearch;
  const LibraryScreen({super.key, required this.onNavigateToSearch});

  @override
  _LibraryScreenState createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
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
      final response = await http.get(Uri.parse('https://task-4-0pfy.onrender.com/all'));
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        //print(data);
        setState(() {
          playlists = data;
          isLoading = false;
        });
        // for (var playlist in playlists) {
        //   String name = playlist['name'] ?? 'Unknown Playlist';
        //   int songCount = (playlist['songs'] as List).length;
        //   print('Playlist: $name, Number of Songs: $songCount');
        // }
      } else {
        throw Exception('Failed to load playlists');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      //print('Error: $e');
    }
  }

  Future<void> _deletePlaylist(String playlistId) async {
    try {
      final response = await http.delete(
        Uri.parse('https://task-4-0pfy.onrender.com/playlist/$playlistId'),
      );

      if (response.statusCode == 200) {
        setState(() {
          playlists.removeWhere((playlist) => playlist['id'] == playlistId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Playlist deleted successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete playlist')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
  }


  void _showDeleteConfirmationDialog(String playlistId, String playlistName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color.fromARGB(255, 29, 26, 57),
          title: const Text(
            'Delete Playlist',
            style: TextStyle(color: Color.fromARGB(255, 243, 159, 89)),
          ),
          content: Text(
            'Are you sure you want to delete the playlist "$playlistName"?',
            style: const TextStyle(color: Colors.grey),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel', style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Close the dialog
                await _deletePlaylist(playlistId);
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: Color.fromARGB(255, 233, 188, 185)),
              ),
            ),
          ],
        );
      },
    );
  }


  void _showCreatePlaylistDialog() {
    final TextEditingController playlistNameController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color.fromARGB(255, 29, 26, 57),
          title: const Text('Create New Playlist',style: TextStyle(color: Color.fromARGB(255, 243, 159, 89)),),
          content: TextField(
            controller: playlistNameController,
            decoration: const InputDecoration(hintText: 'Enter playlist name', suffixStyle: TextStyle(color: Color.fromARGB(255, 233, 188, 185))),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel', style: TextStyle(color: Colors.red, fontSize: 16)),
            ),
            TextButton(
              onPressed: () async {
                String playlistName = playlistNameController.text.trim();

                if (playlistName.isNotEmpty) {
                  final response = await http.post(
                    Uri.parse('https://task-4-0pfy.onrender.com/createOrFind'),
                    headers: {"Content-Type": "application/json"},
                    body: json.encode({
                      'name': playlistName,
                    }),
                  );

                  if (response.statusCode == 200) {
                    _fetchPlaylists();
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Playlist "$playlistName" created!')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Failed to create playlist')),
                    );
                  }
                }
              },
              child: const Text('Create',style: TextStyle(color: Color.fromARGB(255, 233, 188, 185))),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 29, 26, 57),
      body: SafeArea(
        child: Container(
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
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 25,
                      backgroundImage: avatarUrl != null ? AssetImage(avatarUrl!) : null,
                      child: avatarUrl == null
                          ? const Icon(Icons.person, size: 28, color: Colors.grey)
                          : null,
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      'Your Library',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 243, 159, 89)),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.search, size: 28, color: Color.fromARGB(255, 233, 188, 185)),
                      onPressed: widget.onNavigateToSearch,
                    ),
                    IconButton(
                      icon: const Icon(Icons.add, size: 28, color: Color.fromARGB(255, 233, 188, 185)),
                      onPressed: _showCreatePlaylistDialog,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),
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
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    itemCount: playlists.length,
                    itemBuilder: (context, index) {
                      final playlist = playlists[index];
                      int songCount = (playlist['songs'] as List).length;
                      return Card(
                        color: Colors.transparent,
                        elevation: 0,
                        margin: const EdgeInsets.symmetric(vertical: 2.0),
                        child: GestureDetector(
                          onLongPress: () {
                            _showDeleteConfirmationDialog(playlist['id'], playlist['name']);
                          },
                          child: ListTile(
                            leading: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                image: playlist['image'] != null
                                    ? DecorationImage(
                                  image: NetworkImage(playlist['image']),
                                  fit: BoxFit.cover,
                                )
                                    : null,
                                color: Colors.grey,
                              ),
                              child: playlist['image'] == null
                                  ? const Icon(Icons.music_note, color: Colors.white)
                                  : null,
                            ),
                            title: Text(
                              playlist['name'] ?? 'Unknown Playlist',
                              style: const TextStyle(
                                color: Colors.white,
                                fontFamily: 'KumbhSans',
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            subtitle: Text(
                              '$songCount song(s)',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontFamily: 'KumbhSans',
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => OpenPlaylist(
                                    playlistName: playlist['name'] ?? 'Unknown Playlist',
                                    playlistDescription: playlist['description'] ?? '',
                                    songs: playlist['songs'] ?? [],
                                  ),
                                ),
                              );
                            },
                          ),
                        )
                      );
                    },
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
