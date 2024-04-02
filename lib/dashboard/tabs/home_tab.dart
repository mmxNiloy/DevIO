import 'package:devio/dashboard/components/post_container.dart';
import 'package:flutter/material.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      child: Column(
        children: [
          PostContainer(hasPhoto: true),
          PostContainer(hasPhoto: false),
          PostContainer(hasPhoto: true),
          PostContainer(hasPhoto: true),
          PostContainer(hasPhoto: false),
        ],
      ),
    );
  }
}
