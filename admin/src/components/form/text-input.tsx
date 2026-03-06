import { useFormContext, Controller } from 'react-hook-form'
import { clsx } from 'clsx'

type Props = {
  name: string
  label?: string
  placeholder: string
  type: string
  autoComplete?: string
  required?: boolean
  variant?: 'outline' | 'standard'
  disabled?: boolean
}

export default function RHFTextField({
  name,
  label,
  required,
  variant = 'outline',
  type,
  disabled = false,
  ...other
}: Props) {
  const { control } = useFormContext()

  return (
    <Controller
      name={name}
      control={control}
      render={({ field, fieldState: { error } }) => (
        <div className="flex flex-col w-full">
          {label && (
            <label className="text-xs sm:text-sm font-roboto text-[#6D6D6D] font-medium mb-1.5 sm:mb-2">
              {label}
              {required && <span className="text-red-500 ml-1">*</span>}
            </label>
          )}
          <input
            {...field}
            {...other}
            disabled={disabled}
            value={type === 'number' && field.value === 0 ? '' : field.value}
            onChange={event => {
              const { value } = event.target
              if (type === 'number') {
                if (value === '') {
                  field.onChange(0)
                  return
                }

                const numericValue = Number(value)
                if (Number.isNaN(numericValue)) {
                  return
                }

                field.onChange(Math.max(0, numericValue))
              } else {
                field.onChange(value)
              }
            }}
            className={clsx(
              'bg-white text-sm font-roboto font-normal w-full outline-none h-11 sm:h-12 rounded-[8px] p-4',
              error ? 'border-red-500' : 'border-secondary-lighter',
              variant === 'outline' && 'border',
              variant === 'standard' && '',
              disabled && 'bg-gray-50 cursor-not-allowed text-gray-400'
            )}
          />
          {error && (
            <span className="text-xs text-red-500 mt-1.5">{error.message}</span>
          )}
        </div>
      )}
    />
  )
}
