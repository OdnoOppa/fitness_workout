import 'dart:io';

import 'package:fitness_workout/common/colo_extension.dart';
import 'package:fitness_workout/common_widget/round_button.dart';
import 'package:fitness_workout/view/workout_tracker/AnalysisResultScreen.dart';
import 'package:fitness_workout/view/workout_tracker/exercises_stpe_details.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../../common_widget/exercises_set_section.dart';

import 'package:fitness_workout/view/workout_tracker/VideoPlayerScreen.dart';

import 'package:permission_handler/permission_handler.dart';




class WorkoutDetailView extends StatefulWidget {
  final Map dObj;
  const WorkoutDetailView({super.key, required this.dObj});

  @override
  State<WorkoutDetailView> createState() => _WorkoutDetailViewState();
}

class _WorkoutDetailViewState extends State<WorkoutDetailView> {
  static const platform = MethodChannel('com.example.app/python');

  List latestArr = [
    {
      "image": "assets/img/Workout1.png",
      "title": "Fullbody Workout",
      "time": "Today, 03:00pm"
    },
    {
      "image": "assets/img/Workout2.png",
      "title": "Upperbody Workout",
      "time": "June 05, 02:00pm"
    },
  ];

  List youArr = [
    {"image": "assets/img/barbell.png", "title": "жин"},
  ];

  List exercisesArr = [
    {
      "set": [
        {"image": "assets/img/img_1.png", "title": "заавар", "value": "05:00"},
      ],
    }
  ];

  // Function to run the Python script
  void runPythonScript() async {
    try {
      final result = await platform.invokeMethod('runBicepCurl');
      print('Python script result: $result');
    } catch (e) {
      print('Error running Python script: $e');
    }
  }

