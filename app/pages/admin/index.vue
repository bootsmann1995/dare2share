<template>
  <div class="min-h-screen bg-gray-50">
    <!-- Header -->
    <div class="bg-white shadow">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="flex justify-between items-center py-6">
          <div>
            <h1 class="text-3xl font-bold text-gray-900">Admin Dashboard</h1>
            <p class="mt-1 text-sm text-gray-600">Manage users and subscriptions</p>
          </div>
          <NuxtLink to="/" class="bg-blue-600 text-white px-4 py-2 rounded-md hover:bg-blue-700">
            Back to App
          </NuxtLink>
        </div>
      </div>
    </div>

    <!-- Stats Cards -->
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6 mb-8">
        <div class="bg-white overflow-hidden shadow rounded-lg">
          <div class="p-5">
            <div class="flex items-center">
              <div class="flex-shrink-0">
                <div class="w-8 h-8 bg-blue-500 rounded-full flex items-center justify-center">
                  <span class="text-white text-sm font-bold">👥</span>
                </div>
              </div>
              <div class="ml-5 w-0 flex-1">
                <dl>
                  <dt class="text-sm font-medium text-gray-500 truncate">Total Users</dt>
                  <dd class="text-lg font-medium text-gray-900">{{ stats.total_users }}</dd>
                </dl>
              </div>
            </div>
          </div>
        </div>

        <div class="bg-white overflow-hidden shadow rounded-lg">
          <div class="p-5">
            <div class="flex items-center">
              <div class="flex-shrink-0">
                <div class="w-8 h-8 bg-green-500 rounded-full flex items-center justify-center">
                  <span class="text-white text-sm font-bold">💳</span>
                </div>
              </div>
              <div class="ml-5 w-0 flex-1">
                <dl>
                  <dt class="text-sm font-medium text-gray-500 truncate">Paid Users</dt>
                  <dd class="text-lg font-medium text-gray-900">{{ stats.paid_users }}</dd>
                </dl>
              </div>
            </div>
          </div>
        </div>

        <div class="bg-white overflow-hidden shadow rounded-lg">
          <div class="p-5">
            <div class="flex items-center">
              <div class="flex-shrink-0">
                <div class="w-8 h-8 bg-purple-500 rounded-full flex items-center justify-center">
                  <span class="text-white text-sm font-bold">📋</span>
                </div>
              </div>
              <div class="ml-5 w-0 flex-1">
                <dl>
                  <dt class="text-sm font-medium text-gray-500 truncate">Total Listings</dt>
                  <dd class="text-lg font-medium text-gray-900">{{ stats.total_listings }}</dd>
                </dl>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- User Search and Management -->
      <div class="bg-white shadow rounded-lg">
        <div class="px-4 py-5 sm:p-6">
          <h3 class="text-lg leading-6 font-medium text-gray-900 mb-4">User Management</h3>
          
          <!-- Search Bar -->
          <div class="mb-6">
            <div class="flex gap-4">
              <div class="flex-1">
                <input
                  v-model="searchTerm"
                  type="text"
                  placeholder="Search by email or name..."
                  class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                  @keyup.enter="handleSearch"
                >
              </div>
              <button
                @click="handleSearch"
                :disabled="searching"
                class="px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700 disabled:opacity-50"
              >
                {{ searching ? 'Searching...' : 'Search' }}
              </button>
            </div>
          </div>

          <!-- Users Table -->
          <div class="overflow-hidden shadow ring-1 ring-black ring-opacity-5 md:rounded-lg">
            <table class="min-w-full divide-y divide-gray-300">
              <thead class="bg-gray-50">
                <tr>
                  <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">User</th>
                  <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Role</th>
                  <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Status</th>
                  <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Listings</th>
                  <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Joined</th>
                  <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Actions</th>
                </tr>
              </thead>
              <tbody class="bg-white divide-y divide-gray-200">
                <tr v-for="user in users" :key="user.id">
                  <td class="px-6 py-4 whitespace-nowrap">
                    <div>
                      <div class="text-sm font-medium text-gray-900">{{ user.full_name || 'No name' }}</div>
                      <div class="text-sm text-gray-500">{{ user.email }}</div>
                    </div>
                  </td>
                  <td class="px-6 py-4 whitespace-nowrap">
                    <span :class="getRoleBadgeClass(user.user_role)" class="inline-flex px-2 py-1 text-xs font-semibold rounded-full">
                      {{ getRoleDisplayName(user.user_role) }}
                    </span>
                  </td>
                  <td class="px-6 py-4 whitespace-nowrap">
                    <span :class="getStatusBadgeClass(user.subscription_status)" class="inline-flex px-2 py-1 text-xs font-semibold rounded-full">
                      {{ user.subscription_status }}
                    </span>
                  </td>
                  <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                    {{ user.listing_count }}
                  </td>
                  <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                    {{ formatDate(user.created_at) }}
                  </td>
                  <td class="px-6 py-4 whitespace-nowrap text-sm font-medium">
                    <button
                      @click="selectUser(user)"
                      class="text-blue-600 hover:text-blue-900 mr-4"
                    >
                      Manage
                    </button>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>

          <!-- No Results -->
          <div v-if="users.length === 0 && !searching" class="text-center py-8">
            <p class="text-gray-500">No users found. Try a different search term.</p>
          </div>
        </div>
      </div>
    </div>

    <!-- User Management Modal -->
    <div v-if="selectedUser" class="fixed inset-0 bg-gray-600 bg-opacity-50 overflow-y-auto h-full w-full z-50">
      <div class="relative top-20 mx-auto p-5 border w-11/12 md:w-3/4 lg:w-1/2 shadow-lg rounded-md bg-white">
        <div class="mt-3">
          <div class="flex justify-between items-center mb-4">
            <h3 class="text-lg font-medium text-gray-900">Manage User: {{ selectedUser.full_name || selectedUser.email }}</h3>
            <button @click="closeModal" class="text-gray-400 hover:text-gray-600">
              <span class="sr-only">Close</span>
              <svg class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
              </svg>
            </button>
          </div>

          <div class="space-y-4">
            <!-- User Info -->
            <div class="bg-gray-50 p-4 rounded-lg">
              <h4 class="font-medium text-gray-900 mb-2">User Information</h4>
              <div class="grid grid-cols-2 gap-4 text-sm">
                <div>
                  <span class="text-gray-500">Email:</span>
                  <span class="ml-2 text-gray-900">{{ selectedUser.email }}</span>
                </div>
                <div>
                  <span class="text-gray-500">Name:</span>
                  <span class="ml-2 text-gray-900">{{ selectedUser.full_name || 'Not provided' }}</span>
                </div>
                <div>
                  <span class="text-gray-500">Listings:</span>
                  <span class="ml-2 text-gray-900">{{ selectedUser.listing_count }}</span>
                </div>
                <div>
                  <span class="text-gray-500">Joined:</span>
                  <span class="ml-2 text-gray-900">{{ formatDate(selectedUser.created_at) }}</span>
                </div>
              </div>
            </div>

            <!-- Subscription Management -->
            <div class="space-y-4">
              <h4 class="font-medium text-gray-900">Subscription Management</h4>
              
              <div class="grid grid-cols-2 gap-4">
                <div>
                  <label class="block text-sm font-medium text-gray-700">User Role</label>
                  <select v-model="editForm.user_role" class="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500">
                    <option value="free_user">Free User</option>
                    <option value="paid_user">Paid User</option>
                    <option value="super_user">Super User</option>
                  </select>
                </div>

                <div>
                  <label class="block text-sm font-medium text-gray-700">Subscription Status</label>
                  <select v-model="editForm.subscription_status" class="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500">
                    <option value="active">Active</option>
                    <option value="inactive">Inactive</option>
                    <option value="trial">Trial</option>
                    <option value="expired">Expired</option>
                  </select>
                </div>
              </div>

              <div class="grid grid-cols-2 gap-4">
                <div>
                  <label class="block text-sm font-medium text-gray-700">Start Date</label>
                  <input
                    v-model="editForm.subscription_start_date"
                    type="date"
                    class="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                  >
                </div>

                <div>
                  <label class="block text-sm font-medium text-gray-700">End Date</label>
                  <input
                    v-model="editForm.subscription_end_date"
                    type="date"
                    class="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                  >
                </div>
              </div>
            </div>

            <!-- Action Buttons -->
            <div class="flex justify-end space-x-3 pt-4">
              <button
                @click="closeModal"
                class="px-4 py-2 border border-gray-300 rounded-md text-gray-700 hover:bg-gray-50"
              >
                Cancel
              </button>
              <button
                @click="updateUser"
                :disabled="updating"
                class="px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700 disabled:opacity-50"
              >
                {{ updating ? 'Updating...' : 'Update User' }}
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import type { UserSearchResult, AdminUserInfo, UserRole, SubscriptionStatus } from '~/types/subscription'

