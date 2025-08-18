import type { AdminUserInfo, UserSearchResult, UserRole, SubscriptionStatus } from '~/types/subscription'

export const useAdminManagement = () => {
  const supabase = useSupabaseClient()
  
  // Search users
  const searchUsers = async (searchTerm: string = '', limit: number = 20, offset: number = 0): Promise<UserSearchResult[]> => {
    const { data, error } = await supabase.rpc('search_users', {
      search_term: searchTerm,
      limit_count: limit,
      offset_count: offset
    } as any)
    
    if (error) {
      console.error('Error searching users:', error)
      throw new Error('Failed to search users')
    }
    
    return data as UserSearchResult[]
  }
  
  // Get detailed user information
  const getUserDetails = async (userId: string): Promise<AdminUserInfo | null> => {
    const { data, error } = await supabase.rpc('get_user_admin_details', {
      user_id: userId
    } as any)
    
    if (error) {
      console.error('Error fetching user details:', error)
      throw new Error('Failed to fetch user details')
    }
    
    return data?.[0] as AdminUserInfo || null
  }
  
  // Update user subscription
  const updateUserSubscription = async (
    userId: string,
    role: UserRole,
    status: SubscriptionStatus,
    startDate?: string | null,
    endDate?: string | null
  ): Promise<boolean> => {
    const { data, error } = await supabase.rpc('admin_update_user_subscription', {
      user_id: userId,
      new_role: role,
      new_status: status,
      new_start_date: startDate || null,
      new_end_date: endDate || null
    } as any)
    
    if (error) {
      console.error('Error updating user subscription:', error)
      throw new Error('Failed to update user subscription')
    }
    
    return data as boolean
  }
  
  // Get dashboard statistics
  const getDashboardStats = async () => {
    const { data, error } = await supabase.rpc('get_admin_dashboard_stats')
    
    if (error) {
      console.error('Error fetching dashboard stats:', error)
      throw new Error('Failed to fetch dashboard statistics')
    }
    
    return data?.[0] || {
      total_users: 0,
      free_users: 0,
      paid_users: 0,
      super_users: 0,
      active_subscriptions: 0,
      total_listings: 0
    }
  }
  
  return {
    searchUsers,
    getUserDetails,
    updateUserSubscription,
    getDashboardStats
  }
}
