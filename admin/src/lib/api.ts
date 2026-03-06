import { apiClient } from './apiClient';

const API_BASE_URL = import.meta.env.VITE_API_BASE_URL;

// TEMPORARY: For testing - In production, get this from auth context
const TEMP_AUTH_TOKEN = import.meta.env.VITE_TEST_JWT_TOKEN || '';
const TEMP_REFRESH_TOKEN = import.meta.env.VITE_TEST_REFRESH_TOKEN || '';

// ============================================================================
// NEW: Production endpoints with automatic token refresh
// ============================================================================

export interface StartKycData {
  firstName?: string;
  lastName?: string;
  residentialCountry?: string;
  dob?: string;
  country?: string;
  address?: string;
  city?: string;
}

/**
 * Start KYC verification - automatically refreshes token on 401
 */
export async function startKycVerification(authToken?: string, data?: StartKycData) {
  // If custom token provided, use old method (for backward compatibility)
  if (authToken) {
    const body = data && Object.keys(data).length > 0 ? JSON.stringify(data) : undefined;
    const response = await fetch(`${API_BASE_URL}/user/kyc/start`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${authToken}`,
      },
      body,
    });

    const result = await response.json().catch(() => ({}));

    if (!response.ok) {
      const errorMessage = result.message || result.error?.message || result.error || response.statusText;
      throw new Error(`Failed to start KYC: ${errorMessage}`);
    }

    return result.data;
  }

  // Use apiClient with automatic token refresh
  return apiClient.post('/user/kyc/start', data);
}

/**
 * Get KYC status - automatically refreshes token on 401
 */
export async function getKycStatus(authToken?: string) {
  // If custom token provided, use old method (for backward compatibility)
  if (authToken) {
    const response = await fetch(`${API_BASE_URL}/user/kyc/status`, {
      method: 'GET',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${authToken}`,
      },
    });

    const result = await response.json();

    if (!response.ok) {
      const errorMessage = result.message || result.error?.message || result.error || response.statusText;
      throw new Error(`Failed to get KYC status: ${errorMessage}`);
    }

    return result.data;
  }

  // Use apiClient with automatic token refresh
  return apiClient.get('/user/kyc/status');
}

/**
 * Start Binance KYC (only available after Sumsub is approved).
 */
export async function startBinanceKyc(authToken?: string) {
  if (authToken) {
    const response = await fetch(`${API_BASE_URL}/user/kyc/binance/start`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${authToken}`,
      },
    });
    const result = await response.json();
    if (!response.ok) {
      const errorMessage = result.message || result.error?.message || result.error || response.statusText;
      throw new Error(`Failed to start Binance KYC: ${errorMessage}`);
    }
    return result.data;
  }
  return apiClient.post('/user/kyc/binance/start');
}

/**
 * Refresh access token using refresh token
 * Note: This is called automatically by apiClient on 401 errors
 */
export async function refreshAccessToken(refreshToken?: string) {
  const token = refreshToken || TEMP_REFRESH_TOKEN;
  
  const response = await fetch(`${API_BASE_URL}/auth/refresh`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({ refresh_token: token }),
  });

  const result = await response.json();

  if (!response.ok) {
    const errorMessage = result.message || result.error?.message || result.error || response.statusText;
    throw new Error(`Failed to refresh token: ${errorMessage}`);
  }

  return result.data; // Returns { access_token, refresh_token }
}

// OLD: Dev tools endpoint (kept for backward compatibility)
export async function generateSumsubAccessToken(data: {
  userId: string;
  levelName: string; // Required - must match a level created in Sumsub Dashboard
  email?: string;
  phone?: string;
  ttlInSecs?: number;
}) {
  const response = await fetch(`${API_BASE_URL}/dev-tools/sumsub/access-token`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify(data),
  });

  const result = await response.json();

  if (!response.ok) {
    const errorMessage = result.message || result.error?.message || result.error || response.statusText;
    throw new Error(`Failed to generate access token: ${errorMessage}`);
  }

  // Handle both response formats: { data: {...} } or direct response
  return result.data || result;
}

export async function getSumsubLevels() {
  const response = await fetch(`${API_BASE_URL}/dev-tools/sumsub/levels`, {
    method: 'GET',
    headers: {
      'Content-Type': 'application/json',
    },
  });

  const result = await response.json();

  if (!response.ok) {
    const errorMessage = result.message || result.error?.message || result.error || response.statusText;
    throw new Error(`Failed to get levels: ${errorMessage}`);
  }

  return result.data || result;
}

export async function getSumsubApplicantStatus(userId: string) {
  const response = await fetch(
    `${API_BASE_URL}/dev-tools/sumsub/applicant-status/${userId}`,
    {
      method: 'GET',
      headers: {
        'Content-Type': 'application/json',
      },
    },
  );

  if (!response.ok) {
    throw new Error(`Failed to get applicant status: ${response.statusText}`);
  }

  const result = await response.json();
  return result.data;
}
