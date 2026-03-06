import { createFileRoute, useNavigate } from '@tanstack/react-router'
import {
  BackIcon,
  EditIcon,
  DeleteIcon,
  CheckCircleIcon,
} from '@/components/icon'
import { useState, useMemo } from 'react'
import clsx from 'clsx'
import { type ColumnDef } from '@tanstack/react-table'
import { DataTable } from '@/components/common/data-table'
import Modal from '@/components/common/modal'
import {
  useGetUserDetails,
  useGetUserActivity,
  useBlockUser,
  useUnblockUser,
  type UserActivityItem,
} from '@/api/users'
import { format } from 'date-fns'

export const Route = createFileRoute('/_dashboard/dashboard/users/$userId/')({
  component: UserDetailsPage,
})

function UserDetailsPage() {
  return (
    <div className="max-w-7xl mx-auto px-5 flex flex-col gap-8 w-full">
      <PersonalInformation />
      <UserWallet />
      <TransactionHistory />
    </div>
  )
}

const PersonalInformation = () => {
  const { userId } = Route.useParams()
  const navigate = useNavigate()
  const { data: user, isLoading } = useGetUserDetails(userId)
  const blockMutation = useBlockUser(userId)
  const unblockMutation = useUnblockUser(userId)
  const [isOpen, setIsOpen] = useState(false)
  const [blockReason, setBlockReason] = useState('')
  const [activeStatus, setActiveStatus] = useState<
    'active' | 'block' | 'block-confirm'
  >('block')

  const isBlocked = user?.status === 'BLOCKED'

  const handleOpen = () => {
    setActiveStatus(isBlocked ? 'active' : 'block')
    setBlockReason('')
    setIsOpen(true)
  }

  const handleClose = () => setIsOpen(false)

  const handleBlock = () => {
    if (activeStatus === 'block') {
      setActiveStatus('block-confirm')
      return
    }
    if (activeStatus === 'block-confirm' && blockReason.trim()) {
      blockMutation.mutate(
        { reason: blockReason.trim() },
        { onSuccess: () => handleClose() }
      )
    }
  }

  const handleUnblock = () => {
    unblockMutation.mutate(undefined, { onSuccess: () => handleClose() })
  }

  if (isLoading || !user) {
    return (
      <div className="p-4 bg-dark-main rounded-[8px]">
        <span className="text-light-secondary">Loading...</span>
      </div>
    )
  }

  return (
    <>
      <div className="p-4 flex flex-col gap-6 bg-dark-main rounded-[8px]">
        <div className="flex items-center gap-6 h-[55px]">
          <button
            onClick={() => navigate({ to: '/dashboard/users' })}
            className="text-primary-main hover:text-primary-dark text-sm font-medium"
          >
            <BackIcon />
          </button>
          <h3 className="text-2xl font-semibold font-poppins text-light-main">
            Personal Information
          </h3>
        </div>
        <div className="grid grid-cols-2 gap-4">
          <div className="col-span-1 flex justify-between items-center py-2.5">
            <span className="w-1/2 text-lg font-medium text-light font-poppins">
              Full Name
            </span>
            <span className="w-1/2 text-base font-semibold text-light-active">
              {user.fullName || '—'}
            </span>
          </div>
          <div className="col-span-1 flex justify-between items-center py-2.5">
            <span className="w-1/2 text-lg font-medium text-light font-poppins">
              Email
            </span>
            <span className="w-1/2 text-base font-semibold text-light-active">
              {user.email}
            </span>
          </div>
          <div className="col-span-1 flex justify-between items-center py-2.5">
            <span className="w-1/2 text-lg font-medium text-light font-poppins">
              Phone
            </span>
            <span className="w-1/2 text-base font-semibold text-light-active">
              {user.phoneNumber}
            </span>
          </div>
          <div className="col-span-1 flex justify-between items-center py-2.5">
            <span className="w-1/2 text-lg font-medium text-light font-poppins">
              Registered At
            </span>
            <span className="w-1/2 text-base font-semibold text-light-active">
              {format(new Date(user.dateRegistered), 'dd, MMMM, yyyy')}
            </span>
          </div>
          <div className="col-span-1 flex justify-between items-center py-2.5">
            <span className="w-1/2 text-lg font-medium text-light font-poppins">
              Account Status
            </span>
            <div className="w-1/2 flex items-center gap-2.5">
              <span
                className={clsx(
                  'inline-flex px-3 py-1 text-xs font-medium rounded-full text-base font-roboto font-medium',
                  user.status === 'ACTIVE'
                    ? 'bg-[#05C1681A] text-[#14CA74] border border-[#05C16880]'
                    : 'bg-red-500/20 text-red-400'
                )}
              >
                {user.status === 'ACTIVE' ? 'Active' : 'Blocked'}
              </span>
              <button
                onClick={handleOpen}
                className="text-primary-main hover:text-primary-dark text-sm font-medium"
              >
                <EditIcon />
              </button>
            </div>
          </div>
        </div>
      </div>
      <Modal isOpen={isOpen} onClose={handleClose} maxWidth="max-w-[400px]">
        <div className="flex flex-col gap-8">
          <div className="flex flex-col gap-4">
            {activeStatus === 'active' && (
              <div className="h-12 w-12 rounded-full flex items-center justify-center bg-[#2196F31F] text-primary">
                <CheckCircleIcon />
              </div>
            )}
            {(activeStatus === 'block' || activeStatus === 'block-confirm') && (
              <div className="h-12 w-12 rounded-full flex items-center justify-center bg-[#F92A2A1F] text-[#F92A2A]">
                <DeleteIcon />
              </div>
            )}
            {activeStatus === 'block' && (
              <div className="flex flex-col gap-1">
                <h3 className="text-lg font-inter font-semibold text-[#F92A2A]">
                  Block User?
                </h3>
                <p className="text-sm font-inter font-normal text-light">
                  This will prevent them from logging in or making transactions.
                  You can unblock them at any time.
                </p>
                <label className="text-sm font-medium text-light mt-2">
                  Reason (required)
                </label>
                <textarea
                  value={blockReason}
                  onChange={e => setBlockReason(e.target.value)}
                  placeholder="e.g. Suspicious activity detected"
                  className="mt-1 px-3 py-2 border border-[#D5D7DA] rounded-[8px] text-base bg-dark text-light min-h-[80px]"
                  rows={3}
                />
              </div>
            )}
            {activeStatus === 'block-confirm' && (
              <div className="flex flex-col gap-1">
                <h3 className="text-lg font-inter font-semibold text-[#F92A2A]">
                  Final Confirmation Required
                </h3>
                <p className="text-sm font-inter font-normal text-light">
                  This action is permanent and cannot be undone. You are about
                  to revoke all system-wide access for this user.
                </p>
              </div>
            )}
            {activeStatus === 'active' && (
              <div className="flex flex-col gap-1">
                <h3 className="text-lg font-inter font-semibold text-primary">
                  Unblock User?
                </h3>
                <p className="text-sm font-inter font-normal text-light">
                  This will allow them to log in and make transactions. You can
                  block them at any time.
                </p>
              </div>
            )}
          </div>
          <div className="flex gap-3 w-full">
            <button
              onClick={handleClose}
              className="flex-1 bg-white rounded-[8px] py-2.5 px-4 border border-[#D5D7DA] text-base font-semibold font-inter text-[#414651]"
            >
              Cancel
            </button>
            {activeStatus === 'block' && (
              <button
                onClick={() => setActiveStatus('block-confirm')}
                disabled={!blockReason.trim()}
                className="flex-1 bg-[#F92A2A] rounded-[8px] py-2.5 px-4 border border-[#F92A2A] text-base font-semibold font-inter text-white disabled:opacity-50 disabled:cursor-not-allowed"
              >
                Block User
              </button>
            )}
            {activeStatus === 'block-confirm' && (
              <button
                onClick={handleBlock}
                disabled={blockMutation.isPending || !blockReason.trim()}
                className="flex-1 bg-[#F92A2A] rounded-[8px] py-2.5 px-4 border border-[#F92A2A] text-base font-semibold font-inter text-white disabled:opacity-50 disabled:cursor-not-allowed"
              >
                {blockMutation.isPending ? 'Blocking...' : 'Block Anyway'}
              </button>
            )}
            {activeStatus === 'active' && (
              <button
                onClick={handleUnblock}
                disabled={unblockMutation.isPending}
                className="flex-1 bg-primary rounded-[8px] py-2.5 px-4 border border-primary-dark text-base font-semibold font-inter text-white"
              >
                {unblockMutation.isPending ? 'Unblocking...' : 'Unblock User'}
              </button>
            )}
          </div>
        </div>
      </Modal>
    </>
  )
}