// Middleware protection
definePageMeta({
  middleware: ['auth', 'admin']
})

const { searchUsers, getUserDetails, updateUserSubscription, getDashboardStats } = useAdminManagement()

// Reactive data
const searchTerm = ref('')
const users = ref<UserSearchResult[]>([])
const selectedUser = ref<AdminUserInfo | null>(null)
const searching = ref(false)
const updating = ref(false)
const stats = ref({
  total_users: 0,
  free_users: 0,
  paid_users: 0,
  super_users: 0,
  active_subscriptions: 0,
  total_listings: 0
})

const editForm = ref({
  user_role: 'free_user' as UserRole,
  subscription_status: 'inactive' as SubscriptionStatus,
  subscription_start_date: '',
  subscription_end_date: ''
})

// Load initial data
onMounted(async () => {
  await loadStats()
  await handleSearch() // Load all users initially
})

// Methods
const loadStats = async () => {
  try {
    stats.value = await getDashboardStats()
  } catch (error) {
    console.error('Error loading stats:', error)
  }
}

const handleSearch = async () => {
  try {
    searching.value = true
    users.value = await searchUsers(searchTerm.value)
  } catch (error) {
    console.error('Error searching users:', error)
  } finally {
    searching.value = false
  }
}

const selectUser = async (user: UserSearchResult) => {
  try {
    const userDetails = await getUserDetails(user.id)
    if (userDetails) {
      selectedUser.value = userDetails
      editForm.value = {
        user_role: userDetails.user_role,
        subscription_status: userDetails.subscription_status,
        subscription_start_date: userDetails.subscription_start_date ? userDetails.subscription_start_date.split('T')[0] : '',
        subscription_end_date: userDetails.subscription_end_date ? userDetails.subscription_end_date.split('T')[0] : ''
      }
    }
  } catch (error) {
    console.error('Error loading user details:', error)
  }
}

