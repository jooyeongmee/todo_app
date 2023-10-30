class TodoItem {
  String content;
  bool isDone;

  TodoItem({required this.content, required this.isDone});

  setContent(String content) {
    this.content = content;
  }

  setIsDone() {
    isDone = !isDone;
  }
}
