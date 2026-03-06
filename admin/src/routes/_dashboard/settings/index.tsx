import { createFileRoute, useNavigate } from '@tanstack/react-router'
import { TablerEditIcon } from '@/components/icon'
import { useGetAdminMe } from '@/api/auth'
import { useAuthIsAuthenticated } from '@/stores/useStore'

export const Route = createFileRoute('/_dashboard/settings/')({
  component: SettingsPage,
})

function SettingsPage() {
  const navigate = useNavigate()
  const isAuth = useAuthIsAuthenticated()
  const { data, isLoading } = useGetAdminMe({ isAuth })

  if (isLoading || !data) {
    return (
      <div className="max-w-7xl mx-auto px-5 py-10 flex items-center justify-center">
        <span className="text-light-secondary">Loading...</span>
      </div>
    )
  }

  return (
    <div className="max-w-7xl mx-auto px-5 py-10 flex flex-col gap-8 w-full">
      <div className="flex items-center gap-2 justify-between">
        <h2 className="text-2xl font-semibold font-poppins text-light-main">
          Admin Information
        </h2>
        <button
          onClick={() => navigate({ to: '/settings/edit' })}
          className="flex items-center gap-2 px-4 py-2 bg-transparent border border-primary-main rounded-[6px] text-base font-roboto font-medium text-primary-main"
        >
          <TablerEditIcon />
          Edit
        </button>
      </div>

      <div className="flex flex-col bg-dark-main rounded-[8px] p-4 gap-6">
        <h3 className="text-2xl font-semibold font-poppins text-light my-2">
          Personal Information
        </h3>
        <div className="flex flex-col gap-4">
          <div className="flex justify-between items-center py-2 h-12">
            <span className="w-1/4 text-lg font-medium text-light font-poppins">
              Email Address
            </span>
            <span className="w-3/4 text-base font-semibold text-light-active">
              {data.email ?? '—'}
            </span>
          </div>
          <div className="flex justify-between items-center py-2 h-12">
            <span className="w-1/4 text-lg font-medium text-light font-poppins">
              Mobile Number
            </span>
            <span className="w-3/4 text-base font-semibold text-light-active">
              {data.phoneNumber ?? '—'}
            </span>
          </div>
          <div className="flex justify-between items-center py-2 h-12">
            <span className="w-1/4 text-lg font-medium text-light font-poppins">
              Password
            </span>
            <span className="w-3/4 text-base font-semibold text-light-active">
              **********
            </span>
          </div>
        </div>
      </div>
    </div>
  )
}
