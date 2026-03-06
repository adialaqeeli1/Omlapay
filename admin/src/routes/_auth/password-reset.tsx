import { createFileRoute, useNavigate } from '@tanstack/react-router'
import { FormProvider, useForm } from 'react-hook-form'
import { zodResolver } from '@hookform/resolvers/zod'
import PasswordInput from '../../components/form/password-input'
import { z } from 'zod'

const passwordResetSchema = z
  .object({
    password: z
      .string()
      .min(1, 'Password is required')
      .min(8, 'Password must be at least 8 characters'),
    confirm_password: z
      .string()
      .min(1, 'Confirm password is required')
      .min(8, 'Confirm password must be at least 8 characters'),
  })
  .refine(data => data.password === data.confirm_password, {
    path: ['confirm_password'],
    message: 'Passwords do not match',
  })

type PasswordResetFormData = z.infer<typeof passwordResetSchema>

export const Route = createFileRoute('/_auth/password-reset' as '/_auth/password-reset')({
  component: PasswordResetPage,
})

function PasswordResetPage() {
  const navigate = useNavigate()
  const methods = useForm<PasswordResetFormData>({
    resolver: zodResolver(passwordResetSchema),
    mode: 'onChange',
    defaultValues: {
      password: '',
      confirm_password: '',
    },
  })

  const { handleSubmit } = methods

  const onSubmit = async (data: PasswordResetFormData) => {
    console.log(data)
    navigate({ to: '/login' })
  }

  const handleCancel = () => {
    navigate({ to: '/login' })
  }

  return (
    <div className="h-full flex flex-col gap-8 items-center justify-center w-[485px] -ml-28">
      <FormProvider {...methods}>
        <form onSubmit={handleSubmit(onSubmit)} className="w-full">
          <div className="flex flex-col gap-8 p-9 rounded-[12px] bg-[#F8F8F8] w-full">
            <h2 className="text-2xl font-semibold text-[#161326] leading-9">
              Reset Password
            </h2>
            <div className="flex flex-col gap-8">
              <PasswordInput
                name="password"
                label="Password"
                placeholder="Enter password"
                required
                variant="standard"
              />

              <PasswordInput
                name="confirm_password"
                label="Confirm Password"
                placeholder="Confirm password"
                required
                variant="standard"
              />
              <div className="flex justify-between items-center gap-5">
                <button
                  type="button"
                  onClick={handleCancel}
                  className="w-full h-12 flex justify-center items-center py-2 px-4 border border-transparent rounded-md text-base font-inter font-bold text-primary-main bg-white border border-primary outline-none"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  className="w-full h-12 flex justify-center items-center py-2 px-4 border border-transparent rounded-md text-base font-inter font-bold text-white bg-primary-main hover:bg-primary outline-none"
                >
                  Reset
                </button>
              </div>
            </div>
          </div>
        </form>
      </FormProvider>
    </div>
  )
}
