class CopyWith<T> {
  CopyWith(this.value, {this.skipIfValueNull = false});
  final T value;
  final bool skipIfValueNull;
}
