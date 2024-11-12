import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class WeatherPage extends StatefulWidget {
  final String city;

  WeatherPage({required this.city, required String locationId});

  @override
  _WeatherPageState createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  String? weatherDescription;
  double? temperature;
  List? forecast; // List to hold forecast data

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
    final forecastUrl =
        'https://api.openweathermap.org/data/2.5/forecast?q=${widget.city}&appid=$apiKey&units=metric';

    try {
      // Fetch current weather data
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          weatherDescription = data['weather'][0]['description'];
          temperature = data['main']['temp'];
        });
      } else {
        throw Exception('Failed to load current weather');
      }

      // Fetch forecast data
      final forecastResponse = await http.get(Uri.parse(forecastUrl));
      if (forecastResponse.statusCode == 200) {
        final forecastData = json.decode(forecastResponse.body);
        setState(() {
          forecast =
              forecastData['list']; // Forecast data is in the 'list' field
        });
      } else {
        throw Exception('Failed to load forecast');
      }
    } catch (e) {
      print("Error fetching weather: $e");
    }
  }

  // Group forecast data by date
  Map<String, List> groupForecastByDate() {
    Map<String, List> groupedData = {};
    for (var forecastItem in forecast!) {
      final date = DateTime.parse(forecastItem['dt_txt']);
      final dateStr = '${date.year}-${date.month}-${date.day}';

      if (!groupedData.containsKey(dateStr)) {
        groupedData[dateStr] = [];
      }

      groupedData[dateStr]!.add(forecastItem);
    }
    return groupedData;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Weather in ${widget.city}",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: weatherDescription == null ||
                temperature == null ||
                forecast == null
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Display current weather
                    Text(
                      'Weather: ${weatherDescription}',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight:
                            FontWeight.w600, // Slightly bolder font weight
                        color: Colors.grey[800],
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Temperature: ${temperature?.toStringAsFixed(1)} °C',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange[600],
                      ),
                    ),
                    SizedBox(height: 24),
                    Text(
                      '5-Day Forecast:',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                    SizedBox(height: 16),
                    // Group forecast by date and display
                    ...groupForecastByDate().entries.map((entry) {
                      final dateStr = entry.key;
                      final dailyForecast = entry.value;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Date header
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Text(
                              '$dateStr',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.teal[600],
                              ),
                            ),
                          ),
                          // Display forecast details for each time of day
                          Column(
                            children: dailyForecast.map((forecastItem) {
                              final date =
                                  DateTime.parse(forecastItem['dt_txt']);
                              final time =
                                  '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
                              final temp = forecastItem['main']['temp'];
                              final description =
                                  forecastItem['weather'][0]['description'];

                              return Card(
                                margin: EdgeInsets.symmetric(vertical: 6),
                                color: Colors.teal[50],
                                child: ListTile(
                                  title: Text(
                                    '$time',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Text(
                                    '$description, ${temp.toStringAsFixed(1)} °C',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight:
                                          FontWeight.w500, // Slightly bolder
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      );
                    }).toList(),
                  ],
                ),
              ),
      ),
    );
  }
}
