import { useState } from 'react'
import { createFileRoute, Link, useNavigate } from '@tanstack/react-router'
import { FormProvider, useForm, Controller } from 'react-hook-form'
import { zodResolver } from '@hookform/resolvers/zod'
import PasswordInput from '../../components/form/password-input'
import { z } from 'zod'
import OTPInput from 'react-otp-input'
import clsx from 'clsx'
import { useForgotPassword, useVerifyOtp, useResendOtp, useResetPassword } from '@/api/auth'
import { toast } from 'react-toastify'
import { SaudiFlag } from '@/components/icon'
import { formatSaudiPhoneNumber } from '@/utils/format'
import OTPTimer from '@/components/common/otp-timer'

const passwordRegex =
  /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]+$/

const forgetPasswordSchema = z
  .object({
    identifier: z.string().min(1, 'Email or phone is required'),
    otp: z.string().length(6, 'OTP must be 6 digits').regex(/^\d+$/, 'OTP must be numeric'),
    password: z
      .string()
      .min(8, 'Password must be at least 8 characters')
      .regex(
        passwordRegex,
        'Password must contain uppercase, lowercase, number, and special character (@$!%*?&)'
      ),
    confirm_password: z.string().min(1, 'Confirm password is required'),
  })
  .refine(data => data.password === data.confirm_password, {
    message: 'Passwords do not match',
    path: ['confirm_password'],
  })
  .refine(
    data => {
      if (!data.identifier) return false
      const id = data.identifier.trim()
      if (id.includes('@')) return z.string().email().safeParse(id).success
      const digits = id.replace(/\D/g, '')
      return (
        (digits.length === 9 && digits.startsWith('5')) ||
        (digits.length === 10 && digits.startsWith('05')) ||
        (digits.length === 12 && digits.startsWith('966'))
      )
    },
    {
      message: 'Enter a valid email or Saudi phone (05XXXXXXXX)',
      path: ['identifier'],
    }
  )

type ForgetPasswordFormData = z.infer<typeof forgetPasswordSchema>

export const Route = createFileRoute(
  '/_auth/forget-password' as '/_auth/forget-password'
)({
  component: ForgetPasswordPage,
})

