ellipsize
=========

Truncates and adds ellipses to multiline text that overflows its container.

Usage
-----

```dart
import 'dart:html';
import 'package:ellipsize/ellipsize.dart';

main() {
  var container = query("#hasLotsOfText");
  new Ellipsize(container);
}
```
