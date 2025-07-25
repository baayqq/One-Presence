import 'package:flutter/material.dart';
import 'package:onepresence/pages/in_navbot/home_page.dart';
import 'package:onepresence/pages/in_navbot/profile.dart';
import 'package:onepresence/pages/in_navbot/rekappage.dart';

class HomeBottom extends StatefulWidget {
  const HomeBottom({super.key});

  @override
  State<HomeBottom> createState() => _HomeBottomState();
}

class _HomeBottomState extends State<HomeBottom> {
  int _pilihIndex = 0;

  static final List<Widget> _butonNavigator = <Widget>[
    HomeSpage(),
    RekapAbs(),
    ProfilePage(),
  ];

  static final List<String> _appBarTitles = ['Home', 'Rekap', 'Profile'];

  void _pilihNavigator(int index) {
    setState(() {
      _pilihIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffF1F1F5),

      // appBar: AppBar(
      //   title: Text(
      //     _appBarTitles[_pilihIndex],
      //     style: TextStyle(
      //       fontWeight: FontWeight.bold,
      //       fontSize: 24,
      //       color: Colors.white,
      //     ),
      //   ),
      //   centerTitle: true,
      //   backgroundColor: Color(0xff468585),
      //   iconTheme: IconThemeData(color: Colors.white),
      // ),
      body: _butonNavigator[_pilihIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt), label: 'Rekap'),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Profile',
          ),
        ],
        backgroundColor: Color(0xff106D6B),
        currentIndex: _pilihIndex,
        selectedItemColor: Color(0xffF1EEDC),
        unselectedItemColor: Colors.white70,
        onTap: _pilihNavigator,
      ),
    );
  }
}
