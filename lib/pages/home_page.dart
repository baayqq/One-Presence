import 'package:flutter/material.dart';

class HomeSpage extends StatefulWidget {
  const HomeSpage({super.key});

  @override
  State<HomeSpage> createState() => _HomeSpageState();
}

class _HomeSpageState extends State<HomeSpage> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: MediaQuery.of(context).size.height * 0.3,
          child: Container(color: Color(0xff468585)),
        ),
        Positioned(
          top: MediaQuery.of(context).size.height * 0.3,
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(color: Colors.white),
        ),

        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(Icons.account_circle, size: 72),
                  SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Bayu Saputra', style: TextStyle(fontSize: 20)),
                      Text('1231233', style: TextStyle(fontSize: 16)),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 20),
              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: const Color(0x9fDEF9C4),
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.center,
                child: Row(
                  children: [
                    Column(children: [Text('0')]),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // List absensi
              Expanded(
                child: ListView(
                  children: List.generate(6, (index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Container(
                        height: 100,
                        decoration: BoxDecoration(
                          color: const Color(0x8f9CDBA6),
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
                              children: const [
                                Text('Check In'),
                                Text('07:50:00'),
                              ],
                            ),
                            const SizedBox(width: 52),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Text('Check Out'),
                                Text('17:50:00'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
