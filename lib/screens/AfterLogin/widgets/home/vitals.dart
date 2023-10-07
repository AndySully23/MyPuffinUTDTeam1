import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:futurefit/db/functions/sensordata.dart';
import 'package:futurefit/screens/AfterLogin/widgets/home/widgets/air_pressure.dart';
import 'package:futurefit/screens/AfterLogin/widgets/home/widgets/ambient_temperature.dart';
import 'package:futurefit/screens/AfterLogin/widgets/home/widgets/gas.dart';
import 'package:futurefit/screens/AfterLogin/widgets/home/widgets/heartrate.dart';
import 'package:futurefit/screens/AfterLogin/widgets/home/widgets/humidity.dart';
import 'package:futurefit/screens/AfterLogin/widgets/home/widgets/oxygen_saturation.dart';
import 'package:futurefit/screens/AfterLogin/widgets/home/widgets/skin_temperature.dart';
import 'package:rxdart/rxdart.dart';

// Define a widget to display extended health data on the home screen
class HomeExtended extends StatefulWidget {
  const HomeExtended({Key? key}) : super(key: key);

  @override
  State<HomeExtended> createState() => _HomeExtendedState();
}

// Define the state for the HomeExtended widget
class _HomeExtendedState extends State<HomeExtended> {

  // Combine sensor data streams into a single stream of HealthData objects
  Stream<HealthData> get combinedHealthDataStream {
    return Rx.combineLatest7(
      getHeartRateStream(),
      getBloodOxygenStream(),
      getSkinTemperatureStream(),
      getHumidityStream(),
      getAmbientTemperatureStream(),
      getAirPressureStream(),
      getGasStream(),
      (heartRate, bloodOxygen, skinTemp, humidity, environmentalData, air_pressure, gas) =>
          HealthData(
            heartRate: heartRate,
            bloodOxygen: bloodOxygen,
            skinTemperature: skinTemp,
            humidity: humidity,
            environmentalData: environmentalData,
            airpressure: air_pressure,
            gas: gas,
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<HealthData>(
      stream: combinedHealthDataStream,
      builder: (BuildContext context, AsyncSnapshot<HealthData> snapshot) {
        if (snapshot.hasError) {
          print('Error: ${snapshot.error}');
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot == null) {
          return const Center(child: CircularProgressIndicator());
        }

        HealthData data = snapshot.data!;

        // Build a scrollable list of health data widgets
        return Expanded(
          child: Scrollbar(
            thickness: 0,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => HeartRateMonitor()),
                      );
                    },
                    child: _buildContainer(
                      color: const Color.fromARGB(50, 150, 0, 0),
                      icon: Icons.heart_broken_sharp,
                      label: 'Heart Rate',
                      value: '${data.heartRate}',
                      unit: ' bpm',
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => OxygenSaturation()),
                      );
                    },
                    child: _buildContainer(
                      color: const Color.fromARGB(50, 0, 150, 7),
                      icon: FontAwesomeIcons.lungs,
                      label: 'Blood Oxygen',
                      value: '${data.bloodOxygen}',
                      unit: ' %',
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Humidity()),
                      );
                    },
                    child: _buildContainer(
                      color: const Color.fromARGB(50, 100, 50, 0),
                      icon: Icons.water_drop,
                      label: 'Humidity',
                      value: '${data.humidity}',
                      unit: ' %',
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SkinTemperature()),
                      );
                    },
                    child: _buildContainer(
                      color: const Color.fromARGB(50, 150, 0, 0),
                      icon: FontAwesomeIcons.temperatureHalf,
                      label: 'Skin Temperature',
                      value: '${data.skinTemperature}',
                      unit: ' °C',
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AmbientTemperature()),
                      );
                    },
                    child: _buildContainer(
                      color: const Color.fromARGB(50, 0, 150, 7),
                      icon: Icons.sunny,
                      label: 'Ambient\nTemperature',
                      value: '${data.environmentalData}',
                      unit: ' °C',
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AirPressure()),
                      );
                    },
                    child: _buildContainer(
                      color: const Color.fromARGB(50, 100, 50, 0),
                      icon: FontAwesomeIcons.compress,
                      label: 'Air\nPressure',
                      value: '${data.airpressure}',
                      unit: ' hpa',
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Gas()),
                      );
                    },
                    child: _buildContainer(
                      color: const Color.fromARGB(50, 150, 0, 0),
                      icon: FontAwesomeIcons.atom,
                      label: 'Gas',
                      value: '${data.gas}',
                      unit: ' R',
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Helper method to build a container for displaying health data
  Widget _buildContainer({
    required Color color,
    required IconData icon,
    required String label,
    required String value,
    required String unit,
  }) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: const BorderRadius.all(Radius.circular(10)),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(30, 20, 30, 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: const Color.fromARGB(150, 0, 0, 0)),
              Text(label, style: const TextStyle(color: Color.fromARGB(150, 0, 0, 0), fontWeight: FontWeight.w500)),
              Row(
                children: [
                  Text(
                    value,
                    style: const TextStyle(color: Color.fromARGB(150, 0, 0, 0), fontSize: 38, fontWeight: FontWeight.w700),
                  ),
                  Text(
                    unit,
                    style: const TextStyle(color: Color.fromARGB(150, 0, 0, 0)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
