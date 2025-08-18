<template>
  <div class="min-h-screen flex items-center justify-center py-12 px-4 sm:px-6 lg:px-8">
    <div class="max-w-md w-full space-y-8">
      <div>
        <h2 class="mt-6 text-center text-3xl font-extrabold text-gray-900">
          Sign in to your account
        </h2>
        <p class="mt-2 text-center text-sm text-gray-600">
          Or
          <NuxtLink to="/auth/register" class="font-medium text-blue-600 hover:text-blue-500">
            create a new account
          </NuxtLink>
        </p>
      </div>
      
      <form class="mt-8 space-y-6" @submit.prevent="signIn">
        <div class="rounded-md shadow-sm -space-y-px">
          <div>
            <label for="email" class="sr-only">Email address</label>
            <input
              id="email"
              v-model="email"
              name="email"
              type="email"
              autocomplete="email"
              required
              class="relative block w-full px-3 py-2 border border-gray-300 placeholder-gray-500 text-gray-900 rounded-t-md focus:outline-none focus:ring-blue-500 focus:border-blue-500 focus:z-10 sm:text-sm"
              placeholder="Email address"
            />
          </div>
          <div>
            <label for="password" class="sr-only">Password</label>
            <input
              id="password"
              v-model="password"
              name="password"
              type="password"
              autocomplete="current-password"
              required
              class="relative block w-full px-3 py-2 border border-gray-300 placeholder-gray-500 text-gray-900 rounded-b-md focus:outline-none focus:ring-blue-500 focus:border-blue-500 focus:z-10 sm:text-sm"
              placeholder="Password"
            />
          </div>
        </div>

        <div v-if="error" class="text-red-600 text-sm text-center">
          {{ error }}
        </div>

        <div class="flex items-center justify-between">
          <div class="text-sm">
            <button
              type="button"
              @click="showForgotPassword = true"
              class="font-medium text-blue-600 hover:text-blue-500"
            >
              Forgot your password?
            </button>
          </div>
        </div>

        <div>
          <button
            type="submit"
            :disabled="loading"
            class="group relative w-full flex justify-center py-2 px-4 border border-transparent text-sm font-medium rounded-md text-white bg-blue-600 hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 disabled:opacity-50"
          >
            <span v-if="loading">Signing in...</span>
            <span v-else>Sign in</span>
          </button>
        </div>

        <div class="text-center">
          <button
            type="button"
            @click="signInWithGoogle"
            class="w-full flex justify-center py-2 px-4 border border-gray-300 rounded-md shadow-sm text-sm font-medium text-gray-700 bg-white hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500"
          >
            <svg class="w-5 h-5 mr-2" viewBox="0 0 24 24">
              <path fill="#4285F4" d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"/>
              <path fill="#34A853" d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"/>
              <path fill="#FBBC05" d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l2.85-2.22.81-.62z"/>
              <path fill="#EA4335" d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z"/>
            </svg>
            Continue with Google
          </button>
        </div>
      </form>

      <!-- Forgot Password Modal -->
      <div v-if="showForgotPassword" class="fixed inset-0 bg-gray-600 bg-opacity-50 overflow-y-auto h-full w-full z-50">
        <div class="relative top-20 mx-auto p-5 border w-96 shadow-lg rounded-md bg-white">
          <div class="mt-3">
            <h3 class="text-lg font-medium text-gray-900 text-center mb-4">
              Reset your password
            </h3>
            <p class="text-sm text-gray-600 text-center mb-4">
              Enter your email address and we'll send you a link to reset your password.
            </p>
            
            <form @submit.prevent="sendPasswordReset">
              <div class="mb-4">
                <label for="reset-email" class="sr-only">Email address</label>
                <input
                  id="reset-email"
                  v-model="resetEmail"
                  name="reset-email"
                  type="email"
                  autocomplete="email"
                  required
                  class="w-full px-3 py-2 border border-gray-300 placeholder-gray-500 text-gray-900 rounded-md focus:outline-none focus:ring-blue-500 focus:border-blue-500 sm:text-sm"
                  placeholder="Email address"
                />
              </div>

              <div v-if="resetError" class="text-red-600 text-sm text-center mb-4">
                {{ resetError }}
              </div>

              <div v-if="resetSuccess" class="text-green-600 text-sm text-center mb-4">
                {{ resetSuccess }}
              </div>

              <div class="flex space-x-3">
                <button
                  type="button"
                  @click="closeForgotPassword"
                  class="flex-1 py-2 px-4 border border-gray-300 rounded-md shadow-sm text-sm font-medium text-gray-700 bg-white hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  :disabled="resetLoading"
                  class="flex-1 py-2 px-4 border border-transparent text-sm font-medium rounded-md text-white bg-blue-600 hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 disabled:opacity-50"
                >
                  <span v-if="resetLoading">Sending...</span>
                  <span v-else>Send Reset Link</span>
                </button>
              </div>
            </form>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
