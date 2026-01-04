extension IterableExtensions<E> on Iterable<E> {
  Iterable<T> mapIndexed<T>(T Function(int index, E item) f) sync* {
    var index = 0;
    for (var item in this) {
      yield f(index, item);
      index += 1;
    }
  }
}