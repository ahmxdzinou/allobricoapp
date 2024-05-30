import 'package:allobricoapp/drawer_screens/aide_screen.dart';
import 'package:allobricoapp/drawer_screens/favorite_screen.dart';
import 'package:allobricoapp/drawer_screens/history_screen.dart';
import 'package:allobricoapp/drawer_screens/messages_screen.dart';
import 'package:allobricoapp/drawer_screens/profile_page.dart';
import 'package:allobricoapp/drawer_screens/request_screen.dart';
import 'package:allobricoapp/provider/auth_provider.dart';
import 'package:allobricoapp/screens/welcome_screen.dart';
import 'package:allobricoapp/widgets/list_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final ap =Provider.of<AuthProvider>(context, listen: false);
    return Drawer(
      child: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.white60,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                //header
                DrawerHeader(
                  child: Image.asset(
                    'assets/image1.png',
                    width: 100,
                  ),  
                ),
                MyListTile(
                  icon: Icons.person, 
                  text: 'MON PROFIL', 
                  onTap:() => Navigator.push(
                                context, 
                                MaterialPageRoute(
                                builder: (context) => const ProfilePage(),
                                ),
                              ),
                ),
                MyListTile(
                  icon: Icons.shopping_bag, 
                  text: 'MES DEMANDES', 
                  onTap:() => Navigator.push(
                                context, 
                                MaterialPageRoute(
                                builder: (context) => const DemandeScreen(),
                                ),
                              ),
                ),
                MyListTile(
                  icon: Icons.favorite, 
                  text: 'MES FAVORIS', 
                  onTap:() => Navigator.push(
                                context, 
                                MaterialPageRoute(
                                builder: (context) => const Favorites(),
                                ),
                              ),
                ),
                MyListTile(
                  icon: Icons.history, 
                  text: 'HISTORIQUE', 
                  onTap:() => Navigator.push(
                                context, 
                                MaterialPageRoute(
                                builder: (context) => const HistoryScreen(),
                                ),
                              ),
                ),
                MyListTile(
                  icon: Icons.message, 
                  text: 'MESSAGES', 
                  onTap:() => Navigator.push(
                                context, 
                                MaterialPageRoute(
                                builder: (context) => const MessagesScreen(),
                                ),
                              ),
                ),
                MyListTile(
                  icon: Icons.help, 
                  text: 'AIDE', 
                  onTap:() => Navigator.push(
                                context, 
                                MaterialPageRoute(
                                builder: (context) => const AideScreen(),
                                ),
                              ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 50.0),
              child: MyListTile(
                icon: Icons.logout, 
                text: 'DECONNECTER',
                onTap:() {
                  ap.userSignOut().then(
                    (value) => Navigator.push(
                      context, 
                      MaterialPageRoute(
                        builder: (context)=> const WelcomeScreen()
                        ),
                      ),
                    );
                },
              ),
            ),
          ],
        ),
      )
    );
  }
}
