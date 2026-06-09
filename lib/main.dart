import 'dart:async';
import 'package:flutter/material.dart';

void main() {
  runApp(const StopwatchApp());
}

class StopwatchApp extends StatefulWidget {
  const StopwatchApp({super.key});

  @override
  State<StopwatchApp> createState() => _StopwatchAppState();
}

class _StopwatchAppState extends State<StopwatchApp> {
  bool isDark = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
      darkTheme: ThemeData.dark(useMaterial3: true),
      home: StopwatchScreen(
        isDark: isDark,
        onThemeChanged: () => setState(() => isDark = !isDark),
      ),
    );
  }
}

class StopwatchScreen extends StatefulWidget {
  final bool isDark;
  final VoidCallback onThemeChanged;

  const StopwatchScreen({
    super.key,
    required this.isDark,
    required this.onThemeChanged,
  });

  @override
  State<StopwatchScreen> createState() => _StopwatchScreenState();
}

class _StopwatchScreenState extends State<StopwatchScreen> {
  Timer? timer;
  int milliseconds = 0;
  bool isRunning = false;

  final List<int> laps = [];
  final List<String> activityLog = [];
  final List<String> achievements = [];

  int pauseCount = 0;
  static const int targetTime = 60000;

  void startStopwatch() {
    timer = Timer.periodic(const Duration(milliseconds: 10), (_) {
      setState(() {
        milliseconds += 10;
        checkAchievements();
      });
    });

    activityLog.insert(0, "▶ Started Stopwatch");

    setState(() => isRunning = true);
  }

  void pauseStopwatch() {
    timer?.cancel();
    pauseCount++;
    activityLog.insert(0, "⏸ Paused Stopwatch");

    setState(() => isRunning = false);
  }

  void resetStopwatch() {
    timer?.cancel();

    setState(() {
      milliseconds = 0;
      laps.clear();
      isRunning = false;
      pauseCount = 0;
      achievements.clear();
      activityLog.insert(0, "🔄 Reset Stopwatch");
    });
  }

  void addLap() {
    if (milliseconds <= 0) return;

    setState(() {
      laps.insert(0, milliseconds);
    });

    activityLog.insert(0, "🏁 Lap Recorded");
    checkAchievements();
  }

  void checkAchievements() {
    if (milliseconds >= 30000 &&
        !achievements.contains("🏅 Reached 30 Seconds")) {
      achievements.add("🏅 Reached 30 Seconds");
    }

    if (milliseconds >= 60000 &&
        !achievements.contains("🏆 Reached 1 Minute")) {
      achievements.add("🏆 Reached 1 Minute");
    }

    if (laps.length >= 5 && !achievements.contains("🚩 Recorded 5 Laps")) {
      achievements.add("🚩 Recorded 5 Laps");
    }
  }

  String getMotivation() {
    if (milliseconds < 10000) return "🚀 Great Start!";
    if (milliseconds < 30000) return "🔥 Keep Going!";
    if (milliseconds < 60000) return "💪 Amazing Focus!";
    if (milliseconds < 120000) return "⭐ Fantastic Work!";
    return "🏆 Champion Performance!";
  }

  String formatTime(int ms) {
    int hundredths = (ms ~/ 10) % 100;
    int seconds = (ms ~/ 1000) % 60;
    int minutes = (ms ~/ 60000) % 60;
    int hours = ms ~/ 3600000;

    return "${hours.toString().padLeft(2, '0')}:"
        "${minutes.toString().padLeft(2, '0')}:"
        "${seconds.toString().padLeft(2, '0')}:"
        "${hundredths.toString().padLeft(2, '0')}";
  }

  String getAverageLap() {
    if (laps.isEmpty) return "00:00:00:00";
    int total = laps.reduce((a, b) => a + b);
    return formatTime(total ~/ laps.length);
  }

  List<int> get rankedLaps {
    final sorted = List<int>.from(laps);
    sorted.sort();
    return sorted;
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Advanced Stopwatch"),
        actions: [
          IconButton(
            icon: Icon(
                widget.isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: widget.onThemeChanged,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Text(
              formatTime(milliseconds),
              style: const TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              getMotivation(),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            LinearProgressIndicator(
              value: (milliseconds / targetTime).clamp(0.0, 1.0),
            ),
            const SizedBox(height: 15),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Text("⏸ Pauses: $pauseCount"),
                    Text("🏁 Total Laps: ${laps.length}"),
                    Text("📈 Average Lap: ${getAverageLap()}"),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed:
                  isRunning ? pauseStopwatch : startStopwatch,
                  icon: Icon(
                      isRunning ? Icons.pause : Icons.play_arrow),
                  label: Text(isRunning ? "Pause" : "Start"),
                ),
                ElevatedButton.icon(
                  onPressed: addLap,
                  icon: const Icon(Icons.flag),
                  label: const Text("Lap"),
                ),
                ElevatedButton.icon(
                  onPressed: resetStopwatch,
                  icon: const Icon(Icons.refresh),
                  label: const Text("Reset"),
                ),
              ],
            ),
            Expanded(
              child: ListView(
                children: [
                  ExpansionTile(
                    title: const Text("🏆 Achievements"),
                    children: achievements.isEmpty
                        ? [const ListTile(title: Text("No achievements yet"))]
                        : achievements
                        .map((e) => ListTile(title: Text(e)))
                        .toList(),
                  ),
                  ExpansionTile(
                    title: const Text("📜 Activity Log"),
                    children: activityLog.isEmpty
                        ? [const ListTile(title: Text("No activity yet"))]
                        : activityLog
                        .map((e) => ListTile(title: Text(e)))
                        .toList(),
                  ),
                  const ListTile(
                    title: Text(
                      "🏁 Lap History",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  ...List.generate(laps.length, (index) {
                    final lap = laps[index];

                    String medal = "";

                    if (rankedLaps.isNotEmpty && lap == rankedLaps[0]) {
                      medal = "🥇";
                    } else if (rankedLaps.length > 1 &&
                        lap == rankedLaps[1]) {
                      medal = "🥈";
                    } else if (rankedLaps.length > 2 &&
                        lap == rankedLaps[2]) {
                      medal = "🥉";
                    }

                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text("${laps.length - index}"),
                        ),
                        title: Text(formatTime(lap)),
                        subtitle:
                        Text("Lap ${laps.length - index} $medal"),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
