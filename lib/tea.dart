class Tea {
  String name;
  int temperature;
  double gPer100Ml;
  List<Infusion> infusions;
  String notes;

  Tea(this.name, this.temperature, this.gPer100Ml, this.infusions, this.notes);

  Map toJson() => {
        'name': name,
        'temperature': temperature,
        'gPer100Ml': gPer100Ml,
        'infusionsSeconds': infusions,
        'notes': notes
      };
}

class Infusion {
  int duration;

  Infusion(this.duration);

  Map toJson() => {'duration': duration};
}
