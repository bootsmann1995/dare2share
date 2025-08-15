<template>
  <div class="min-h-screen bg-gray-50">
    <!-- Navigation Header -->
    <nav class="bg-white shadow-sm border-b">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="flex justify-between h-16">
          <div class="flex items-center">
            <NuxtLink to="/" class="flex-shrink-0 flex items-center">
              <h1 class="text-2xl font-bold text-blue-600">Dare2Share</h1>
            </NuxtLink>
          </div>
          
          <div class="flex items-center space-x-4">
            <NuxtLink to="/search" class="text-gray-700 hover:text-blue-600 px-3 py-2 rounded-md text-sm font-medium">
              Search
            </NuxtLink>
            <NuxtLink to="/listings/create" class="text-gray-700 hover:text-blue-600 px-3 py-2 rounded-md text-sm font-medium">
              List Item
            </NuxtLink>
            
            <!-- Auth Section -->
            <div v-if="user" class="flex items-center space-x-3">
              <NuxtLink to="/profile" class="text-gray-700 hover:text-blue-600 px-3 py-2 rounded-md text-sm font-medium">
                Profile
              </NuxtLink>
              <button @click="signOut" class="btn-secondary text-sm">
                Sign Out
              </button>
            </div>
            <div v-else class="flex items-center space-x-2">
              <NuxtLink to="/auth/login" class="btn-secondary text-sm">
                Login
              </NuxtLink>
              <NuxtLink to="/auth/register" class="btn-primary text-sm">
                Sign Up
              </NuxtLink>
            </div>
          </div>
        </div>
      </div>
    </nav>

    <!-- Main Content -->
    <main class="flex-1">
      <slot />
    </main>

    <!-- Footer -->
    <footer class="bg-white border-t mt-auto">
      <div class="max-w-7xl mx-auto py-6 px-4 sm:px-6 lg:px-8">
        <div class="text-center text-gray-500 text-sm">
          <p>&copy; 2025 Dare2Share. Share what you dare.</p>
        </div>
      </div>
    </footer>
  </div>
</template>

<script setup>
const supabase = useSupabaseClient()
const user = useSupabaseUser()

const signOut = async () => {
  await supabase.auth.signOut()
  await navigateTo('/')
}
</script>
