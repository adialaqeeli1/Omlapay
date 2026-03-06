import { useMutation, useQueryClient } from '@tanstack/react-query'
import axiosInstance, { endpoints } from '@/utils/axios'

// Change Email Flow
export const useInitiateChangeEmail = () => {
  return useMutation({
    mutationFn: async () => {
      const res = await axiosInstance.post<{ message: string; maskedEmail: string }>(
        endpoints.profile.changeEmail.initiate
      )
      return res.data
    },
  })
}

export const useVerifyCurrentEmail = () => {
  return useMutation({
    mutationFn: async (dto: { otp: string }) => {
      const res = await axiosInstance.post<{ message: string }>(
        endpoints.profile.changeEmail.verifyCurrent,
        dto
      )
      return res.data
    },
  })
}

export const useEnterNewEmail = () => {
  return useMutation({
    mutationFn: async (dto: { newEmail: string }) => {
      const res = await axiosInstance.post<{ message: string; maskedNewEmail: string }>(
        endpoints.profile.changeEmail.enterNew,
        dto
      )
      return res.data
    },
  })
}

export const useVerifyNewEmail = () => {
  return useMutation({
    mutationFn: async (dto: { otp: string }) => {
      const res = await axiosInstance.post<{ message: string }>(
        endpoints.profile.changeEmail.verifyNew,
        dto
      )
      return res.data
    },
  })
}

// Change Phone Flow
export const useInitiateChangePhone = () => {
  return useMutation({
    mutationFn: async () => {
      const res = await axiosInstance.post<{ message: string; maskedPhone: string }>(
        endpoints.profile.changePhone.initiate
      )
      return res.data
    },
  })
}

export const useVerifyCurrentPhone = () => {
  return useMutation({
    mutationFn: async (dto: { otp: string }) => {
      const res = await axiosInstance.post<{ message: string }>(
        endpoints.profile.changePhone.verifyCurrent,
        dto
      )
      return res.data
    },
  })
}

export const useEnterNewPhone = () => {
  return useMutation({
    mutationFn: async (dto: { newPhoneNumber: string }) => {
      const res = await axiosInstance.post<{ message: string; maskedNewPhone: string }>(
        endpoints.profile.changePhone.enterNew,
        dto
      )
      return res.data
    },
  })
}

export const useVerifyNewPhone = () => {
  return useMutation({
    mutationFn: async (dto: { otp: string }) => {
      const res = await axiosInstance.post<{ message: string }>(
        endpoints.profile.changePhone.verifyNew,
        dto
      )
      return res.data
    },
  })
}

// Change Password
export type ChangePasswordDto = {
  currentPassword: string
  newPassword: string
  confirmPassword: string
}

export const useChangePassword = () => {
  const queryClient = useQueryClient()
  return useMutation({
    mutationFn: async (dto: ChangePasswordDto) => {
      const res = await axiosInstance.post<{ status: string; message: string }>(
        endpoints.profile.changePassword,
        dto
      )
      return res.data
    },
    onSuccess: () => {
      queryClient.clear()
    },
  })
}

// Resend OTP
export const useResendProfileOtp = () => {
  return useMutation({
    mutationFn: async (type: 'email' | 'phone') => {
      const res = await axiosInstance.post<{ message: string }>(
        endpoints.profile.resendOtp(type)
      )
      return res.data
    },
  })
}
