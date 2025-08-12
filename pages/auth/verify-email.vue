<template>
  <div class="min-h-screen flex items-center justify-center py-12 px-4 sm:px-6 lg:px-8">
    <div class="max-w-md w-full space-y-8">
      <div class="text-center">
        <div v-if="verificationStatus === 'expired'" class="mb-6">
          <svg class="w-16 h-16 text-yellow-500 mx-auto mb-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-2.5L13.732 4c-.77-.833-1.964-.833-2.732 0L4.082 16.5c-.77.833.192 2.5 1.732 2.5z"></path>
          </svg>
          <h2 class="text-2xl font-bold text-gray-900 mb-2">Email Link Expired</h2>
          <p class="text-gray-600 mb-6">
            Your email verification link has expired or is invalid. Don't worry, we can send you a new one!
          </p>
        </div>

        <div v-else-if="verificationStatus === 'success'" class="mb-6">
          <svg class="w-16 h-16 text-green-500 mx-auto mb-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"></path>
          </svg>
          <h2 class="text-2xl font-bold text-gray-900 mb-2">Email Verified!</h2>
          <p class="text-gray-600 mb-6">
            Your email has been successfully verified. You can now access all features of Dare2Share.
          </p>
          <NuxtLink to="/" class="btn-primary">
            Go to Homepage
          </NuxtLink>
        </div>

        <div v-else class="mb-6">
          <svg class="w-16 h-16 text-blue-500 mx-auto mb-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 8l7.89 4.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z"></path>
          </svg>
          <h2 class="text-2xl font-bold text-gray-900 mb-2">Check Your Email</h2>
          <p class="text-gray-600 mb-6">
            We've sent you a verification link. Please check your email and click the link to verify your account.
          </p>
        </div>

        <!-- Resend Email Form -->
        <div v-if="verificationStatus === 'expired' || showResendForm" class="space-y-4">
          <form @submit.prevent="resendVerification" class="space-y-4">
            <div>
              <label for="email" class="block text-sm font-medium text-gray-700 mb-2">Email Address</label>
              <input
                id="email"
                v-model="email"
                type="email"
                required
                class="input-field"
                placeholder="Enter your email address"
              />
            </div>

            <div v-if="error" class="text-red-600 text-sm text-center">
              {{ error }}
            </div>

            <div v-if="success" class="text-green-600 text-sm text-center">
              {{ success }}
            </div>

            <button
              type="submit"
              :disabled="loading"
              class="w-full btn-primary disabled:opacity-50"
            >
              <span v-if="loading">Sending...</span>
              <span v-else>Resend Verification Email</span>
            </button>
          </form>

          <div class="text-center">
            <p class="text-sm text-gray-600">
              Already verified? 
              <NuxtLink to="/auth/login" class="font-medium text-blue-600 hover:text-blue-500">
                Sign in here
              </NuxtLink>
            </p>
          </div>
        </div>

        <div v-else-if="verificationStatus !== 'success'" class="space-y-4">
          <button
            @click="showResendForm = true"
            class="text-blue-600 hover:text-blue-500 font-medium"
          >
            Didn't receive the email? Click to resend
          </button>
          
          <div class="text-center">
            <NuxtLink to="/auth/login" class="text-sm text-gray-600 hover:text-gray-500">
              Back to Login
            </NuxtLink>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
const supabase = useSupabaseClient()
const route = useRoute()

const email = ref('')
const loading = ref(false)
const error = ref('')
const success = ref('')
const showResendForm = ref(false)
const verificationStatus = ref('pending')

// Check URL parameters for verification status
onMounted(() => {
  const urlParams = new URLSearchParams(window.location.search)
  const hashParams = new URLSearchParams(window.location.hash.substring(1))
  
  const errorCode = urlParams.get('error_code') || hashParams.get('error_code')
  const errorMsg = urlParams.get('error') || hashParams.get('error')
  
  if (errorCode === 'otp_expired' || errorMsg === 'access_denied') {
    verificationStatus.value = 'expired'
  } else if (route.query.verified === 'true') {
    verificationStatus.value = 'success'
  }
})

const resendVerification = async () => {
  try {
    loading.value = true
    error.value = ''
    success.value = ''

    if (!email.value) {
      throw new Error('Please enter your email address')
    }

    const { error: resendError } = await supabase.auth.resend({
      type: 'signup',
      email: email.value
    })

    if (resendError) throw resendError

    success.value = 'Verification email sent! Please check your inbox and spam folder.'
    showResendForm.value = false
    verificationStatus.value = 'pending'

  } catch (err) {
    error.value = err.message
  } finally {
    loading.value = false
  }
}

useHead({
  title: 'Email Verification - Dare2Share'
})
</script>
