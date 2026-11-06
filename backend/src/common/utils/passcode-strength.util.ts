import { BadRequestException } from '@nestjs/common';

/**
 * Obvious passcodes refused when a passcode is set (registration, forgot-passcode reset,
 * change passcode): all the same digit (000000, 111111, …) or a straight run up or down
 * (123456, 234567, 654321, …). Existing passcodes are not affected.
 */
export function isWeakPasscode(passcode: string): boolean {
  if (!/^\d{6}$/.test(passcode)) return false; // format is checked elsewhere
  const d = [...passcode].map(Number);
  const steps = d.slice(1).map((v, i) => v - d[i]);
  return [0, 1, -1].some((step) => steps.every((s) => s === step));
}

export function assertStrongPasscode(passcode: string): void {
  if (isWeakPasscode(passcode)) {
    throw new BadRequestException({
      status: 'error',
      code: 'WEAK_PASSCODE',
      message:
        'This passcode is too easy to guess. Avoid repeated digits (like 111111) and sequences (like 123456).',
      message_ar:
        'رمز المرور هذا سهل التخمين. تجنّب الأرقام المكررة (مثل 111111) والمتسلسلة (مثل 123456).',
    });
  }
}
