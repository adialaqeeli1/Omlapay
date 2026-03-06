import { UserKycEntity } from '@common/database/model';
import { KycProvider } from '@common/database/model';

/**
 * Extract full name from a single KYC provider payload.
 * Supports Sumsub format (info.firstName, info.lastName) and
 * Binance format (basicInfo.firstName, basicInfo.lastName).
 */
function extractFromPayload(p: Record<string, unknown>): string {
  const info = p?.info as Record<string, unknown> | undefined;
  const sumsubFirst = (info?.firstName as string)?.trim() || '';
  const sumsubLast = (info?.lastName as string)?.trim() || '';

  const basicInfo = p?.basicInfo as Record<string, unknown> | undefined;
  const binanceFirst = (basicInfo?.firstName as string)?.trim() || '';
  const binanceLast = (basicInfo?.lastName as string)?.trim() || '';

  const firstName = sumsubFirst || binanceFirst;
  const lastName = sumsubLast || binanceLast;
  return `${firstName} ${lastName}`.trim();
}

/**
 * Extract full name from KYC provider payload(s).
 * Supports Sumsub format (info.firstName, info.lastName) and
 * Binance format (basicInfo.firstName, basicInfo.lastName).
 * When multiple records provided, prefers Sumsub over Binance.
 */
export function getFullNameFromKyc(
  kyc: UserKycEntity | null | (UserKycEntity | null)[],
): string {
  const records = Array.isArray(kyc) ? kyc : [kyc];
  const valid = records.filter((r): r is UserKycEntity => !!r?.providerPayload);

  const sorted = [...valid].sort((a, b) =>
    a.provider === KycProvider.SUMSUB && b.provider !== KycProvider.SUMSUB
      ? -1
      : a.provider !== KycProvider.SUMSUB && b.provider === KycProvider.SUMSUB
        ? 1
        : 0,
  );

  for (const r of sorted) {
    const full = extractFromPayload(r.providerPayload as Record<string, unknown>);
    if (full) return full;
  }

  return '—';
}
