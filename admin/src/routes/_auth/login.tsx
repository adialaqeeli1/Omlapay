import { useState, useMemo, useEffect, useCallback } from 'react'
import { createFileRoute, useNavigate } from '@tanstack/react-router'
import { FormProvider, useForm, Controller } from 'react-hook-form'
import { zodResolver } from '@hookform/resolvers/zod'
// import RHFTextField from '../../components/form/text-input'
import PasswordInput from '../../components/form/password-input'
import { Field, Checkbox, Label } from '@headlessui/react'
import { z } from 'zod'
import { useAuthActions } from '../../stores/useStore'
import clsx from 'clsx'
import RHFTextField from '@/components/form/text-input'
import OTPInput from 'react-otp-input'
import { useLogin, useSendOtp } from '@/api/auth'
import { toast } from 'react-toastify'
import { SaudiFlag } from '@/components/icon'
import { formatSaudiPhoneNumber } from "@/utils/format"
import OTPTimer from '@/components/common/otp-timer'


type LoginFormData = {
  email?: string
  phone_number?: string
  password: string
  otp?: string
  remember_me?: boolean
  terms_and_conditions?: boolean
}

const baseLoginSchema = z.object({
  email: z.string().optional(),
  phone_number: z.string().optional(),
  password: z
    .string()
    .min(1, 'Password is required')
    .min(8, 'Password must be at least 8 characters'),
  otp: z
    .string()
    .length(6, 'OTP must be 6 digits')
    .regex(/^\d+$/, 'OTP must be numeric')
    .optional(),
  remember_me: z.boolean().optional(),
  terms_and_conditions: z.boolean().optional(),
})



export const Route = createFileRoute('/_auth/login')({
  component: LoginPage,
})

