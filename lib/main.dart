import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:todo_app/create.dart';
import 'package:todo_app/firebase_options.dart';
import 'package:todo_app/model.dart';
import 'package:todo_app/update.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // main 함수에서 async 사용하기 위함
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('todo').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text('Something went wrong');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return Text("Loading");
            }
            final documents = snapshot.data?.docs ?? []; // 문서들 가져오기

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.1),
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
                    Text("전체: ${documents.length}"),
                    Text(
                      "진행 중: ${documents.where((doc) => doc.get('isDone') == false).length}",
                      style: TextStyle(
                          color: Colors.red[600], fontWeight: FontWeight.w500),
                    ),
                    Text(
                        "완료: ${documents.where((doc) => doc.get('isDone') == true).length}"),
                  ],
                ),
                const Divider(thickness: 1),
                Container(
                  constraints:
                      const BoxConstraints(maxHeight: 400, minHeight: 400),
                  child: documents.isNotEmpty
                      ? ListView.builder(
                          padding: const EdgeInsets.all(0),
                          shrinkWrap: true,
                          itemCount: documents.length,
                          itemBuilder: (context, index) {
                            final doc = documents[index];
                            String content = doc.get('content');
                            bool isDone = doc.get('isDone');
                            return _buildTodoItem(
                                TodoItem(content: content, isDone: isDone),
                                doc.id);
                          },
                        )
                      : const Center(child: Text('No items')),
                ),
                const SizedBox(height: 50),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      final String todo = await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const Create()));
                      if (todo.trim().isEmpty) return;
                      TodoItem todoItem =
                          TodoItem(content: todo, isDone: false);
                      await FirebaseFirestore.instance.collection('todo').add({
                        'content': todoItem.content, // 하고싶은 일
                        'isDone': false, // 완료 여부
                      });
                    },
                    child: const Text("추가"),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.1),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildTodoItem(TodoItem todoItem, String docId) {
    return Row(
      children: [
        Checkbox(
            value: todoItem.isDone,
            onChanged: (value) async {
              await FirebaseFirestore.instance
                  .collection('todo')
                  .doc(docId)
                  .update({'isDone': value});
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
            setState(() async {
              await FirebaseFirestore.instance
                  .collection('todo')
                  .doc(docId)
                  .update({'content': todo});
            });
          },
        ),
        const SizedBox(width: 6),
        InkWell(
          onTap: () async {
            await FirebaseFirestore.instance
                .collection('todo')
                .doc(docId)
                .delete();
          },
          child: const Icon(Icons.delete_outline),
        ),
      ],
    );
  }
}
