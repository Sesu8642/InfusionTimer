// SPDX-License-Identifier: GPL-3.0-or-later
import 'package:infusion_timer/id_generator.dart';

class Tea {
  double id;
  String name;
  int temperature;
  double gPer100Ml;
  List<Infusion> infusions;
  String notes;

  Tea(this.id, this.name, this.temperature, this.gPer100Ml, this.infusions,
      this.notes);

  Tea.withGeneratedId(
      this.name, this.temperature, this.gPer100Ml, this.infusions, this.notes)
      : this.id = IdGenerator.nextdouble();

  Tea.fromJson(Map<String, dynamic> json)
      : this.id =
            json.containsKey('id') ? json['id'] : IdGenerator.nextdouble(),
        this.name = json['name'],
        this.temperature = json['temperature'],
        this.gPer100Ml = json['gPer100Ml'] is double
            ? json['gPer100Ml']
            : double.parse(json['gPer100Ml'].toString()),
        this.infusions = List<Infusion>.from(
            json['infusions'].map((i) => Infusion.fromJson(i))),
        this.notes = json['notes'];

  Map toJson() => {
        'id': id,
        'name': name,
        'temperature': temperature,
        'gPer100Ml': gPer100Ml,
        'infusions': infusions,
        'notes': notes
      };
}

class Infusion {
  int duration;

  Infusion(this.duration);

  Infusion.fromJson(Map<String, dynamic> json) : duration = json['duration'];

  Map toJson() => {'duration': duration};
}
