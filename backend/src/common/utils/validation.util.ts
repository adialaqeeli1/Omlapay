import { BadRequestException } from '@nestjs/common';

/**
 * Validation utility functions for common input validation patterns
 */

export enum SupportedCountryCode {
  SAUDI_ARABIA = '+966',
  INDIA = '+91',
}

export interface ValidationResult {
  isValid: boolean;
  error?: string;
}

/**
 * Validates if a string field is present and not empty
 */
export function validateRequired(
  value: string | undefined | null,
  fieldName: string,
): void {
  if (!value || !value.trim()) {
    throw new BadRequestException({
      status: 'error',
      message: `${fieldName} is required.`,
    });
  }
}

/**
 * Validates country code format
 * Supported codes: +966 (Saudi Arabia), +91 (India)
 */
export function validateCountryCode(countryCode: string): void {
  validateRequired(countryCode, 'Country code');

  const supportedCodes = Object.values(SupportedCountryCode);
  if (!supportedCodes.includes(countryCode as SupportedCountryCode)) {
    throw new BadRequestException({
      status: 'error',
      message: `Invalid country code. Allowed: ${supportedCodes.join(', ')}`,
    });
  }
}

/**
 * Validates mobile number format based on country code
 * +966: 9 digits
 * +91: 10 digits
 */
export function validateMobileNumber(
  mobileNumber: string,
  countryCode: string,
): void {
  validateRequired(mobileNumber, 'Mobile number');

  validateCountryCode(countryCode);

  let expectedLength: number;
  let regex: RegExp;

  switch (countryCode) {
    case SupportedCountryCode.SAUDI_ARABIA:
      expectedLength = 9;
      regex = /^\d{9}$/;
      break;
    case SupportedCountryCode.INDIA:
      expectedLength = 10;
      regex = /^\d{10}$/;
      break;
    default:
      throw new BadRequestException({
        status: 'error',
        message: 'Unsupported country code.',
      });
  }

  if (!regex.test(mobileNumber)) {
    throw new BadRequestException({
      status: 'error',
      message: `Mobile number must be ${expectedLength} digits long.`,
    });
  }
}

/**
 * Validates country code and mobile number together
 */
export function validateCountryCodeAndMobileNumber(
  countryCode: string,
  mobileNumber: string,
): void {
  validateCountryCode(countryCode);
  validateMobileNumber(mobileNumber, countryCode);
}

/**
 * Validates passcode format
 * - Minimum 6 digits
 * - Numeric only
 */
export function validatePasscode(passcode: string, fieldName = 'Passcode'): void {
  validateRequired(passcode, fieldName);

  if (passcode.length < 6) {
    throw new BadRequestException({
      status: 'error',
      message: `${fieldName} must be at least 6 digits long.`,
    });
  }

  if (!/^\d+$/.test(passcode)) {
    throw new BadRequestException({
      status: 'error',
      message: `${fieldName} must contain only digits.`,
    });
  }
}

/**
 * Validates password format
 * - Minimum 8 characters
 */
export function validatePassword(password: string, fieldName = 'Password'): void {
  validateRequired(password, fieldName);

  if (password.length < 8) {
    throw new BadRequestException({
      status: 'error',
      message: `${fieldName} must be at least 8 characters long.`,
    });
  }
}

/**
 * Validates that two passcodes match
 */
export function validatePasscodeMatch(
  passcode: string,
  confirmPasscode: string,
): void {
  validatePasscode(passcode, 'Passcode');
  validatePasscode(confirmPasscode, 'Passcode confirmation');

  if (passcode !== confirmPasscode) {
    throw new BadRequestException({
      status: 'error',
      message: 'Passcodes do not match.',
    });
  }
}

/**
 * Validates that two passwords match
 */
export function validatePasswordMatch(
  password: string,
  confirmPassword: string,
): void {
  validatePassword(password, 'Password');
  validatePassword(confirmPassword, 'Password confirmation');

  if (password !== confirmPassword) {
    throw new BadRequestException({
      status: 'error',
      message: 'Passwords do not match.',
    });
  }
}

/**
 * Validates email format
 */
export function validateEmail(email: string): void {
  validateRequired(email, 'Email');

  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  if (!emailRegex.test(email)) {
    throw new BadRequestException({
      status: 'error',
      message: 'Invalid email format.',
    });
  }
}

/**
 * Validates UUID format
 */
export function validateUUID(uuid: string, fieldName = 'ID'): void {
  validateRequired(uuid, fieldName);

  const uuidRegex =
    /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;
  if (!uuidRegex.test(uuid)) {
    throw new BadRequestException({
      status: 'error',
      message: `Invalid ${fieldName.toLowerCase()} format.`,
    });
  }
}

/**
 * Validates OTP format (typically 4-6 digits)
 */
export function validateOTP(otp: string): void {
  validateRequired(otp, 'OTP');

  if (!/^\d{4,6}$/.test(otp)) {
    throw new BadRequestException({
      status: 'error',
      message: 'OTP must be 4 to 6 digits.',
    });
  }
}

/**
 * Validates token format (non-empty string)
 */
export function validateToken(token: string, tokenName = 'Token'): void {
  validateRequired(token, tokenName);
}

/**
 * Validates that a boolean value is true (for terms acceptance, etc.)
 */
export function validateBooleanTrue(
  value: boolean | undefined | null,
  fieldName: string,
  errorMessage?: string,
): void {
  if (!value) {
    throw new BadRequestException({
      status: 'error',
      message:
        errorMessage ||
        `You must accept the ${fieldName} to proceed.`,
    });
  }
}

/**
 * Validates that a number is within a range
 */
export function validateNumberRange(
  value: number,
  min: number,
  max: number,
  fieldName: string,
): void {
  if (value < min || value > max) {
    throw new BadRequestException({
      status: 'error',
      message: `${fieldName} must be between ${min} and ${max}.`,
    });
  }
}

/**
 * Validates that a string length is within a range
 */
export function validateStringLength(
  value: string,
  min: number,
  max: number,
  fieldName: string,
): void {
  validateRequired(value, fieldName);

  if (value.length < min || value.length > max) {
    throw new BadRequestException({
      status: 'error',
      message: `${fieldName} must be between ${min} and ${max} characters.`,
    });
  }
}

/**
 * Validates URL format
 */
export function validateURL(url: string, fieldName = 'URL'): void {
  validateRequired(url, fieldName);

  try {
    new URL(url);
  } catch {
    throw new BadRequestException({
      status: 'error',
      message: `Invalid ${fieldName.toLowerCase()} format.`,
    });
  }
}

/**
 * Validates that an account is active
 */
export function validateAccountActive(
  isActive: boolean | undefined | null,
  accountType: 'account' | 'admin account' = 'account',
): void {
  if (!isActive) {
    throw new BadRequestException({
      status: 'error',
      message: `Your ${accountType} has been deactivated. Please contact support.`,
    });
  }
}

/**
 * Helper to build full mobile number from country code and mobile number
 */
export function buildFullMobileNumber(
  countryCode: string,
  mobileNumber: string,
): string {
  validateCountryCodeAndMobileNumber(countryCode, mobileNumber);
  return `${countryCode}${mobileNumber}`;
}

/**
 * Gets expected mobile number length for a country code
 */
export function getExpectedMobileNumberLength(countryCode: string): number {
  switch (countryCode) {
    case SupportedCountryCode.SAUDI_ARABIA:
      return 9;
    case SupportedCountryCode.INDIA:
      return 10;
    default:
      throw new BadRequestException({
        status: 'error',
        message: 'Unsupported country code.',
      });
  }
}
