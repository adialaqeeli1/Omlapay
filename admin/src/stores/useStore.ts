import { create } from 'zustand'
import {
  getToken,
  getRefreshToken,
  removeToken,
  setToken,
  setRefreshToken,
} from '@/utils/session-storage'
import axiosInstance from '@/utils/axios'
import {
  scheduleProactiveRefresh,
  clearRefreshTimer,
} from '@/utils/auth-refresh'

interface LoginResponse {
  accessToken: string
  refreshToken?: string
}
interface AuthState {
  user: Record<string, unknown> | null
  isAuthenticated: boolean
  actions: {
    setAuthToken: (token: LoginResponse) => void
    setAuthUserDetails: (userDetails: Record<string, unknown>) => void
    logout: () => void
  }
}

const useAuthStore = create<AuthState>(set => {
  const token = getToken()
  const refreshToken = getRefreshToken()
  let isAuthenticated = false

  if (token) {
    isAuthenticated = true
    axiosInstance.defaults.headers.common.Authorization = `Bearer ${token}`
    if (refreshToken) {
      scheduleProactiveRefresh(
        token,
        (newToken) => {
          axiosInstance.defaults.headers.common.Authorization = `Bearer ${newToken}`
        },
        () => {
          delete axiosInstance.defaults.headers.common['Authorization']
          set({ user: null, isAuthenticated: false })
        }
      )
    }
  }

  return {
    user: null,
    isAuthenticated,
    actions: {
      setAuthToken: (loginData: LoginResponse) => {
        if (loginData?.accessToken) {
          setToken(loginData.accessToken)
          if (loginData.refreshToken) {
            setRefreshToken(loginData.refreshToken)
          }
          axiosInstance.defaults.headers.common.Authorization = `Bearer ${loginData.accessToken}`

          set({ isAuthenticated: true })

          if (loginData.refreshToken) {
            scheduleProactiveRefresh(
              loginData.accessToken,
              (newToken) => {
                axiosInstance.defaults.headers.common.Authorization = `Bearer ${newToken}`
              },
              () => {
                delete axiosInstance.defaults.headers.common['Authorization']
                set({ user: null, isAuthenticated: false })
              }
            )
          }
        }
      },
      setAuthUserDetails: (userDetails: Record<string, unknown>) => {
        set({ user: userDetails })
      },
      logout: () => {
        clearRefreshTimer()
        removeToken()
        delete axiosInstance.defaults.headers.common['Authorization']
        set({ user: null, isAuthenticated: false })
      },
    },
  }
})

export const useAuthUser = () => useAuthStore(state => state.user)
export const useAuthIsAuthenticated = () =>
  useAuthStore(state => state.isAuthenticated)
export const useAuthActions = () => useAuthStore(state => state.actions)

// Export the store for direct access (useful in non-React contexts like route loaders)
export { useAuthStore }
