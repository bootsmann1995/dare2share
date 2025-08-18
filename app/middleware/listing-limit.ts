import type { UserSubscriptionInfo } from '~/types/subscription'

// Middleware to check listing limits before allowing listing creation
export default defineNuxtRouteMiddleware(async (to, from) => {
  const supabase = useSupabaseClient()
  const user = useSupabaseUser()
  
  // Only apply to listing creation routes
  if (!to.path.includes('/listings/create')) {
    return
  }
  
  if (!user.value) {
    return navigateTo('/auth/login')
  }
  
  try {
    // Check if user can create more listings using the database function
    const { data: canCreate, error } = await supabase
      .rpc('can_create_listing', { user_id: user.value.id })
    
    if (error) {
      console.error('Error checking listing limit:', error)
      throw createError({
        statusCode: 500,
        statusMessage: 'Error checking listing permissions'
      })
    }
    
    if (!canCreate) {
      // Get user subscription info for better error message
      const { data: subscription } = await supabase
        .from('user_subscription_info')
        .select('user_role, listing_count, listing_limit')
        .eq('id', user.value.id)
        .single()
      
      const subscriptionData = subscription as UserSubscriptionInfo | null
      
      if (subscriptionData?.user_role === 'free_user') {
        throw createError({
          statusCode: 403,
          statusMessage: 'Listing limit reached. You have used all 2 free listings. Upgrade to Premium for unlimited listings.'
        })
      } else {
        throw createError({
          statusCode: 403,
          statusMessage: 'You have reached your listing limit. Please contact support.'
        })
      }
    }
  } catch (error: any) {
    if (error.statusCode) {
      throw error
    }
    
    console.error('Unexpected error in listing limit middleware:', error)
    throw createError({
      statusCode: 500,
      statusMessage: 'Error validating listing permissions'
    })
  }
})
