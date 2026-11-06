import { BadRequestException } from '@nestjs/common';
import { assertStrongPasscode, isWeakPasscode } from './passcode-strength.util';

describe('obvious passcodes are refused', () => {
  it.each([
    '000000',
    '111111',
    '999999',
    '123456',
    '234567',
    '456789',
    '012345',
    '654321',
    '987654',
    '543210',
  ])('%s is weak', (p) => {
    expect(isWeakPasscode(p)).toBe(true);
    expect(() => assertStrongPasscode(p)).toThrow(BadRequestException);
  });

  it.each([
    '135790',
    '246802',
    '112233',
    '123455',
    '890123',
    '102938',
    '121212',
    '100000',
  ])('%s is accepted', (p) => {
    expect(isWeakPasscode(p)).toBe(false);
    expect(() => assertStrongPasscode(p)).not.toThrow();
  });

  it('explains why, in English and Arabic', () => {
    try {
      assertStrongPasscode('123456');
    } catch (e) {
      expect((e as BadRequestException).getResponse()).toMatchObject({
        code: 'WEAK_PASSCODE',
        message: expect.stringContaining('too easy') as unknown,
        message_ar: expect.stringContaining('سهل التخمين') as unknown,
      });
    }
  });
});
