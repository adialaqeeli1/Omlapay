/**
 * Standard success response utility
 */
export interface SuccessResponse<T = any> {
  status: 'success';
  message?: string;
  data?: T;
}

/**
 * Standard error response utility
 */
export interface ErrorResponse {
  status: 'error';
  message: string;
  error?: any;
}

/**
 * Create a success response
 */
export function successResponse<T>(data?: T, message?: string): SuccessResponse<T> {
  const response: SuccessResponse<T> = {
    status: 'success',
  };
  
  if (message) {
    response.message = message;
  }
  
  if (data !== undefined) {
    response.data = data;
  }
  
  return response;
}

/**
 * Create an error response
 */
export function errorResponse(message: string, error?: any): ErrorResponse {
  const response: ErrorResponse = {
    status: 'error',
    message,
  };
  
  if (error) {
    response.error = error;
  }
  
  return response;
}

