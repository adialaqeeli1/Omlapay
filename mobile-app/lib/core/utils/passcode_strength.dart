/// Obvious passcodes, refused when a passcode is set (registration, forgot
/// passcode, change passcode). Same rule as the backend (WEAK_PASSCODE):
/// all the same digit (000000, 111111, …) or a straight run up or down
/// (123456, 234567, 654321, …).
bool isWeakPasscode(String passcode) {
  if (!RegExp(r'^\d{6}$').hasMatch(passcode)) return false;
  final d = passcode.split('').map(int.parse).toList();
  final steps = [for (var i = 1; i < d.length; i++) d[i] - d[i - 1]];
  return [0, 1, -1].any((step) => steps.every((s) => s == step));
}
