const tokenKey = 'auth-token'
const refreshTokenKey = 'auth-refresh-token'

export const getToken = () => {
  if (typeof window !== 'undefined') {
    return sessionStorage.getItem(tokenKey)
  }
  return null // or handle it appropriately for server-side
}

export const removeToken = () => {
  if (typeof window !== 'undefined') {
    sessionStorage.removeItem(tokenKey)
    sessionStorage.removeItem(refreshTokenKey)
  }
}

export const getRefreshToken = () => {
  if (typeof window !== 'undefined') {
    return sessionStorage.getItem(refreshTokenKey)
  }
  return null
}

export const setRefreshToken = (token: string) => {
  if (typeof window !== 'undefined') {
    sessionStorage.setItem(refreshTokenKey, token)
  }
}

export const removeRefreshToken = () => {
  if (typeof window !== 'undefined') {
    sessionStorage.removeItem(refreshTokenKey)
  }
}

export const setToken = (token: string) => {
  if (typeof window !== 'undefined') {
    sessionStorage.setItem(tokenKey, token)
  }
}

export function jwtDecode(token: string) {
  const base64Url = token.split('.')[1]
  const base64 = base64Url.replace(/-/g, '+').replace(/_/g, '/')
  const jsonPayload = decodeURIComponent(
    window
      .atob(base64)
      .split('')
      .map(c => `%${`00${c.charCodeAt(0).toString(16)}`.slice(-2)}`)
      .join('')
  )

  return JSON.parse(jsonPayload)
}

export const getOtpEmail = () => {
  if (typeof window !== 'undefined') {
    return sessionStorage.getItem('otp-email')
  }
  return null
}

export const getOtpTime = () => {
  if (typeof window !== 'undefined') {
    return sessionStorage.getItem('otp-time')
  }
  return null
}

export const removeOtpEmail = () => {
  if (typeof window !== 'undefined') {
    sessionStorage.removeItem('otp-email')
  }
}

export const removeOtpTime = () => {
  if (typeof window !== 'undefined') {
    sessionStorage.removeItem('otp-time')
  }
}

export const setOtpEmail = (email: string) => {
  if (typeof window !== 'undefined') {
    sessionStorage.setItem('otp-email', email)
  }
}

export const setOtpTime = (time: string) => {
  if (typeof window !== 'undefined') {
    sessionStorage.setItem('otp-time', time)
  }
}
