/**
 * API Client with automatic token refresh on 401 errors
 * 
 * Usage:
 *   import { apiClient } from './apiClient';
 *   const data = await apiClient.get('/user/kyc/status');
 *   const result = await apiClient.post('/user/kyc/start', {});
 */

import { getStoredTokens, storeTokens, clearTokens } from './auth-utils';

const API_BASE_URL = import.meta.env.VITE_API_BASE_URL;

// TEMPORARY: For testing - In production, get this from auth context
const TEMP_AUTH_TOKEN = import.meta.env.VITE_TEST_JWT_TOKEN || '';
const TEMP_REFRESH_TOKEN = import.meta.env.VITE_TEST_REFRESH_TOKEN || '';

interface RequestOptions extends RequestInit {
  skipAuth?: boolean; // Skip adding Authorization header
  skipRetry?: boolean; // Skip automatic retry with refresh token
}

/**
 * Get current access token (from localStorage or temp env var)
 */
function getCurrentAccessToken(): string | null {
  const stored = getStoredTokens();
  return stored?.accessToken || TEMP_AUTH_TOKEN || null;
}

/**
 * Get current refresh token (from localStorage or temp env var)
 */
function getCurrentRefreshToken(): string | null {
  const stored = getStoredTokens();
  return stored?.refreshToken || TEMP_REFRESH_TOKEN || null;
}

/**
 * Refresh access token and update storage
 */
async function refreshToken(): Promise<string | null> {
  const refreshToken = getCurrentRefreshToken();
  
  if (!refreshToken) {
    console.error('❌ No refresh token available');
    return null;
  }

  try {
    console.log('🔄 Refreshing access token...');
    
    const response = await fetch(`${API_BASE_URL}/auth/refresh`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ refresh_token: refreshToken }),
    });

    const result = await response.json();

    if (!response.ok) {
      console.error('❌ Token refresh failed:', result.message);
      clearTokens(); // Clear invalid tokens
      return null;
    }

    const { access_token, refresh_token } = result.data;

    // Store new tokens
    storeTokens(access_token, refresh_token, 24 * 60 * 60); // 24 hours

    console.log('✅ Token refreshed successfully');
    return access_token;
  } catch (error) {
    console.error('❌ Token refresh error:', error);
    clearTokens();
    return null;
  }
}

/**
 * Make API request with automatic token refresh on 401
 */
async function request<T = any>(
  endpoint: string,
  options: RequestOptions = {}
): Promise<T> {
  const { skipAuth = false, skipRetry = false, ...fetchOptions } = options;

  // Build full URL
  const url = endpoint.startsWith('http') ? endpoint : `${API_BASE_URL}${endpoint}`;

  // Add Authorization header if not skipped
  const headers: Record<string, string> = {
    'Content-Type': 'application/json',
    ...(fetchOptions.headers as Record<string, string> | undefined),
  };

  if (!skipAuth) {
    const token = getCurrentAccessToken();
    if (token) {
      headers['Authorization'] = `Bearer ${token}`;
    }
  }

  // Make request
  let response = await fetch(url, {
    ...fetchOptions,
    headers,
  });

  // Handle 401 Unauthorized - try to refresh token and retry
  if (response.status === 401 && !skipRetry && !skipAuth) {
    console.warn('⚠️  401 Unauthorized - attempting token refresh...');
    
    const newToken = await refreshToken();
    
    if (newToken) {
      // Retry request with new token
      console.log('🔄 Retrying request with new token...');
      
      headers['Authorization'] = `Bearer ${newToken}`;
      
      response = await fetch(url, {
        ...fetchOptions,
        headers,
      });

      if (response.ok) {
        console.log('✅ Request succeeded after token refresh');
      }
    } else {
      // Refresh failed - redirect to login or throw error
      console.error('❌ Token refresh failed - user needs to login again');
      
      // Trigger login redirect (you can customize this)
      if (typeof window !== 'undefined') {
        window.dispatchEvent(new CustomEvent('auth:expired'));
      }
      
      throw new Error('Session expired. Please login again.');
    }
  }

  // Parse response
  const result = await response.json();

  // Handle errors
  if (!response.ok) {
    const errorMessage = result.message || result.error?.message || result.error || response.statusText;
    throw new Error(errorMessage);
  }

  // Return data (handle both { data: ... } and direct response)
  return result.data || result;
}

/**
 * API Client with convenient methods
 */
export const apiClient = {
  /**
   * GET request
   */
  get: <T = any>(endpoint: string, options?: RequestOptions) =>
    request<T>(endpoint, { ...options, method: 'GET' }),

  /**
   * POST request
   */
  post: <T = any>(endpoint: string, body?: any, options?: RequestOptions) =>
    request<T>(endpoint, {
      ...options,
      method: 'POST',
      body: body ? JSON.stringify(body) : undefined,
    }),

  /**
   * PUT request
   */
  put: <T = any>(endpoint: string, body?: any, options?: RequestOptions) =>
    request<T>(endpoint, {
      ...options,
      method: 'PUT',
      body: body ? JSON.stringify(body) : undefined,
    }),

  /**
   * PATCH request
   */
  patch: <T = any>(endpoint: string, body?: any, options?: RequestOptions) =>
    request<T>(endpoint, {
      ...options,
      method: 'PATCH',
      body: body ? JSON.stringify(body) : undefined,
    }),

  /**
   * DELETE request
   */
  delete: <T = any>(endpoint: string, options?: RequestOptions) =>
    request<T>(endpoint, { ...options, method: 'DELETE' }),
};

/**
 * Listen for auth expiration events
 * Usage in your app:
 *   window.addEventListener('auth:expired', () => {
 *     // Redirect to login
 *     router.push('/login');
 *   });
 */
export type AuthExpiredEvent = CustomEvent<void>;
