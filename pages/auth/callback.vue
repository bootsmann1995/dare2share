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
const user = useSupabaseUser()

// Redirect to home once authenticated
watchEffect(() => {
  if (user.value) {
    navigateTo('/')
  }
})

useHead({
  title: 'Authenticating - Dare2Share'
})
</script>
