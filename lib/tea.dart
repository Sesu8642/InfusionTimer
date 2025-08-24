// SPDX-License-Identifier: GPL-3.0-or-later
import 'package:infusion_timer/id_generator.dart';

class Tea {
  double id;
  String? name;
  int? rating;
  int? temperature;
  double? gPer100Ml;
  List<Infusion> infusions;
  String? subtitle;
  String? detailedNotes;

  Tea(this.id, this.name, this.temperature, this.gPer100Ml, this.infusions,
      this.subtitle, this.detailedNotes, this.rating);

  Tea.withGeneratedId(this.name, this.temperature, this.gPer100Ml,
      this.infusions, this.subtitle, this.rating)
      : id = IdGenerator.nextdouble();

  Tea.fromJson(Map<String, dynamic> json)
      : id = json.containsKey('id') ? json['id'] : IdGenerator.nextdouble(),
        name = json['name'],
        rating = json['rating'],
        temperature = json['temperature'],
        gPer100Ml = json['gPer100Ml'] is double
            ? json['gPer100Ml']
            : double.parse(json['gPer100Ml'].toString()),
        infusions = List<Infusion>.from(
            json['infusions']?.map((i) => Infusion.fromJson(i)) ??
                List.empty()),
        // subtitle used to be called notes
        subtitle = json['notes'] ?? json['subtitle'],
        detailedNotes = json['detailedNotes'];

  Map toJson() => {
        'id': id,
        'name': name,
        'rating': rating,
        'temperature': temperature,
        'gPer100Ml': gPer100Ml,
        'infusions': infusions,
        'subtitle': subtitle,
        'detailedNotes': detailedNotes
      };

  String toSharableString() => 'Name: $name'
      '${subtitle != null && subtitle!.isNotEmpty ? '\nSubtitle: $subtitle' : ''}'
      '${rating != null ? '\nRating: $rating/5' : ''}'
      '\nTemperature: $temperature°C'
      '\nAmount: $gPer100Ml g/100 ml'
      '\nInfusions: ${infusions.map((infusion) => "${infusion.duration}" "s").join(", ")}'
      '${detailedNotes != null && detailedNotes!.isNotEmpty ? '\nNotes: $detailedNotes' : ''}';

  validate() {
    if (name == null) {
      throw const FormatException("Tea has no name.");
    }
    if (rating != null && (rating! < 0 || rating! > 5)) {
      throw FormatException("Tea '$name' has an invalid rating.");
    }
    if (temperature == null) {
      throw FormatException("Tea '$name' has no brewing temperature.");
    }
    if (gPer100Ml == null) {
      throw FormatException("Tea '$name' has no tea amount.");
    }
    if (infusions.isEmpty) {
      throw FormatException("Tea '$name' has no infusions.");
    }
    for (var infusion in infusions) {
      if (infusion.duration.isNegative) {
        throw FormatException(
            "Tea '$name' has an infusion with invalid duration.");
      }
    }
    if (subtitle == null) {
      throw FormatException("Tea '$name' has no subtitle.");
    }
  }
}

class Infusion {
  int duration;

  Infusion(this.duration);

  Infusion.fromJson(Map<String, dynamic> json) : duration = json['duration'];

  Map toJson() => {'duration': duration};
}
