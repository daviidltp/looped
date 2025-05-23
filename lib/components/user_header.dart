import 'package:flutter/material.dart';

class UserHeader extends StatelessWidget {
  final String username;
  final String name;
  final bool verificado;
  final String profilePic;

  const UserHeader({
    super.key,
    required this.username,
    required this.name,
    required this.verificado,
    required this.profilePic,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 24,
            backgroundImage: NetworkImage(profilePic),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (verificado) ...[
                      const SizedBox(width: 4),
                      const Icon(Icons.verified, color: Colors.blue, size: 18),
                    ],
                  ],
                ),
                Text(
                  username,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          // Container(
          //   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          //   decoration: BoxDecoration(
          //     border: Border.all(color: Colors.white24),
          //     borderRadius: BorderRadius.circular(4),
          //   ),
          //   child: Row(
          //     mainAxisSize: MainAxisSize.min,
          //     children: [
          //       Icon(
          //         Icons.loop,
          //         size: 12,
          //         color: Colors.white70,
          //       ),
          //       const SizedBox(width: 4),
          //       Text(
          //         'Siguiendo',
          //         style: TextStyle(
          //           color: Colors.white70,
          //           fontSize: 10,
          //           fontWeight: FontWeight.w500,
          //           letterSpacing: 1,
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
        ],
      ),
    );
  }
} 