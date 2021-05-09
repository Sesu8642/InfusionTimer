class Tea {
  String name;
  int temperature;
  List<int> infusionsSeconds;
  String notes;

  Tea(this.name, this.temperature, this.infusionsSeconds, this.notes);

  Map toJson() => {
        'name': name,
        'temperature': temperature,
        'infusionsSeconds': infusionsSeconds,
        'notes': notes
      };
}
