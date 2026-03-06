import { useFormContext, Controller } from 'react-hook-form'
import { EyeIcon, EyeClosedIcon } from '../icon'
import { useState } from 'react'
import { clsx } from 'clsx'

type Props = {
  name: string
  label?: string
  secondaryLabel?: string
  placeholder: string
  autoComplete?: string
  required?: boolean
  variant?: 'outline' | 'standard'
  disabled?: boolean
}

export default function PasswordInput({
  name,
  label,
  secondaryLabel,
  required,
  variant = 'outline',
  disabled = false,
  ...other
}: Props) {
  const { control } = useFormContext()
  const [showPassword, setShowPassword] = useState(false)
  return (
    <Controller
      name={name}
      control={control}
      render={({ field, fieldState: { error } }) => (
        <div className="flex flex-col">
          <div className="flex flex-col gap-1.5 sm:gap-2 mb-1.5 sm:mb-2">
            {label && (
              <label className="text-xs sm:text-sm font-roboto text-[#6D6D6D] font-medium">
                {label}
                {required && <span className="text-red-500 ml-1">*</span>}
              </label>
            )}
            {secondaryLabel && (
              <span className="text-xs sm:text-sm font-poppins text-[#666666] font-normal">
                {secondaryLabel}
              </span>
            )}
          </div>
          <div className="relative">
            <input
              {...field}
              {...other}
              id={name}
              autoComplete="new-password"
              type={showPassword ? 'text' : 'password'}
              disabled={disabled}
              className={clsx(
                'text-sm font-roboto font-normal w-full outline-none h-11 sm:h-12 rounded-[8px] p-4',
                error ? 'border-red-500' : 'border-secondary-lighter',
                variant === 'outline' && 'border',
                variant === 'standard' && '',
                disabled ? 'bg-gray-100 cursor-not-allowed text-gray-400' : 'bg-white'
              )}
            />
            <button
              type="button"
              onClick={() => setShowPassword(!showPassword)}
              disabled={disabled}
              className="absolute right-4 top-1/2 -translate-y-1/2 text-[#666666] cursor-pointer"
            >
              {showPassword ? <EyeClosedIcon /> : <EyeIcon />}
            </button>
          </div>
          {error && (
            <span className="text-xs text-red-500 mt-1.5">{error.message}</span>
          )}
        </div>
      )}
    />
  )
}
