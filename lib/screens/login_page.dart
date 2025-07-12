import 'package:flutter/material.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String enteredPin = '';

  void onKeyTap(String value) {
    if (enteredPin.length < 5) {
      setState(() {
        enteredPin += value;
      });
    }
  }

  void onDelete() {
    if (enteredPin.isNotEmpty) {
      setState(() {
        enteredPin = enteredPin.substring(0, enteredPin.length - 1);
      });
    }
  }

  void onLogin() {
    if (enteredPin == '12345') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomePage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Incorrect PIN. Try 12345.')),
      );
      setState(() {
        enteredPin = '';
      });
    }
  }

  Widget buildPinBox() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return AnimatedContainer(
          duration: Duration(milliseconds: 200),
          margin: EdgeInsets.symmetric(horizontal: 6),
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: index < enteredPin.length ? Color(0xFF3B5EDF) : Colors.grey[300],
          ),
        );
      }),
    );
  }

  Widget buildNumberPad() {
    final keys = [
      '1', '2', '3',
      '4', '5', '6',
      '7', '8', '9',
      '', '0', '⌫',
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: keys.length,
      padding: EdgeInsets.all(4),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 1.1,
      ),
      itemBuilder: (context, index) {
        final key = keys[index];
        if (key == '') return SizedBox();

        return InkWell(
          onTap: () {
            key == '⌫' ? onDelete() : onKeyTap(key);
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Center(
              child: key == '⌫'
                  ? Icon(Icons.backspace_outlined, size: 20, color: Colors.black54)
                  : Text(
                key,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Container(
            width: 300,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: Color(0xFF3B5EDF),
                  child: Text("ai", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
                SizedBox(height: 10),
                Text(
                  "Canara Bank",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF3B5EDF)),
                ),
                SizedBox(height: 4),
                Text("Enter your 5-digit PIN", style: TextStyle(color: Colors.black87)),
                SizedBox(height: 20),
                buildPinBox(),
                SizedBox(height: 24),
                buildNumberPad(),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: onLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF3B5EDF),
                    minimumSize: Size(double.infinity, 42),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text("Login", style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
                SizedBox(height: 10),
                Text("Demo PIN: 12345", style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
