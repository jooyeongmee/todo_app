import 'package:flutter/material.dart';
import 'package:todo_app/create.dart';
import 'package:todo_app/model.dart';
import 'package:todo_app/update.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // 더미 데이터
  List<TodoItem> todoList = [
    TodoItem(content: "111", isDone: false),
    TodoItem(content: "111", isDone: true),
    TodoItem(content: "111", isDone: true),
    TodoItem(content: "111", isDone: false),
    TodoItem(content: "111", isDone: true)
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.2),
            const Text(
              "오늘의 todo",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text("전체: ${todoList.length}"),
                Text(
                  "진행 중: ${todoList.where((element) => element.isDone == false).length}",
                  style: TextStyle(
                      color: Colors.red[600], fontWeight: FontWeight.w500),
                ),
                Text(
                    "완료: ${todoList.where((element) => element.isDone == true).length}"),
              ],
            ),
            const Divider(thickness: 1),
            ListView.builder(
              padding: const EdgeInsets.all(0),
              shrinkWrap: true,
              itemCount: todoList.length,
              itemBuilder: (context, index) {
                final TodoItem todoItem = todoList[index];
                return _buildTodoItem(todoItem);
              },
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final String todo = await Navigator.push(context,
                      MaterialPageRoute(builder: (context) => const Create()));
                  if (todo.trim().isEmpty) return;
                  setState(() {
                    todoList.add(TodoItem(content: todo, isDone: false));
                  });
                },
                child: const Text("추가"),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.2),
          ],
        ),
      ),
    );
  }

  Widget _buildTodoItem(TodoItem todoItem) {
    return Row(
      children: [
        Checkbox(
            value: todoItem.isDone,
            onChanged: (value) {
              setState(() {
                todoItem.setIsDone();
              });
            }),
        const SizedBox(width: 12),
        Expanded(
            child: Text(
          todoItem.content,
          style: const TextStyle(fontSize: 16),
        )),
        const SizedBox(width: 10),
        InkWell(
          child: const Icon(Icons.edit),
          onTap: () async {
            final String todo = await Navigator.push(context,
                MaterialPageRoute(builder: (context) => const Update()));
            if (todo.trim().isEmpty) return;
            setState(() {
              todoItem.setContent(todo);
            });
          },
        ),
        const SizedBox(width: 6),
        InkWell(
          child: const Icon(Icons.delete_outline),
          onTap: () {
            setState(() {
              todoList.removeWhere((element) => element == todoItem);
            });
          },
        ),
      ],
    );
  }
}
