// This is a preview post container, do not use
import 'dart:math';

import 'package:flutter/material.dart';

class PostContainer extends StatelessWidget {
  final bool hasPhoto;
  const PostContainer({super.key, required this.hasPhoto});

  @override
  Widget build(BuildContext context) {
    final gen = Random.secure();
    final n = gen.nextInt(10) + 1;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Community info
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(
                      'https://picsum.photos/seed/devio-avatar$n/64'
                  ),
                ),
                const SizedBox(width: 8,),
                const Text('Community Name', style: TextStyle(fontWeight: FontWeight.bold,),),
                const SizedBox(width: 16,),
                Text('${n}h'),
              ],
            ),

            Text('Lorem Ipsum Dolor Sit Amet', style: Theme.of(context).textTheme.headlineSmall,),
            renderImage(),
          ],
        ),
      ),
    );
  }

  Widget renderImage() {
    double dimen = 256.0;
    if(!hasPhoto) dimen = 0;
    final seed = Random.secure().nextInt(100);
    return Container(
      height: dimen,
      width: dimen,
      child: Image.network('https://picsum.photos/seed/devio$seed/${dimen.toInt()}'),
    );
  }
}
