import {
  queryOptions,
  useMutation,
  useQuery,
  useQueryClient,
} from '@tanstack/react-query'
import { useAuthActions } from '@/stores/useStore'
import axiosInstance, { endpoints } from '@/utils/axios'

type dashboardStatsResponse = {
  totalFundsReceived: string
  totalFundsSent: string
  totalExternalSent: string
  totalTransactions: number
  totalUsers: number
  totalKycCompletedUsers: number
}

type dashboardStatsParams = {
  fromDate?: string // 2024-01-01T00:00:00.000Z
  toDate?: string // 2024-01-01T00:00:00.000Z
}

export const useGetDashboardStats = (params: dashboardStatsParams) => {
  return useQuery({
    queryKey: ['dashboardStats', params],
    queryFn: async () => {
      const res = await axiosInstance.get<dashboardStatsResponse>(
        endpoints.dashboard.stats,
        {
          params,
        }
      )
      return res.data
    },
  })
}
