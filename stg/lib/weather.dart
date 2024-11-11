import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class WeatherPage extends StatefulWidget {
  final String city;

  WeatherPage({required this.city});

  @override
  _WeatherPageState createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  String? weatherDescription;
  double? temperature;

  @override
  void initState() {
    super.initState();
    fetchWeather();
  }

  // Fetch weather data from OpenWeatherMap API
  Future<void> fetchWeather() async {
    final apiKey =
        '83f625e84be068cb115600d8a9b1c98f'; // Replace with your OpenWeatherMap API key
    final url =
        'https://api.openweathermap.org/data/2.5/weather?q=${widget.city}&appid=$apiKey&units=metric';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          weatherDescription = data['weather'][0]['description'];
          temperature = data['main']['temp'];
        });
      } else {
        throw Exception('Failed to load weather');
      }
    } catch (e) {
      print("Error fetching weather: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Weather in ${widget.city}"),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: weatherDescription == null || temperature == null
            ? Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'City: ${widget.city}',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Weather: $weatherDescription',
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Temperature: ${temperature?.toStringAsFixed(1)} °C',
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
      ),
    );
  }
}
