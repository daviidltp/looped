import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../components/home/friend_header.dart';
import '../components/home/friend_top_songs_row.dart';
import '../components/home/friend_comments_section.dart';
import '../screens/comments_screen.dart';
import '../services/track_service.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> with AutomaticKeepAliveClientMixin {
  List<List<Map<String, String>>> _topSongsList = [];
  bool _isLoading = true;
  bool _isFirstLoad = true;
  
  // Lista de amigos con nombres de usuario y comentarios
  final List<Map<String, dynamic>> _friends = [
    {
      'name': '@musiclover42',
      'profilePic': 'https://randomuser.me/api/portraits/men/32.jpg',
      'description': "Mis bucles favoritos de esta semana. ¡No puedo parar de escucharlos!",
      'comments': [
        {
          'username': 'beatmaster99',
          'profilePic': 'https://randomuser.me/api/portraits/men/45.jpg',
          'text': '¡Increíble selección! Me encanta especialmente la primera canción.',
          'time': '2h',
        },
        {
          'username': 'vinylcollector',
          'profilePic': 'https://randomuser.me/api/portraits/men/67.jpg',
          'text': '¿Has escuchado el último álbum de este artista?',
          'time': '1h',
        },
      ],
    },
    {
      'name': '@beatmaster99',
      'profilePic': 'https://randomuser.me/api/portraits/men/45.jpg',
      'description': "Perfecto para estudiar y concentrarse. Estas canciones me ayudan a mantener el foco.",
      'comments': [], // Sin comentarios
    },
    {
      'name': '@vinylcollector',
      'profilePic': 'https://randomuser.me/api/portraits/men/67.jpg',
      'description': "Vibes de verano para empezar el día con energía",
      'comments': [
        {
          'username': 'musiclover42',
          'profilePic': 'https://randomuser.me/api/portraits/men/32.jpg',
          'text': '¡Qué buenos gustos!',
          'time': '3h',
        },
      ],
    },
    {
      'name': '@rockstar2023',
      'profilePic': 'https://randomuser.me/api/portraits/men/89.jpg',
      'description': "Mi playlist definitiva para el gimnasio. ¡Estas canciones me dan el empujón que necesito!",
      'comments': [
        {
          'username': 'abepe1010',
          'profilePic': 'https://randomuser.me/api/portraits/men/8.jpg',
          'text': 'GUAU GUAU GUAU 🐶',
          'time': '5h',
        },
        {
          'username': 'davidltp',
          'profilePic': 'https://randomuser.me/api/portraits/men/3.jpg',
          'text': 'Abepe perro',
          'time': '5h',
        },
        {
          'username': 'jazzenthusiast',
          'profilePic': 'https://randomuser.me/api/portraits/men/12.jpg',
          'text': '¡Me encanta esta selección!',
          'time': '5h',
        },
        {
          'username': 'musiclover42',
          'profilePic': 'https://randomuser.me/api/portraits/men/32.jpg',
          'text': '¿Has escuchado su último single?',
          'time': '4h',
        },
        {
          'username': 'beatmaster99',
          'profilePic': 'https://randomuser.me/api/portraits/men/45.jpg',
          'text': '¡Increíble!',
          'time': '3h',
        },
      ],
    },
    {
      'name': '@jazzenthusiast',
      'profilePic': 'https://randomuser.me/api/portraits/men/12.jpg',
      'description': "Una selección de jazz contemporáneo que me tiene enganchado últimamente",
      'comments': [
        {
          'username': 'vinylcollector',
          'profilePic': 'https://randomuser.me/api/portraits/men/67.jpg',
          'text': '¡Qué buen gusto musical!',
          'time': '1h',
        },
      ],
    },
  ];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadTrackData();

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        systemNavigationBarColor: Color.fromARGB(255, 0, 0, 0),
        systemNavigationBarDividerColor: Color.fromARGB(255, 0, 0, 0),
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
  }

  Future<void> _loadTrackData() async {
    if (!mounted) return;
    
    if (_isFirstLoad) {
      setState(() {
        _isLoading = true;
      });
    }

    final trackData = await TrackService.getPopularTracksList();
    
    if (!mounted) return;
    
    setState(() {
      _topSongsList = trackData;
      _isLoading = false;
      _isFirstLoad = false;
    });
  }

  void _openCommentsScreen(BuildContext context, int index) {
    Navigator.of(context).push(
      CommentsScreen.route(
        username: _friends[index]['name'],
        profilePicUrl: _friends[index]['profilePic'],
        songs: _topSongsList[index % _topSongsList.length],
        comments: List<Map<String, dynamic>>.from(_friends[index]['comments']),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    if (_isLoading && _isFirstLoad) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadTrackData,
      child: ListView.builder(
        itemCount: _friends.length,
        itemBuilder: (context, i) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 0.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FriendHeader(
                profilePicUrl: _friends[i]['profilePic'],
                name: _friends[i]['name'],
              ),
              FriendTopSongsRow(
                songs: _topSongsList[i % _topSongsList.length],
                description: _friends[i]['description'],
                profilePicUrl: _friends[i]['profilePic'],
                name: _friends[i]['name'],
              ),
              FriendCommentsSection(
                comments: List<Map<String, String>>.from(_friends[i]['comments']),
                onCommentTap: () => _openCommentsScreen(context, i),
                profilePicUrl: _friends[i]['profilePic'],
                username: _friends[i]['name'],
              ),
            ],
          ),
        ),
      ),
    );
  }
}