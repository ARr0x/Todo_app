import 'package:flutter/material.dart';
import 'api_service.dart';
import 'models/todo_model.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ToDo App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.blue, // Fond bleu
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.blue, // Barre d'application en bleu
          titleTextStyle: TextStyle(color: Colors.white),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        textTheme: TextTheme(
          bodyMedium: TextStyle(color: Colors.white),
        ),
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
      ),
      home: const TodoListScreen(),
    );
  }
}

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({Key? key}) : super(key: key);

  @override
  _TodoListScreenState createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  final ApiService apiService = ApiService();
  List<Todo> todos = [];

  @override
  void initState() {
    super.initState();
    fetchTodos();
  }

  Future<void> fetchTodos() async {
    final response = await apiService.fetchTodos();
    setState(() {
      todos = List<Todo>.from(response.todos);
    });
  }

  Future<void> addTodo(String title) async {
    final newTodo = Todo(
      id: todos.isNotEmpty ? todos.last.id + 1 : 1,
      todo: title,
      completed: false,
      userId: 5,
    );

    setState(() {
      todos = List<Todo>.from(todos)..add(newTodo);
    });
  }

  Future<void> updateTodo(int index) async {
    final updatedTodo = todos[index].copyWith(completed: !todos[index].completed);

    setState(() {
      todos = List<Todo>.from(todos)..[index] = updatedTodo;
    });
  }

  Future<void> deleteTodo(int index) async {
    setState(() {
      todos = List<Todo>.from(todos)..removeAt(index);
    });
  }

  void showAddTodoDialog(BuildContext context) {
    TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Ajouter une tâche'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'Entrez le titre de la tâche'),
            style: TextStyle(color: Colors.black), // Texte en noir pour contraste
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Annuler', style: TextStyle(color: Colors.black)),
            ),
            TextButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  addTodo(controller.text);
                }
                Navigator.of(context).pop();
              },
              child: const Text('Ajouter', style: TextStyle(color: Colors.black)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ToDo List',
          style: TextStyle(
            fontSize: 24, // Taille du texte augmentée
            fontWeight: FontWeight.bold, // Texte en gras
          ),
        ),
      ),
      body: todos.isEmpty
          ? const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
          : ListView.builder(
              itemCount: todos.length,
              itemBuilder: (context, index) {
                final todo = todos[index];
                return ListTile(
                  title: Text(
                    todo.todo,
                    style: TextStyle(
                      color: Colors.white,
                      decoration: todo.completed ? TextDecoration.lineThrough : TextDecoration.none,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          todo.completed ? Icons.check_box : Icons.check_box_outline_blank,
                          color: Colors.white,
                        ),
                        onPressed: () => updateTodo(index),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.white),
                        onPressed: () => deleteTodo(index),
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showAddTodoDialog(context),
        backgroundColor: Colors.yellow,
        child: const Text(
          '+',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
