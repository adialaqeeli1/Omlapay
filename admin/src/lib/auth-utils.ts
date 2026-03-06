/**
 * Auth utilities for handling JWT tokens with automatic refresh
 */

import { refreshAccessToken } from './api';

interface TokenData {
  accessToken: string;
  refreshToken: string;
  expiresAt?: number;
}

// Token storage keys
const ACCESS_TOKEN_KEY = 'omlapay_access_token';
const REFRESH_TOKEN_KEY = 'omlapay_refresh_token';
const EXPIRES_AT_KEY = 'omlapay_token_expires_at';

/**
 * Store tokens in localStorage
 */
export function storeTokens(accessToken: string, refreshToken: string, expiresInSeconds?: number) {
  localStorage.setItem(ACCESS_TOKEN_KEY, accessToken);
  localStorage.setItem(REFRESH_TOKEN_KEY, refreshToken);
  
  if (expiresInSeconds) {
    const expiresAt = Date.now() + (expiresInSeconds * 1000);
    localStorage.setItem(EXPIRES_AT_KEY, expiresAt.toString());
  }
}

/**
 * Get stored tokens from localStorage
 */
export function getStoredTokens(): TokenData | null {
  const accessToken = localStorage.getItem(ACCESS_TOKEN_KEY);
  const refreshToken = localStorage.getItem(REFRESH_TOKEN_KEY);
  const expiresAt = localStorage.getItem(EXPIRES_AT_KEY);

  if (!accessToken || !refreshToken) {
    return null;
  }

  return {
    accessToken,
    refreshToken,
    expiresAt: expiresAt ? parseInt(expiresAt, 10) : undefined,
  };
}

/**
 * Clear stored tokens from localStorage
 */
export function clearTokens() {
  localStorage.removeItem(ACCESS_TOKEN_KEY);
  localStorage.removeItem(REFRESH_TOKEN_KEY);
  localStorage.removeItem(EXPIRES_AT_KEY);
}

/**
 * Check if access token is expired or about to expire (within 5 minutes)
 */
export function isTokenExpired(expiresAt?: number): boolean {
  if (!expiresAt) {
    return false; // Can't determine, assume valid
  }

  const bufferTime = 5 * 60 * 1000; // 5 minutes buffer
  return Date.now() >= (expiresAt - bufferTime);
}

/**
 * Get valid access token, refreshing if necessary
 * Returns null if refresh fails or no tokens available
 */
export async function getValidAccessToken(): Promise<string | null> {
  const tokens = getStoredTokens();

  if (!tokens) {
    // Check for temp test token from env
    const tempToken = import.meta.env.VITE_TEST_JWT_TOKEN;
    return tempToken || null;
  }

  // If token is not expired, return it
  if (!isTokenExpired(tokens.expiresAt)) {
    return tokens.accessToken;
  }

  // Token is expired, try to refresh
  try {
    console.log('🔄 Access token expired, refreshing...');
    const newTokens = await refreshAccessToken(tokens.refreshToken);

    // Store new tokens
    storeTokens(
      newTokens.access_token,
      newTokens.refresh_token,
      // Parse JWT to get expiry (simple approach - you can use a JWT library)
      24 * 60 * 60 // Default 24 hours
    );

    console.log('✅ Token refreshed successfully');
    return newTokens.access_token;
  } catch (error) {
    console.error('❌ Failed to refresh token:', error);
    clearTokens(); // Clear invalid tokens
    return null;
  }
}

/**
 * Decode JWT token (simple implementation - doesn't verify signature)
 */
export function decodeJWT(token: string): any {
  try {
    const base64Url = token.split('.')[1];
    const base64 = base64Url.replace(/-/g, '+').replace(/_/g, '/');
    const jsonPayload = decodeURIComponent(
      atob(base64)
        .split('')
        .map((c) => '%' + ('00' + c.charCodeAt(0).toString(16)).slice(-2))
        .join('')
    );
    return JSON.parse(jsonPayload);
  } catch (error) {
    console.error('Failed to decode JWT:', error);
    return null;
  }
}

/**
 * Get user ID from JWT token
 */
export function getUserIdFromToken(token?: string): string | null {
  const actualToken = token || getStoredTokens()?.accessToken;
  if (!actualToken) return null;

  const decoded = decodeJWT(actualToken);
  return decoded?.userId || null;
}

/**
 * Check if user is authenticated
 */
export function isAuthenticated(): boolean {
  const tokens = getStoredTokens();
  if (!tokens) {
    // Check for temp test token
    return !!import.meta.env.VITE_TEST_JWT_TOKEN;
  }

  return !isTokenExpired(tokens.expiresAt);
}

/**
 * Logout user by clearing tokens
 */
export function logout() {
  clearTokens();
  // Optionally call backend logout endpoint
  // await fetch(`${API_BASE_URL}/user/logout`, ...)
}
