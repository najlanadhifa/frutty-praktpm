class CurrencyConverter {
  // Kurs statis untuk contoh: USD, EUR, IDR (rupiah)
  static final Map<String, double> _ratesToUSD = {
    'USD': 1.0,
    'EUR': 0.92,
    'IDR': 15000.0,
  };

  /// Konversi nilai [amount] dari [fromCurrency] ke [toCurrency]
  static double convert(double amount, String fromCurrency, String toCurrency) {
    if (!_ratesToUSD.containsKey(fromCurrency) || !_ratesToUSD.containsKey(toCurrency)) {
      throw Exception('Mata uang tidak didukung');
    }

    double amountInUSD = amount / _ratesToUSD[fromCurrency]!; // ke USD dulu
    double convertedAmount = amountInUSD * _ratesToUSD[toCurrency]!; // ke mata uang tujuan

    return convertedAmount;
  }
}
