import type { UserSubscriptionInfo, UserRole, SubscriptionStatus, SubscriptionStatusDisplay } from '~/types/subscription'

// User subscription and role management composable
export const useUserSubscription = () => {
  const supabase = useSupabaseClient()
  const user = useSupabaseUser()
  
  const userSubscription = ref<UserSubscriptionInfo | null>(null)
  const loading = ref<boolean>(false)
  
  // Fetch user subscription info
  const fetchUserSubscription = async (): Promise<UserSubscriptionInfo | null> => {
    if (!user.value) return null
    
    try {
      loading.value = true
      const { data, error } = await supabase
        .from('user_subscription_info')
        .select('*')
        .eq('id', user.value.id)
        .single()
      
      if (error) throw error
      
      userSubscription.value = data
      return data
    } catch (error) {
      console.error('Error fetching user subscription:', error)
      return null
    } finally {
      loading.value = false
    }
  }
  
  // Check if user can create more listings
  const canCreateListing = async (): Promise<boolean> => {
    if (!user.value) return false
    
    try {
      const { data, error } = await supabase
        .rpc('can_create_listing', { user_id: user.value.id })
      
      if (error) throw error
      return data as boolean
    } catch (error) {
      console.error('Error checking listing creation permission:', error)
      return false
    }
  }
  
  // Get user's current listing limit
  const getListingLimit = (userRole: UserRole): number => {
    switch (userRole) {
      case 'super_user':
        return -1 // Unlimited
      case 'paid_user':
        return -1 // Unlimited
      case 'free_user':
        return 2  // 2 free listings
      default:
        return 0
    }
  }
  
  // Get role display name
  const getRoleDisplayName = (role: UserRole): string => {
    switch (role) {
      case 'super_user':
        return 'Super User'
      case 'paid_user':
        return 'Premium Member'
      case 'free_user':
        return 'Free Member'
      default:
        return 'Unknown'
    }
  }
  
  // Get role benefits
  const getRoleBenefits = (role: UserRole): string[] => {
    switch (role) {
      case 'super_user':
        return [
          'Unlimited listings',
          'Priority support',
          'Advanced analytics',
          'All premium features'
        ]
      case 'paid_user':
        return [
          'Unlimited listings',
          'Contact sellers directly',
          'Priority listing placement',
          'Advanced search filters'
        ]
      case 'free_user':
        return [
          '2 free listings',
          'Basic listing features',
          'Browse all items',
          'Basic messaging'
        ]
      default:
        return []
    }
  }
  
  // Check if user needs to upgrade
  const needsUpgrade = computed((): boolean => {
    if (!userSubscription.value) return false
    return userSubscription.value.user_role === 'free_user' && 
           !userSubscription.value.can_create_more_listings
  })
  
  // Get subscription status display
  const getSubscriptionStatusDisplay = (status: SubscriptionStatus): SubscriptionStatusDisplay => {
    switch (status) {
      case 'active':
        return { text: 'Active', class: 'text-green-600 bg-green-100' }
      case 'inactive':
        return { text: 'Inactive', class: 'text-gray-600 bg-gray-100' }
      case 'trial':
        return { text: 'Trial', class: 'text-blue-600 bg-blue-100' }
      case 'expired':
        return { text: 'Expired', class: 'text-red-600 bg-red-100' }
      default:
        return { text: 'Unknown', class: 'text-gray-600 bg-gray-100' }
    }
  }
  
  // Update user role (admin function)
  const updateUserRole = async (userId: string, newRole: UserRole): Promise<boolean> => {
    try {
      const { error } = await supabase
        .from('profiles')
        .update({ 
          user_role: newRole,
          updated_at: new Date().toISOString()
        })
        .eq('id', userId)
      
      if (error) throw error
      
      // Refresh subscription info if updating current user
      if (userId === user.value?.id) {
        await fetchUserSubscription()
      }
      
      return true
    } catch (error) {
      console.error('Error updating user role:', error)
      return false
    }
  }
  
  // Initialize subscription data when user changes
  watch(user, (newUser) => {
    if (newUser) {
      fetchUserSubscription()
    } else {
      userSubscription.value = null
    }
  }, { immediate: true })
  
  return {
    userSubscription: readonly(userSubscription),
    loading: readonly(loading),
    fetchUserSubscription,
    canCreateListing,
    getListingLimit,
    getRoleDisplayName,
    getRoleBenefits,
    needsUpgrade,
    getSubscriptionStatusDisplay,
    updateUserRole
  }
}
