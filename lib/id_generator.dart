// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:math';

class IdGenerator {
  static Random _random = new Random();

  static double nextdouble() {
    // good enough for this
    return _random.nextDouble();
  }
}
