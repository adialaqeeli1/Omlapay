import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import axiosInstance, { endpoints } from '@/utils/axios'

export type TicketStatus = 'OPEN' | 'SOLVED' | 'REJECTED'
export type TicketListSortBy = 'user' | 'title' | 'createdAt' | 'status'
export type TicketListSortOrder = 'ASC' | 'DESC'

export type TicketListItem = {
  id: string
  ticketId: string
  title: string
  createdDate: string
  status: TicketStatus
  statusColor: string
  userEmail: string
  userPhone: string
}

export type TicketListParams = {
  search?: string
  status?: TicketStatus
  fromDate?: string
  toDate?: string
  page?: number
  limit?: number
  sortBy?: TicketListSortBy
  sortOrder?: TicketListSortOrder
}

export type TicketListResponse = {
  tickets: TicketListItem[]
  pagination: {
    page: number
    limit: number
    total: number
    totalPages: number
  }
}

export const useGetTicketList = (params: TicketListParams) => {
  return useQuery({
    queryKey: ['ticketList', params],
    queryFn: async () => {
      const res = await axiosInstance.get<TicketListResponse>(
        endpoints.tickets.list,
        { params }
      )
      return res.data
    },
  })
}

export type TicketDetails = {
  ticket: {
    id: string
    ticketId: string
    title: string
    description: string
    status: TicketStatus
    statusColor: string
    createdAt: string
    updatedAt: string
  }
  user: {
    email: string
    phoneNumber: string
    fullName: string | null
  }
  attachments: Array<{ url: string; type: 'image' | 'document' }>
  responses: Array<{
    id: string
    message: string
    isAdmin: boolean
    adminId: string | null
    createdAt: string
  }>
}

export const useGetTicketDetails = (ticketId: string | undefined) => {
  return useQuery({
    queryKey: ['ticketDetails', ticketId],
    queryFn: async () => {
      if (!ticketId) throw new Error('Ticket ID required')
      const res = await axiosInstance.get<TicketDetails>(
        endpoints.tickets.details(ticketId)
      )
      return res.data
    },
    enabled: !!ticketId,
  })
}

export const useGetOpenTicketCount = () => {
  return useQuery({
    queryKey: ['ticketOpenCount'],
    queryFn: async () => {
      const res = await axiosInstance.get<{ openCount: number }>(
        endpoints.tickets.openCount
      )
      return res.data
    },
  })
}

export type AddTicketResponseDto = { message: string }

export const useAddTicketResponse = (ticketId: string | undefined) => {
  const queryClient = useQueryClient()
  return useMutation({
    mutationFn: async (dto: AddTicketResponseDto) => {
      if (!ticketId) throw new Error('Ticket ID required')
      const res = await axiosInstance.post(
        endpoints.tickets.addResponse(ticketId),
        dto
      )
      return res.data
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['ticketDetails', ticketId] })
      queryClient.invalidateQueries({ queryKey: ['ticketList'] })
    },
  })
}

export type UpdateTicketStatusDto = {
  status: TicketStatus
  comment?: string
}

export const useUpdateTicketStatus = (ticketId: string | undefined) => {
  const queryClient = useQueryClient()
  return useMutation({
    mutationFn: async (dto: UpdateTicketStatusDto) => {
      if (!ticketId) throw new Error('Ticket ID required')
      const res = await axiosInstance.post(
        endpoints.tickets.updateStatus(ticketId),
        dto
      )
      return res.data
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['ticketDetails', ticketId] })
      queryClient.invalidateQueries({ queryKey: ['ticketList'] })
      queryClient.invalidateQueries({ queryKey: ['ticketOpenCount'] })
    },
  })
}
