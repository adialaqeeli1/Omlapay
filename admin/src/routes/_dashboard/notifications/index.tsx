import { createFileRoute } from '@tanstack/react-router'
import { useState } from 'react'
import clsx from 'clsx'
import {
  AccountBlockIcon,
  SupportTicketIcon,
  UserLifecycleIcon,
  TransactionIcon,
} from '@/components/icon'
import {
  useGetNotifications,
  useMarkNotificationRead,
  useMarkAllNotificationsRead,
  type AdminNotificationType,
} from '@/api/notifications'
import { format } from 'date-fns'

const TYPE_TO_TAB: Record<string, AdminNotificationType | undefined> = {
  all: undefined,
  SECURITY: 'SECURITY',
  USER: 'USER',
  TRANSACTION: 'TRANSACTION',
  TICKET: 'TICKET',
}

const TYPE_LABEL: Record<AdminNotificationType, string> = {
  SECURITY: 'Moderation',
  USER: 'User Lifecycle',
  TRANSACTION: 'Transactions',
  TICKET: 'Support',
}

const tabs: { label: string; value: string }[] = [
  { label: 'All', value: 'all' },
  { label: 'Moderation', value: 'SECURITY' },
  { label: 'User Lifecycle', value: 'USER' },
  { label: 'Support', value: 'TICKET' },
]

const TYPE_STYLES: Record<AdminNotificationType, string> = {
  SECURITY: 'bg-[#FF6B6B1A] text-[#FF6B6B]',
  USER: 'bg-[#05C1681A] text-[#05C168]',
  TRANSACTION: 'bg-[#F59E0B1A] text-[#F59E0B]',
  TICKET: 'bg-[#698CFF1A] text-[#698CFF]',
}

const TYPE_ICONS: Record<AdminNotificationType, React.ReactNode> = {
  SECURITY: <AccountBlockIcon />,
  USER: <UserLifecycleIcon />,
  TRANSACTION: <TransactionIcon />,
  TICKET: <SupportTicketIcon />,
}

export const Route = createFileRoute('/_dashboard/notifications/')({
  component: NotificationsPage,
})

