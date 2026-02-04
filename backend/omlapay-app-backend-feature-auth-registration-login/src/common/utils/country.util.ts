/**
 * Country code utilities for ISO 3166-1 conversions.
 */
export class CountryUtil {
  /**
   * Convert ISO 3166-1 alpha-3 country code to alpha-2.
   * Used for APIs that require 2-letter country codes (e.g., Binance).
   * 
   * @param alpha3 - 3-letter country code (e.g., 'USA', 'GBR')
   * @returns 2-letter country code (e.g., 'US', 'GB')
   */
  static alpha3ToAlpha2(alpha3: string): string {
    const map: Record<string, string> = {
      // Common countries
      GBR: 'GB', USA: 'US', CAN: 'CA', AUS: 'AU', NZL: 'NZ',
      // Europe
      DEU: 'DE', FRA: 'FR', ITA: 'IT', ESP: 'ES', NLD: 'NL', BEL: 'BE',
      CHE: 'CH', AUT: 'AT', PRT: 'PT', IRL: 'IE', POL: 'PL', SWE: 'SE',
      NOR: 'NO', DNK: 'DK', FIN: 'FI', GRC: 'GR', CZE: 'CZ', HUN: 'HU',
      // Middle East
      SAU: 'SA', ARE: 'AE', QAT: 'QA', KWT: 'KW', BHR: 'BH', OMN: 'OM',
      JOR: 'JO', LBN: 'LB', ISR: 'IL', TUR: 'TR', EGY: 'EG',
      // Asia
      IND: 'IN', CHN: 'CN', JPN: 'JP', KOR: 'KR', SGP: 'SG', MYS: 'MY',
      THA: 'TH', IDN: 'ID', PHL: 'PH', VNM: 'VN', PAK: 'PK', BGD: 'BD',
      // Americas
      MEX: 'MX', BRA: 'BR', ARG: 'AR', CHL: 'CL', COL: 'CO', PER: 'PE',
      // Africa
      ZAF: 'ZA', NGA: 'NG', KEN: 'KE', MAR: 'MA', DZA: 'DZ', TUN: 'TN',
    };
    
    const upper = (alpha3 || '').toUpperCase().slice(0, 3);
    return map[upper] ?? upper.slice(0, 2);
  }
}
