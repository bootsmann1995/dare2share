import type { UserRole } from '~/types/subscription'

// Middleware to protect admin routes - only super_user can access
export default defineNuxtRouteMiddleware(async (to, from) => {
  const supabase = useSupabaseClient()
  const user = useSupabaseUser()
  
  if (!user.value) {
    throw createError({
      statusCode: 401,
      statusMessage: 'Authentication required'
    })
  }
  
  try {
    // Get user profile with role
    const { data: profile, error } = await supabase
      .from('profiles')
      .select('user_role')
      .eq('id', user.value.id)
      .single()
    
    if (error) {
      console.error('Error fetching user profile:', error)
      throw createError({
        statusCode: 500,
        statusMessage: 'Error verifying admin permissions'
      })
    }
    
    const userRole = profile?.user_role as UserRole | undefined
    
    if (userRole !== 'super_user') {
      throw createError({
        statusCode: 403,
        statusMessage: 'Admin access required. Only super users can access this area.'
      })
    }
  } catch (error: any) {
    if (error.statusCode) {
      throw error
    }
    
    console.error('Unexpected error in admin middleware:', error)
    throw createError({
      statusCode: 500,
      statusMessage: 'Error validating admin permissions'
    })
  }
})
