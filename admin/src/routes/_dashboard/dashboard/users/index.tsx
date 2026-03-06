import { createFileRoute, Link } from '@tanstack/react-router'
import { useMemo, useState, useCallback, useEffect } from 'react'
import { type ColumnDef } from '@tanstack/react-table'
import { DataTable } from '@/components/common/data-table'
import DateRangeFilter from '../../../../components/common/date-range-filter'
import { SearchIcon, AvatarIcon, VisibleIcon, CloseIcon } from '@/components/icon'
import clsx from 'clsx'
import {
  useGetUserList,
  type UserListItem,
  type UserListTabFilter,
} from '@/api/users'
import { format } from 'date-fns'

const TAB_TO_FILTER: Record<string, UserListTabFilter> = {
  all_users: 'ALL',
  kyc_users: 'KYC',
  non_kyc_users: 'NON_KYC',
  blocked_users: 'BLOCKED',
}

const tabs = [
  { label: 'All Users', value: 'all_users' },
  { label: 'KYC Users', value: 'kyc_users' },
  { label: 'Non-KYC Users', value: 'non_kyc_users' },
  { label: 'Blocked Users', value: 'blocked_users' },
]

export const Route = createFileRoute('/_dashboard/dashboard/users/')({
  component: UsersListPage,
})

