import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../components/home/friend_header.dart';
import '../components/home/friend_carousel.dart';
import '../components/home/friend_comments_section.dart';
import '../screens/comments_screen.dart';
import '../services/track_service.dart';
import '../components/user_header.dart';
import '../screens/profile_screen.dart';
import 'package:flutter/cupertino.dart';
import '../data/users_data.dart'; // para usuarios
import '../data/posts_data.dart'; // para posts
import '../screens/detail/friend_songs_details_screen.dart';
import '../utils/navigation_utils.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'dart:async';
import '../screens/search_friends_screen.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> with AutomaticKeepAliveClientMixin {
  List<List<Map<String, String>>> _topSongsList = [];
  bool _isLoading = true;
  bool _isFirstLoad = true;
  bool _isRefreshing = false;
  
  @override
  bool get wantKeepAlive => true;

  final ScrollController _scrollController = ScrollController();

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

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadTrackData() async {
    if (!mounted) return;
    
    if (_isFirstLoad) {
      setState(() {
        _isLoading = true;
      });
    } else {
      setState(() {
        _isRefreshing = true;
      });
    }

    final trackData = await TrackService.getPopularTracksList();
    
    if (!mounted) return;
    
    setState(() {
      _topSongsList = trackData;
      _isLoading = false;
      _isFirstLoad = false;
      _isRefreshing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    if (_isLoading && _isFirstLoad) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: RefreshIndicator(
        onRefresh: _loadTrackData,
        child: Stack(
          children: [
            CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverAppBar(
                  backgroundColor: Colors.black,
                  floating: true,
                  snap: true,
                  elevation: 0,
                  scrolledUnderElevation: 0,
                  flexibleSpace: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const SizedBox(width: 40),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset(
                                'assets/logo_final.png',
                                height: 40,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                "looped",
                                style: GoogleFonts.raleway(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(Icons.search, color: Colors.white, size: 28),
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (context) => const SearchFriendsScreen()),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) {
                      final post = postsData[i];
                      final user = usersData.firstWhere(
                        (u) => u['username'] == post['user'],
                        orElse: () => {},
                      );
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 0.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (user.isNotEmpty)
                              InkWell(
                                splashFactory: NoSplash.splashFactory,
                                highlightColor: Colors.transparent,
                                onTap: () => NavigationUtils.openProfileScreen(context, user),
                                child: UserHeader(
                                  username: user['username'],
                                  name: user['name'],
                                  verificado: user['verificado'],
                                  profilePic: user['profilePic'],
                                ),
                              ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: InkWell(
                                splashFactory: NoSplash.splashFactory,
                                highlightColor: Colors.transparent,
                                onTap: () => NavigationUtils.openSongsDetailScreen(
                                  context,
                                  songs: _topSongsList[i % _topSongsList.length],
                                  user: user,
                                ),
                                child: FriendCarousel(
                                  songs: _topSongsList[i % _topSongsList.length],
                                  description: post['description'],
                                  profilePicUrl: user['profilePic'],
                                  name: user['username'],
                                ),
                              ),
                            ),
                            InkWell(
                              splashFactory: NoSplash.splashFactory,
                              highlightColor: Colors.transparent,
                              onTap: () => NavigationUtils.openCommentsScreen(
                                context,
                                username: post['user'],
                                songs: _topSongsList[i % _topSongsList.length],
                                comments: List<Map<String, dynamic>>.from(post['comments']),
                              ),
                              child: FriendCommentsSection(
                                comments: List<Map<String, String>>.from(post['comments']),
                                username: post['user'],
                                songs: _topSongsList[i % _topSongsList.length],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    childCount: postsData.length,
                  ),
                ),
              ],
            ),
            if (_isRefreshing)
              const Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: LinearProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }
}