  Future<void> requestPermission() async {
  PermissionStatus status = await Permission.storage.request();
  if (status.isGranted) {
    print("Storage permission granted");
  } else if (status.isDenied) {
    print("Storage permission denied");
  } else if (status.isPermanentlyDenied) {
    print("Storage permission permanently denied");
    // Direct the user to settings to manually grant permission
    openAppSettings();
  }
}


  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Container(
      decoration:
          BoxDecoration(gradient: LinearGradient(colors: TColor.primaryG)),
      child: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              backgroundColor: Colors.transparent,
              centerTitle: true,
              elevation: 0,
              leading: InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                  margin: const EdgeInsets.all(8),
                  height: 40,
                  width: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: TColor.lightGray,
                      borderRadius: BorderRadius.circular(10)),
                  child: Image.asset(
                    "assets/img/black_btn.png",
                    width: 15,
                    height: 15,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              actions: [
                InkWell(
                  onTap: () {},
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    height: 40,
                    width: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: TColor.lightGray,
                        borderRadius: BorderRadius.circular(10)),
                    child: Image.asset(
                      "assets/img/more_btn.png",
                      width: 15,
                      height: 15,
                      fit: BoxFit.contain,
                    ),
                  ),
                )
              ],
            ),
            SliverAppBar(
              backgroundColor: Colors.transparent,
              centerTitle: true,
              elevation: 0,
              leadingWidth: 0,
              leading: Container(),
              expandedHeight: media.width * 0.5,
              flexibleSpace: Align(
                alignment: Alignment.center,
                child: Image.asset(
                  "assets/img/bicep_detail.png",
                  width: media.width * 0.75,
                  height: media.width * 0.8,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ];
        },
        body: Container(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
              color: TColor.white,
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(25), topRight: Radius.circular(25))),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Stack(
              children: [
                SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      Container(
                        width: 50,
                        height: 4,
                        decoration: BoxDecoration(
                            color: TColor.gray.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(3)),
                      ),
                      SizedBox(
                        height: media.width * 0.05,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.dObj["title"]?.toString() ?? '',
                                  style: TextStyle(
                                    color: TColor.black,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                if (widget.dObj["дасгалууд"] != null && widget.dObj["time"] != null)
                                  Text(
                                    "${widget.dObj["дасгалууд"]} | ${widget.dObj["time"]}",
                                    style: TextStyle(
                                      color: TColor.gray,
                                      fontSize: 12,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: () {},
                            child: Image.asset(
                              "assets/img/fav.png",
                              width: 15,
                              height: 15,
                              fit: BoxFit.contain,
                            ),
                          )
                        ],
                      ),             
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "хэрэглэгдэх зүйлс",
                            style: TextStyle(
                                color: TColor.black,
                                fontSize: 16,
                                fontWeight: FontWeight.w700),
                          ),
                          TextButton(
                            onPressed: () {},
                            child: Text(
                              "${youArr.length} Items",
                              style:
                                  TextStyle(color: TColor.gray, fontSize: 12),
                            ),
                          )
                        ],
                      ),
                      SizedBox(
                        height: media.width * 0.5,
                        child: ListView.builder(
                            padding: EdgeInsets.zero,
                            scrollDirection: Axis.horizontal,
                            shrinkWrap: true,
                            itemCount: youArr.length,
                            itemBuilder: (context, index) {
                              var yObj = youArr[index] as Map? ?? {};
                              return Container(
                                  margin: const EdgeInsets.all(8),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        height: media.width * 0.35,
                                        width: media.width * 0.35,
                                        decoration: BoxDecoration(
                                            color: TColor.lightGray,
                                            borderRadius:
                                                BorderRadius.circular(15)),
                                        alignment: Alignment.center,
                                        child: Image.asset(
                                          yObj["image"].toString(),
                                          width: media.width * 0.12,
                                          height: media.width * 0.12,
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          yObj["title"].toString(),
                                          style: TextStyle(
                                              color: TColor.black,
                                              fontSize: 12),
                                        ),
                                      )
                                    ],
                                  ));
                            }),
                      ),
                      SizedBox(
                        height: media.width * 0.05,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Exercises",
                            style: TextStyle(
                                color: TColor.black,
                                fontSize: 16,
                                fontWeight: FontWeight.w700),
                          ),
                          TextButton(
                            onPressed: () {},
                            child: Text(
                              "${exercisesArr.length} Sets",
                              style:
                                  TextStyle(color: TColor.gray, fontSize: 12),
                            ),
                          )
                        ],
                      ),
                      ListView.builder(
                          padding: EdgeInsets.zero,
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: exercisesArr.length,
                          itemBuilder: (context, index) {
                            var sObj = exercisesArr[index] as Map? ?? {};
                            return ExercisesSetSection(
                              sObj: sObj,
                              onPressed: (obj) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ExercisesStepDetails(
                                      eObj: obj,
                                    ),
                                  ),
                                );
                              },
                            );
                          }),
                      SizedBox(
                        height: media.width * 0.1,
                      ),
                    ],
                  ),
                ),
                SafeArea(
  child: Column(
    mainAxisSize: MainAxisSize.max,
    mainAxisAlignment: MainAxisAlignment.end,
    children: [
      RoundButton(
        title: "Дасгал эхлэх",  // Button title
        // onPressed: () async {
        //   // Request permission before uploading video
        //   await requestPermission();  // Request storage permission

        //   // Check if permission is granted before proceeding
        //   PermissionStatus status = await Permission.storage.status;
        //   if (status.isGranted) {
        //     // Proceed with the video upload
        //     final videoPath = 'assets/videos/bicep_s.mov'; // Replace with actual video path
        //     final video = File(videoPath); // picked or recorded video
        //     final request = http.MultipartRequest('POST', Uri.parse("http://192.168.1.210:5000/analyze"));
        //     request.files.add(await http.MultipartFile.fromPath('video', video.path));

        //     final response = await request.send();

        //     if (response.statusCode == 200) {
        //       final tempDir = await getTemporaryDirectory();
        //       final processedVideoPath = '${tempDir.path}/processed_video.mp4';
        //       final bytes = await response.stream.toBytes();

        //       final file = File(processedVideoPath);
        //       await file.writeAsBytes(bytes);

        //       Navigator.push(
        //         context,
        //         MaterialPageRoute(
        //           builder: (_) => VideoPlayerScreen(videoPath: processedVideoPath),
        //         ),
        //       );
        //     } else {
        //       // Handle error
        //     }
        //   } else {
        //     // Handle the case where permission is denied
        //     print('Storage permission is required to upload the video.');
        //   }
        // },
        onPressed: () {
    // Simulate analysis by going to the result screen
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AnalysisResultScreen()),
    );
  },
      ),
    ],
  ),
)

              ],
            ),
          ),
        ),
      ),
    );
  }

  LineTouchData get lineTouchData1 {
    return LineTouchData(
      touchTooltipData: LineTouchTooltipData(
        getTooltipColor: (LineBarSpot touchedSpot) => Colors.blueAccent,
        // You can customize other properties here as needed
      ),
    );
  }

  List<LineChartBarData> get lineBarsData1 {
    return [lineChartBarData1_1, lineChartBarData1_2];
  }

  LineChartBarData get lineChartBarData1_1 {
    return LineChartBarData(
      spots: [FlSpot(0, 1), FlSpot(1, 3)],
      isCurved: true,
      color: Colors.red,
    );
  }

  LineChartBarData get lineChartBarData1_2 {
    return LineChartBarData(
      spots: [FlSpot(0, 2), FlSpot(1, 4)],
      isCurved: true,
      color: Colors.green,
    );
  }

  SideTitles get rightTitles {
    return SideTitles(
      showTitles: true,
      getTitlesWidget: (value, meta) {
        return Text('$value');
      },
    );
  }

  SideTitles get bottomTitles {
    return SideTitles(
      showTitles: true,
      getTitlesWidget: (value, meta) {
        return Text('$value');
      },
    );
  }
}