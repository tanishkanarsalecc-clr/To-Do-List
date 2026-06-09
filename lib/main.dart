import 'package:flutter/material.dart';

void main() {
  runApp(const TodoApp());
}

class TodoApp extends StatefulWidget {
  const TodoApp({super.key});

  @override
  State<TodoApp> createState() => _TodoAppState();
}

class _TodoAppState extends State<TodoApp> {
  bool isDark = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
      ),
      darkTheme: ThemeData.dark(useMaterial3: true),
      home: TodoPage(
        isDark: isDark,
        toggleTheme: () {
          setState(() {
            isDark = !isDark;
          });
        },
      ),
    );
  }
}

class TodoPage extends StatefulWidget {
  final bool isDark;
  final VoidCallback toggleTheme;

  const TodoPage({
    super.key,
    required this.isDark,
    required this.toggleTheme,
  });

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  final TextEditingController taskController =
  TextEditingController();

  final TextEditingController searchController =
  TextEditingController();

  List<Map<String, dynamic>> tasks = [];

  void addTask() {
    if (taskController.text.trim().isEmpty) return;

    setState(() {
      tasks.add({
        "title": taskController.text.trim(),
        "done": false,
        "favorite": false,
        "time": TimeOfDay.now().format(context),
      });
    });

    taskController.clear();
  }

  void deleteTask(int index) {
    setState(() {
      tasks.removeAt(index);
    });
  }

  void toggleTask(int index) {
    setState(() {
      tasks[index]["done"] =
      !tasks[index]["done"];
    });

    if (tasks[index]["done"]) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("🎉 Task Completed!"),
        ),
      );
    }
  }

  void toggleFavorite(int index) {
    setState(() {
      tasks[index]["favorite"] =
      !tasks[index]["favorite"];
    });
  }

  void clearCompleted() {
    setState(() {
      tasks.removeWhere(
            (task) => task["done"] == true,
      );
    });
  }

  String get motivation {
    int completed =
        tasks.where((t) => t["done"]).length;

    if (completed == 0) {
      return "🚀 Start your day!";
    } else if (completed < 3) {
      return "🔥 Keep going!";
    } else if (completed < 5) {
      return "💪 Great progress!";
    } else {
      return "🏆 Productivity Master!";
    }
  }

  @override
  Widget build(BuildContext context) {
    int completed =
        tasks.where((t) => t["done"]).length;

    int pending = tasks.length - completed;

    double progress =
    tasks.isEmpty ? 0 : completed / tasks.length;

    List<Map<String, dynamic>> filteredTasks =
    tasks.where((task) {
      return task["title"]
          .toLowerCase()
          .contains(
        searchController.text.toLowerCase(),
      );
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Smart To-Do"),
        actions: [
          IconButton(
            onPressed: widget.toggleTheme,
            icon: Icon(
              widget.isDark
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Text(
                      motivation,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    LinearProgressIndicator(
                      value: progress,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Total: ${tasks.length} | "
                          "Completed: $completed | "
                          "Pending: $pending",
                    ),
                  ],
                ),
              ),
            ),

            TextField(
              controller: searchController,
              decoration: const InputDecoration(
                hintText: "Search tasks...",
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (_) {
                setState(() {});
              },
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: taskController,
                    decoration:
                    const InputDecoration(
                      hintText: "Enter task",
                      border:
                      OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: addTask,
                  child: const Text("Add"),
                ),
              ],
            ),

            const SizedBox(height: 10),

            ElevatedButton.icon(
              onPressed: clearCompleted,
              icon: const Icon(Icons.cleaning_services),
              label:
              const Text("Clear Completed"),
            ),

            const SizedBox(height: 10),

            Expanded(
              child: filteredTasks.isEmpty
                  ? const Center(
                child:
                Text("No tasks found"),
              )
                  : ListView.builder(
                itemCount:
                filteredTasks.length,
                itemBuilder:
                    (context, index) {
                  final task =
                  filteredTasks[index];

                  int realIndex =
                  tasks.indexOf(task);

                  return Card(
                    child: ListTile(
                      leading: Checkbox(
                        value:
                        task["done"],
                        onChanged: (_) =>
                            toggleTask(
                                realIndex),
                      ),
                      title: Text(
                        task["title"],
                        style: TextStyle(
                          decoration:
                          task["done"]
                              ? TextDecoration
                              .lineThrough
                              : null,
                        ),
                      ),
                      subtitle: Text(
                        "Added: ${task["time"]}",
                      ),
                      trailing: Row(
                        mainAxisSize:
                        MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(
                              task["favorite"]
                                  ? Icons.star
                                  : Icons
                                  .star_border,
                              color: Colors
                                  .amber,
                            ),
                            onPressed: () =>
                                toggleFavorite(
                                    realIndex),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete,
                            ),
                            onPressed: () =>
                                deleteTask(
                                    realIndex),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
