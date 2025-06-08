import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/auth_service.dart';
import 'login_page.dart';
import 'favorite_fruit_page.dart';
import 'home_page.dart';
import 'saran_kesan_page.dart';
import 'profile_page.dart';

class KonversiWaktuUangPage extends StatefulWidget {
  const KonversiWaktuUangPage({Key? key}) : super(key: key);

  @override
  State<KonversiWaktuUangPage> createState() => _KonversiWaktuUangPageState();
}

class _KonversiWaktuUangPageState extends State<KonversiWaktuUangPage> {
  // === TIME CONVERSION DATA === //
  static const Map<String, int> _timeZones = {
    'WIB (Jakarta)': 7,   // UTC+7
    'WITA (Makassar)': 8, // UTC+8 
    'WIT (Jayapura)': 9,  // UTC+9 
    'London (GMT)': 0,    // UTC+0 
  };

  String _selectedTimeFrom = 'WIB (Jakarta)';
  String _selectedTimeTo = 'London (GMT)';
  TimeOfDay _selectedTime = TimeOfDay.now();
  TimeOfDay? _convertedTimeOfDay;

  // === CURRENCY CONVERSION DATA === //
  final TextEditingController _amountController = TextEditingController();
  
  // Kurs terbaru yang diberikan user
  static const Map<String, double> _currencyRatesToIDR = {
    'IDR': 1.0,
    'USD': 16258.05,  // 1 USD = 16,258.05 IDR
    'JPY': 112.64,    // 1 JPY = 112.64 IDR
  };

  String _selectedCurrencyFrom = 'USD';
  String _selectedCurrencyTo = 'IDR';
  String _convertedCurrency = '';

  @override
  void initState() {
    super.initState();
    // Jangan panggil _convertTime() di sini karena context belum tersedia
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Panggil _convertTime() di sini setelah context tersedia
    _convertTime();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  // === TIME CONVERSION METHODS === //
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.lightBlue[300]!,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
      _convertTime();
    }
  }

  void _convertTime() {
    final fromOffset = _timeZones[_selectedTimeFrom]!;
    final toOffset = _timeZones[_selectedTimeTo]!;

    // Hitung selisih jam yang benar
    // WIB (UTC+7) lebih cepat 7 jam dari London (UTC+0)
    // Jadi jika London jam 3 pagi, maka WIB jam 10 pagi (3 + 7 = 10)
    final timeDifference = toOffset - fromOffset;
    
    // Konversi waktu
    int newHour = _selectedTime.hour + timeDifference;
    int newMinute = _selectedTime.minute;
    
    // Handle overflow/underflow untuk jam
    if (newHour >= 24) {
      newHour -= 24;
    } else if (newHour < 0) {
      newHour += 24;
    }
    
    setState(() {
      _convertedTimeOfDay = TimeOfDay(hour: newHour, minute: newMinute);
    });
  }

  // === CURRENCY CONVERSION METHODS === //
  void _convertCurrency() {
    final amount = double.tryParse(_amountController.text) ?? 0;
    
    if (amount == 0) {
      setState(() {
        _convertedCurrency = '';
      });
      return;
    }

    final rateFrom = _currencyRatesToIDR[_selectedCurrencyFrom]!;
    final rateTo = _currencyRatesToIDR[_selectedCurrencyTo]!;
    
    // Convert to IDR first, then to target currency
    final amountInIDR = amount * rateFrom;
    final result = amountInIDR / rateTo;

    setState(() {
      if (_selectedCurrencyTo == 'IDR') {
        // Format IDR without decimal places
        _convertedCurrency = NumberFormat('#,###', 'id_ID').format(result.round());
      } else {
        // Format other currencies with 2 decimal places
        _convertedCurrency = NumberFormat('#,##0.00', 'en_US').format(result);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.lightBlue[300],
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Konversi waktu & mata uang',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildTimeConversionSection(),
            const SizedBox(height: 24),
            _buildCurrencyConversionSection(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  // === TIME CONVERSION UI === //
  Widget _buildTimeConversionSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.lightBlue[300],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Text(
            'Konversi waktu',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Current Time Display
          const Text(
            'Waktu saat ini',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white,
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Time Picker Button
          GestureDetector(
            onTap: () => _selectTime(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Text(
                _selectedTime.format(context),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Timezone Selectors
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    const Text(
                      'Dari',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildTimeZoneDropdown(_selectedTimeFrom, (value) {
                      setState(() => _selectedTimeFrom = value!);
                      _convertTime();
                    }),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Icon(
                  Icons.arrow_forward,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    const Text(
                      'Ke',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildTimeZoneDropdown(_selectedTimeTo, (value) {
                      setState(() => _selectedTimeTo = value!);
                      _convertTime();
                    }),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Result
          const Text(
            'Hasil konversi',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white,
            ),
          ),
          
          const SizedBox(height: 8),
          
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 2),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Text(
              _convertedTimeOfDay != null 
                ? _convertedTimeOfDay!.format(context)
                : '--:--',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeZoneDropdown(String value, ValueChanged<String?> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white, width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          dropdownColor: Colors.lightBlue[300],
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
          style: const TextStyle(color: Colors.white, fontSize: 12),
          items: _timeZones.keys.map((tz) {
            return DropdownMenuItem(
              value: tz,
              child: Text(
                tz,
                style: const TextStyle(fontSize: 12),
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  // === CURRENCY CONVERSION UI === //
  Widget _buildCurrencyConversionSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.lightBlue[300],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Text(
            'Konversi mata uang',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Amount Input
          const Text(
            'Nominal uang',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white,
            ),
          ),
          
          const SizedBox(height: 8),
          
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 2),
              borderRadius: BorderRadius.circular(25),
            ),
            child: TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: '0.00',
                hintStyle: TextStyle(
                  color: Colors.white70,
                  fontSize: 18,
                ),
              ),
              onChanged: (_) => _convertCurrency(),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Currency Selectors
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    const Text(
                      'Dari',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildCurrencyDropdown(_selectedCurrencyFrom, (value) {
                      setState(() => _selectedCurrencyFrom = value!);
                      _convertCurrency();
                    }),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Icon(
                  Icons.arrow_forward,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    const Text(
                      'Ke',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildCurrencyDropdown(_selectedCurrencyTo, (value) {
                      setState(() => _selectedCurrencyTo = value!);
                      _convertCurrency();
                    }),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Result
          const Text(
            'Hasil konversi',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white,
            ),
          ),
          
          const SizedBox(height: 8),
          
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 2),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Text(
              _convertedCurrency.isEmpty 
                ? '0' 
                : '$_convertedCurrency $_selectedCurrencyTo',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencyDropdown(String value, ValueChanged<String?> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white, width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          dropdownColor: Colors.lightBlue[300],
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
          style: const TextStyle(color: Colors.white, fontSize: 14),
          items: _currencyRatesToIDR.keys.map((currency) {
            return DropdownMenuItem(
              value: currency,
              child: Text(
                currency,
                style: const TextStyle(fontSize: 14),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.lightBlue[300],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(Icons.home, 'Beranda', false, onTap: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
            );
          }),
          _buildNavItem(Icons.sync, 'Konversi', true),
          _buildNavItem(Icons.description, 'S&K', false, onTap: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const SaranKesanPage()),
            );
          }),
          _buildNavItem(Icons.person, 'Profil', false, onTap: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const ProfilePage()),
            );
          }),
          _buildNavItem(Icons.logout, 'Keluar', false, onTap: () async {
            await AuthService.logout();
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginPage()),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isActive ? Colors.white : Colors.white70,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.white : Colors.white70,
              fontSize: 10,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
