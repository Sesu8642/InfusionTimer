// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/foundation.dart';

class AdditionalLicenseFactory {
  static Stream<LicenseEntry> create() async* {
    yield AdditionalLicense([
      'hand-bell-ringing-sound'
    ], [
      LicenseParagraph(""""Free Sounds Library"


Free Sound Effects Site.


Licence: License: Attribution 4.0 International (CC BY 4.0). You are allowed to use sound effects free of charge and royalty free in your multimedia projects for commercial or non-commercial purposes.


http://www.freesoundslibrary.com

https://www.freesoundslibrary.com/hand-bell-ringing-sound/
BY SPANAC

converted to wav by Sesu8642 using ffmpeg""", 0)
    ]);
  }
}

class AdditionalLicense extends LicenseEntry {
  final packages;
  final paragraphs;

  AdditionalLicense(this.packages, this.paragraphs);
}
