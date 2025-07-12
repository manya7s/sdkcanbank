import 'package:flutter/material.dart';
import 'package:phishsafe_sdk/phishsafe_sdk.dart';
import 'package:phishsafe_sdk/route_aware_wrapper.dart';
import 'package:dummy_bank/observer.dart';

class ManageDepositsPage extends StatefulWidget {
  @override
  _ManageDepositsPageState createState() => _ManageDepositsPageState();
}

class _ManageDepositsPageState extends State<ManageDepositsPage> {
  final List<Map<String, dynamic>> _fixedDeposits = [
    {
      'id': '1',
      'amount': 100000.0,
      'principal': 100000.0,
      'rate': 6.5,
      'duration': 365,
      'startDate': DateTime.now().subtract(Duration(days: 30)),
      'type': 'Regular',
      'status': 'Active',
    },
    {
      'id': '2',
      'amount': 200000.0,
      'principal': 200000.0,
      'rate': 7.25,
      'duration': 180,
      'startDate': DateTime.now().subtract(Duration(days: 60)),
      'type': 'Tax Saver',
      'status': 'Active',
    },
  ];


  void _showPinPopup(BuildContext context, VoidCallback onSuccess) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => PinPopup(onComplete: (enteredPin) {
        Navigator.pop(context); // Close popup
        onSuccess();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Fixed Deposit broken successfully."),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context); // Go back to homepage
      }),
    );
  }

  String _formatCurrency(double amount) {
    return '₹${amount.toStringAsFixed(2).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
    )}';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return RouteAwareWrapper(
      screenName: 'ManageDepositsPage',
      observer: routeObserver,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Manage Fixed Deposits", style: TextStyle(color: Colors.white)),
          backgroundColor: Color(0xFF3B5EDF),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        body: ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: _fixedDeposits.length,
          itemBuilder: (context, index) {
            final fd = _fixedDeposits[index];
            final maturityDate = (fd['startDate'] as DateTime).add(Duration(days: fd['duration'] as int));
            final maturityAmount = (fd['principal'] as double) +
                ((fd['principal'] as double) *
                    (fd['rate'] as double) *
                    (fd['duration'] as int) /
                    36500);

            return Card(
              margin: EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("FD-${fd['id']}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        Chip(
                          label: Text(fd['status'].toString(), style: TextStyle(color: Colors.white)),
                          backgroundColor: fd['status'] == 'Active' ? Colors.green : Colors.orange,
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _buildLabelValue("Principal", _formatCurrency(fd['principal']))),
                        Expanded(child: _buildLabelValue("Rate", "${fd['rate']}%")),
                      ],
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _buildLabelValue("Start Date", _formatDate(fd['startDate']))),
                        Expanded(child: _buildLabelValue("Maturity Date", _formatDate(maturityDate))),
                      ],
                    ),
                    SizedBox(height: 16),
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Maturity Amount"),
                              Text(_formatCurrency(maturityAmount),
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                            ],
                          ),
                          if (fd['status'] == 'Active')
                            ElevatedButton(
                              onPressed: () {
                                _showPinPopup(context, () {
                                  setState(() {
                                    _fixedDeposits[index]['status'] = 'Broken';
                                  });
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red[50],
                                foregroundColor: Colors.red,
                              ),
                              child: Text("Break FD"),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
          child: Icon(Icons.add, color: Colors.white),
          backgroundColor: Color(0xFF3B5EDF),
          elevation: 4,
        ),
      ),
    );
  }

  Widget _buildLabelValue(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.grey)),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}

// Inline PIN Popup Widget (no separate import)
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
      setState(() => enteredDigits.add(val));
    }
  }

  void onDelete() {
    if (enteredDigits.isNotEmpty) {
      setState(() => enteredDigits.removeLast());
    }
  }

  void onSubmit() {
    final pin = enteredDigits.join();
    if (pin == "12345") {
      widget.onComplete(pin);
    } else {
      setState(() {
        errorText = "Incorrect PIN. Please try again.";
        enteredDigits.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final keys = ['1','2','3','4','5','6','7','8','9'];
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Enter PIN", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) => Container(
                    margin: EdgeInsets.symmetric(horizontal: 6),
                    width: 40,
                    height: 50,
                    decoration: BoxDecoration(
                      border: Border.all(color: Color(0xFF3B5EDF)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(index < enteredDigits.length ? '●' : '',
                          style: TextStyle(fontSize: 24, color: Color(0xFF3B5EDF))),
                    ),
                  )),
                ),
                if (errorText != null) ...[
                  SizedBox(height: 12),
                  Text(errorText!, style: TextStyle(color: Colors.red)),
                ],
                SizedBox(height: 16),
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
                    return _keyButton(text: key, onTap: () => onKeyTap(key));
                  },
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: _keyButton(
                      text: 'Submit',
                      backgroundColor: Color(0xFF3B5EDF),
                      textColor: Colors.white,
                      onTap: onSubmit,
                    )),
                    SizedBox(width: 8),
                    Expanded(child: _keyButton(text: '0', onTap: () => onKeyTap('0'))),
                    SizedBox(width: 8),
                    Expanded(child: _keyButton(icon: Icons.backspace_outlined, onTap: onDelete)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _keyButton({
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
}
