import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Enum to represent different views
enum ViewState {
  daily,
  weekly,
  monthly,
}

class OxygenSaturation extends StatefulWidget {
  @override
  _OxygenSaturationState createState() => _OxygenSaturationState();
}

class _OxygenSaturationState extends State<OxygenSaturation> with SingleTickerProviderStateMixin {
  // Animation controller for the icon animation
  late AnimationController _animationController;
  late Animation<double> _animation;
  // Stream to fetch oxygen saturation data
  late Stream<QuerySnapshot<Map<String, dynamic>>> _heartRateStream = Stream.empty();
  // Current view state
  ViewState _currentView = ViewState.daily;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller and animation
    _animationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
      reverseCurve: Curves.easeOut,
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _animationController.reverse();
        } else if (status == AnimationStatus.dismissed) {
          _animationController.forward();
        }
      });

    _animationController.forward();

    // Initial update of the oxygen saturation stream
    _updateHeartRateStream(_currentView);
  }

  // Function to update the oxygen saturation stream based on the selected view
  Future<void> _updateHeartRateStream(ViewState view) async {
    int hoursAgo;
    int limit;

    DateTime now = DateTime.now();
    Timestamp timeLimit;

    switch (view) {
      case ViewState.daily:
        hoursAgo = 24;
        limit = 24;
        timeLimit = Timestamp.fromDate(now.subtract(Duration(hours: hoursAgo)));
        break;
      case ViewState.weekly:
        hoursAgo = 7 * 24;
        limit = 7 * 24;
        timeLimit = Timestamp.fromDate(now.subtract(Duration(hours: hoursAgo)));
        break;
      case ViewState.monthly:
        hoursAgo = 30 * 24;
        limit = 30 * 24;
        timeLimit = Timestamp.fromDate(now.subtract(Duration(hours: hoursAgo)));
        break;
      default:
        hoursAgo = 24;
        limit = 24;
        timeLimit = Timestamp.fromDate(now.subtract(Duration(hours: hoursAgo)));
    }

    _heartRateStream = FirebaseFirestore.instance
        .collection('oxygen_saturation')
        .where('time', isGreaterThanOrEqualTo: timeLimit)
        .where('user', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
        .orderBy('time', descending: true)
        .limit(limit)
        .snapshots();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        title: const Padding(
          padding: EdgeInsets.fromLTRB(15, 10, 10, 10),
          child: Text(
            'Oxygen Saturation',
            style: TextStyle(
              color: Color.fromARGB(255, 13, 177, 173),
              fontSize: 28,
              fontWeight: FontWeight.w500
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Back', style: TextStyle(color: Colors.grey),),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Oxygen saturation display section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 30,),
                StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: _heartRateStream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    }
                    if (snapshot.hasError) {
                      print('ERROR ${snapshot.error}');
                      return const Center(child: Text('Something went wrong'));
                    }

                    if (!snapshot.hasData) {
                      return const Text(
                        '--',
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 60,
                          color: Colors.grey,
                        ),
                      );
                    }
                    try{
                      final latestReading = snapshot.data!.docs.first['reading'].toString();
                      return Column(
                        children: [
                          Text(
                            latestReading,
                            style: const TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 60,
                              color: Color.fromARGB(169, 9, 176, 206),
                            ),
                          ),
                        ],
                      );
                    } catch(e){
                      return const Text(
                        '--',
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 60,
                          color: Colors.grey,
                        ),
                      );
                    }
                  },
                ),
                AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    return Transform.scale(
                      scaleX: 1,
                      scaleY: 1,
                      child: const FaIcon(
                        FontAwesomeIcons.lungs,
                        color: Color.fromARGB(169, 9, 176, 206),
                        size: 80,
                      ),
                    );
                  },
                ),
                const SizedBox(width: 30,),
              ],
            ),
            const SizedBox(height: 20),
            // Metrics section (AVG, MIN, MAX)
            StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _heartRateStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                try{
                  final heartRateData = snapshot.data!.docs.map((doc) {
                    return doc['reading'].toDouble();
                  }).toList();
                  final double avgHeartRate = heartRateData.reduce((a, b) => a + b) / heartRateData.length;
                  final double minHeartRate = heartRateData.reduce((a, b) => a < b ? a : b);
                  final double maxHeartRate = heartRateData.reduce((a, b) => a > b ? a : b);
                  return Column(
                    children: [
                      // The AVG, MIN, MAX containers
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildMetricCard('AVG', avgHeartRate),
                          _buildMetricCard('MIN', minHeartRate),
                          _buildMetricCard('MAX', maxHeartRate),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                  );
                }catch(e){
                  return Column(
                    children: [
                      // The AVG, MIN, MAX containers
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildMetricCard('AVG', 0.0),
                          _buildMetricCard('MIN', 0.0),
                          _buildMetricCard('MAX', 0.0),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                  );
                }
              },
            ),
            const SizedBox(height: 20),
            // Periodical variations section
            Container(
              color: const Color.fromARGB(17, 13, 177, 174),
              height: 50,
              width: double.infinity,
              child: const Center(
                child: Text(
                  'Periodical Variations',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w400,
                    color: Color.fromARGB(255, 13, 177, 173),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Buttons for selecting view (Daily, Weekly, Monthly)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const SizedBox(width: 10),
                OutlinedButton(
                  onPressed: () {
                    _currentView = ViewState.daily;
                    _updateHeartRateStream(_currentView);
                  },
                  child: const Text('Daily', style: TextStyle(color: Color.fromARGB(255, 13, 177, 173)),),
                ),
                const SizedBox(width: 10),
                OutlinedButton(
                  onPressed: () {
                    _currentView = ViewState.weekly;
                    _updateHeartRateStream(_currentView);
                  },
                  child: const Text('Weekly', style: TextStyle(color: Color.fromARGB(255, 13, 177, 173)),),
                ),
                const SizedBox(width: 10),
                OutlinedButton(
                  onPressed: () {
                    _currentView = ViewState.monthly;
                    _updateHeartRateStream(_currentView);
                  },
                  child: const Text('Monthly', style: TextStyle(color: Color.fromARGB(255, 13, 177, 173)),),
                ),
                const SizedBox(width: 10),
              ],
            ),
            const SizedBox(height: 10),
            // Line chart to display oxygen saturation data
            StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _heartRateStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                try{
                  final heartRateData = snapshot.data!.docs.map((doc) {
                    return doc['reading'].toDouble();
                  }).toList();
                  return Container(
                    height: 200,
                    width: 300,
                    child: _buildLineChart(heartRateData.reversed.toList()),
                  );
                }catch(e){
                  return Container(
                    height: 200,
                    width: 300,
                    child: _buildLineChart([0]),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  // Widget to build the line chart
  Widget _buildLineChart(List<dynamic> data) {
    print(data);
    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: true),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: const Color.fromARGB(255, 160, 212, 255), width: 1),
        ),
        lineTouchData: LineTouchData(
          touchTooltipData: const LineTouchTooltipData(
            tooltipBgColor: Colors.blueAccent,
          ),
          touchCallback: (FlTouchEvent event, LineTouchResponse? touchResponse) {},
          handleBuiltInTouches: true,
          getTouchedSpotIndicator: (LineChartBarData barData, List<int> spotIndexes) {
            return spotIndexes.map((spotIndex) {
              return null;
            }).toList();
          },
        ),
        lineBarsData: [
          LineChartBarData(
            spots: data.asMap().entries.map((e) {
              return FlSpot(e.key.toDouble(), e.value.toDouble());
            }).toList(),
            isCurved: true,
            dotData: FlDotData(show: false),
            color: Color.fromARGB(255, 228, 26, 26),
            barWidth: 3,
            isStrokeCapRound: true,
            belowBarData: BarAreaData(show: false),
            aboveBarData: BarAreaData(show: false),
          )
        ],
      ),
    );
  }

  // Widget to build a metric card (AVG, MIN, MAX)
  Widget _buildMetricCard(String label, double value) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
        child: Column(
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 24,
                fontWeight: FontWeight.w500
              ),
            ),
            Text(
              value.toStringAsFixed(0),
              style: const TextStyle(
                color: Colors.black,
                fontSize: 34,
                fontWeight: FontWeight.w500
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
