extension ListExtensions<T> on List<T> {
  List<T> get copy => List.from(this);

  List<T> addConditionally(
      {required Function dataFunc,
      required bool condition,
      bool first = false}) {
    if (first) {
      if (condition) {
        insert(0, dataFunc());
      }
    } else {
      if (condition) {
        add(dataFunc());
      }
    }
    // if (condition) {
    //   add(dataFunc());
    // }
    return this;
  }
}
