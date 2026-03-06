import { useState } from 'react'
import { createFileRoute } from '@tanstack/react-router'
import {
  FundsReceivedIcon,
  FundsSendIcon,
  TransactionsIcon,
  UserGroupIcon,
  KYCCompletedIcon,
} from '@/components/icon'
import clsx from 'clsx'
import DateRangeFilter from '../../../components/common/date-range-filter'
import { useGetDashboardStats } from '@/api/dashboard'

export const Route = createFileRoute('/_dashboard/dashboard/')({
  component: DashboardPage,
})

function DashboardPage() {
  const [dateRange, setDateRange] = useState<{
    from: Date | null
    to: Date | null
  }>({
    from: null,
    to: null,
  })

  // Convert dates to ISO string format for API
  // For fromDate, set time to start of day (00:00:00.000Z)
  const formatDateForAPI = (date: Date | null): string | undefined => {
    if (!date) return undefined
    const startOfDay = new Date(date)
    startOfDay.setHours(0, 0, 0, 0)
    return startOfDay.toISOString()
  }

  // For toDate, set time to end of day (23:59:59.999Z)
  const formatToDateForAPI = (date: Date | null): string | undefined => {
    if (!date) return undefined
    const endOfDay = new Date(date)
    endOfDay.setHours(23, 59, 59, 999)
    return endOfDay.toISOString()
  }

  const { data: stats } = useGetDashboardStats({
    fromDate: formatDateForAPI(dateRange.from),
    toDate: formatToDateForAPI(dateRange.to),
  })

  const handleDateRangeConfirm = (range: { from: Date; to: Date }) => {
    setDateRange({
      from: range.from,
      to: range.to,
    })
  }

  const handleDateRangeCancel = () => {
    // Optionally reset dates on cancel
    // setDateRange({ from: null, to: null })
  }


  const dashboardStats: Array<{
    title: string
    value: string | number | undefined
    color: string
    icon: React.ReactNode
  }> = [
    {
      title: 'Funds Received',
      value: stats?.totalFundsReceived,
      color: 'text-[#FF6F61]',
      icon: <FundsReceivedIcon />,
    },
    {
      title: 'Total Funds Sent',
      value: stats?.totalFundsSent,
      color: 'text-[#A5FFD6]',
      icon: <FundsSendIcon />,
    },
    {
      title: 'Total External Sent',
      value: stats?.totalExternalSent,
      color: 'text-[#698CFF]',
      icon: <FundsSendIcon />,
    },
    {
      title: 'Total Transactions',
      value: stats?.totalTransactions,
      color: 'text-[#F06292]',
      icon: <TransactionsIcon />,
    },
    {
      title: 'Total Users',
      value: stats?.totalUsers,
      color: 'text-[#FFB800]',
      icon: <UserGroupIcon />,
    },
    {
      title: 'Total KYC Completed Users',
      value: stats?.totalKycCompletedUsers,
      color: 'text-[#2AA29A]',
      icon: <KYCCompletedIcon />,
    },
  ]
  return (
    <div className="max-w-7xl mx-auto py-10 px-5 flex flex-col gap-10">
      <div className="flex justify-between items-center">
        <h2 className="text-2xl font-semibold text-light-main">Dashboard</h2>
        <DateRangeFilter
          onConfirm={handleDateRangeConfirm}
          onCancel={handleDateRangeCancel}
          initialFrom={dateRange.from || undefined}
          initialTo={dateRange.to || undefined}
        />
      </div>
      <div className="grid grid-cols-3 gap-3">
        {dashboardStats?.map(stat => (
          <div key={stat.title} className="col-span-1">
            <div
              className={clsx(
                'bg-dark-main rounded-lg w-full px-6 py-4 flex flex-col gap-2',
                stat.color
              )}
            >
              <h3 className="text-[32px] font-semibold font-poppins">
                {stat.value}
              </h3>
              <div className="flex items-center gap-2">
                {stat.icon}
                <span className="text-light-active text-sm font-normal font-roboto text-light-secondary">
                  {stat.title}
                </span>
              </div>
            </div>
          </div>
        ))}
      </div>
    </div>
  )
}
