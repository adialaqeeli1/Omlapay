const Map<String, String> _namedEntities = {
  'amp': '&',
  'lt': '<',
  'gt': '>',
  'quot': '"',
  'apos': "'",
  'nbsp': ' ',
  'copy': '©',
  'reg': '®',
  'trade': '™',
  'hellip': '…',
  'mdash': '—',
  'ndash': '–',
  'lsquo': '‘',
  'rsquo': '’',
  'ldquo': '“',
  'rdquo': '”',
  'bull': '•',
  'middot': '·',
  'times': '×',
  'divide': '÷',
};

/// Decode HTML entities (named and numeric) in [input].
/// Unknown entities are left verbatim.
String decodeHtmlEntities(String input) {
  if (!input.contains('&')) return input;
  final buffer = StringBuffer();
  var i = 0;
  while (i < input.length) {
    final ch = input[i];
    if (ch != '&') {
      buffer.write(ch);
      i++;
      continue;
    }
    final semi = input.indexOf(';', i + 1);
    if (semi == -1 || semi - i > 10) {
      buffer.write(ch);
      i++;
      continue;
    }
    final body = input.substring(i + 1, semi);
    final decoded = _decodeEntityBody(body);
    if (decoded != null) {
      buffer.write(decoded);
      i = semi + 1;
    } else {
      buffer.write(ch);
      i++;
    }
  }
  return buffer.toString();
}

String? _decodeEntityBody(String body) {
  if (body.isEmpty) return null;
  if (body.startsWith('#')) {
    final digits = body.substring(1);
    if (digits.isEmpty) return null;
    int? code;
    if (digits.startsWith('x') || digits.startsWith('X')) {
      code = int.tryParse(digits.substring(1), radix: 16);
    } else {
      code = int.tryParse(digits);
    }
    if (code == null || code < 0 || code > 0x10FFFF) return null;
    return String.fromCharCode(code);
  }
  return _namedEntities[body];
}
