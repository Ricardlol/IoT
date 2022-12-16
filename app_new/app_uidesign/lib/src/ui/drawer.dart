import 'package:flutter/material.dart';
import '../api/models/user.dart';

class MobileDrawer extends StatefulWidget {
  const MobileDrawer({Key? key, required this.user}) : super(key: key);

  final User user;

  @override
  State<MobileDrawer> createState() => _DrawerState();
}

class _DrawerState extends State<MobileDrawer> {
  var drawerTextColor = TextStyle(
    color: Colors.grey[600],
  );

  var tilePadding = const EdgeInsets.only(left: 8.0, right: 8, top: 8);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.grey[300],
      elevation: 0,
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(widget.user.full_name),
            accountEmail: Text(widget.user.phone_number),
            currentAccountPicture: CircleAvatar(
              backgroundImage: NetworkImage(
                  widget.user.avatar_url),
            ),
          ),
          Padding(
            padding: tilePadding,
            child: ListTile(
              leading: const Icon(Icons.home),
              title: Text(
                'D A S H B O A R D',
                style: drawerTextColor,
              ),
            ),
          ),
          Padding(
            padding: tilePadding,
            child: ListTile(
              leading: const Icon(Icons.settings),
              title: Text(
                'S E T T I N G S',
                style: drawerTextColor,
              ),
            ),
          ),
          Padding(
            padding: tilePadding,
            child: ListTile(
              leading: const Icon(Icons.info),
              title: Text(
                'A B O U T',
                style: drawerTextColor,
              ),
            ),
          ),
          Padding(
            padding: tilePadding,
            child: ListTile(
              leading: const Icon(Icons.logout),
              title: Text(
                'L O G O U T',
                style: drawerTextColor,
              ),
            ),
          ),
        ],
      ),
    );
  }




}
