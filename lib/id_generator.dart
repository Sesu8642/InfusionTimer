// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:math';

class IdGenerator {
  static final Random _random = Random();

  static double nextdouble() {
    // good enough for this
    return _random.nextDouble();
  }
}
