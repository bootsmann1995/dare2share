export default defineNuxtRouteMiddleware((to) => {
  // Prevent infinite redirect loop - don't redirect if already on verify-email page
  if (to.path === '/auth/verify-email') {
    return
  }
  
  // Handle Supabase email verification errors
  if (to.query.error_code === 'otp_expired' || to.query.error === 'access_denied') {
    return navigateTo('/auth/verify-email')
  }
  
  // Handle hash-based errors (sometimes Supabase puts errors in the hash)
  if (process.client && window.location.hash.includes('error=access_denied')) {
    return navigateTo('/auth/verify-email')
  }
})
