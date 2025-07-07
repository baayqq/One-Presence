import 'package:flutter/material.dart';

class HomeSpage extends StatefulWidget {
  const HomeSpage({super.key});

  @override
  State<HomeSpage> createState() => _HomeSpageState();
}

class _HomeSpageState extends State<HomeSpage> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(16)),
                child: Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(color: Color(0xff50B498)),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 200),
                  Text(
                    'Jangan Lupa Absen\nHari Ini',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 20),
          Expanded(
            child: ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Color(0xff9CDBA6),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Color(0xffDEF9C4),
                              ),
                              child: Center(
                                child: Text(
                                  '13',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 28,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 24),
                            Container(
                              child: Column(
                                children: [Text('Check In'), Text('07:50:00')],
                              ),
                            ),
                            SizedBox(width: 24),
                            Container(
                              child: Column(
                                children: [Text('Check Out'), Text('17:50:00')],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.white70,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(color: Colors.white),
                              child: Text('13'),
                            ),
                            SizedBox(width: 24),
                            Container(
                              child: Column(
                                children: [Text('Check In'), Text('07:50:00')],
                              ),
                            ),
                            SizedBox(width: 24),
                            Container(
                              child: Column(
                                children: [Text('Check Out'), Text('17:50:00')],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.white70,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(color: Colors.white),
                              child: Text('13'),
                            ),
                            SizedBox(width: 24),
                            Container(
                              child: Column(
                                children: [Text('Check In'), Text('07:50:00')],
                              ),
                            ),
                            SizedBox(width: 24),
                            Container(
                              child: Column(
                                children: [Text('Check Out'), Text('17:50:00')],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.white70,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(color: Colors.white),
                              child: Text('13'),
                            ),
                            SizedBox(width: 24),
                            Container(
                              child: Column(
                                children: [Text('Check In'), Text('07:50:00')],
                              ),
                            ),
                            SizedBox(width: 24),
                            Container(
                              child: Column(
                                children: [Text('Check Out'), Text('17:50:00')],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.white70,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(color: Colors.white),
                              child: Text('13'),
                            ),
                            SizedBox(width: 24),
                            Container(
                              child: Column(
                                children: [Text('Check In'), Text('07:50:00')],
                              ),
                            ),
                            SizedBox(width: 24),
                            Container(
                              child: Column(
                                children: [Text('Check Out'), Text('17:50:00')],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.white70,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(color: Colors.white),
                              child: Text('13'),
                            ),
                            SizedBox(width: 24),
                            Container(
                              child: Column(
                                children: [Text('Check In'), Text('07:50:00')],
                              ),
                            ),
                            SizedBox(width: 24),
                            Container(
                              child: Column(
                                children: [Text('Check Out'), Text('17:50:00')],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.white70,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(color: Colors.white),
                              child: Text('13'),
                            ),
                            SizedBox(width: 24),
                            Container(
                              child: Column(
                                children: [Text('Check In'), Text('07:50:00')],
                              ),
                            ),
                            SizedBox(width: 24),
                            Container(
                              child: Column(
                                children: [Text('Check Out'), Text('17:50:00')],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
