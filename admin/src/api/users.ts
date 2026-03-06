import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import axiosInstance, { endpoints } from '@/utils/axios'

export type UserListTabFilter = 'ALL' | 'KYC' | 'NON_KYC' | 'BLOCKED'
export type UserListSortBy = 'createdAt' | 'email'
export type UserListSortOrder = 'ASC' | 'DESC'

export type UserListItem = {
  id: string
  phoneNumber: string
  email: string
  fullName: string | null
  dateRegistered: string
  totalBalance: string
  mainWallet?: string
  status: 'ACTIVE' | 'BLOCKED'
}

export type UserListParams = {
  search?: string
  filter?: UserListTabFilter
  dateFrom?: string
  dateTo?: string
  sortBy?: UserListSortBy
  sortOrder?: UserListSortOrder
  page?: number
}

export type UserListResponse = {
  data: UserListItem[]
  pagination: {
    page: number
    limit: number
    totalRecords: number
    totalPages: number
  }
}

export const useGetUserList = (params: UserListParams) => {
  return useQuery({
    queryKey: ['userList', params],
    queryFn: async () => {
      const res = await axiosInstance.get<UserListResponse>(
        endpoints.users.list,
        { params }
      )
      return res.data
    },
  })
}

export type UserDetails = {
  id: string
  phoneNumber: string
  email: string
  fullName: string | null
  dateRegistered: string
  status: 'ACTIVE' | 'BLOCKED'
  wallet: {
    totalBalance: string
    coins: Array<{
      coin: string
      balance: string
      publicAddress: string
    }>
  }
}

export const useGetUserDetails = (userId: string | undefined) => {
  return useQuery({
    queryKey: ['userDetails', userId],
    queryFn: async () => {
      if (!userId) throw new Error('User ID required')
      const res = await axiosInstance.get<UserDetails>(
        endpoints.users.details(userId)
      )
      return res.data
    },
    enabled: !!userId,
  })
}

export type UserTransaction = {
  id: string
  coin: string
  amount: string
  direction: 'RECEIVED' | 'SENT'
  from: string
  to: string
  txHash: string | null
  status: string
  network: string
  timestamp: string
}

export type UserTransactionsParams = {
  page?: number
  limit?: number
  walletType?: string
}

export type UserTransactionsResponse = {
  data: UserTransaction[]
  pagination: { page: number; limit: number; totalRecords: number; totalPages: number }
}

export const useGetUserTransactions = (
  userId: string | undefined,
  params: UserTransactionsParams = {}
) => {
  return useQuery({
    queryKey: ['userTransactions', userId, params],
    queryFn: async () => {
      if (!userId) throw new Error('User ID required')
      const res = await axiosInstance.get<UserTransactionsResponse>(
        endpoints.users.transactions(userId),
        { params }
      )
      return res.data
    },
    enabled: !!userId,
  })
}

export type UserActivityItem = {
  id: string
  type: 'TRANSACTION' | 'SWAP'
  coin?: string
  amount: string
  direction: string
  from?: string
  to?: string
  txHash: string | null
  status: string
  network: string
  timestamp: string
  coinSent?: string
  coinReceived?: string
}

export type UserActivityParams = {
  page?: number
  limit?: number
  type?: 'ALL' | 'TRANSACTION' | 'SWAP'
  walletType?: string
}

export type UserActivityResponse = {
  data: UserActivityItem[]
  pagination: { page: number; limit: number; totalRecords: number; totalPages: number }
}

export const useGetUserActivity = (
  userId: string | undefined,
  params: UserActivityParams = {}
) => {
  return useQuery({
    queryKey: ['userActivity', userId, params],
    queryFn: async () => {
      if (!userId) throw new Error('User ID required')
      const res = await axiosInstance.get<UserActivityResponse>(
        endpoints.users.activity(userId),
        { params }
      )
      return res.data
    },
    enabled: !!userId,
  })
}

export type UserSwap = {
  coinSent: string
  coinReceived: string
  amount: string
  timestamp: string
}

export type UserSwapsResponse = {
  data: UserSwap[]
  pagination: { page: number; limit: number; totalRecords: number; totalPages: number }
}

export const useGetUserSwaps = (
  userId: string | undefined,
  page = 1,
  limit = 10
) => {
  return useQuery({
    queryKey: ['userSwaps', userId, page, limit],
    queryFn: async () => {
      if (!userId) throw new Error('User ID required')
      const res = await axiosInstance.get<UserSwapsResponse>(
        endpoints.users.swaps(userId),
        { params: { page, limit } }
      )
      return res.data
    },
    enabled: !!userId,
  })
}

export type BlockUserDto = { reason: string }

export const useBlockUser = (userId: string | undefined) => {
  const queryClient = useQueryClient()
  return useMutation({
    mutationFn: async (dto: BlockUserDto) => {
      if (!userId) throw new Error('User ID required')
      const res = await axiosInstance.post(
        endpoints.users.block(userId),
        dto
      )
      return res.data
    },
    onSuccess: (_, __, context) => {
      queryClient.invalidateQueries({ queryKey: ['userDetails', userId] })
      queryClient.invalidateQueries({ queryKey: ['userList'] })
    },
  })
}

export const useUnblockUser = (userId: string | undefined) => {
  const queryClient = useQueryClient()
  return useMutation({
    mutationFn: async () => {
      if (!userId) throw new Error('User ID required')
      const res = await axiosInstance.post(endpoints.users.unblock(userId))
      return res.data
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['userDetails', userId] })
      queryClient.invalidateQueries({ queryKey: ['userList'] })
    },
  })
}
