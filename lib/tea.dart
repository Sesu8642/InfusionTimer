class Tea {
  String name;
  int temperature;
  double gPer100Ml;
  List<Infusion> infusions;
  String notes;

  Tea(this.name, this.temperature, this.gPer100Ml, this.infusions, this.notes);

  Tea.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        temperature = json['temperature'],
        gPer100Ml = json['gPer100Ml'],
        infusions = List<Infusion>.from(
            json['infusions'].map((i) => Infusion.fromJson(i))),
        notes = json['notes'];

  Map toJson() => {
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
