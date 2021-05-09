class Tea {
  String _name;
  int _temperature;
  List<int> _infusionsSeconds;
  String _notes;

  Tea(this._name, this._temperature, this._infusionsSeconds, this._notes);

  Map toJson() => {
        'name': _name,
        'temperature': _temperature,
        'infusionsSeconds': _infusionsSeconds,
        'notes': _notes
      };
}
