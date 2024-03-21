class UsersCollection {
  static const String collectionName = 'users';
  static const String firstNameKey = 'first_name';
  static const String lastNameKey = 'last_name';
  static const String usernameKey = 'username';
  static const String uidKey = 'uid';
  static const String profilePicUriKey = 'profile_pic';
  static const String genderKey = 'gender';
  static const String dateOfBirthKey = 'date_of_birth';
}

class UsernamesCollection {
  static const String collectionName = 'usernames';
  static const String uidKey = 'uid';
}

class PostsCollection {
  static const String name = 'posts';

  static const String titleKey = 'title';
  static const String contentKey = 'content';
  static const String timestampKey = 'timestamp';
  static const String ownerIdKey = 'owner_id';
  static const String imgRefsKey = 'img_refs';
  static const String upVotesKey = 'upvotes';
  static const String downVotesKey = 'downvotes';

  // Preset or expected possible values
  static const String visibilityPublic = 'public';
  static const String visibilityPrivate = 'private';
}