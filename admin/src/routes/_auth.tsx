import { createFileRoute, Outlet, redirect } from '@tanstack/react-router'
import { useAuthStore } from '../stores/useStore'

export const Route = createFileRoute('/_auth' as '/_auth')({
  beforeLoad: () => {
    const isAuthenticated = useAuthStore.getState().isAuthenticated
    // If authenticated, redirect to dashboard
    if (isAuthenticated) {
      throw redirect({
        to: '/dashboard',
        search: {
          redirect: location.href,
        },
      })
    }
  },
  component: AuthLayout,
})

function AuthLayout() {
  return (
    <div className="min-h-screen flex items-center justify-center bg-white">
      <div className="max-w-[1108px] w-full mx-auto">
        <div className="grid grid grid-cols-5 h-screen">
          <div className="col-span-3 bg-dark h-full w-full flex items-center justify-center">
            <div className="h-[598px] w-[473px]">
              <img
                src="/illustrations/Photos.png"
                alt="auth-bg"
                className="w-full h-full object-cover"
              />
            </div>
          </div>
          <div className="col-span-2 bg-white w-full h-full">
            <Outlet />
          </div>
        </div>
      </div>
    </div>
  )
}
