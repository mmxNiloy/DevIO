import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:devio/constants/db_constants.dart';
import 'package:devio/dashboard/drawers/dashboard_drawer_main.dart';
import 'package:devio/dashboard/drawers/dashboard_drawer_profile.dart';
import 'package:devio/dashboard/tabs/chat_tab.dart';
import 'package:devio/dashboard/tabs/communities_tab.dart';
import 'package:devio/dashboard/tabs/create_tab.dart';
import 'package:devio/dashboard/tabs/home_tab.dart';
import 'package:devio/dashboard/tabs/notifications_tab.dart';
import 'package:devio/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int _navbarIndex = 0;
  final PageController _pageController = PageController(initialPage: 0);

  Stream<DocumentSnapshot<Map<String, dynamic>>> userInfoStream() {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return FirebaseFirestore.instance
        .collection(UsersCollection.collectionName)
        .doc(uid)
        .snapshots();
  }

  final List<NavigationDestination> _bottomNavItems = [
    const NavigationDestination(
      icon: Icon(Icons.home_outlined),
      selectedIcon: Icon(Icons.home),
      label: "Home",
    ),
    const NavigationDestination(
        icon: Icon(Icons.groups_outlined),
        selectedIcon: Icon(Icons.groups),
        label: 'Communities'),
    const NavigationDestination(
        icon: Icon(Icons.add_circle_outline),
        selectedIcon: Icon(Icons.add_circle),
        label: 'Create'),
    const NavigationDestination(
        icon: Icon(Icons.chat_outlined),
        selectedIcon: Icon(Icons.chat),
        label: 'Chat'),
    const NavigationDestination(
        icon: Icon(Icons.notifications_outlined),
        selectedIcon: Icon(Icons.notifications),
        label: 'Notifications'),
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        ///**AppBar*/
        appBar: AppBar(
          title: const Text('DevIO'),
          actions: [
            // Builder(
            //   builder: (context) => ElevatedButton(
            //     onPressed: () {
            //       Scaffold.of(context).openEndDrawer();
            //     },
            //     style: ElevatedButton.styleFrom(shape: const CircleBorder()),
            //     child: Image.network(src),
            //   ),
            // ),

            StreamBuilder(
                stream: userInfoStream(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    UserModel model =
                        UserModel.fromJson(snapshot.data!.data()!);
                    return ElevatedButton(
                      onPressed: () {
                        Scaffold.of(context).openEndDrawer();
                      },
                      style:
                          ElevatedButton.styleFrom(shape: const CircleBorder()),
                      child: CircleAvatar(
                        foregroundImage: NetworkImage(model.dpUrl!),
                        backgroundColor: Colors.purple,
                        child: Text(model.firstName.characters.first),
                      ),
                    );
                  }
                  return CircleAvatar(
                    backgroundColor: Colors.purple,
                  );
                })
          ],
        ),
        // Main drawer
        drawer: DashboardDrawerMain(),
        endDrawer: DashboardDrawerProfile(),
        bottomNavigationBar: NavigationBar(
          labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
          destinations: _bottomNavItems,
          selectedIndex: _navbarIndex,
          onDestinationSelected: handleNavbarChange,
        ),

        //**Body part Begins from here */
        body: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: const [
            HomeTab(),
            CommunitiesTab(),
            CreateTab(),
            ChatTab(),
            NotificationsTab()
          ],
        ),
      ),
    );
  }

  void handleNavbarChange(int value) {
    setState(() {
      _navbarIndex = value;
      _pageController.jumpToPage(value);
    });
  }
}

Widget buildPage(String text) => Center(
        child: Text(
      text,
      style: const TextStyle(fontSize: 28.0),
    ));
