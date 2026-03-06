/**
 * Masks an email address: first char, asterisks, last char before @.
 * Example: john@example.com → j***n@example.com
 */
export function maskEmail(email: string): string {
  if (!email?.trim()) return '';
  const [local, domain] = email.split('@');
  if (!local || !domain) return email;
  if (local.length <= 2) return `${local[0]}***@${domain}`;
  return `${local[0]}${'*'.repeat(local.length - 2)}${local[local.length - 1]}@${domain}`;
}

/**
 * Masks a phone number: only last 4 digits visible.
 * Example: +966501234567 → +966 *****4567
 * Example: +919876543210 → +91 ******3210
 */
export function maskPhoneNumber(phone: string): string {
  if (!phone?.trim()) return '';
  const cleaned = phone.replace(/\D/g, '');
  if (cleaned.length < 5) return phone;

  const { countryCode, number } = parseCountryCode(cleaned);
  if (number.length < 4) return phone;

  const last4 = number.slice(-4);
  const masked = '*'.repeat(number.length - 4);
  return `${countryCode} ${masked}${last4}`;
}

function parseCountryCode(cleaned: string): { countryCode: string; number: string } {
  if (cleaned.startsWith('966')) {
    return { countryCode: '+966', number: cleaned.slice(3) };
  }
  if (cleaned.startsWith('91')) {
    return { countryCode: '+91', number: cleaned.slice(2) };
  }
  const ccLen = Math.min(3, Math.max(1, cleaned.length - 4));
  return {
    countryCode: `+${cleaned.slice(0, ccLen)}`,
    number: cleaned.slice(ccLen),
  };
}

/**
 * Masks a blockchain address: first 4 and last 4 characters visible.
 * Example: 0x1234567890abcdef → 0x12****cdef
 */
export function maskAddress(addr: string): string {
  if (!addr || addr.length < 8) return addr;
  return `${addr.slice(0, 4)}****${addr.slice(-4)}`;
}
