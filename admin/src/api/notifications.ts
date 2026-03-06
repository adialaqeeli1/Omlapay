import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import axiosInstance, { endpoints } from '@/utils/axios'

export type AdminNotificationType = 'SECURITY' | 'USER' | 'TRANSACTION' | 'TICKET'

export type NotificationListItem = {
  id: string
  type: AdminNotificationType
  title: string
  message: string
  isRead: boolean
  createdAt: string
}

export type NotificationListParams = {
  type?: AdminNotificationType
  isRead?: boolean
  page?: number
  limit?: number
}

export type NotificationListResponse = {
  notifications: NotificationListItem[]
  pagination: {
    page: number
    limit: number
    total: number
    totalPages: number
  }
  unreadCount: number
  typeCounts: Record<AdminNotificationType, number>
}

export const useGetNotifications = (params: NotificationListParams) => {
  return useQuery({
    queryKey: ['notifications', params],
    queryFn: async () => {
      const res = await axiosInstance.get<NotificationListResponse>(
        endpoints.notifications.list,
        { params }
      )
      return res.data
    },
  })
}

export const useGetUnreadCount = () => {
  return useQuery({
    queryKey: ['notificationUnreadCount'],
    queryFn: async () => {
      const res = await axiosInstance.get<{ unreadCount: number }>(
        endpoints.notifications.unreadCount
      )
      return res.data
    },
  })
}

export const useMarkNotificationRead = () => {
  const queryClient = useQueryClient()
  return useMutation({
    mutationFn: async (notificationId: string) => {
      const res = await axiosInstance.post(
        endpoints.notifications.markRead(notificationId)
      )
      return res.data
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['notifications'] })
      queryClient.invalidateQueries({ queryKey: ['notificationUnreadCount'] })
    },
  })
}

export const useMarkAllNotificationsRead = () => {
  const queryClient = useQueryClient()
  return useMutation({
    mutationFn: async () => {
      const res = await axiosInstance.post(
        endpoints.notifications.markAllRead
      )
      return res.data
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['notifications'] })
      queryClient.invalidateQueries({ queryKey: ['notificationUnreadCount'] })
    },
  })
}
