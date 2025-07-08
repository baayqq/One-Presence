import 'package:flutter/material.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            children: List.generate(6, (index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  height: 100,
                  decoration: BoxDecoration(
                    color: const Color(0xff9CDBA6),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Container(
                          width: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: const Color(0xffDEF9C4),
                          ),
                          child: const Center(
                            child: Text(
                              '13\nJuli',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 28),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [Text('Check In'), Text('07:50:00')],
                      ),
                      const SizedBox(width: 52),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [Text('Check Out'), Text('17:50:00')],
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}