const WALLET_TABS = [
  { label: 'EVM', value: 'evm', coinSymbols: ['ETH', 'BNB', 'BSC'] },
  { label: 'Bitcoin', value: 'bitcoin', coinSymbols: ['BTC'] },
  { label: 'Tron', value: 'tron', coinSymbols: ['TRX', 'TRON'] },
  { label: 'Solana', value: 'solana', coinSymbols: ['SOL'] },
]

const UserWallet = () => {
  const { userId } = Route.useParams()
  const { data: user, isLoading } = useGetUserDetails(userId)
  const [activeTab, setActiveTab] = useState(0)

  const coins = user?.wallet.coins ?? []
  const activeTabConfig = WALLET_TABS[activeTab]
  const activeCoin = activeTabConfig
    ? coins.find((c: { coin: string }) =>
        activeTabConfig.coinSymbols.includes(c.coin.toUpperCase())
      )
    : undefined

  if (isLoading || !user) return null

  return (
    <div className="p-4 flex flex-col gap-4 bg-dark-main rounded-[8px]">
      <h3 className="text-2xl font-semibold font-poppins text-light-main">
        User Wallets
      </h3>
      <div className="flex flex-col gap-6 w-full">
        <div className="flex items-center gap-8">
          {WALLET_TABS.map((tab, i) => (
            <button
              key={tab.value}
              onClick={() => setActiveTab(i)}
              className={clsx(
                'p-1 text-lg font-medium font-poppins outline-none cursor-pointer',
                activeTab === i
                  ? 'text-primary border-b-2 border-primary-dark'
                  : 'text-light-active'
              )}
            >
              {tab.label}
            </button>
          ))}
        </div>
        {activeCoin ? (
          <div className="flex flex-col gap-4 max-w-[583px] w-full">
            <div className="flex flex-col gap-2">
              <span className="text-base font-normal font-roboto text-light">
                Public Address
              </span>
              <div className="inline-flex items-center h-14 px-4 py-2 border border-main rounded-[8px] text-base font-normal font-roboto text-[#787E84]">
                {activeCoin.publicAddress}
              </div>
            </div>
            <div className="flex flex-col gap-2">
              <span className="text-base font-normal font-roboto text-light">
                Balance
              </span>
              <div className="inline-flex items-center gap-1 h-14 px-4 py-2 border border-main rounded-[8px] text-base font-normal font-roboto text-[#787E84]">
                {activeCoin.balance}{' '}
                <span className="text-primary">{activeCoin.coin}</span>
              </div>
            </div>
          </div>
        ) : (
          <div className="text-light-secondary text-sm py-4">Empty</div>
        )}
      </div>
    </div>
  )
}

