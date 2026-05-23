class AmountToWords {
  static const _ones = [
    '', 'One', 'Two', 'Three', 'Four', 'Five', 'Six', 'Seven', 'Eight',
    'Nine', 'Ten', 'Eleven', 'Twelve', 'Thirteen', 'Fourteen', 'Fifteen',
    'Sixteen', 'Seventeen', 'Eighteen', 'Nineteen'
  ];
  static const _tens = [
    '', '', 'Twenty', 'Thirty', 'Forty', 'Fifty',
    'Sixty', 'Seventy', 'Eighty', 'Ninety'
  ];

  static String convert(double amount) {
    final n = amount.toInt();
    if (n == 0) return 'Zero Rupees Only';
    return '${_convert(n)} Rupees Only';
  }

  static String _convert(int n) {
    if (n < 20) return _ones[n];
    if (n < 100) return _tens[n ~/ 10] + (n % 10 != 0 ? ' ${_ones[n % 10]}' : '');
    if (n < 1000) return '${_ones[n ~/ 100]} Hundred${n % 100 != 0 ? ' ${_convert(n % 100)}' : ''}';
    if (n < 100000) return '${_convert(n ~/ 1000)} Thousand${n % 1000 != 0 ? ' ${_convert(n % 1000)}' : ''}';
    if (n < 10000000) return '${_convert(n ~/ 100000)} Lakh${n % 100000 != 0 ? ' ${_convert(n % 100000)}' : ''}';
    return '${_convert(n ~/ 10000000)} Crore${n % 10000000 != 0 ? ' ${_convert(n % 10000000)}' : ''}';
  }
}
