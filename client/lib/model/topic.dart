enum TopicRole {
  member,
  admin,
  owner;

  bool get isAdmin => this == admin;

  bool get isOwner => this == owner;

  bool get isMember => this == member;

  bool gt(TopicRole other) {
    return index > other.index;
  }

  bool ge(TopicRole other) {
    return index >= other.index;
  }

  bool eq(TopicRole other) {
    return index == other.index;
  }
}
