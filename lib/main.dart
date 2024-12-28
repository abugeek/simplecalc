import 'package:calculator/widgets/buttons.dart';
import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';

void main() => runApp(const CalculatorApp());

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
      ),
      home: const CalculatorHome(),
    );
  }
}

class CalculatorHome extends StatefulWidget {
  const CalculatorHome({super.key});

  @override
  State<CalculatorHome> createState() => _CalculatorHomeState();
}

class _CalculatorHomeState extends State<CalculatorHome> {
  String userInput = '';
  String answer = '0';
  String history = '';

  final List<String> buttons = [
    'C',
    '+/-',
    '%',
    'DEL',
    '7',
    '8',
    '9',
    '/',
    '4',
    '5',
    '6',
    'x',
    '1',
    '2',
    '3',
    '-',
    '0',
    '.',
    '=',
    '+',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 10,
              child: _buildDisplay(),
            ),
            Expanded(
              flex: 13,
              child: _buildKeypad(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDisplay() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            history,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
            textAlign: TextAlign.end,
          ),
          Text(
            userInput,
            style: const TextStyle(
              fontSize: 24,
              color: Colors.white70,
            ),
            textAlign: TextAlign.end,
          ),
          const SizedBox(height: 10),
          Text(
            answer,
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.end,
          ),
        ],
      ),
    );
  }

  Widget _buildKeypad() {
    return Container(
      padding: const EdgeInsets.all(12),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: buttons.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          childAspectRatio: 1.3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemBuilder: _buildButton,
      ),
    );
  }

  Widget _buildButton(BuildContext context, int index) {
    return CalculatorButton(
      text: buttons[index],
      onTap: () => _handleButtonPress(buttons[index]),
      color: _getButtonColor(index),
      textColor: _getTextColor(index),
    );
  }

  Color _getButtonColor(int index) {
    if (index == 0) return Colors.red.withOpacity(0.8);
    if (index == 18) return Theme.of(context).colorScheme.primary;
    if (isOperator(buttons[index]))
      return Theme.of(context).colorScheme.secondary;
    return Theme.of(context).colorScheme.surface;
  }

  Color _getTextColor(int index) {
    if (index == 0 || index == 18 || isOperator(buttons[index])) {
      return Colors.white;
    }
    return Theme.of(context).colorScheme.onSurface;
  }

  void _handleButtonPress(String button) {
    setState(() {
      switch (button) {
        case 'C':
          _clear();
        case 'DEL':
          _delete();
        case '+/-':
          _toggleSign();
        case '=':
          _calculate();
        default:
          if (isOperator(button) && userInput.isNotEmpty) {
            if (isOperator(userInput[userInput.length - 1])) {
              userInput = userInput.substring(0, userInput.length - 1);
            }
            if (answer != '0' && userInput.isEmpty) {
              userInput = answer + button;
            } else {
              userInput += button;
            }
          } else if (!isOperator(button)) {
            if (answer != '0' && userInput.isEmpty) {
              _clear();
            }
            userInput += button;
          }
      }
    });
  }

  void _clear() {
    userInput = '';
    answer = '0';
    history = '';
  }

  void _delete() {
    if (userInput.isNotEmpty) {
      userInput = userInput.substring(0, userInput.length - 1);
    }
  }

  void _toggleSign() {
    if (answer != '0') {
      answer = (double.parse(answer) * -1).toString();
    }
  }

  void _calculate() {
    try {
      String finalInput = userInput.replaceAll('x', '*');
      Parser p = Parser();
      Expression exp = p.parse(finalInput);
      ContextModel cm = ContextModel();
      double eval = exp.evaluate(EvaluationType.REAL, cm);

      history = userInput;
      answer = eval.toStringAsFixed(eval.truncateToDouble() == eval ? 0 : 2);
      userInput = '';
    } catch (e) {
      answer = 'Error';
    }
  }

  bool isOperator(String op) {
    return ['+', '-', 'x', '/', '='].contains(op);
  }
}
