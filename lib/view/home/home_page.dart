import 'package:fitness_workout/common/colo_extension.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  final List<Map<String, String>> exercises = [
    {
      "title": "Bicep Curl",
      "time": "10 mins",
      "count": "32",
      "reps": "8",
    },
    {
      "title": "Lateral Raise",
      "time": "8 mins",
      "count": "28",
      "reps": "7",
    },
    {
      "title": "Shoulder Press",
      "time": "12 mins",
      "count": "36",
      "reps": "9",
    },
  ];

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: TColor.white,
      appBar: AppBar(
        backgroundColor: TColor.primaryColor2,
        title: const Text(
          "Fitness Reports",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Graph Section
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: TColor.primaryColor2.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Миний дасгалын явц",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: media.width * 0.5,
                    child: LineChart(
                      LineChartData(
                        lineBarsData: [
                          LineChartBarData(
                            isCurved: true,
                            color: TColor.primaryColor2,
                            barWidth: 4,
                            isStrokeCapRound: true,
                            belowBarData: BarAreaData(show: false),
                            spots: const [
                              FlSpot(1, 20),
                              FlSpot(2, 40),
                              FlSpot(3, 60),
                              FlSpot(4, 80),
                              FlSpot(5, 100),
                            ],
                          ),
                        ],
                        titlesData: FlTitlesData( 
                          leftTitles: AxisTitles(),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                switch (value.toInt()) {
                                  case 1:
                                    return const Text("Mon");
                                  case 2:
                                    return const Text("Tue");
                                  case 3:
                                    return const Text("Wed");
                                  case 4:
                                    return const Text("Thu");
                                  case 5:
                                    return const Text("Fri");
                                  default:
                                    return const Text("");
                                }
                              },
                            ),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        gridData: FlGridData(show: false),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Exercise Reports Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: const Text(
                "Exercise Reports",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: exercises.length,
              itemBuilder: (context, index) {
                final exercise = exercises[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: TColor.primaryColor2.withOpacity(0.2),
                      child: const Icon(Icons.fitness_center, color: Colors.black),
                    ),
                    title: Text(
                      exercise["title"]!,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      "Time: ${exercise["time"]}, Count: ${exercise["count"]}, Reps: ${exercise["reps"]}",
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}