
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const CalculatorApp());
}

class CalculatorApp extends StatefulWidget {
  const CalculatorApp({super.key});

  @override
  State<CalculatorApp> createState() => _CalculatorAppState();
}

class _CalculatorAppState extends State<CalculatorApp> {
  ThemeMode _themeMode = ThemeMode.light;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('isDark') ?? false;
    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    });
  }

  Future<void> _toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = _themeMode == ThemeMode.dark;
    setState(() {
      _themeMode = isDark ? ThemeMode.light : ThemeMode.dark;
    });
    await prefs.setBool('isDark', !isDark);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Calculator',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        primarySwatch: Colors.teal,
      ),
      home: CalculatorScreen(toggleTheme: _toggleTheme),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  final VoidCallback toggleTheme;
  const CalculatorScreen({super.key, required this.toggleTheme});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _expression = '';
  String _result = '';

  void _buttonPressed(String value) {
    setState(() {
      if (value == 'AC') {
        _expression = '';
        _result = '';
      } else if (value == '=') {
        _calculateResult();
      } else {
        if (_expression.isNotEmpty &&
            '+-×÷.'.contains(value) &&
            '+-×÷.'.contains(_expression[_expression.length - 1])) {
          return;
        }
        _expression += value;
      }
    });
  }

  void _calculateResult() {
    try {
      String finalExpression = _expression.replaceAll('×', '*').replaceAll('÷', '/');
      double eval = _evaluate(finalExpression);
      _result = eval.toStringAsFixed(eval.truncateToDouble() == eval ? 0 : 2);
    } catch (e) {
      _result = 'Error';
    }
  }

  double _evaluate(String expr) {
    final parsed = expr.replaceAll(' ', '');
    final exp = RegExp(r'([+\-*/])').allMatches(parsed);
    List<String> tokens = parsed.split(RegExp(r'([+\-*/])'));
    List<String> ops = exp.map((e) => e.group(0)!).toList();

    double result = double.parse(tokens[0]);
    for (int i = 0; i < ops.length; i++) {
      double next = double.parse(tokens[i + 1]);
      switch (ops[i]) {
        case '+':
          result += next;
          break;
        case '-':
          result -= next;
          break;
        case '*':
          result *= next;
          break;
        case '/':
          result /= next;
          break;
      }
    }
    return result;
  }

  Widget _buildButton(String text, {Color? color}) {
    return ElevatedButton(
      onPressed: () => _buttonPressed(text),
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: color ?? Colors.blueAccent,
        padding: const EdgeInsets.all(20),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final buttons = [
      ['AC', '÷', '×', '⌫'],
      ['7', '8', '9', '-'],
      ['4', '5', '6', '+'],
      ['1', '2', '3', '='],
      ['0', '.', '']
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Calculator'),
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: widget.toggleTheme,
          )
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(
            child: Container(
              alignment: Alignment.bottomRight,
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(_expression, style: const TextStyle(fontSize: 36)),
                  const SizedBox(height: 10),
                  Text(_result, style: const TextStyle(fontSize: 30, color: Colors.grey)),
                ],
              ),
            ),
          ),
          const Divider(height: 1),
          ...buttons.map((row) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: row.map((text) {
                if (text.isEmpty) return const SizedBox(width: 70);
                Color? color;
                if (text == 'AC') color = Colors.redAccent;
                if ('÷×-+'.contains(text)) color = Colors.orangeAccent;
                if (text == '=') color = Colors.green;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: _buildButton(text, color: color),
                  ),
                );
              }).toList(),
            );
          }),
        ],
      ),
    );
  }
}