function LoginPage() {
  const navigate = useNavigate()
  const { setAuthToken } = useAuthActions()
  const { mutate: adminLogin, isPending } = useLogin()
  const { mutate: sendOtp, isPending: isSendingOtp } = useSendOtp()
  const [loginError, setLoginError] = useState('')
  const [loginType, setLoginType] = useState<'mobile' | 'email'>('mobile')
  const [otpSendSuccess, setOtpSendSuccess] = useState(false)
  const [canResendOtp, setCanResendOtp] = useState(true)
  const [isOtpExpired, setIsOtpExpired] = useState(false)
  const [twoFactorOTPexpiryTime, setTwoFactorOTPexpiryTime] = useState<number>(0)


  const handleOtpChange = (value: string) => {
    setValue('otp', value, { shouldValidate: true })
  }


  // Create dynamic schema based on loginType
  const loginSchema = useMemo(
    () =>
      baseLoginSchema
        .refine(
          data => {
            if (loginType === 'mobile') {
              return data.phone_number && data.phone_number.trim().length > 0
            } else {
              return data.email && data.email.trim().length > 0
            }
          },
          {
            message:
              loginType === 'mobile'
                ? 'Phone number is required'
                : 'Email is required',
            path: [loginType === 'mobile' ? 'phone_number' : 'email'],
          }
        )
        .refine(
          data => {
            if (loginType === 'email' && data.email) {
              return z.string().email().safeParse(data.email).success
            }
            return true
          },
          {
            message: 'Please enter a valid email',
            path: ['email'],
          }
        )
        .refine(
          data => {
            if (loginType === 'mobile' && data.phone_number) {
              // Remove all non-digit characters
              const digitsOnly = data.phone_number.replace(/\D/g, '')
              // Accept:
              // - 9 digits starting with 5 (5XXXXXXXX)
              // - 10 digits starting with 05 (05XXXXXXXX)
              // - 12 digits starting with 966 (9665XXXXXXXX)
              const isValidFormat =
                (digitsOnly.length === 9 && digitsOnly.startsWith('5')) ||
                (digitsOnly.length === 10 && digitsOnly.startsWith('05')) ||
                (digitsOnly.length === 12 && digitsOnly.startsWith('966'))
              return isValidFormat
            }
            return true
          },
          {
            message: 'Please enter a valid Saudi phone number (05XXXXXXXX)',
            path: ['phone_number'],
          }
        ),
    [loginType]
  )

  const methods = useForm<LoginFormData>({
    resolver: zodResolver(loginSchema),
    mode: 'onChange',
    defaultValues: {
      email: '',
      phone_number: '',
      password: '',
      otp: '',
      remember_me: false,
      terms_and_conditions: false,
    },
  })

  const {
    handleSubmit,
    watch,
    setValue,
    control,
    trigger,
    clearErrors,
    reset,
    formState: { errors },
  } = methods

  const remember_me = watch('remember_me')
  const terms_and_conditions = watch('terms_and_conditions')

  const handleLoginTypeChange = (type: 'mobile' | 'email') => {
    setLoginType(type)
  }

  const onSubmit = async (data: LoginFormData) => {
    const otpValue = (data.otp || '').trim()
    if (!otpSendSuccess) return

    try {
      setLoginError('')

      // Format phone number if mobile login type
      let identifier = data.email || data.phone_number || ''
      if (loginType === 'mobile' && data.phone_number) {
        identifier = formatSaudiPhoneNumber(data.phone_number)
      }

      adminLogin({
        identifier: identifier,
        password: data.password,
        otp: otpValue,
        acceptTerms: terms_and_conditions,
      }, {
        onSuccess: () => {
          toast.success('Login successful!')
          navigate({ to: '/dashboard' })
        },
        onError: (error: any) => {
          const errorMessage = error?.message || 'Login failed. Please try again.'
          setLoginError(errorMessage)
          toast.error(errorMessage)
        }
      })

    } catch (error: any) {
      const errorMessage = error?.message || 'An unexpected error occurred'
      toast.error(errorMessage)
    }

  }

  const handleSendOtp = async (identifier: string) => {
    const isValid = await trigger(['phone_number', 'email']);
    if (!isValid) return;
    try {
      let formattedIdentifier = identifier.trim()

      // Format phone number if mobile login type
      if (loginType === "mobile") {
        formattedIdentifier = formatSaudiPhoneNumber(identifier)
      }

      sendOtp({ identifier: formattedIdentifier }, {
        onSuccess: () => {
          setOtpSendSuccess(true)
          setCanResendOtp(false)
          setIsOtpExpired(false)
          toast.success('OTP sent successfully!')
          setTwoFactorOTPexpiryTime(Date.now() + 60 * 1000) // 1 minute cooldown
        },
        onError: (error: any) => {
          const errorMessage = error?.message || 'Failed to send OTP. Please try again.'
          toast.error(errorMessage)
        }
      })
    } catch (error: any) {
      const errorMessage = error?.message || 'An unexpected error occurred'
      toast.error(errorMessage)

    }
  }

  const handleOTPExpiry = useCallback(() => {
    setTwoFactorOTPexpiryTime(0);
    setCanResendOtp(true);
    setIsOtpExpired(true);
  }, []);


  return (
    <div className="h-full flex flex-col gap-8 items-center justify-center w-[485px] -ml-28">
      <div className="flex flex-col gap-3 items-center justify-center">
        <h3 className="text-2xl font-semibold font-poppins text-[#161326]">
          Hello
        </h3>
        <p className="text-sm font-normal font-roboto text-[#6D6D6D]">
          Welcome again to our website
        </p>
      </div>
      <FormProvider {...methods}>
        <form onSubmit={handleSubmit(onSubmit)} className="w-full">
          <div className="flex flex-col gap-8 p-9 rounded-[12px] bg-[#F8F8F8] w-full">
            <h2 className="text-2xl font-semibold text-[#161326] leading-9">
              Login
            </h2>
            <div className="flex flex-col gap-6">

              <div className="flex flex-col gap-5">
                <div className="w-[345px] p-1 rounded-[12px] bg-[#E5E5E5] mx-auto">
                  <button
                    type="button"
                    className={clsx(
                      'w-1/2 text-base font-semibold font-inter rounded-[8px] h-9',
                      loginType === 'mobile' && 'bg-[#2AA29A] text-white'
                    )}
                    onClick={() => handleLoginTypeChange('mobile')}
                  >
                    Mobile
                  </button>
                  <button
                    type="button"
                    className={clsx(
                      'w-1/2 text-base font-semibold font-inter rounded-[8px] h-9',
                      loginType === 'email' && 'bg-[#2AA29A] text-white'
                    )}
                    onClick={() => handleLoginTypeChange('email')}
                  >
                    Email
                  </button>
                </div>
              </div>
              {loginType === 'mobile' && (
                <div className="flex gap-1.5 sm:gap-2">
                  <div className='flex gap-1.5 items-center h-14 bg-[#E5E5E5] px-2 py-1 rounded-[8px]'>
                    <SaudiFlag />
                    <span className='text-sm font-medium font-inter text-[#6D6D6D]'>+966</span>
                  </div>
                  <Controller
                    name="phone_number"
                    control={control}
                    render={({ field, fieldState: { error } }) => {
                      const handlePhoneChange = (e: React.ChangeEvent<HTMLInputElement>) => {
                        const value = e.target.value
                        // Allow user to type digits only (we'll format on blur or send)
                        const digitsOnly = value.replace(/\D/g, '')
                        field.onChange(digitsOnly)
                      }

                      const handlePhoneBlur = () => {
                        if (field.value) {
                          // Format the phone number when user leaves the field
                          const formatted = formatSaudiPhoneNumber(field.value)
                          // Store only the digits without country code in the form (for display)
                          // But we'll use the formatted version when sending
                          const displayValue = formatted.startsWith('+966')
                            ? formatted.replace('+966', '')
                            : field.value
                          field.onChange(displayValue)
                        }
                        field.onBlur()
                      }

                      return (
                        <div className="flex flex-col gap-1.5 flex-1">
                          <div
                            className={clsx(
                              'w-full h-14 px-4 py-2 flex items-center gap-2 justify-between bg-white border rounded-[8px]',
                              error
                                ? 'border-red-500'
                                : 'border-[#282828]'
                            )}
                          >
                            <input
                              {...field}
                              type="tel"
                              disabled={otpSendSuccess}
                              placeholder="05XXXXXXXX"
                              className="w-full outline-none text-sm font-normal font-roboto bg-transparent"
                              onChange={handlePhoneChange}
                              onBlur={handlePhoneBlur}
                            />
                            <button
                              type="button"
                              onClick={() => {
                                if (field.value && !error) {
                                  const formattedPhone = formatSaudiPhoneNumber(field.value)
                                  handleSendOtp(formattedPhone)
                                }
                              }}
                              disabled={!canResendOtp || isSendingOtp || !!error || !field.value}
                              className={clsx(
                                'bg-[#2AA29A] text-white rounded-full px-2 py-1 text-xs font-medium font-roboto whitespace-nowrap',
                                (!canResendOtp || isSendingOtp || !!error || !field.value) &&
                                'opacity-50 cursor-not-allowed'
                              )}
                            >
                              {isSendingOtp ? 'Sending...' : otpSendSuccess ? 'Resend OTP' : 'Send OTP'}
                            </button>
                          </div>
                          {error && (
                            <span className="text-xs text-red-500">
                              {error.message}
                            </span>
                          )}
                        </div>
                      )
                    }}
                  />
                </div>
              )}
              {loginType === 'email' && (
                <div className="flex flex-col gap-1.5 sm:gap-2">
                  <Controller
                    name="email"
                    control={control}
                    render={({ field, fieldState: { error } }) => (
                      <div className="flex flex-col gap-1.5 sm:gap-2">
                        <div
                          className={clsx(
                            'w-full h-14 px-4 py-2 flex items-center gap-2 justify-between bg-white border rounded-[8px]',
                            error
                              ? 'border-red-500'
                              : 'border-[#282828]'
                          )}
                        >
                          <input
                            {...field}
                            type="email"
                            disabled={otpSendSuccess}
                            placeholder="Enter email address"
                            className={clsx("w-full outline-none text-sm font-normal font-roboto bg-transparent", otpSendSuccess && 'bg-gray-50 cursor-not-allowed text-gray-400')}
                          />
                          <button
                            type="button"
                            onClick={() => {
                              if (field.value && !error) {
                                handleSendOtp(field.value)
                              }
                            }}
                            disabled={!canResendOtp || isSendingOtp || !!error || !field.value}
                            className={clsx(
                              'bg-[#2AA29A] text-white rounded-full px-2 py-1 text-xs font-medium font-roboto whitespace-nowrap',
                              (!canResendOtp || isSendingOtp || !!error || !field.value) &&
                              'opacity-50 cursor-not-allowed'
                            )}
                          >
                            {isSendingOtp ? 'Sending...' : otpSendSuccess ? 'Resend OTP' : 'Send OTP'}
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

              <div className="max-w-full sm:max-w-[410px] flex flex-col gap-2">
                <span className="text-sm font-roboto text-[#6D6D6D] font-medium">
                  Verification code
                  <span className="text-red-500 ml-1">*</span>
                </span>
                <OTPInput
                  value={watch('otp') || ''}
                  onChange={handleOtpChange}
                  numInputs={6}
                  inputType="number"
                  renderSeparator={<span />}
                  renderInput={props => (
                    <input
                      {...props}
                      disabled={!otpSendSuccess}
                      className={clsx(
                        'min-w-12 min-h-12 sm:min-w-[54px] sm:min-h-[54px] w-full h-full text-black text-lg sm:text-2xl rounded-xl outline-none border focus:border-[#4020FF]',
                        errors.otp ? 'border-red-500' : 'border-secondary-lighter',
                        !otpSendSuccess ? 'bg-gray-100 cursor-not-allowed text-gray-400' : 'bg-white'
                      )}
                    />
                  )}
                  containerStyle={{
                    display: 'flex',
                    justifyContent: 'space-between',
                    gap: 1,
                  }}
                />
                <div className='flex justify-between items-center'>
                  <span className="text-xs text-red-500">
                    {errors.otp ? (errors.otp.message as string) : ''}
                  </span>

                  {otpSendSuccess && (
                    isOtpExpired ? (
                      <span className="text-xs font-inter text-orange-500 whitespace-nowrap">
                        OTP expired
                      </span>
                    ) : (
                      <span className="text-sm font-inter text-dark-main font-normal whitespace-nowrap inline-flex items-center gap-1">
                        Time remaining{' '}
                        <OTPTimer twoFactorOTPexpiryTime={twoFactorOTPexpiryTime.toString()} handleOTPExpiry={handleOTPExpiry} />
                      </span>
                    )
                  )}
                </div>
              </div>

              <div className="flex flex-col gap-1.5 sm:gap-2">
                <PasswordInput
                  name="password"
                  label="Password"
                  placeholder="Enter password"
                  required
                  variant="standard"
                  disabled={!otpSendSuccess}
                />
                <div className="flex justify-between items-center gap-4 sm:gap-6">
                  <Field className="flex gap-2 py-2">
                    <Checkbox
                      checked={remember_me || false}
                      onChange={() => {
                        setValue('remember_me', !remember_me)
                      }}
                      className="shrink-0 group block size-5 rounded border border-gray-300 bg-white data-checked:bg-black data-checked:border-black"
                    >
                      <svg
                        className="stroke-white opacity-0 group-data-checked:opacity-100"
                        viewBox="0 0 14 14"
                        fill="none"
                      >
                        <path
                          d="M3 8L6 11L11 3.5"
                          strokeWidth={2}
                          strokeLinecap="round"
                          strokeLinejoin="round"
                        />
                      </svg>
                    </Checkbox>
                    <Label className="text-sm font-roboto text-[#21272A] font-medium leading-5">
                      Remember me
                    </Label>
                  </Field>
                  <a
                    href="/forget-password"
                    className="text-[10px] font-roboto text-[#21272A] font-normal underline"
                  >
                    Forgot Password?
                  </a>
                </div>

                <Field className="flex gap-2 py-2">
                  <Checkbox
                    checked={terms_and_conditions || false}
                    onChange={() => {
                      setValue('terms_and_conditions', !terms_and_conditions)
                    }}
                    className="shrink-0 group block size-5 rounded border border-gray-300 bg-white data-checked:bg-black data-checked:border-black"
                  >
                    <svg
                      className="stroke-white opacity-0 group-data-checked:opacity-100"
                      viewBox="0 0 14 14"
                      fill="none"
                    >
                      <path
                        d="M3 8L6 11L11 3.5"
                        strokeWidth={2}
                        strokeLinecap="round"
                        strokeLinejoin="round"
                      />
                    </svg>
                  </Checkbox>
                  <Label className="text-sm font-roboto text-[#21272A] font-normal leading-5">
                    By proceeding, you agree to the{' '}
                    <span className="text-[#161326] font-medium">
                      Terms and Conditions
                    </span>
                  </Label>
                </Field>
              </div>
              {loginError && (
                <p className="text-sm text-red-500">{loginError}</p>
              )}
              <button
                type="submit"
                disabled={!otpSendSuccess}
                className={clsx("h-12 w-full flex justify-center items-center py-2 px-4 border border-transparent rounded-md text-base font-inter font-bold text-white bg-primary-main hover:bg-primary outline-none", !otpSendSuccess && 'opacity-50 cursor-not-allowed')}
              >
                Log In
              </button>
            </div>
          </div>
        </form>
      </FormProvider>
    </div>
  )
}
