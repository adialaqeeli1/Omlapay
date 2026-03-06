import axios from 'axios'

const axiosInstance = axios.create({
  baseURL: import.meta.env.VITE_API_URL + '/v1/admin',
})

axiosInstance.interceptors.response.use(
  res => res,
  error =>
    Promise.reject(
      (error.response && error.response.data) || 'Something went wrong'
    )
)

export const endpoints = {
  auth: {
    sendOtp: '/auth/send-otp',
    login: '/auth/login',
    logout: '/auth/logout',
    me: '/auth/me',
    forgotPassword: '/auth/forgot-password',
    verifyOtp: '/auth/verify-otp',
    resendOtp: '/auth/resend-otp',
    resetPassword: '/auth/reset-password',
  },
  dashboard: {
    stats: '/dashboard/stats',
  },
  users: {
    list: '/users',
    details: (userId: string) => `/users/${userId}`,
    transactions: (userId: string) => `/users/${userId}/transactions`,
    activity: (userId: string) => `/users/${userId}/activity`,
    swaps: (userId: string) => `/users/${userId}/swaps`,
    block: (userId: string) => `/users/${userId}/block`,
    unblock: (userId: string) => `/users/${userId}/unblock`,
  },
  tickets: {
    list: '/tickets',
    openCount: '/tickets/open-count',
    details: (ticketId: string) => `/tickets/${ticketId}`,
    addResponse: (ticketId: string) => `/tickets/${ticketId}/response`,
    updateStatus: (ticketId: string) => `/tickets/${ticketId}/status`,
  },
  notifications: {
    list: '/notifications',
    unreadCount: '/notifications/unread-count',
    markRead: (id: string) => `/notifications/${id}/read`,
    markAllRead: '/notifications/read-all',
  },
  profile: {
    changeEmail: {
      initiate: '/profile/change-email/initiate',
      verifyCurrent: '/profile/change-email/verify-current',
      enterNew: '/profile/change-email/enter-new',
      verifyNew: '/profile/change-email/verify-new',
    },
    changePhone: {
      initiate: '/profile/change-phone/initiate',
      verifyCurrent: '/profile/change-phone/verify-current',
      enterNew: '/profile/change-phone/enter-new',
      verifyNew: '/profile/change-phone/verify-new',
    },
    changePassword: '/profile/change-password',
    resendOtp: (type: 'email' | 'phone') => `/profile/resend-otp/${type}`,
  },
}

export default axiosInstance
