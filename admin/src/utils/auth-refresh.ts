import axios from 'axios'
import { jwtDecode } from './session-storage'
import { getRefreshToken, setToken, removeToken, removeRefreshToken } from './session-storage'

const REFRESH_BEFORE_EXPIRY_MS = 5 * 60 * 1000 // 5 minutes before expiry

let refreshTimerId: ReturnType<typeof setTimeout> | null = null

type OnRefreshSuccess = (accessToken: string) => void
type OnRefreshFailure = () => void

function getRefreshUrl(): string {
  const base = import.meta.env.VITE_API_URL
  return `${base}/v1/admin/auth/refresh-token`
}

export function scheduleProactiveRefresh(
  accessToken: string,
  onSuccess: OnRefreshSuccess,
  onFailure: OnRefreshFailure
) {
  clearRefreshTimer()

  let exp: number
  try {
    const payload = jwtDecode(accessToken)
    exp = payload.exp
    if (!exp || typeof exp !== 'number') return
  } catch {
    return
  }

  const expiresAtMs = exp * 1000
  const refreshAtMs = expiresAtMs - REFRESH_BEFORE_EXPIRY_MS
  const delayMs = refreshAtMs - Date.now()

  if (delayMs <= 0) {
    doRefresh(onSuccess, onFailure)
    return
  }

  refreshTimerId = setTimeout(() => {
    refreshTimerId = null
    doRefresh(onSuccess, onFailure)
  }, delayMs)
}

async function doRefresh(
  onSuccess: OnRefreshSuccess,
  onFailure: OnRefreshFailure
) {
  const refreshToken = getRefreshToken()
  if (!refreshToken) {
    onFailure()
    return
  }

  try {
    const { data } = await axios.post<{ accessToken: string; expiresIn: number }>(
      getRefreshUrl(),
      { refreshToken }
    )

    setToken(data.accessToken)
    onSuccess(data.accessToken)

    scheduleProactiveRefresh(data.accessToken, onSuccess, onFailure)
  } catch {
    removeToken()
    removeRefreshToken()
    onFailure()
  }
}

export function clearRefreshTimer() {
  if (refreshTimerId) {
    clearTimeout(refreshTimerId)
    refreshTimerId = null
  }
}
