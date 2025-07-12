import 'package:flutter/material.dart';

class PinPopup extends StatefulWidget {
  final void Function(String) onComplete;

  const PinPopup({Key? key, required this.onComplete}) : super(key: key);

  @override
  State<PinPopup> createState() => _PinPopupState();
}

class _PinPopupState extends State<PinPopup> {
  List<String> enteredDigits = [];
  String? errorText;

  void onKeyTap(String val) {
    if (enteredDigits.length < 5) {
      setState(() {
        enteredDigits.add(val);
      });
    }
  }

  void onDelete() {
    if (enteredDigits.isNotEmpty) {
      setState(() {
        enteredDigits.removeLast();
      });
    }
  }

  void onSubmit() {
    final pin = enteredDigits.join();
    if (pin.length == 5 && pin == "12345") {
      widget.onComplete(pin);
    } else {
      setState(() {
        errorText = "Incorrect PIN. Please try again.";
        enteredDigits.clear();
      });
    }
  }

  Widget _buildKeyButton({
    String? text,
    IconData? icon,
    Color? backgroundColor,
    Color? textColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.grey[100],
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: icon != null
              ? Icon(icon, size: 20)
              : Text(
            text ?? '',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor ?? Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  Widget buildPinDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 6),
          width: 40,
          height: 50,
          decoration: BoxDecoration(
            border: Border.all(color: Color(0xFF3B5EDF)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              index < enteredDigits.length ? '●' : '',
              style: TextStyle(fontSize: 24, color: Color(0xFF3B5EDF)),
            ),
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
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: keys.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 1.2,
          ),
          itemBuilder: (context, index) {
            final key = keys[index];
            return _buildKeyButton(
              text: key,
              onTap: () => onKeyTap(key),
            );
          },
        ),
        SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildKeyButton(
                text: 'Submit',
                backgroundColor: Color(0xFF3B5EDF),
                textColor: Colors.white,
                onTap: onSubmit,
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: _buildKeyButton(
                text: '0',
                onTap: () => onKeyTap('0'),
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: _buildKeyButton(
                icon: Icons.backspace_outlined,
                onTap: onDelete,
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Center(
      child: Material(
        color: Colors.transparent,
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(20),
            margin: EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            constraints: BoxConstraints(
              maxHeight: screenHeight * 0.85,
              minHeight: 320,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Power off button at top-right
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,

                ),
                Text(
                  "Enter PIN",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                buildPinDots(),
                if (errorText != null) ...[
                  SizedBox(height: 12),
                  Text(
                    errorText!,
                    style: TextStyle(color: Colors.red, fontSize: 14),
                  ),
                ],
                SizedBox(height: 16),
                buildNumberPad(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
