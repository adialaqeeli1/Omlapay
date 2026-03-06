// Format Saudi phone number to include country code
export const formatSaudiPhoneNumber = (phone: string): string => {
  if (!phone) return phone

  // Remove all non-digit characters for processing
  const digitsOnly = phone.replace(/\D/g, '')

  // If already starts with 966 (without +), add +
  if (digitsOnly.startsWith('966') && digitsOnly.length >= 12) {
    return `+${digitsOnly}`
  }

  // If already starts with +966, return as is
  if (phone.startsWith('+966') && digitsOnly.length >= 12) {
    return phone
  }

  // If starts with 05 and is 10 digits, format to +9665XXXXXXXX
  if (digitsOnly.startsWith('05') && digitsOnly.length === 10) {
    return `+966${digitsOnly.substring(1)}` // Remove leading 0 and add +966
  }

  // If starts with 5 and is 9 digits, format to +9665XXXXXXXX
  if (digitsOnly.startsWith('5') && digitsOnly.length === 9) {
    return `+966${digitsOnly}`
  }

  // Return original if no pattern matches
  return phone
}