const updateUser = async () => {
  if (!selectedUser.value) return
  
  try {
    updating.value = true
    await updateUserSubscription(
      selectedUser.value.id,
      editForm.value.user_role,
      editForm.value.subscription_status,
      editForm.value.subscription_start_date || '',
      editForm.value.subscription_end_date || ''
    )
    
    // Refresh data
    await handleSearch()
    await loadStats()
    closeModal()
  } catch (error) {
    console.error('Error updating user:', error)
  } finally {
    updating.value = false
  }
}

const closeModal = () => {
  selectedUser.value = null
}

// Utility functions
const getRoleBadgeClass = (role: UserRole) => {
  const classes = {
    free_user: 'bg-gray-100 text-gray-800',
    paid_user: 'bg-green-100 text-green-800',
    super_user: 'bg-purple-100 text-purple-800'
  }
  return classes[role] || 'bg-gray-100 text-gray-800'
}

const getStatusBadgeClass = (status: SubscriptionStatus) => {
  const classes = {
    active: 'bg-green-100 text-green-800',
    inactive: 'bg-gray-100 text-gray-800',
    trial: 'bg-blue-100 text-blue-800',
    expired: 'bg-red-100 text-red-800'
  }
  return classes[status] || 'bg-gray-100 text-gray-800'
}

const getRoleDisplayName = (role: UserRole) => {
  const names = {
    free_user: 'Free',
    paid_user: 'Premium',
    super_user: 'Admin'
  }
  return names[role] || role
}

const formatDate = (dateString: string) => {
  return new Date(dateString).toLocaleDateString()
}
</script>
