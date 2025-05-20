import 'package:flutter/material.dart';
import 'package:looped/screens/profile_screen.dart';
import '../services/auth_service.dart';
import 'package:flutter/cupertino.dart';
import '../components/user_header.dart';
import '../data/users_data.dart';
import '../utils/navigation_utils.dart';

class SearchFriendsScreen extends StatefulWidget {
  const SearchFriendsScreen({super.key});

  @override
  State<SearchFriendsScreen> createState() => _SearchFriendsScreenState();
}

class _SearchFriendsScreenState extends State<SearchFriendsScreen> with AutomaticKeepAliveClientMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  List<Map<String, dynamic>> _searchResults = [];
  bool _isLoading = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // Opcional: mostrar todos los usuarios al inicio
    // _searchResults = usersData;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  Future<void> _searchUsers(String query) async {
    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(milliseconds: 300)); // Simula delay

    setState(() {
      if (query.isEmpty) {
        _searchResults = [];
      } else {
        _searchResults = usersData
            .where((user) =>
                user['username'].toLowerCase().contains(query.toLowerCase()) ||
                user['name'].toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
      _isLoading = false;
    });
  }

  Future<void> _addFriend(String username) async {
    // TODO: Implement actual add friend API call
    setState(() {
      final userIndex = _searchResults.indexWhere((user) => user['username'] == username);
      if (userIndex != -1) {
        _searchResults[userIndex]['isFriend'] = true;
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 80,
        title: Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Icon(Icons.search, color: Colors.grey[600]),
                ),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Buscar usuarios...',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      border: InputBorder.none,
                    ),
                    onTapOutside: (event) {
                      _searchFocusNode.unfocus();
                    },
                    onChanged: _searchUsers,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
              ),
            )
          : _searchResults.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search_off,
                        size: 64,
                        color: Colors.grey[700],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No se encontraron resultados',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    final user = _searchResults[index];
                    return GestureDetector(
                      onTap: () => NavigationUtils.openProfileScreen(context, user),
                      child: UserHeader(
                        username: user['username'],
                        name: user['name'],
                        verificado: user['verificado'],
                        profilePic: user['profilePic'],
                      ),
                    );
                  },
                ),
    );
  }
}