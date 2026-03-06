import { createFileRoute, Link } from '@tanstack/react-router'
import { useMemo, useState, useCallback, useEffect } from 'react'
import { type ColumnDef } from '@tanstack/react-table'
import { DataTable } from '@/components/common/data-table'
import DateRangeFilter from '../../../components/common/date-range-filter'
import { SearchIcon, AvatarIcon, VisibleIcon, CloseIcon } from '@/components/icon'
import clsx from 'clsx'
import {
  useGetTicketList,
  type TicketListItem,
  type TicketStatus,
} from '@/api/tickets'
import { format } from 'date-fns'

const TAB_TO_STATUS: Record<string, TicketStatus | undefined> = {
  all: undefined,
  open: 'OPEN',
  solved: 'SOLVED',
  rejected: 'REJECTED',
}

const STATUS_DISPLAY: Record<TicketStatus, string> = {
  OPEN: 'Open',
  SOLVED: 'Solved',
  REJECTED: 'Rejected',
}

const tabs = [
  { label: 'All', value: 'all' },
  { label: 'Open', value: 'open' },
  { label: 'Solved', value: 'solved' },
  { label: 'Rejected', value: 'rejected' },
]

export const Route = createFileRoute('/_dashboard/support/')({
  component: SupportPage,
})

function SupportPage() {
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

  const { data, isLoading } = useGetTicketList({
    page,
    status: TAB_TO_STATUS[activeTab],
    search: searchDebounced || undefined,
    fromDate: formatDateForAPI(dateRange.from),
    toDate: formatToDateForAPI(dateRange.to),
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

  const columns = useMemo<ColumnDef<TicketListItem>[]>(
    () => [
      {
        accessorKey: 'userEmail',
        header: 'User',
        cell: ({ row }) => {
          const email = row.original.userEmail
          const phone = row.original.userPhone
          return (
            <div className="flex items-center gap-1">
              <AvatarIcon />
              <div className="flex flex-col">
                <span className="text-xs font-inter text-primary font-semibold">
                  {email}
                </span>
                <span className="text-[#9C9C9C] text-xs font-medium font-inter">
                  {phone}
                </span>
              </div>
            </div>
          )
        },
      },
      {
        accessorKey: 'title',
        header: 'Title',
      },
      {
        accessorKey: 'createdDate',
        header: 'Time',
        cell: ({ row }) => format(new Date(row.original.createdDate), 'dd MMM yyyy'),
      },
      {
        accessorKey: 'status',
        header: 'Status',
        cell: ({ row }) => {
          const status = row.original.status
          return (
            <div
              className={clsx(
                `w-[120px] h-10 inline-flex items-center justify-center p-2 text-sm font-roboto font-medium rounded-full`,
                (status === 'OPEN' && 'bg-[#2196F31A] text-[#2196F3]') ||
                  (status === 'SOLVED' && 'bg-[#14CA741A] text-[#14CA74]') ||
                  (status === 'REJECTED' && 'bg-[#F92A2A1A] text-[#F92A2A]')
              )}
            >
              {STATUS_DISPLAY[status]}
            </div>
          )
        },
      },
      {
        id: 'actions',
        header: '',
        cell: ({ row }) => {
          const ticket = row.original
          return (
            <Link
              to="/support/$ticketId"
              params={{ ticketId: ticket.id }}
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

  const tickets = data?.tickets ?? []
  const pagination = data?.pagination ?? {
    page: 1,
    totalPages: 1,
    total: 0,
  }

  return (
    <div className="max-w-7xl mx-auto px-5">
      <div className="py-10 px-4 bg-dark-main flex flex-col gap-6 w-full">
        <div className="flex justify-between items-center gap-4">
          <h2 className="text-[22px] font-semibold text-light-main whitespace-nowrap">
            Latest Tickets List
          </h2>
          <div className="h-12 w-full rounded-[8px] bg-dark flex items-center gap-2 px-4 py-2 overflow-hidden">
            <SearchIcon className="shrink-0 w-5 h-5 text-light-secondary" />
            <input
              type="search"
              placeholder="Search"
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
              data={tickets}
              enableSorting
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
