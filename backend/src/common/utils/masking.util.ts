/**
 * Masks an email address, showing first character, asterisks, last character before @
 * Example: john@example.com → j***n@example.com
 */
export function maskEmail(email: string): string {
  if (!email) return '';
  const [local, domain] = email.split('@');
  if (!local || !domain) return email;
  if (local.length <= 2) return `${local[0]}***@${domain}`;
  return `${local[0]}${'*'.repeat(local.length - 2)}${local[local.length - 1]}@${domain}`;
}

/**
 * Masks a phone number with proper formatting
 * Example: +966501234567 → +966 XXX XXX 4567
 * Example: +91 9876543210 → +91 XXXX XXX 210
 */
export function maskPhoneNumber(phone: string): string {
  if (!phone) return '';
  
  // Extract country code and number
  const cleaned = phone.replace(/\D/g, ''); // Remove non-digits
  if (cleaned.length < 6) return phone;
  
  // Check if it starts with common country codes
  let countryCode = '';
  let number = cleaned;
  
  if (cleaned.startsWith('966')) {
    // Saudi Arabia: +966 5XX XXX XXX
    countryCode = '+966';
    number = cleaned.slice(3);
    if (number.length === 9) {
      const first = number.slice(0, 1);
      const last4 = number.slice(-4);
      return `${countryCode} ${first}XX XXX ${last4}`;
    }
  } else if (cleaned.startsWith('91')) {
    // India: +91 XXXX XXX XXX
    countryCode = '+91';
    number = cleaned.slice(2);
    if (number.length === 10) {
      const last3 = number.slice(-3);
      return `${countryCode} XXXX XXX ${last3}`;
    }
  }
  
  // Generic fallback: show first 3 and last 4 digits
  const first3 = cleaned.slice(0, 3);
  const last4 = cleaned.slice(-4);
  const maskedLength = cleaned.length - 7;
  return `+${first3} ${'X'.repeat(Math.max(maskedLength, 3))} ${last4}`;
}
