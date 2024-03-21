import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:devio/constants/db_constants.dart';
import 'package:intl/intl.dart';

class PostVisibility {
  static const String POST_PUBLIC = 'public';
  static const String POST_PRIVATE = 'private';
}

class PostsModel {
  final String title;
  final String content;
  final Timestamp timestamp;
  final String ownerId;
  String? postID;
  final int upvotes;
  final int downvotes;
  List<String> imgRefs;

  PostsModel({
    required this.title,
    required this.content,
    required this.ownerId,
    required this.timestamp,
    required this.upvotes,
    required this.downvotes,
    required this.imgRefs,
    this.postID,
  });

  factory PostsModel.fromJson(Map<String, dynamic> json) {
    final List<String> links = [];
    final List<dynamic> imgRefResponses =
        json[PostsCollection.imgRefsKey] ?? [];
    for (dynamic link in imgRefResponses) {
      links.add(link.toString());
    }

    return PostsModel(
        title: json[PostsCollection.titleKey],
        content: json[PostsCollection.contentKey] ?? '',
        ownerId: json[PostsCollection.ownerIdKey],
        imgRefs: links,
        timestamp: json[PostsCollection.timestampKey],
        upvotes: json[PostsCollection.upVotesKey],
        downvotes: json[PostsCollection.downVotesKey]);
  }

  @override
  String toString() {
    return 'PostModel: {\n\ttitle: $title\n\tmessage: $content\n\townerId: $ownerId\n\ttimestamp: ${timestamp.toString()}\n\tvisibility: $imgRefs\n}';
  }

  Map<String, dynamic> toFirestore() {
    return {
      PostsCollection.titleKey: title,
      PostsCollection.contentKey: content,
      PostsCollection.timestampKey: timestamp,
      PostsCollection.ownerIdKey: ownerId,
      PostsCollection.imgRefsKey: imgRefs,
      PostsCollection.upVotesKey: upvotes,
      PostsCollection.downVotesKey: downvotes
    };
  }

  factory PostsModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot,
      SnapshotOptions? options) {
    final data = snapshot.data();
    return PostsModel.fromJson(data!);
  }

  String getStandardTime() {
    final dateFormat = DateFormat("dd-MM-yyyy hh:mm a");
    // TODO: Business logic must be implemented.
    return dateFormat.format(timestamp.toDate());
  }
}