const supabase = useSupabaseClient()
const user = useSupabaseUser()

// Redirect if already logged in
watchEffect(() => {
  if (user.value) {
    navigateTo('/')
  }
})

const email = ref('')
const password = ref('')
const loading = ref(false)
const error = ref('')

// Forgot password functionality
const showForgotPassword = ref(false)
const resetEmail = ref('')
const resetLoading = ref(false)
const resetError = ref('')
const resetSuccess = ref('')

// Handle URL errors (like expired OTP)
const route = useRoute()

onMounted(() => {
  // Check for auth errors in URL parameters
  const urlError = route.query.error || route.hash?.match(/error=([^&]+)/)?.[1]
  const errorCode = route.query.error_code || route.hash?.match(/error_code=([^&]+)/)?.[1]
  const errorDescription = route.query.error_description || route.hash?.match(/error_description=([^&]+)/)?.[1]
  
  if (urlError) {
    if (errorCode === 'otp_expired' || urlError === 'access_denied') {
      error.value = 'The email link is invalid or has expired. Please request a new password reset or verification email.'
      // Auto-open forgot password modal if it's a password reset issue
      if (errorDescription?.includes('Email+link')) {
        showForgotPassword.value = true
      }
    } else {
      error.value = errorDescription ? decodeURIComponent(errorDescription.replace(/\+/g, ' ')) : 'Authentication error occurred'
    }
    
    // Clean up URL by removing error parameters
    const cleanUrl = window.location.pathname
    window.history.replaceState({}, document.title, cleanUrl)
  }
})

const signIn = async () => {
  try {
    loading.value = true
    error.value = ''
    
    const { error: signInError } = await supabase.auth.signInWithPassword({
      email: email.value,
      password: password.value,
    })
    
    if (signInError) throw signInError
    
    await navigateTo('/')
  } catch (err) {
    error.value = err.message
  } finally {
    loading.value = false
  }
}

const signInWithGoogle = async () => {
  try {
    const { getAuthRedirectUrl } = useAppConfig()
    const { error } = await supabase.auth.signInWithOAuth({
      provider: 'google',
      options: {
        redirectTo: getAuthRedirectUrl('/auth/callback')
      }
    })
    if (error) throw error
  } catch (err) {
    error.value = err.message
  }
}

// Forgot password functions
const sendPasswordReset = async () => {
  try {
    resetLoading.value = true
    resetError.value = ''
    resetSuccess.value = ''
    
    const { getAuthRedirectUrl } = useAppConfig()
    const { error } = await supabase.auth.resetPasswordForEmail(resetEmail.value, {
      redirectTo: getAuthRedirectUrl('/auth/reset-password')
    })
    
    if (error) {
      // Handle specific error cases based on the memory about email verification issues
      if (error.message.includes('otp_expired') || error.message.includes('invalid') || error.message.includes('expired')) {
        resetError.value = 'The reset link is invalid or has expired. Please try again.'
      } else {
        resetError.value = error.message
      }
    } else {
      resetSuccess.value = 'Password reset email sent! Check your inbox and follow the instructions.'
      resetEmail.value = ''
    }
  } catch (err) {
    resetError.value = err.message
  } finally {
    resetLoading.value = false
  }
}

const closeForgotPassword = () => {
  showForgotPassword.value = false
  resetEmail.value = ''
  resetError.value = ''
  resetSuccess.value = ''
  resetLoading.value = false
}

useHead({
  title: 'Login - Dare2Share'
})
</script>
