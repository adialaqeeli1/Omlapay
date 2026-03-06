import { createFileRoute, useNavigate } from '@tanstack/react-router'
import { BackIcon, VerifyIcon } from '@/components/icon'
import Modal from '@/components/common/modal'
import { useState } from 'react'
import { useGetAdminMe } from '@/api/auth'
import { useAuthIsAuthenticated, useAuthActions } from '@/stores/useStore'
import {
  useInitiateChangeEmail,
  useVerifyCurrentEmail,
  useEnterNewEmail,
  useVerifyNewEmail,
  useInitiateChangePhone,
  useVerifyCurrentPhone,
  useEnterNewPhone,
  useVerifyNewPhone,
  useChangePassword,
  useResendProfileOtp,
} from '@/api/admin-profile'

export const Route = createFileRoute('/_dashboard/settings/edit/')({
  component: EditSettingsPage,
})

type VerifyType = 'email' | 'mobile'

function EditSettingsPage() {
  const navigate = useNavigate()
  const { logout } = useAuthActions()
  const isAuth = useAuthIsAuthenticated()
  const { data: admin, isLoading } = useGetAdminMe({ isAuth })

  const [verifyType, setVerifyType] = useState<VerifyType | null>(null)
  const [verificationStep, setVerificationStep] = useState(1)
  const [otp, setOtp] = useState('')
  const [newEmail, setNewEmail] = useState('')
  const [newPhone, setNewPhone] = useState('')
  const [error, setError] = useState<string | null>(null)

  const [currentPassword, setCurrentPassword] = useState('')
  const [newPassword, setNewPassword] = useState('')
  const [confirmPassword, setConfirmPassword] = useState('')
  const [passwordError, setPasswordError] = useState<string | null>(null)

  const initiateEmail = useInitiateChangeEmail()
  const verifyCurrentEmail = useVerifyCurrentEmail()
  const enterNewEmail = useEnterNewEmail()
  const verifyNewEmail = useVerifyNewEmail()
  const initiatePhone = useInitiateChangePhone()
  const verifyCurrentPhone = useVerifyCurrentPhone()
  const enterNewPhone = useEnterNewPhone()
  const verifyNewPhone = useVerifyNewPhone()
  const changePassword = useChangePassword()
  const resendOtp = useResendProfileOtp()

  const handleLogoutAndRedirect = () => {
    logout()
    navigate({ to: '/login' })
  }

  const handleClose = () => {
    setVerifyType(null)
    setVerificationStep(1)
    setOtp('')
    setNewEmail('')
    setNewPhone('')
    setError(null)
  }

  const handleOpen = async (type: VerifyType) => {
    setVerifyType(type)
    setVerificationStep(1)
    setOtp('')
    setNewEmail('')
    setNewPhone('')
    setError(null)
    try {
      if (type === 'email') {
        await initiateEmail.mutateAsync()
      } else {
        await initiatePhone.mutateAsync()
      }
    } catch (e: unknown) {
      setError((e as { message?: string })?.message ?? 'Failed to initiate')
    }
  }

  const handleResendOtp = async () => {
    if (!verifyType) return
    setError(null)
    try {
      await resendOtp.mutateAsync(verifyType === 'email' ? 'email' : 'phone')
    } catch (e: unknown) {
      setError((e as { message?: string })?.message ?? 'Failed to resend OTP')
    }
  }

  const handleContinue = async () => {
    setError(null)
    try {
      if (verifyType === 'email') {
        if (verificationStep === 1) {
          await verifyCurrentEmail.mutateAsync({ otp })
          setVerificationStep(2)
          setOtp('')
        } else if (verificationStep === 2) {
          if (!newEmail.trim()) {
            setError('Enter new email address')
            return
          }
          await enterNewEmail.mutateAsync({ newEmail: newEmail.trim() })
          setVerificationStep(3)
          setOtp('')
        } else if (verificationStep === 3) {
          await verifyNewEmail.mutateAsync({ otp })
          handleClose()
          handleLogoutAndRedirect()
        }
      } else if (verifyType === 'mobile') {
        if (verificationStep === 1) {
          await verifyCurrentPhone.mutateAsync({ otp })
          setVerificationStep(2)
          setOtp('')
        } else if (verificationStep === 2) {
          if (!newPhone.trim()) {
            setError('Enter new mobile number')
            return
          }
          await enterNewPhone.mutateAsync({ newPhoneNumber: newPhone.trim() })
          setVerificationStep(3)
          setOtp('')
        } else if (verificationStep === 3) {
          await verifyNewPhone.mutateAsync({ otp })
          handleClose()
          handleLogoutAndRedirect()
        }
      }
    } catch (e: unknown) {
      const msg = (e as { message?: string })?.message
      setError(typeof msg === 'string' ? msg : 'Verification failed')
    }
  }

  const handleSavePassword = async () => {
    setPasswordError(null)
    if (newPassword !== confirmPassword) {
      setPasswordError('Passwords do not match')
      return
    }
    try {
      await changePassword.mutateAsync({
        currentPassword,
        newPassword,
        confirmPassword,
      })
      handleLogoutAndRedirect()
    } catch (e: unknown) {
      const msg = (e as { message?: string })?.message
      setPasswordError(typeof msg === 'string' ? msg : 'Failed to change password')
    }
  }

  const handleCancel = () => {
    navigate({ to: '/settings' })
  }

  if (isLoading || !admin) {
    return (
      <div className="max-w-7xl mx-auto px-5 py-10 flex items-center justify-center">
        <span className="text-light-secondary">Loading...</span>
      </div>
    )
  }

  const isEmailPending =
    initiateEmail.isPending ||
    verifyCurrentEmail.isPending ||
    enterNewEmail.isPending ||
    verifyNewEmail.isPending
  const isPhonePending =
    initiatePhone.isPending ||
    verifyCurrentPhone.isPending ||
    enterNewPhone.isPending ||
    verifyNewPhone.isPending
  const isVerifyPending = verifyType === 'email' ? isEmailPending : isPhonePending

  return (
    <>
      <div className="max-w-7xl mx-auto px-5 py-10 flex flex-col gap-8 w-full">
        <div className="flex items-center gap-6">
          <button
            onClick={handleCancel}
            className="text-primary-main hover:text-primary-dark text-sm font-medium"
          >
            <BackIcon />
          </button>
          <h2 className="text-2xl font-semibold font-poppins text-light-main">
            Admin Information
          </h2>
        </div>

        <div className="flex flex-col bg-dark-main rounded-[8px] p-4 gap-6">
          <h3 className="text-2xl font-semibold font-poppins text-light my-2">
            Personal Information
          </h3>
          <div className="flex flex-col gap-4">
            <div className="flex items-center py-2 h-12">
              <span className="w-1/5 text-lg font-medium text-light font-poppins">
                Email Address
              </span>
              <div className="w-2/5 h-12 px-4 py-2 flex items-center gap-2 justify-between bg-transparent border-[0.5px] border-light-secondary rounded-[4px]">
                <input
                  type="text"
                  className="w-full outline-none text-sm font-normal font-roboto text-light-active bg-transparent"
                  value={admin.email ?? ''}
                  readOnly
                />
                <button
                  onClick={() => handleOpen('email')}
                  disabled={!admin.email}
                  className="text-light-active text-sm font-normal font-roboto hover:text-primary disabled:opacity-50"
                >
                  Edit
                </button>
              </div>
            </div>
            <div className="flex items-center py-2 h-12">
              <span className="w-1/5 text-lg font-medium text-light font-poppins">
                Mobile Number
              </span>
              <div className="w-2/5 h-12 px-4 py-2 flex items-center gap-2 justify-between bg-transparent border-[0.5px] border-light-secondary rounded-[4px]">
                <input
                  type="text"
                  className="w-full outline-none text-sm font-normal font-roboto text-light-active bg-transparent"
                  value={admin.phoneNumber ?? ''}
                  readOnly
                />
                <button
                  onClick={() => handleOpen('mobile')}
                  disabled={!admin.phoneNumber}
                  className="text-light-active text-sm font-normal font-roboto hover:text-primary disabled:opacity-50"
                >
                  Edit
                </button>
              </div>
            </div>
            <div className="flex items-center py-2 h-12">
              <span className="w-1/5 text-lg font-medium text-light font-poppins">
                Current Password
              </span>
              <input
                type="password"
                className="w-2/5 h-12 px-4 py-2 border-[0.5px] border-light-secondary rounded-[4px] outline-none text-sm font-normal font-roboto text-light-active bg-transparent"
                placeholder="Enter current password"
                value={currentPassword}
                onChange={e => setCurrentPassword(e.target.value)}
              />
            </div>
            <div className="flex items-center py-2 h-12">
              <span className="w-1/5 text-lg font-medium text-light font-poppins">
                New Password
              </span>
              <input
                type="password"
                className="w-2/5 h-12 px-4 py-2 border-[0.5px] border-light-secondary rounded-[4px] outline-none text-sm font-normal font-roboto text-light-active bg-transparent"
                placeholder="Enter new password"
                value={newPassword}
                onChange={e => setNewPassword(e.target.value)}
              />
            </div>
            <div className="flex items-center py-2 h-12">
              <span className="w-1/5 text-lg font-medium text-light font-poppins">
                Confirm Password
              </span>
              <input
                type="password"
                className="w-2/5 h-12 px-4 py-2 border-[0.5px] border-light-secondary rounded-[4px] outline-none text-sm font-normal font-roboto text-light-active bg-transparent"
                placeholder="Confirm new password"
                value={confirmPassword}
                onChange={e => setConfirmPassword(e.target.value)}
              />
            </div>
          </div>
        </div>

        {passwordError && (
          <p className="text-danger text-sm">{passwordError}</p>
        )}

        <div className="w-3/5 flex gap-1.5">
          <button
            onClick={handleCancel}
            className="w-1/2 h-12 p-3 inline-flex items-center justify-center bg-transparent border-2 border-danger text-danger text-base font-medium font-roboto rounded-[8px]"
          >
            Cancel
          </button>
          <button
            onClick={handleSavePassword}
            disabled={
              !currentPassword || !newPassword || !confirmPassword || changePassword.isPending
            }
            className="w-1/2 h-12 p-3 inline-flex items-center justify-center bg-primary-main text-white text-base font-medium font-roboto rounded-[8px] disabled:opacity-50"
          >
            {changePassword.isPending ? 'Saving...' : 'Save'}
          </button>
        </div>
      </div>

      <Modal isOpen={!!verifyType} onClose={handleClose} maxWidth="max-w-[400px]">
        <div className="flex flex-col gap-8">
          <div className="flex flex-col gap-4">
            <div className="h-12 w-12 rounded-[10px] flex items-center justify-center bg-[#2BA39B1F] text-primary">
              <VerifyIcon />
            </div>

            <h3 className="text-lg font-inter font-semibold text-light">
              {verifyType === 'email'
                ? 'Email Verification'
                : 'Mobile Verification'}
            </h3>

            {error && <p className="text-danger text-sm">{error}</p>}

            {verificationStep === 1 && verifyType === 'email' && (
              <div className="flex flex-col gap-1.5">
                <span className="text-sm font-semibold font-inter text-[#697077]">
                  Provide the code sent to {admin.email}
                </span>
                <input
                  type="text"
                  maxLength={6}
                  className="w-full h-11 px-[14px] py-2.5 border border-[#D5D7DA] rounded-[8px] outline-none text-base font-normal font-inter text-light bg-[#FFFFFF1F]"
                  placeholder="Code"
                  value={otp}
                  onChange={e => setOtp(e.target.value.replace(/\D/g, ''))}
                />
                <button
                  onClick={handleResendOtp}
                  disabled={resendOtp.isPending}
                  className="text-primary text-sm text-left"
                >
                  Resend OTP
                </button>
              </div>
            )}
            {verificationStep === 2 && verifyType === 'email' && (
              <div className="flex flex-col gap-1.5">
                <span className="text-sm font-semibold font-inter text-[#697077]">
                  Enter your new email address
                </span>
                <input
                  type="email"
                  className="w-full h-11 px-[14px] py-2.5 border border-[#D5D7DA] rounded-[8px] outline-none text-base font-normal font-inter text-light bg-[#FFFFFF1F]"
                  placeholder="Enter email address"
                  value={newEmail}
                  onChange={e => setNewEmail(e.target.value)}
                />
              </div>
            )}
            {verificationStep === 3 && verifyType === 'email' && (
              <div className="flex flex-col gap-1.5">
                <span className="text-sm font-semibold font-inter text-[#697077]">
                  Provide the code sent to {newEmail || 'your new email'}
                </span>
                <input
                  type="text"
                  maxLength={6}
                  className="w-full h-11 px-[14px] py-2.5 border border-[#D5D7DA] rounded-[8px] outline-none text-base font-normal font-inter text-light bg-[#FFFFFF1F]"
                  placeholder="Code"
                  value={otp}
                  onChange={e => setOtp(e.target.value.replace(/\D/g, ''))}
                />
                <button
                  onClick={handleResendOtp}
                  disabled={resendOtp.isPending}
                  className="text-primary text-sm text-left"
                >
                  Resend OTP
                </button>
              </div>
            )}

            {verificationStep === 1 && verifyType === 'mobile' && (
              <div className="flex flex-col gap-1.5">
                <span className="text-sm font-semibold font-inter text-[#697077]">
                  Provide the code sent to {admin.phoneNumber}
                </span>
                <input
                  type="text"
                  maxLength={6}
                  className="w-full h-11 px-[14px] py-2.5 border border-[#D5D7DA] rounded-[8px] outline-none text-base font-normal font-inter text-light bg-[#FFFFFF1F]"
                  placeholder="Code"
                  value={otp}
                  onChange={e => setOtp(e.target.value.replace(/\D/g, ''))}
                />
                <button
                  onClick={handleResendOtp}
                  disabled={resendOtp.isPending}
                  className="text-primary text-sm text-left"
                >
                  Resend OTP
                </button>
              </div>
            )}
            {verificationStep === 2 && verifyType === 'mobile' && (
              <div className="flex flex-col gap-1.5">
                <span className="text-sm font-semibold font-inter text-[#697077]">
                  Enter new mobile number (KSA format: +966XXXXXXXXX)
                </span>
                <input
                  type="tel"
                  className="w-full h-11 px-[14px] py-2.5 border border-[#D5D7DA] rounded-[8px] outline-none text-base font-normal font-inter text-light bg-[#FFFFFF1F]"
                  placeholder="+966501234567"
                  value={newPhone}
                  onChange={e => setNewPhone(e.target.value)}
                />
              </div>
            )}
            {verificationStep === 3 && verifyType === 'mobile' && (
              <div className="flex flex-col gap-1.5">
                <span className="text-sm font-semibold font-inter text-[#697077]">
                  Provide the code sent to {newPhone || 'your new number'}
                </span>
                <input
                  type="text"
                  maxLength={6}
                  className="w-full h-11 px-[14px] py-2.5 border border-[#D5D7DA] rounded-[8px] outline-none text-base font-normal font-inter text-light bg-[#FFFFFF1F]"
                  placeholder="Code"
                  value={otp}
                  onChange={e => setOtp(e.target.value.replace(/\D/g, ''))}
                />
                <button
                  onClick={handleResendOtp}
                  disabled={resendOtp.isPending}
                  className="text-primary text-sm text-left"
                >
                  Resend OTP
                </button>
              </div>
            )}
          </div>
          <div className="flex gap-3 w-full">
            <button
              onClick={handleClose}
              className="flex-1 bg-[#F92A2A1F] rounded-[8px] py-2.5 px-4 border border-[#F92A2A] text-base font-semibold font-inter text-[#F92A2A]"
            >
              Cancel
            </button>
            <button
              onClick={handleContinue}
              disabled={
                (verificationStep === 1 || verificationStep === 3) && otp.length !== 6
                  ? true
                  : isVerifyPending
              }
              className="flex-1 bg-primary rounded-[8px] py-2.5 px-4 border border-primary-dark text-base font-semibold font-inter text-white disabled:opacity-50"
            >
              {isVerifyPending ? 'Verifying...' : verificationStep === 3 ? 'Verify' : 'Continue'}
            </button>
          </div>
        </div>
      </Modal>
    </>
  )
}