function ForgetPasswordPage() {
  const [verifyType, setVerifyType] = useState<'mobile' | 'email'>('mobile')
  const [otpSendSuccess, setOtpSendSuccess] = useState(false)
  const [canResendOtp, setCanResendOtp] = useState(true)
  const [otpExpiryTime, setOtpExpiryTime] = useState(0)
  const navigate = useNavigate()

  const { mutate: forgotPassword, isPending: isSendingOtp } = useForgotPassword()
  const { mutate: verifyOtp, isPending: isVerifying } = useVerifyOtp()
  const { mutate: resendOtp, isPending: isResending } = useResendOtp()
  const { mutate: resetPassword, isPending: isResetting } = useResetPassword()

  const methods = useForm<ForgetPasswordFormData>({
    resolver: zodResolver(forgetPasswordSchema),
    mode: 'onChange',
    defaultValues: {
      identifier: '',
      otp: '',
      password: '',
      confirm_password: '',
    },
  })

  const { handleSubmit, watch, setValue, control, trigger } = methods
  const identifier = watch('identifier')

  const getFormattedIdentifier = () => {
    const id = (identifier || '').trim()
    if (verifyType === 'mobile' && id) return formatSaudiPhoneNumber(id)
    return id
  }

  const handleSendOtp = async () => {
    const valid = await trigger('identifier')
    if (!valid) return
    const formatted = getFormattedIdentifier()
    forgotPassword(
      { identifier: formatted },
      {
        onSuccess: () => {
          setOtpSendSuccess(true)
          setCanResendOtp(false)
          setOtpExpiryTime(Date.now() + 60 * 1000)
          toast.success('If the account exists, an OTP has been sent.')
        },
        onError: (err: any) => {
          const msg = err?.message ?? 'Failed to send OTP'
          toast.error(msg)
        },
      }
    )
  }

  const handleResendOtp = () => {
    const formatted = getFormattedIdentifier()
    resendOtp(
      { identifier: formatted },
      {
        onSuccess: () => {
          setCanResendOtp(false)
          setOtpExpiryTime(Date.now() + 60 * 1000)
          toast.success('If the account exists, a new OTP has been sent.')
        },
        onError: (err: any) => {
          const msg = err?.message ?? 'Failed to resend OTP'
          toast.error(msg)
        },
      }
    )
  }

  const handleOtpExpiry = () => {
    setOtpExpiryTime(0)
    setCanResendOtp(true)
  }

  const onSubmit = async (data: ForgetPasswordFormData) => {
    if (!otpSendSuccess) return

    const formatted = getFormattedIdentifier()

    verifyOtp(
      { identifier: formatted, otp: data.otp },
      {
        onSuccess: (res) => {
          resetPassword(
            {
              resetToken: res.resetToken,
              newPassword: data.password,
              confirmPassword: data.confirm_password,
            },
            {
              onSuccess: () => {
                toast.success('Password reset successful.')
                navigate({ to: '/login' })
              },
              onError: (err: any) => {
                const msg = err?.message ?? 'Failed to reset password'
                toast.error(msg)
              },
            }
          )
        },
        onError: (err: any) => {
          const msg = err?.message ?? 'Invalid or expired OTP'
          toast.error(msg)
        },
      }
    )
  }

  const isPending = isSendingOtp || isVerifying || isResetting

  return (
    <div className="h-full flex flex-col gap-8 items-center justify-center w-[485px] -ml-28">
      <FormProvider {...methods}>
        <form onSubmit={handleSubmit(onSubmit)} className="w-full">
          <div className="flex flex-col gap-8 p-9 rounded-[12px] bg-[#F8F8F8] w-full">
            <h2 className="text-2xl font-semibold text-[#161326] leading-9">
              Forget Password
            </h2>
            <div className="flex flex-col gap-8">
              <div className="flex flex-col gap-5">
                <div className="w-[345px] p-1 rounded-[12px] bg-[#E5E5E5] mx-auto">
                  <button
                    type="button"
                    className={clsx(
                      'w-1/2 text-base font-semibold font-inter rounded-[8px] h-9',
                      verifyType === 'mobile' && 'bg-[#2AA29A] text-white'
                    )}
                    onClick={() => setVerifyType('mobile')}
                  >
                    Mobile
                  </button>
                  <button
                    type="button"
                    className={clsx(
                      'w-1/2 text-base font-semibold font-inter rounded-[8px] h-9',
                      verifyType === 'email' && 'bg-[#2AA29A] text-white'
                    )}
                    onClick={() => setVerifyType('email')}
                  >
                    Email
                  </button>
                </div>
              </div>

              {verifyType === 'mobile' && (
                <div className="flex gap-1.5 sm:gap-2">
                  <div className="flex gap-1.5 items-center h-14 bg-[#E5E5E5] px-2 py-1 rounded-[8px]">
                    <SaudiFlag />
                    <span className="text-sm font-medium font-inter text-[#6D6D6D]">
                      +966
                    </span>
                  </div>
                  <Controller
                    name="identifier"
                    control={control}
                    render={({ field, fieldState: { error } }) => (
                      <div className="flex flex-col gap-1.5 flex-1">
                        <div
                          className={clsx(
                            'w-full h-14 px-4 py-2 flex items-center gap-2 justify-between bg-white border rounded-[8px]',
                            error ? 'border-red-500' : 'border-[#282828]'
                          )}
                        >
                          <input
                            {...field}
                            type="tel"
                            disabled={otpSendSuccess}
                            placeholder="05XXXXXXXX"
                            className="w-full outline-none text-sm font-normal font-roboto bg-transparent"
                            onChange={e => {
                              const v = e.target.value.replace(/\D/g, '')
                              field.onChange(v)
                            }}
                          />
                          <button
                            type="button"
                            onClick={handleSendOtp}
                            disabled={
                              isSendingOtp ||
                              !field.value ||
                              !!error ||
                              otpSendSuccess
                            }
                            className={clsx(
                              'bg-[#2AA29A] text-white rounded-full px-2 py-1 text-xs font-medium font-roboto whitespace-nowrap',
                              (isSendingOtp ||
                                !field.value ||
                                !!error ||
                                otpSendSuccess) &&
                                'opacity-50 cursor-not-allowed'
                            )}
                          >
                            {isSendingOtp ? 'Sending...' : 'Send OTP'}
                          </button>
                        </div>
                        {error && (
                          <span className="text-xs text-red-500">
                            {error.message}
                          </span>
                        )}
                      </div>
                    )}
                  />
                </div>
              )}

              {verifyType === 'email' && (
                <div className="flex flex-col gap-1.5 sm:gap-2">
                  <Controller
                    name="identifier"
                    control={control}
                    render={({ field, fieldState: { error } }) => (
                      <div className="flex flex-col gap-1.5">
                        <div
                          className={clsx(
                            'w-full h-14 px-4 py-2 flex items-center gap-2 justify-between bg-white border rounded-[8px]',
                            error ? 'border-red-500' : 'border-[#282828]'
                          )}
                        >
                          <input
                            {...field}
                            type="email"
                            disabled={otpSendSuccess}
                            placeholder="Enter email address"
                            className={clsx(
                              'w-full outline-none text-sm font-normal font-roboto bg-transparent',
                              otpSendSuccess && 'bg-gray-50 cursor-not-allowed text-gray-400'
                            )}
                          />
                          <button
                            type="button"
                            onClick={handleSendOtp}
                            disabled={
                              isSendingOtp ||
                              !field.value ||
                              !!error ||
                              otpSendSuccess
                            }
                            className={clsx(
                              'bg-[#2AA29A] text-white rounded-full px-2 py-1 text-xs font-medium font-roboto whitespace-nowrap',
                              (isSendingOtp ||
                                !field.value ||
                                !!error ||
                                otpSendSuccess) &&
                                'opacity-50 cursor-not-allowed'
                            )}
                          >
                            {isSendingOtp ? 'Sending...' : 'Send OTP'}
                          </button>
                        </div>
                        {error && (
                          <span className="text-xs text-red-500">
                            {error.message}
                          </span>
                        )}
                      </div>
                    )}
                  />
                </div>
              )}

              {otpSendSuccess && (
                <div className="max-w-full sm:max-w-[410px] flex flex-col gap-2">
                  <span className="text-sm font-roboto text-light font-medium">
                    Verification code
                  </span>
                  <Controller
                    name="otp"
                    control={control}
                    render={({ field, fieldState: { error } }) => (
                      <>
                        <OTPInput
                          value={field.value}
                          onChange={v => {
                            field.onChange(v)
                          }}
                          numInputs={6}
                          inputType="number"
                          renderSeparator={<span />}
                          renderInput={props => (
                            <input
                              {...props}
                              className={clsx(
                                'min-w-12 min-h-12 sm:min-w-[54px] sm:min-h-[54px] w-full h-full bg-transparent text-black text-lg sm:text-2xl rounded-xl outline-none border focus:border-[#4020FF]',
                                error ? 'border-red-500' : 'border-secondary-lighter'
                              )}
                            />
                          )}
                          containerStyle={{
                            display: 'flex',
                            justifyContent: 'space-between',
                            gap: 1,
                          }}
                        />
                        <div className="flex justify-between items-center">
                          <span className="text-xs text-red-500">
                            {error?.message}
                          </span>
                          {otpExpiryTime > 0 ? (
                            <span className="text-sm font-inter text-dark-main font-normal whitespace-nowrap inline-flex items-center gap-1">
                              Time remaining{' '}
                              <OTPTimer
                                twoFactorOTPexpiryTime={otpExpiryTime.toString()}
                                handleOTPExpiry={handleOtpExpiry}
                              />
                            </span>
                          ) : (
                            <button
                              type="button"
                              onClick={handleResendOtp}
                              disabled={!canResendOtp || isResending}
                              className="text-sm font-medium text-primary-main disabled:opacity-50"
                            >
                              {isResending ? 'Sending...' : 'Resend OTP'}
                            </button>
                          )}
                        </div>
                      </>
                    )}
                  />
                </div>
              )}

              <PasswordInput
                name="password"
                label="Password"
                placeholder="Enter new password"
                required
                variant="standard"
                disabled={!otpSendSuccess}
              />

              <PasswordInput
                name="confirm_password"
                label="Confirm Password"
                placeholder="Confirm new password"
                required
                variant="standard"
                disabled={!otpSendSuccess}
              />

              <div className="flex justify-between items-center gap-5 w-full">
                <Link
                  to="/login"
                  className="h-12 w-1/2 flex justify-center items-center py-2 px-4 rounded-md text-base font-inter font-bold text-primary bg-transparent border border-primary hover:opacity-80 outline-none"
                >
                  Back to Login
                </Link>
                <button
                  type="submit"
                  disabled={!otpSendSuccess || isPending}
                  className={clsx(
                    'h-12 w-1/2 flex justify-center items-center py-2 px-4 border border-transparent rounded-md text-base font-inter font-bold text-white bg-primary-main hover:bg-primary outline-none hover:opacity-80',
                    (!otpSendSuccess || isPending) &&
                      'opacity-50 cursor-not-allowed'
                  )}
                >
                  {isPending ? 'Processing...' : 'Reset Password'}
                </button>
              </div>
            </div>
          </div>
        </form>
      </FormProvider>
    </div>
  )
}
