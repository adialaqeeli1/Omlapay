import { createFileRoute, Outlet, redirect } from '@tanstack/react-router'
import { useAuthStore, useAuthIsAuthenticated } from '../stores/useStore'
import { useGetAdminMe, useLogout } from '@/api/auth'
import { useGetOpenTicketCount } from '@/api/tickets'
import { useGetUnreadCount } from '@/api/notifications'
import {
  DashboardIcon,
  UsersIcon,
  SupportIcon,
  SettingsIcon,
  LogoutIcon,
  NotificationIcon,
  WalletIcon,
  BrandLogo,
} from '../components/icon'
import clsx from 'clsx'
import { useLocation, useNavigate } from '@tanstack/react-router'

export const Route = createFileRoute('/_dashboard')({
  beforeLoad: ({ location }) => {
    const isAuthenticated = useAuthStore.getState().isAuthenticated
    // If not authenticated, redirect to login
    if (!isAuthenticated) {
      throw redirect({
        to: '/login',
        search: {
          redirect: location.href,
        },
      })
    }
  },
  component: DashboardLayout,
})

function DashboardLayout() {
  const location = useLocation()
  const pathname = location.pathname
  const navigate = useNavigate()
  const isAuth = useAuthIsAuthenticated()
  const { data: admin } = useGetAdminMe({ isAuth })
  const { mutate: logout, isPending: isLoggingOut } = useLogout()
  const { data: openCountData } = useGetOpenTicketCount()
  const { data: unreadCountData } = useGetUnreadCount()
  const SidebarItem = [
    {
      label: 'Dashboard',
      icon: <DashboardIcon />,
      href: '/dashboard',
    },
    {
      label: 'Users',
      icon: <UsersIcon />,
      href: '/dashboard/users',
    },
    {
      icon: <SupportIcon />,
      label: 'Support',
      href: '/support',
      badgeValue: openCountData?.openCount,
    },
    {
      icon: <WalletIcon />,
      label: 'Fees',
      href: '/fees',
    },
    {
      icon: <SettingsIcon />,
      label: 'Settings',
      href: '/settings',
    },
    {
      icon: <NotificationIcon />,
      label: 'Notification',
      href: '/notifications',
      badgeValue: unreadCountData?.unreadCount,
    },
  ]
  return (
    <div className="min-h-screen flex flex-col">
      <div
        className={clsx(
          'fixed top-0 left-0 w-[var(--sidebar-width)] h-full bg-[#111111] z-30 py-10'
        )}
      >
        <div className="h-full py-5 flex flex-col gap-[30px] lg:gap-10 border-r border-main shadow-primary1">
          <div className="flex gap-4 items-center px-10">
            <BrandLogo />
            <span className="text-2xl font-extrabold inline-block text-transparent bg-clip-text bg-[radial-gradient(79.47%_235.94%_at_3.68%_100%,#FFFFFF_24.44%,#B9E0DE_49.23%,#2AA29A_100%)]">
              OMLAPAY
            </span>
          </div>
          <div className="flex flex-col gap-[14px] px-5">
            {SidebarItem?.map((navItem, index) => (
              <button
                key={index}
                onClick={() => {
                  if (navItem?.href) {
                    navigate({ to: navItem?.href })
                  }
                }}
                className={clsx(
                  'group h-10 text-lg font-medium font-poppins inline-flex items-center gap-4 px-5 py-1.5 rounded-[6px] cursor-pointer',
                  pathname === navItem?.href
                    ? 'text-light-active bg-primary-light'
                    : 'text-light hover:opacity-80'
                )}
              >
                {navItem?.icon}
                <span> {navItem?.label}</span>
                {navItem?.badgeValue && (
                  <span className="text-xs font-medium font-poppins inline-flex items-center justify-center bg-dark-lighter text-light-active rounded-full px-2 py-1">
                    {navItem?.badgeValue}
                  </span>
                )}
              </button>
            ))}
          </div>
          <div className="w-full mt-auto">
            <div className="h-[0.5px] bg-[#4A5A59] mb-8" />
            <div className="flex flex-col gap-[14px]">
              <span className="text-light-active h-10 text-lg font-medium font-poppins inline-flex items-center px-5 py-1.5 rounded-[6px] cursor-pointer">
                {admin?.email ?? '—'}
              </span>
              <button
                type="button"
                onClick={() => logout()}
                disabled={isLoggingOut}
                className={clsx(
                  'text-danger h-10 text-lg font-medium font-poppins inline-flex items-center gap-4 px-5 py-1.5 rounded-[6px] cursor-pointer hover:opacity-80',
                  isLoggingOut && 'opacity-50 cursor-not-allowed'
                )}
              >
                <LogoutIcon />
                <span>{isLoggingOut ? 'Logging out...' : 'Logout'}</span>
              </button>
            </div>
          </div>
        </div>
      </div>
      <main className="py-10 ml-[var(--sidebar-width)] flex-1">
        <Outlet />
      </main>
    </div>
  )
}
