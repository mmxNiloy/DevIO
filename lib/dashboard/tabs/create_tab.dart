import 'package:devio/constants/db_constants.dart';
import 'package:devio/models/posts_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'dart:math';

class CreateTab extends StatefulWidget {
  const CreateTab({super.key});

  @override
  State<CreateTab> createState() => _CreateTabState();
}

class _CreateTabState extends State<CreateTab>
    with SingleTickerProviderStateMixin {
  final TextEditingController titleController = TextEditingController();
  List<File> _images = [];
  List<String> _imgRefs = [];
  String _title = '';
  String _content = "";
  bool isAIQuestion = false;
  bool isPublic = false;
  final GlobalKey<FormState> _fkPost = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    titleController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _fkPost,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
        child: Column(
          children: [
            TextFormField(
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Title cannot be empty.";
                }

                return null;
              },
              onChanged: (value) {
                setState(() {
                  _title = value;
                });
              },
              style: Theme.of(context).textTheme.headlineMedium,
              decoration: const InputDecoration(
                hintText: 'Title',
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(0, 8, 0, 0),
                child: TextFormField(
                  onChanged: (value) {
                    setState(() {
                      _content = value;
                    });
                  },
                  style: Theme.of(context).textTheme.bodyMedium,
                  decoration: const InputDecoration.collapsed(
                    hintText: "What's on your mind?",
                  ),
                ),
              ),
            ),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: _images.map((imgFile) {
                    return SizedBox(
                        height: 128, width: 128, child: Image.file(imgFile));
                  }).toList(),
                ),
              ),
            ),
            Row(
              children: [
                IconButton(onPressed: () {}, icon: const Icon(Icons.link)),
                IconButton(
                    onPressed: () {
                      handleImagePicker();
                    },
                    icon: const Icon(Icons.image)),
                const Expanded(
                  child: SizedBox(),
                ),
                OutlinedButton(
                    onPressed: _handlePost,
                    child: const Row(
                      children: [Icon(Icons.rocket_launch), Text('Post')],
                    ))
              ],
            ),
          ],
        ),
      ),
    );
  }

  String? validateTitle(String? value) {
    if (value == null || value.isEmpty) {
      return "Title cannot be empty.";
    }

    return null;
  }

  void onIsPublicSelectionChange(bool? value) {
    setState(() {
      isPublic = value!;
    });
  }

  Future<String> uploadImage(File img) async {
    final storageRef = FirebaseStorage.instance.ref();
    final fileRef =
        storageRef.child("images/${DateTime.now().millisecondsSinceEpoch}");
    await fileRef.putFile(img);
    String link = await fileRef.getDownloadURL();
    return link;
  }

  Future<void> _handlePost() async {
    if (!_fkPost.currentState!.validate()) {
      return;
    }
    User user = FirebaseAuth.instance.currentUser!;
    List<String> links = [];
    if (_images.isNotEmpty) {
      for (File img in _images) {
        links.add(await uploadImage(img));
      }
    }
    PostsModel model = PostsModel(
        title: _title,
        content: _content,
        ownerId: user.uid,
        timestamp: Timestamp.now(),
        upvotes: 0,
        downvotes: 0,
        imgRefs: links);
    final dbRef = FirebaseFirestore.instance;
    final collRef = dbRef.collection(PostsCollection.name);
    await collRef.add(model.toFirestore());
  }

  Future<void> handleImagePicker() async {
    try {
      XFile? img = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (img == null) return;

      File? imgFile = File(img.path);
      List<File> temp = _images;
      temp.add(imgFile);
      setState(() {
        _images = temp;
      });
    } on PlatformException catch (e) {
      debugPrint('Signup page > Image picker > ${e.message}');
      return;
    }
  }
}
