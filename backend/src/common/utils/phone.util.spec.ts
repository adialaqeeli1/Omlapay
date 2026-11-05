import { BadRequestException } from '@nestjs/common';
import {
  assertAllowedPhone,
  normalizeAllowedPhone,
  normalizePhoneDto,
} from './phone.util';

describe('phone.util (Saudi-only OTP numbers)', () => {
  const original = process.env.ALLOWED_PHONE_COUNTRY_CODES;
  afterEach(() => {
    if (original === undefined) delete process.env.ALLOWED_PHONE_COUNTRY_CODES;
    else process.env.ALLOWED_PHONE_COUNTRY_CODES = original;
  });

  it.each([
    ['0512345678', undefined],
    ['512345678', undefined],
    ['966512345678', undefined],
    ['+966512345678', undefined],
    ['00966512345678', undefined],
    ['+966 51 234 5678', undefined],
    ['0512345678', '+966'],
    ['512345678', '+966'],
    ['966512345678', '+966'],
    ['+966512345678', '966'],
  ])('normalizes %s (country code %s) to +966512345678', (input, cc) => {
    expect(normalizeAllowedPhone(input, cc)).toEqual({
      fullMobileNumber: '+966512345678',
      countryCode: '+966',
      mobileNumber: '512345678',
    });
  });

  it.each([
    ['+919876543210', undefined], // India
    ['9876543210', '+91'],
    ['+15551234567', undefined], // US
    ['5551234567', '+1'],
    ['+966112345678', undefined], // Saudi landline (not 5)
    ['+96651234567', undefined], // too short
    ['+9665123456789', undefined], // too long
    ['512345678', '+91'], // Saudi-looking number with another country code
    ['abc', undefined],
    ['', undefined],
  ])(
    'rejects %s (country code %s) with English and Arabic messages',
    (input, cc) => {
      expect.assertions(4);
      try {
        normalizeAllowedPhone(input, cc);
      } catch (err) {
        expect(err).toBeInstanceOf(BadRequestException);
        const body = (err as BadRequestException).getResponse() as Record<
          string,
          string
        >;
        expect(body.code).toBe('PHONE_NOT_ALLOWED');
        expect(body.message).toMatch(/Saudi/);
        expect(body.message_ar).toMatch(/السعودية/);
      }
    },
  );

  it('normalizes a DTO in place', () => {
    const dto = { country_code: '+966', mobile_number: '0512345678' };
    normalizePhoneDto(dto);
    expect(dto).toEqual({ country_code: '+966', mobile_number: '512345678' });
  });

  it('honours ALLOWED_PHONE_COUNTRY_CODES', () => {
    process.env.ALLOWED_PHONE_COUNTRY_CODES = '966,971';
    expect(assertAllowedPhone('+971501234567')).toBe('+971501234567');
    expect(() => assertAllowedPhone('+919876543210')).toThrow(
      BadRequestException,
    );
  });
});
