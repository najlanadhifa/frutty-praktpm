import 'package:flutter/material.dart';
import '../home/home_page.dart';
import '../fruit/fruit_list_page.dart';
import '../conversion/currency_page.dart';
import '../conversion/time_page.dart';
import '../profile/profile_page.dart';
import '../feedback/feedback_page.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  // List widget untuk setiap tab
  static final List<Widget> _pages = <Widget>[
    const HomePage(),
    const FruitListPage(),
    const ConversionPage(),
    const ProfilePage(),
    const FeedbackPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey[600],
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_florist),
            label: 'Buah',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.swap_horiz),
            label: 'Konversi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.feedback),
            label: 'Saran',
          ),
        ],
      ),
    );
  }
}

// Wrapper halaman Konversi untuk tab tunggal gabungan (Currency & Time)
class ConversionPage extends StatefulWidget {
  const ConversionPage({super.key});

  @override
  State<ConversionPage> createState() => _ConversionPageState();
}

class _ConversionPageState extends State<ConversionPage> {
  int _subIndex = 0;

  final List<Widget> _conversionPages = const [
    CurrencyPage(),
    TimePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Konversi'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _subIndex = 0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    color: _subIndex == 0 ? Colors.green[300] : Colors.grey[300],
                    child: const Center(child: Text('Mata Uang')),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _subIndex = 1),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    color: _subIndex == 1 ? Colors.green[300] : Colors.grey[300],
                    child: const Center(child: Text('Waktu')),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: _conversionPages[_subIndex],
    );
  }
}