function NotificationsPage() {
  const [activeTab, setActiveTab] = useState('all')
  const [page, setPage] = useState(1)

  const typeFilter = TYPE_TO_TAB[activeTab]
  const { data, isLoading } = useGetNotifications({
    type: typeFilter,
    page,
    limit: 20,
  })
  const markRead = useMarkNotificationRead()
  const markAllRead = useMarkAllNotificationsRead()

  const notifications = data?.notifications ?? []
  const unreadCount = data?.unreadCount ?? 0
  const typeCounts = data?.typeCounts ?? {
    SECURITY: 0,
    USER: 0,
    TRANSACTION: 0,
    TICKET: 0,
  }
  const pagination = data?.pagination ?? {
    page: 1,
    totalPages: 1,
    total: 0,
  }

  const getTabCount = (tabValue: string) => {
    if (tabValue === 'all') return unreadCount
    return typeCounts[tabValue as AdminNotificationType] ?? 0
  }

  const handleMarkAllRead = () => {
    markAllRead.mutate()
  }

  const handleNotificationClick = (n: { id: string; isRead: boolean }) => {
    if (!n.isRead) {
      markRead.mutate(n.id)
    }
  }

  return (
    <div className="max-w-7xl mx-auto px-5 flex flex-col gap-10 w-full">
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-[14px]">
          <h2 className="text-2xl font-semibold font-poppins text-light-main">
            Notifications
          </h2>
          {unreadCount > 0 && (
            <div className="h-7 w-7 rounded-full bg-primary text-sm font-bold font-roboto text-white flex items-center justify-center">
              {unreadCount}
            </div>
          )}
        </div>
        {unreadCount > 0 && (
          <button
            onClick={handleMarkAllRead}
            disabled={markAllRead.isPending}
            className="text-sm font-roboto font-medium text-primary underline disabled:opacity-50"
          >
            Mark all as read
          </button>
        )}
      </div>

      <div className="flex items-center border-b border-[#1C1F1E]">
        {tabs.map(tab => (
          <div
            key={tab.value}
            onClick={() => {
              setActiveTab(tab.value)
              setPage(1)
            }}
            className={clsx(
              'px-5 py-2 text-lg font-medium font-poppins outline-none cursor-pointer inline-flex items-center gap-2',
              activeTab === tab.value
                ? 'text-primary border-b-2 border-primary'
                : 'text-light-active'
            )}
          >
            {tab.label}
            <div
              className={clsx(
                'h-6 w-6 rounded-full text-xs font-medium font-roboto inline-flex items-center justify-center',
                activeTab === tab.value
                  ? 'bg-[#2AA29A33] text-[#2BA39B]'
                  : 'bg-[#9D9D9D1A] text-[#787E84]'
              )}
            >
              {getTabCount(tab.value)}
            </div>
          </div>
        ))}
      </div>

      <div className="bg-dark-main rounded-[12px] p-6 flex flex-col gap-3">
        {isLoading ? (
          <div className="py-12 text-center text-light-secondary">
            Loading...
          </div>
        ) : notifications.length === 0 ? (
          <div className="py-12 text-center text-light-secondary">
            No notifications
          </div>
        ) : (
          notifications.map(notification => (
            <div
              key={notification.id}
              onClick={() => handleNotificationClick(notification)}
              className={clsx(
                'rounded-[8px] w-full flex items-center py-6 gap-6',
                !notification.isRead && 'cursor-pointer',
                notification.isRead ? 'bg-transparent' : 'bg-[#191919]'
              )}
            >
              <div className="flex items-center">
                {!notification.isRead && (
                  <div className="w-1 h-12 bg-primary rounded-tr-full rounded-br-full" />
                )}
                <div
                  className={clsx(
                    'h-12 w-12 rounded-full flex items-center justify-center ml-5',
                    TYPE_STYLES[notification.type]
                  )}
                >
                  {TYPE_ICONS[notification.type]}
                </div>
              </div>
              <div className="flex flex-col gap-2">
                <div className="flex gap-3">
                  <span
                    className={clsx(
                      'px-2 py-1 rounded-full text-xs font-medium font-roboto',
                      TYPE_STYLES[notification.type]
                    )}
                  >
                    {TYPE_LABEL[notification.type]}
                  </span>
                  {!notification.isRead && (
                    <div className="flex items-center gap-2 justify-center">
                      <div className="h-2 w-2 rounded-full bg-primary" />
                      <span className="text-xs font-medium font-roboto text-primary">
                        Unread
                      </span>
                    </div>
                  )}
                </div>
                <div className="flex flex-col gap-1">
                  <h5 className="text-base font-semibold font-poppins text-light-main leading-6">
                    {notification.title}
                  </h5>
                  <p className="text-sm font-normal font-roboto text-light-secondary">
                    {notification.message}
                  </p>
                </div>
                <span className="text-xs font-normal font-roboto text-[#787E84]">
                  {format(new Date(notification.createdAt), 'dd MMM yyyy, HH:mm')}
                </span>
              </div>
            </div>
          ))
        )}
      </div>

      {pagination.totalPages > 1 && (
        <div className="flex justify-center gap-2">
          <button
            onClick={() => setPage(p => Math.max(1, p - 1))}
            disabled={page <= 1}
            className="px-4 py-2 rounded bg-dark-light text-light disabled:opacity-50"
          >
            Previous
          </button>
          <span className="px-4 py-2 text-light-secondary">
            {page} / {pagination.totalPages}
          </span>
          <button
            onClick={() => setPage(p => Math.min(pagination.totalPages, p + 1))}
            disabled={page >= pagination.totalPages}
            className="px-4 py-2 rounded bg-dark-light text-light disabled:opacity-50"
          >
            Next
          </button>
        </div>
      )}
    </div>
  )
}
