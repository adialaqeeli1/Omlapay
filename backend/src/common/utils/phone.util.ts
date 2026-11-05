import { BadRequestException } from '@nestjs/common';

/**
 * Phone number policy: which countries may receive OTP codes and be set as an account number.
 *
 * ALLOWED_PHONE_COUNTRY_CODES: comma-separated country calling codes, default "966" (Saudi Arabia).
 * Saudi numbers must be mobile numbers: +966 followed by 9 digits starting with 5.
 * Any other code that is configured only gets a basic length check.
 */

const SAUDI_CODE = '966';
const SAUDI_MOBILE = /^\+9665\d{8}$/;

export interface NormalizedPhone {
  /** E.164, e.g. +966512345678 */
  fullMobileNumber: string;
  /** e.g. +966 */
  countryCode: string;
  /** National part without trunk 0, e.g. 512345678 */
  mobileNumber: string;
}

export function getAllowedPhoneCountryCodes(): string[] {
  const codes = (process.env.ALLOWED_PHONE_COUNTRY_CODES ?? SAUDI_CODE)
    .split(',')
    .map((code) => code.trim().replace(/^\+/, ''))
    .filter((code) => /^\d{1,4}$/.test(code));
  return codes.length ? codes : [SAUDI_CODE];
}

function phoneNotAllowed(): BadRequestException {
  const saudiOnly = getAllowedPhoneCountryCodes().every(
    (code) => code === SAUDI_CODE,
  );
  return new BadRequestException({
    status: 'error',
    code: 'PHONE_NOT_ALLOWED',
    message: saudiOnly
      ? 'Only Saudi mobile numbers are supported (+966 5XXXXXXXX).'
      : 'This phone number is not supported.',
    message_ar: saudiOnly
      ? 'يُسمح فقط بأرقام الجوال السعودية (‎+966 5XXXXXXXX‎).'
      : 'رقم الجوال هذا غير مدعوم.',
  });
}

/**
 * Normalizes a phone number to E.164 and checks it against the allowed countries.
 * Accepts, for Saudi numbers: 05XXXXXXXX, 5XXXXXXXX, 9665XXXXXXXX, +9665XXXXXXXX, 009665XXXXXXXX
 * (spaces, dashes, dots and brackets are ignored). countryCode (e.g. "+966") is used when the
 * number itself has no country code.
 * Throws a 400 with an English and Arabic message when the number is not allowed.
 */
export function normalizeAllowedPhone(
  input: string,
  countryCode?: string,
): NormalizedPhone {
  const raw = (input ?? '').replace(/[\s\-().]/g, '');
  const cc = (countryCode ?? '').trim().replace(/^\+/, '');

  let e164: string;
  if (raw.startsWith('+')) {
    e164 = raw;
  } else if (raw.startsWith('00')) {
    e164 = `+${raw.slice(2)}`;
  } else if (cc) {
    if (raw.startsWith(cc) && raw.length > cc.length + 8) e164 = `+${raw}`;
    else e164 = `+${cc}${raw.startsWith('0') ? raw.slice(1) : raw}`;
  } else if (/^05\d{8}$/.test(raw)) {
    e164 = `+${SAUDI_CODE}${raw.slice(1)}`;
  } else if (/^5\d{8}$/.test(raw)) {
    e164 = `+${SAUDI_CODE}${raw}`;
  } else {
    e164 = `+${raw}`;
  }

  if (!/^\+\d+$/.test(e164)) throw phoneNotAllowed();

  for (const code of getAllowedPhoneCountryCodes()) {
    if (!e164.startsWith(`+${code}`)) continue;
    const valid =
      code === SAUDI_CODE
        ? SAUDI_MOBILE.test(e164)
        : new RegExp(`^\\+${code}\\d{6,12}$`).test(e164);
    if (valid) {
      return {
        fullMobileNumber: e164,
        countryCode: `+${code}`,
        mobileNumber: e164.slice(code.length + 1),
      };
    }
  }
  throw phoneNotAllowed();
}

/** Same as normalizeAllowedPhone, returning only the E.164 number. */
export function assertAllowedPhone(
  input: string,
  countryCode?: string,
): string {
  return normalizeAllowedPhone(input, countryCode).fullMobileNumber;
}

/**
 * Validates and normalizes a request DTO's country_code + mobile_number in place, so the rest of
 * the flow always sees e.g. country_code "+966" and mobile_number "512345678".
 */
export function normalizePhoneDto<
  T extends { country_code: string; mobile_number: string },
>(dto: T): NormalizedPhone {
  const phone = normalizeAllowedPhone(dto.mobile_number, dto.country_code);
  dto.country_code = phone.countryCode;
  dto.mobile_number = phone.mobileNumber;
  return phone;
}
