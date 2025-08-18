<template>
  <div class="min-h-screen flex items-center justify-center py-12 px-4 sm:px-6 lg:px-8">
    <div class="max-w-md w-full space-y-8">
      <div>
        <h2 class="mt-6 text-center text-3xl font-extrabold text-gray-900">
          Reset your password
        </h2>
        <p class="mt-2 text-center text-sm text-gray-600">
          Enter your new password below
        </p>
      </div>
      
      <form class="mt-8 space-y-6" @submit.prevent="resetPassword">
        <div class="rounded-md shadow-sm -space-y-px">
          <div>
            <label for="new-password" class="sr-only">New Password</label>
            <input
              id="new-password"
              v-model="newPassword"
              name="new-password"
              type="password"
              autocomplete="new-password"
              required
              class="relative block w-full px-3 py-2 border border-gray-300 placeholder-gray-500 text-gray-900 rounded-t-md focus:outline-none focus:ring-blue-500 focus:border-blue-500 focus:z-10 sm:text-sm"
              placeholder="New password"
            />
          </div>
          <div>
            <label for="confirm-password" class="sr-only">Confirm Password</label>
            <input
              id="confirm-password"
              v-model="confirmPassword"
              name="confirm-password"
              type="password"
              autocomplete="new-password"
              required
              class="relative block w-full px-3 py-2 border border-gray-300 placeholder-gray-500 text-gray-900 rounded-b-md focus:outline-none focus:ring-blue-500 focus:border-blue-500 focus:z-10 sm:text-sm"
              placeholder="Confirm new password"
            />
          </div>
        </div>

        <div v-if="error" class="text-red-600 text-sm text-center">
          {{ error }}
        </div>

        <div v-if="success" class="text-green-600 text-sm text-center">
          {{ success }}
        </div>

        <div>
          <button
            type="submit"
            :disabled="loading"
            class="group relative w-full flex justify-center py-2 px-4 border border-transparent text-sm font-medium rounded-md text-white bg-blue-600 hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 disabled:opacity-50"
          >
            <span v-if="loading">Updating password...</span>
            <span v-else>Update password</span>
          </button>
        </div>

        <div class="text-center">
          <NuxtLink to="/auth/login" class="font-medium text-blue-600 hover:text-blue-500">
            Back to login
          </NuxtLink>
        </div>
      </form>
    </div>
  </div>
</template>

<script setup>
const supabase = useSupabaseClient()
const route = useRoute()

const newPassword = ref('')
const confirmPassword = ref('')
const loading = ref(false)
const error = ref('')
const success = ref('')

// Check if we have the required tokens from the URL
const accessToken = route.query.access_token
const refreshToken = route.query.refresh_token

onMounted(async () => {
  // If we have tokens, set the session
  if (accessToken && refreshToken) {
    try {
      const { error } = await supabase.auth.setSession({
        access_token: accessToken,
        refresh_token: refreshToken
      })
      
      if (error) {
        console.error('Error setting session:', error)
        error.value = 'Invalid or expired reset link. Please request a new password reset.'
      }
    } catch (err) {
      console.error('Session error:', err)
      error.value = 'Invalid or expired reset link. Please request a new password reset.'
    }
  } else {
    error.value = 'Invalid reset link. Please request a new password reset.'
  }
})

const resetPassword = async () => {
  try {
    loading.value = true
    error.value = ''
    success.value = ''
    
    // Validate passwords match
    if (newPassword.value !== confirmPassword.value) {
      error.value = 'Passwords do not match'
      return
    }
    
    // Validate password length
    if (newPassword.value.length < 6) {
      error.value = 'Password must be at least 6 characters long'
      return
    }
    
    const { error: updateError } = await supabase.auth.updateUser({
      password: newPassword.value
    })
    
    if (updateError) {
      // Handle specific error cases based on the memory about email verification issues
      if (updateError.message.includes('otp_expired') || updateError.message.includes('invalid') || updateError.message.includes('expired')) {
        error.value = 'The reset link is invalid or has expired. Please request a new password reset.'
      } else {
        error.value = updateError.message
      }
    } else {
      success.value = 'Password updated successfully! Redirecting to login...'
      
      // Clear form
      newPassword.value = ''
      confirmPassword.value = ''
      
      // Redirect to login after 2 seconds
      setTimeout(() => {
        navigateTo('/auth/login')
      }, 2000)
    }
  } catch (err) {
    error.value = err.message
  } finally {
    loading.value = false
  }
}

useHead({
  title: 'Reset Password - Dare2Share'
})
</script>