const WALLET_TYPE_MAP: Record<string, string> = {
  all: '',
  evm: 'EVM',
  bitcoin: 'BITCOIN',
  tron: 'TRON',
  solana: 'SOLANA',
}

const TransactionHistory = () => {
  const { userId } = Route.useParams()
  const [activeTab, setActiveTab] = useState('all')
  const [page, setPage] = useState(1)

  const { data, isLoading } = useGetUserActivity(userId, {
    page,
    limit: 10,
    type: 'ALL',
    walletType: WALLET_TYPE_MAP[activeTab] || undefined,
  })

  const tabs = [
    { label: 'All', value: 'all' },
    { label: 'EVM', value: 'evm' },
    { label: 'Bitcoin', value: 'bitcoin' },
    { label: 'Tron', value: 'tron' },
    { label: 'Solana', value: 'solana' },
  ]

  const columns = useMemo<ColumnDef<UserActivityItem>[]>(
    () => [
      {
        accessorKey: 'txHash',
        header: 'Transaction Hash',
        cell: ({ row }) => {
          const hash = row.original.txHash
          const display = hash || (row.original.type === 'SWAP' ? 'Swap' : '—')
          return (
            <div className="text-xs font-roboto text-light-active font-normal max-w-[160px] truncate text-ellipsis overflow-hidden">
              {display}
            </div>
          )
        },
      },
      {
        accessorKey: 'from',
        header: 'From',
        cell: ({ row }) => row.original.from ?? '—',
      },
      {
        accessorKey: 'to',
        header: 'To',
        cell: ({ row }) => row.original.to ?? '—',
      },
      {
        accessorKey: 'amount',
        header: 'Amount',
        cell: ({ row }) => {
          const r = row.original
          if (r.type === 'SWAP') {
            return `${r.amount} ${r.coinSent ?? ''} → ${r.coinReceived ?? ''}`
          }
          return `${r.amount} ${r.coin ?? ''}`
        },
      },
      {
        accessorKey: 'method',
        header: 'Method',
        cell: ({ row }) => {
          const dir = row.original.direction
          const isSend = dir === 'SENT' || dir === 'SWAP'
          return (
            <span
              className={clsx(
                'w-[68px] inline-flex justify-center items-center px-1 py-[2px] text-sm font-roboto font-medium rounded-full',
                isSend
                  ? 'bg-[#05C1681A] text-[#14CA74] border border-[#05C16880]'
                  : 'bg-[#FF9E001A] border border-[#FF9E0080] text-[#F57C00] whitespace-pre-wrap break-words'
              )}
            >
              {dir}
            </span>
          )
        },
      },
      {
        accessorKey: 'network',
        header: 'Network',
      },
      {
        accessorKey: 'status',
        header: 'Status',
        cell: ({ row }) => {
          const status = row.original.status
          const statusClass =
            status === 'COMPLETED'
              ? 'text-green-400'
              : status === 'FAILED'
                ? 'text-red-400'
                : status === 'PENDING'
                  ? 'text-yellow-400'
                  : 'text-light-secondary'
          return (
            <span
              className={clsx(
                'inline-flex px-2 py-1 text-xs font-medium rounded',
                statusClass
              )}
            >
              {status}
            </span>
          )
        },
      },
    ],
    []
  )

  const items = data?.data ?? []
  const pagination = data?.pagination ?? {
    page: 1,
    totalPages: 1,
    totalRecords: 0,
  }

  return (
    <div className="p-4 flex flex-col gap-4 bg-dark-main rounded-[8px]">
      <h3 className="text-2xl font-semibold font-poppins text-light-main">
        Activity
      </h3>
      <div className="flex flex-col gap-6 w-full">
        <div className="flex items-center gap-8">
          {tabs.map(tab => (
            <button
              key={tab.value}
              onClick={() => {
                setActiveTab(tab.value)
                setPage(1)
              }}
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
        {isLoading ? (
          <span className="text-light-secondary">Loading...</span>
        ) : (
          <DataTable
            columns={columns}
            data={items}
            enableSorting={false}
            className="w-full"
            enablePagination
            manualPagination
            pageCount={Math.max(1, pagination.totalPages)}
            pageIndex={page - 1}
            onPageChange={idx => setPage(idx + 1)}
          />
        )}
      </div>
    </div>
  )
}
