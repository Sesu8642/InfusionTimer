import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String TEA_VESSEL_SIZE_SAVE_KEY = "tea_vessel_size";

class PreferencesPage extends StatefulWidget {
  PreferencesPage({Key key}) : super(key: key);

  @override
  _PreferencesPageState createState() => _PreferencesPageState();
}

class _PreferencesPageState extends State<PreferencesPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _vesselSizeController = TextEditingController();

  int _teaVesselSizeMl = 100;

  void _savePreferences() async {
    var prefs = await SharedPreferences.getInstance();
    prefs.setInt(TEA_VESSEL_SIZE_SAVE_KEY, _teaVesselSizeMl);
  }

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((prefs) {
      setState(() {
        var savedTeaVesselSizeMl = prefs.getInt(TEA_VESSEL_SIZE_SAVE_KEY);
        if (savedTeaVesselSizeMl != null) {
          _teaVesselSizeMl = savedTeaVesselSizeMl;
        }
        _vesselSizeController.value =
            TextEditingValue(text: _teaVesselSizeMl.toString());
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Preferences")),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  "Size of your tea brewing vessel in ml",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
                TextFormField(
                  controller: _vesselSizeController,
                  decoration: InputDecoration(icon: Icon(Icons.free_breakfast)),
                  keyboardType: TextInputType.phone,
                  maxLength: 5,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp('[0-9]')),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Enter a value";
                    } else {
                      return null;
                    }
                  },
                  onChanged: (value) {
                    if (_formKey.currentState.validate()) {
                      _teaVesselSizeMl = int.parse(value);
                      _savePreferences();
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
