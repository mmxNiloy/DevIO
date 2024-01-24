import 'package:flutter/material.dart';

class DashboardDrawerMain extends StatefulWidget {
  //const DashboardDrawerMain({super.key});

  @override
  State<StatefulWidget> createState() => _DashboardDrawerMainState();
}

class _DashboardDrawerMainState extends State<DashboardDrawerMain> {
  bool _isHNETOpen = false; // For "Happening Now" expansion tile state
  bool _isRVETOpen = false; // For "Recently Viewed" expansion tile state
  bool _isYCETOpen = false; // For "Your Communities" expansion tile state

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          ExpansionTile(
            title: const Text('Happening Now'),
            trailing: drawHNTrailing(),
            onExpansionChanged: handleHNETChange,
            children: const [
              Text("Item 1"),
              Text("Item 2"),
              Text("Item 3"),
            ],
          ),
          ExpansionTile(
            title: const Text('Recently Viewed'),
            trailing: drawRVTrailing(),
            onExpansionChanged: handleRVETChange,
            children: const [
              // TODO: Render recently viewed posts/communities here
              ListTile(title: Text("Item 1")),
              ListTile(title: Text("Item 2")),
            ],
          ),
          ExpansionTile(
            title: const Text('Your Communities'),
            trailing: drawYCETTrailing(),
            onExpansionChanged: handleYCETChange,
            children: const [
              Text('Item 1'),
              Text('Item 2'),
              Text('Item 3'),
              Text('Item 4'),
              Text('Item 5')
            ],
          )
        ],
      ),
    );
  }

  Widget drawRVTrailing() {
    if(_isRVETOpen) {
      return TextButton(
          onPressed: handleRVSeeAllBtn,
          child: const Text('See all')
      );
    }

    return const Icon(
        Icons.arrow_drop_down
    );
  }

  void handleRVSeeAllBtn() {
    // TODO: Handle see all button for recently viewed expansion tile
  }

  void handleRVETChange(bool expanded) {
    setState(() {
      _isRVETOpen = expanded;
    });
  }


  void handleHNETChange(bool value) {
    setState(() {
      _isHNETOpen = value;
    });
  }

  Widget drawHNTrailing() {
    return Icon(
        _isHNETOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down
    );
  }

  Widget drawYCETTrailing() {
    return Icon(
        _isYCETOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down
    );
  }

  void handleYCETChange(bool value) {
    setState(() {
      _isYCETOpen = value;
    });
  }
}