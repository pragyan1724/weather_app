import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; //for jason
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoder/geocoder.dart';
void main() => runApp(WeatherApp());
class WeatherApp extends StatefulWidget {
  @override
  _WeatherAppState createState() => _WeatherAppState();
}
class _WeatherAppState extends State<WeatherApp> {
  int temperature = 0;
  String location = 'New Delhi';
  int woeid = 28743736;
  Position _currentPosition;
  String _currentAddress;
  String searchApiUrl = 'https://www.metaweather.com/api/location/search/?query=';
  String locationApiUrl = 'https://www.metaweather.com/api/location/';
  void api_data(String input) async {                                           // lets the mains program run while this function runs separately , once completed main is notified
    var searchResult = await http.get(Uri.parse(searchApiUrl + input));         // await, iske pehle tk pura program synchronously run karta hai... this makes the program wait until completed.
    var result = json.decode(searchResult.body)[0];                             // decodes data from net
    setState(() {        // assigns values to the variable
      location = result["title"];
      woeid = result["woeid"];
    });}
  void Location() async {
    var locationResult = await http.get(Uri.parse(locationApiUrl + woeid.toString())); //uri.parse...data type
    var result = json.decode(locationResult.body);                                     // storing required data
    var conweather = result["consolidated_weather"];                                   // extracting required data from result.
    var data = conweather[0];
    setState(() {
      temperature = data["the_temp"].round();
    });}
  void Input_data(String input)
  {
    api_data(input);
    Location();
  }
  _getCurrentLocation() {
    Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((Position position) {
      setState(() {
        _currentPosition = position;
      });
      _getAddressFromLatLng();
    }).catchError((e) {
      print(e);
    });
  }
  _getAddressFromLatLng() async {
    try {
      List<Placemark> p = await placemarkFromCoordinates(
          _currentPosition.latitude, _currentPosition.longitude);
      Placemark place = p[0];
      setState(() {
        _currentAddress = "${place.locality}, ${place.postalCode}, ${place.country}";
      });
      Input_data(place.locality);
      print(place.locality);
    } catch (e) {
      print(e);
    }
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('image/rain.jpeg'),
            fit: BoxFit.cover,
          ),
        ),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Center(
                      child: Text(
                        temperature.toString() + ' °C',
                        style: TextStyle(
                            color: Colors.white, fontSize: 70.0,fontWeight: FontWeight.bold,),
                      ),
                    ),
                    Center(
                      child: Text(
                        location,
                        style: TextStyle(
                            color: Colors.white, fontSize: 30.0,fontWeight: FontWeight.bold,),
                      ),
                    ),
                  ],
                ),
                   Row(
                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                     children: <Widget>[
                    Container(
                      width:300,
                      child: TextField(
                        onSubmitted: (String input) {
                          Input_data(input);
                        },
                        style:
                        TextStyle(color: Colors.white, fontSize: 25.0),
                        decoration: InputDecoration(
                          hintText: 'Search location...',
                          hintStyle: TextStyle(
                              color: Colors.white, fontSize: 24.0),
                          prefixIcon:
                          Icon(Icons.search, color: Colors.white),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: ( ){
                        Location();
                        },
                      child: Icon(Icons.refresh, color: Colors.black, size: 30,),
                    ),
                       GestureDetector(
                         onTap: ( ){
                           _getCurrentLocation();
                         },
                         child: Icon(Icons.home, color: Colors.black, size: 30),),
                  ],
                ),
                ],
                ),
            ),
      ),
    );
  }
}
