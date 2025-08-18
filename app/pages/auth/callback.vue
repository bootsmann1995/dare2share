<template>
  <div class="min-h-screen flex items-center justify-center">
    <div class="text-center">
      <div class="animate-spin rounded-full h-32 w-32 border-b-2 border-blue-600 mx-auto"></div>
      <p class="mt-4 text-lg text-gray-600">Completing authentication...</p>
    </div>
  </div>
</template>

<script setup>
// This page handles the OAuth callback from Supabase
const supabase = useSupabaseClient()
const route = useRoute()
const user = useSupabaseUser()

onMounted(async () => {
  // Handle auth callback
  const { data, error } = await supabase.auth.getSession()
  
  if (error) {
    console.error('Auth callback error:', error)
    navigateTo('/auth/login?error=' + encodeURIComponent(error.message))
    return
  }

  // Check if this is a password recovery callback
  const type = route.query.type || route.hash?.match(/type=([^&]+)/)?.[1]
  
  if (type === 'recovery') {
    // For password recovery, redirect to reset password page
    navigateTo('/auth/reset-password')
  } else {
    // For regular OAuth, redirect to home once authenticated
    watchEffect(() => {
      if (user.value) {
        navigateTo('/')
      }
    })
  }
})

useHead({
  title: 'Authenticating - Dare2Share'
})
</script>
