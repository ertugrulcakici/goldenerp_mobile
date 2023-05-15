class ListEqualityObject {
  List list;
  ListEqualityObject(this.list);

  @override
  bool operator ==(Object other) {
    if (other is List) {
      other = ListEqualityObject(other);
    }

    if (other is ListEqualityObject) {
      if (list.length != other.list.length) {
        return false;
      }

      for (var i = 0; i < list.length; i++) {
        var item1 = list[i];
        var item2 = other.list[i];

        if (item1 is List) {
          item1 = ListEqualityObject(item1);
        }

        if (item2 is List) {
          item2 = ListEqualityObject(item2);
        }

        if (list[i] != other.list[i]) {
          return false;
        }
      }

      return true;
    } else {
      return false;
    }
  }
}
