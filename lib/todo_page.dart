import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class TodoPage extends StatefulWidget {
  const TodoPage({super.key});

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  List<Map<String, dynamic>> _todoList = [];
  final TextEditingController _todoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTodoList();
  }

  Future<void> _loadTodoList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _todoList = (jsonDecode(prefs.getString("todos") ?? '[]') as List)
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    });
  }

  Future<void> _saveTodoList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("todos", jsonEncode(_todoList));
  }

  void _addTodo() {
    if (_todoController.text.isNotEmpty) {
      setState(() {
        _todoList.add({"title": _todoController.text, "isDone": false});
        _todoController.clear();
      });
      _saveTodoList();
    }
  }

  void _removeTodoAt(int index) {
    setState(() {
      _todoList.removeAt(index);
    });
    _saveTodoList();
  }

  void _editTodoAt(int index) {
    _todoController.text = _todoList[index]['title'];
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit To-Do'),
          content: TextField(
            controller: _todoController,
            decoration: const InputDecoration(hintText: 'Enter updated to-do'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _todoList[index]['title'] = _todoController.text;
                  _todoController.clear();
                });
                _saveTodoList();
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _toggleTodoStatus(int index) {
    setState(() {
      _todoList[index]['isDone'] = !_todoList[index]['isDone'];
    });
    _saveTodoList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: const Color.fromARGB(255, 8, 206, 224),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "To-Do List",
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _todoList.length.toString(),
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _todoController,
                        decoration: InputDecoration(
                          hintText: 'Enter a new to-do',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: _addTodo,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 15),
                      ),
                      child: const Icon(Icons.add, color: Color.fromARGB(255, 87, 36, 16)),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 25),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(20),
                      topLeft: Radius.circular(20),
                    ),
                  ),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                    itemCount: _todoList.length,
                    itemBuilder: (context, index) {
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        child: ListTile(
                          title: Text(
                            _todoList[index]['title'],
                            style: TextStyle(
                              decoration: _todoList[index]['isDone']
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                            ),
                          ),
                          leading: Checkbox(
                            value: _todoList[index]['isDone'],
                            onChanged: (value) {
                              _toggleTodoStatus(index);
                            },
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => _editTodoAt(index),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _removeTodoAt(index),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
