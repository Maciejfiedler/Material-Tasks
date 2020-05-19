class Task {
  int id;
  String title;
  bool complete;

  Task({
    this.id,
    this.title,
    this.complete,
  });

  Task.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        title = map['title'],
        complete = map['complete'] == 1;

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    map['id'] = id;
    map['title'] = title;
    map['complete'] = complete ? 1 : 0;
    return map;
  }
}
