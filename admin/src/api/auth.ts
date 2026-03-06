import {
  queryOptions,
  useMutation,
  useQuery,
  useQueryClient,
} from '@tanstack/react-query'
import { useNavigate } from '@tanstack/react-router'
import { useAuthActions } from '@/stores/useStore'
import axiosInstance, { endpoints } from '@/utils/axios'

type SendOtpFormData = {
  identifier: string
}

type SendOtpResponse = {
  message: string
  termsRequired: boolean
}

export const useSendOtp = () => {
  return useMutation({
    mutationFn: async (params: SendOtpFormData) => {
      const response = await axiosInstance.post<SendOtpResponse>(
        endpoints.auth.sendOtp,
        params
      )
      return response.data
    },
  })
}

type LoginFormData = {
  identifier: string
  password: string
  otp?: string
  acceptTerms?: boolean
}

type LoginResponse = {
  accessToken: string
  refreshToken: string
  expiresIn: number
}

export const useLogin = () => {
  const queryClient = useQueryClient()
  const { setAuthToken } = useAuthActions()
  return useMutation({
    mutationFn: async (params: LoginFormData) => {
      const response = await axiosInstance.post<LoginResponse>(
        endpoints.auth.login,
        params
      )
      return response.data
    },
    onSuccess: async (loginData) => {
      setAuthToken({
        accessToken: loginData.accessToken,
        refreshToken: loginData.refreshToken,
      })
    },
  })
}

export type AdminMeResponse = {
  adminId: string
  email: string | null
  phoneNumber: string | null
  role: string
  isActive: boolean
  createdAt: string
}

export const useGetAdminMe = ({ isAuth = false }) => {
  return useQuery({
    queryKey: ['adminMe'],
    queryFn: async () => {
      const res = await axiosInstance.get<AdminMeResponse>(endpoints.auth.me)
      return res.data
    },
    enabled: isAuth,
  })
}

export const useLogout = () => {
  const queryClient = useQueryClient()
  const navigate = useNavigate()
  const { logout } = useAuthActions()
  return useMutation({
    mutationFn: async () => {
      await axiosInstance.post(endpoints.auth.logout)
    },
    onSettled: () => {
      logout()
      queryClient.clear()
      navigate({ to: '/login' })
    },
  })
}

// Forgot password flow
type ForgotPasswordParams = { identifier: string }
type VerifyOtpParams = { identifier: string; otp: string }
type ResetPasswordParams = {
  resetToken: string
  newPassword: string
  confirmPassword: string
}

type VerifyOtpResponse = { resetToken: string }

export const useForgotPassword = () => {
  return useMutation({
    mutationFn: async (params: ForgotPasswordParams) => {
      const res = await axiosInstance.post(endpoints.auth.forgotPassword, params)
      return res.data
    },
  })
}

export const useVerifyOtp = () => {
  return useMutation({
    mutationFn: async (params: VerifyOtpParams) => {
      const res = await axiosInstance.post<VerifyOtpResponse>(
        endpoints.auth.verifyOtp,
        params
      )
      return res.data
    },
  })
}

export const useResendOtp = () => {
  return useMutation({
    mutationFn: async (params: ForgotPasswordParams) => {
      const res = await axiosInstance.post(endpoints.auth.resendOtp, params)
      return res.data
    },
  })
}

export const useResetPassword = () => {
  return useMutation({
    mutationFn: async (params: ResetPasswordParams) => {
      const res = await axiosInstance.post(endpoints.auth.resetPassword, params)
      return res.data
    },
  })
}

// {
//     "adminId": "1c27978c-2957-4445-9d11-69ee9db1454f",
//     "email": "smallick@marsdevs.com",
//     "phoneNumber": "+966500000000",
//     "isActive": true,
//     "createdAt": "2026-02-04T12:35:17.459Z"
//   }

// {
//   "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhZG1pbklkIjoiOTY1ZmI4YzItZTQ3Yy00NDJiLThjNjEtMTM3MjJhZTQ3ZWY2IiwiZW1haWwiOiJzbWFsbGlja0BtYXJzZGV2cy5jb20iLCJ0eXBlIjoiYWRtaW4iLCJpYXQiOjE3NzAzODA2MzgsImV4cCI6MTc3MDM4NDIzOH0.WlKwqaPK0tcgdpQl8luv1Fv_ibbtquu6k7tLFrpY4A4",
//   "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhZG1pbklkIjoiOTY1ZmI4YzItZTQ3Yy00NDJiLThjNjEtMTM3MjJhZTQ3ZWY2IiwidHlwZSI6ImFkbWluX3JlZnJlc2giLCJpYXQiOjE3NzAzODA2MzgsImV4cCI6MTc3MDk4NTQzOH0.bDw_lM3IKY04DczkYBn0zd19ilwLIh5eTQQaBItJH9Y",
//   "expiresIn": 3600
// }