function UsersListPage() {
  const [activeTab, setActiveTab] = useState(tabs[0].value)
  const [search, setSearch] = useState('')
  const [searchDebounced, setSearchDebounced] = useState('')
  const [page, setPage] = useState(1)
  const [dateRange, setDateRange] = useState<{
    from: Date | null
    to: Date | null
  }>({ from: null, to: null })

  const formatDateForAPI = (date: Date | null): string | undefined => {
    if (!date) return undefined
    const d = new Date(date)
    d.setHours(0, 0, 0, 0)
    return d.toISOString()
  }

  const formatToDateForAPI = (date: Date | null): string | undefined => {
    if (!date) return undefined
    const d = new Date(date)
    d.setHours(23, 59, 59, 999)
    return d.toISOString()
  }

  const { data, isLoading } = useGetUserList({
    page,
    filter: TAB_TO_FILTER[activeTab],
    search: searchDebounced || undefined,
    dateFrom: formatDateForAPI(dateRange.from),
    dateTo: formatToDateForAPI(dateRange.to),
  })

  useEffect(() => {
    const timer = setTimeout(() => {
      setSearchDebounced(search.trim())
      setPage(1)
    }, 300)
    return () => clearTimeout(timer)
  }, [search])

  const handleDateRangeConfirm = useCallback((range: { from: Date; to: Date }) => {
    setDateRange({ from: range.from, to: range.to })
    setPage(1)
  }, [])

  const handleTabChange = (tab: string) => {
    setActiveTab(tab)
    setPage(1)
  }

  const handleClearFilters = () => {
    setSearch('')
    setSearchDebounced('')
    setActiveTab(tabs[0].value)
    setDateRange({ from: null, to: null })
    setPage(1)
  }

  const handlePageChange = (pageIndex: number) => setPage(pageIndex + 1)

  const hasActiveFilters =
    search.trim() !== '' ||
    activeTab !== tabs[0].value ||
    dateRange.from !== null ||
    dateRange.to !== null

  const columns = useMemo<ColumnDef<UserListItem>[]>(
    () => [
      {
        accessorKey: 'name',
        header: 'Name',
        cell: ({ row }) => {
          const fullName = row.original.fullName
          const email = row.original.email
          const displayName = fullName || email || row.original.phoneNumber || '—'
          return (
            <div className="flex items-center gap-1">
              <AvatarIcon />
              <div className="flex flex-col">
                <span className="text-xs font-inter text-primary font-semibold">
                  {displayName}
                </span>
                <span className="text-[#9C9C9C] text-xs font-medium font-inter">
                  {email}
                </span>
              </div>
            </div>
          )
        },
      },
      {
        accessorKey: 'dateRegistered',
        header: 'Created At',
        cell: ({ row }) => {
          const d = row.original.dateRegistered
          return format(new Date(d), 'dd MMM yyyy')
        },
      },
      {
        accessorKey: 'mainWallet',
        header: 'Main Wallet',
        cell: ({ row }) => {
          const addr = row.original.mainWallet ?? '—'
          return (
            <div className="text-xs font-roboto text-light-active font-normal bg-[#9D9D9D14] px-2.5 py-[2px] rounded-full max-w-[137px] truncate text-ellipsis overflow-hidden">
              {addr}
            </div>
          )
        },
      },
      {
        accessorKey: 'totalBalance',
        header: 'Total Balance',
      },
      {
        accessorKey: 'status',
        header: 'Status',
        cell: ({ row }) => {
          const status = row.original.status
          const isActive = status === 'ACTIVE'
          return (
            <span
              className={`inline-flex px-2 py-1 text-xs font-medium rounded ${
                isActive ? 'bg-green-500/20 text-green-400' : 'bg-red-500/20 text-red-400'
              }`}
            >
              {isActive ? 'Active' : 'Blocked'}
            </span>
          )
        },
      },
      {
        id: 'actions',
        header: 'Actions',
        cell: ({ row }) => {
          const user = row.original
          return (
            <Link
              to="/dashboard/users/$userId"
              params={{ userId: user.id }}
              className="text-primary-main hover:text-primary-dark text-sm font-medium"
            >
              <VisibleIcon />
            </Link>
          )
        },
      },
    ],
    []
  )

  const users = data?.data ?? []
  const pagination = data?.pagination ?? {
    page: 1,
    totalPages: 1,
    totalRecords: 0,
  }

  return (
    <div className="max-w-7xl mx-auto px-5">
      <div className="py-10 px-4 bg-dark-main flex flex-col gap-6 w-full">
        <div className="flex justify-between items-center gap-4">
          <h2 className="text-[22px] font-semibold text-light-main whitespace-nowrap">
            User List
          </h2>
          <div className="h-12 w-full rounded-[8px] bg-dark flex items-center gap-2 px-4 py-2 overflow-hidden">
            <SearchIcon className="shrink-0 w-5 h-5 text-light-secondary" />
            <input
              type="search"
              placeholder="Search by email or mobile number"
              value={search}
              onChange={e => setSearch(e.target.value)}
              className="text-base font-roboto font-normal text-white placeholder:text-light-secondary outline-none w-full min-w-0 bg-transparent"
            />
          </div>
          <DateRangeFilter
            key={`${dateRange.from?.toISOString() ?? 'empty'}-${dateRange.to?.toISOString() ?? 'empty'}`}
            onConfirm={handleDateRangeConfirm}
            initialFrom={dateRange.from ?? undefined}
            initialTo={dateRange.to ?? undefined}
          />
          {hasActiveFilters && (
            <button
              type="button"
              onClick={handleClearFilters}
              className="whitespace-nowrap outline-none border border-primary-dark text-primary h-12 px-4 py-2 text-base font-medium font-roboto inline-flex items-center gap-2 rounded-[6px] cursor-pointer hover:opacity-80"
            >
              <CloseIcon className="w-5 h-5" />
              Clear filters
            </button>
          )}
        </div>
        <div className="flex flex-col gap-4 w-full flex-1 flex-grow">
          <div className="flex items-center gap-4 px-4">
            {tabs.map(tab => (
              <button
                key={tab.value}
                onClick={() => handleTabChange(tab.value)}
                className={clsx(
                  'p-1 text-lg font-medium font-poppins outline-none cursor-pointer',
                  activeTab === tab.value
                    ? 'text-primary border-b-2 border-primary-dark'
                    : 'text-light-active'
                )}
              >
                {tab.label}
              </button>
            ))}
          </div>
          <div className="relative">
            <DataTable
              columns={columns}
              data={users}
              enableSorting={false}
              className="w-full"
              enablePagination
              manualPagination
              pageCount={Math.max(1, pagination.totalPages)}
              pageIndex={page - 1}
              onPageChange={handlePageChange}
            />
            {isLoading && (
              <div className="absolute inset-0 bg-dark-main/50 flex items-center justify-center rounded-lg z-10">
                <span className="text-light-secondary">Loading...</span>
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  )
}
