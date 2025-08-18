<template>
  <div class="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
    <!-- Profile Header -->
    <div class="bg-white rounded-lg shadow-md p-6 mb-8">
      <div class="flex items-center space-x-4">
        <div class="w-20 h-20 bg-gray-300 rounded-full flex items-center justify-center">
          <svg class="w-10 h-10 text-gray-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"></path>
          </svg>
        </div>
        <div class="flex-1">
          <h1 class="text-2xl font-bold text-gray-900">{{ user?.user_metadata?.full_name || 'User' }}</h1>
          <p class="text-gray-600">{{ user?.email }}</p>
          <p class="text-sm text-gray-500">Member since {{ formatDate(user?.created_at) }}</p>
          
          <!-- User Rating Display -->
          <div v-if="userStats" class="flex items-center mt-2">
            <StarRating :rating="userStats.average_rating" :readonly="true" :size="'sm'" />
            <span class="ml-2 text-sm text-gray-600">
              {{ userStats.average_rating.toFixed(1) }} ({{ userStats.total_ratings }} {{ userStats.total_ratings === 1 ? 'rating' : 'ratings' }})
            </span>
          </div>
          <div v-else-if="userStats && userStats.total_ratings === 0" class="text-sm text-gray-500 mt-2">
            No ratings yet
          </div>
        </div>
      </div>
    </div>

    <!-- Navigation Tabs -->
    <div class="mb-8">
      <nav class="flex space-x-8">
        <button
          @click="activeTab = 'listings'"
          :class="[
            'py-2 px-1 border-b-2 font-medium text-sm',
            activeTab === 'listings' 
              ? 'border-blue-500 text-blue-600' 
              : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
          ]"
        >
          My Listings
        </button>
        <button
          @click="activeTab = 'rentals'"
          :class="[
            'py-2 px-1 border-b-2 font-medium text-sm',
            activeTab === 'rentals' 
              ? 'border-blue-500 text-blue-600' 
              : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
          ]"
        >
          My Rentals
        </button>
        <button
          @click="activeTab = 'ratings'"
          :class="[
            'py-2 px-1 border-b-2 font-medium text-sm',
            activeTab === 'ratings' 
              ? 'border-blue-500 text-blue-600' 
              : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
          ]"
        >
          Ratings
        </button>
        <button
          @click="activeTab = 'subscription'"
          :class="[
            'py-2 px-1 border-b-2 font-medium text-sm',
            activeTab === 'subscription' 
              ? 'border-blue-500 text-blue-600' 
              : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
          ]"
        >
          Subscription
        </button>
        <button
          @click="activeTab = 'settings'"
          :class="[
            'py-2 px-1 border-b-2 font-medium text-sm',
            activeTab === 'settings' 
              ? 'border-blue-500 text-blue-600' 
              : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
          ]"
        >
          Settings
        </button>
        <button
          v-if="subscription?.user_role === 'super_user'"
          @click="activeTab = 'admin'"
          :class="[
            'py-2 px-1 border-b-2 font-medium text-sm',
            activeTab === 'admin' 
              ? 'border-purple-500 text-purple-600' 
              : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
          ]"
        >
          Admin
        </button>
      </nav>
    </div>

    <!-- Tab Content -->
    <div v-if="activeTab === 'listings'">
      <div class="flex justify-between items-center mb-6">
        <h2 class="text-xl font-semibold text-gray-900">My Listings</h2>
        <div class="flex items-center gap-3">
          <NuxtLink 
            v-if="!subscription || subscription.can_create_more_listings"
            to="/listings/create" 
            class="btn-primary"
          >
            Add New Listing
          </NuxtLink>
          <div v-else class="flex items-center gap-3">
            <span class="text-sm text-red-600 font-medium">Listing limit reached ({{ subscription.listing_usage_display }})</span>
            <button 
              @click="activeTab = 'subscription'" 
              class="btn-primary"
            >
              Upgrade to Premium
            </button>
          </div>
        </div>
      </div>

      <div v-if="userListings.length === 0" class="text-center py-12">
        <svg class="w-16 h-16 text-gray-400 mx-auto mb-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6"></path>
        </svg>
        <h3 class="text-lg font-medium text-gray-900 mb-2">No listings yet</h3>
        <p class="text-gray-600 mb-4">Start earning by listing your first item</p>
        <NuxtLink 
          v-if="!subscription || subscription.can_create_more_listings"
          to="/listings/create" 
          class="btn-primary"
        >
          Create Your First Listing
        </NuxtLink>
        <button 
          v-else
          @click="activeTab = 'subscription'" 
          class="btn-primary"
        >
          Upgrade to Create Listings
        </button>
      </div>

      <div v-else class="grid md:grid-cols-2 gap-6">
        <div v-for="listing in userListings" :key="listing.id" class="card hover:shadow-lg transition-all relative group">
          <!-- Clickable Card Overlay -->
          <NuxtLink 
            :to="`/listings/${listing.id}`" 
            class="absolute inset-0 z-10 cursor-pointer"
            :aria-label="`View ${listing.title}`"
          ></NuxtLink>
          
          <!-- Listing Image -->
          <div class="h-48 rounded-lg mb-4 overflow-hidden">
            <img 
              v-if="listing.primaryImage" 
              :src="listing.primaryImage" 
              :alt="listing.title"
              class="w-full h-full object-cover transition-transform group-hover:scale-105"
            />
            <div v-else class="bg-gray-200 h-full rounded-lg flex items-center justify-center">
              <svg class="w-12 h-12 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z"></path>
              </svg>
            </div>
          </div>
          
          <h3 class="font-semibold text-lg mb-2">{{ listing.title }}</h3>
          <p class="text-gray-600 mb-3 line-clamp-2">{{ listing.description }}</p>
          <div class="flex justify-between items-center mb-3">
            <span class="text-xl font-bold text-blue-600">${{ listing.price_per_day }}/day</span>
            <div class="flex gap-1">
              <span class="px-2 py-1 text-xs rounded-full" :class="getStatusClass(listing.status)">
                {{ listing.status }}
              </span>
              <span v-if="listing.status === 'active'" class="px-2 py-1 text-xs rounded-full" :class="getRentalStatusClass(listing.rental_status)">
                {{ getRentalStatusText(listing.rental_status) }}
              </span>
            </div>
          </div>
          
          <!-- Rental Status Details -->
          <div v-if="listing.rental_status === 'rented_out' && listing.rented_until" class="mb-3 p-2 bg-red-50 border border-red-200 rounded text-xs text-red-700">
            🔒 Rented until {{ new Date(listing.rented_until).toLocaleDateString() }}
          </div>
          <div v-else-if="listing.rental_status === 'maintenance'" class="mb-3 p-2 bg-yellow-50 border border-yellow-200 rounded text-xs text-yellow-700">
            🔧 Under maintenance
          </div>
          
          <!-- Quick Availability Toggle -->
          <div v-if="listing.status === 'active'" class="mb-3 relative z-20">
            <div class="flex gap-2">
              <button
                v-if="listing.rental_status !== 'available'"
                @click.stop="toggleAvailability(listing, 'available')"
                :disabled="updatingAvailability.has(listing.id)"
                class="flex-1 px-3 py-2 text-sm font-medium rounded-md border-2 border-green-500 text-green-700 bg-green-50 hover:bg-green-100 disabled:opacity-50 transition-colors"
              >
                <span v-if="updatingAvailability.has(listing.id)" class="flex items-center justify-center">
                  <svg class="animate-spin -ml-1 mr-1 h-4 w-4" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                    <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                    <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                  </svg>
                  Updating...
                </span>
                <span v-else class="flex items-center justify-center">
                  ✅ Mark Available
                </span>
              </button>
              
              <button
                v-if="listing.rental_status === 'available'"
                @click.stop="toggleAvailability(listing, 'maintenance')"
                :disabled="updatingAvailability.has(listing.id)"
                class="flex-1 px-3 py-2 text-sm font-medium rounded-md border-2 border-yellow-500 text-yellow-700 bg-yellow-50 hover:bg-yellow-100 disabled:opacity-50 transition-colors"
              >
                <span v-if="updatingAvailability.has(listing.id)" class="flex items-center justify-center">
                  <svg class="animate-spin -ml-1 mr-1 h-4 w-4" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                    <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                    <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                  </svg>
                  Updating...
                </span>
                <span v-else class="flex items-center justify-center">
                  🔧 Mark Unavailable
                </span>
              </button>
            </div>
          </div>

          <!-- Action Buttons (positioned above the overlay) -->
          <div class="flex gap-2 relative z-20">
            <button 
              class="btn-secondary text-sm flex-1" 
              @click.stop="navigateTo(`/listings/edit/${listing.id}`)"
            >
              Edit
            </button>
            <button 
              class="btn-danger text-sm flex-1" 
              @click.stop="confirmDelete(listing)"
              :disabled="deletingListings.has(listing.id)"
            >
              <span v-if="deletingListings.has(listing.id)" class="flex items-center justify-center">
                <svg class="animate-spin -ml-1 mr-2 h-4 w-4 text-white" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                  <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                  <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                </svg>
                Deleting...
              </span>
              <span v-else>Delete</span>
            </button>
          </div>
        </div>
      </div>
    </div>
    
    <!-- Delete Confirmation Modal -->
    <div v-if="showDeleteModal" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50" @click="cancelDelete">
      <div class="bg-white rounded-lg p-6 max-w-md mx-4" @click.stop>
        <div class="flex items-center mb-4">
          <svg class="w-6 h-6 text-red-600 mr-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-2.5L13.732 4c-.77-.833-1.964-.833-2.732 0L4.082 16.5c-.77.833.192 2.5 1.732 2.5z"></path>
          </svg>
          <h3 class="text-lg font-semibold text-gray-900">Delete Listing</h3>
        </div>
        
        <p class="text-gray-600 mb-6">
          Are you sure you want to delete "<strong>{{ listingToDelete?.title }}</strong>"? This action cannot be undone and will also delete all associated images.
        </p>
        
        <div class="flex gap-3 justify-end">
          <button 
            class="btn-secondary" 
            @click="cancelDelete"
            :disabled="deletingListings.has(listingToDelete?.id)"
          >
            Cancel
          </button>
          <button 
            class="btn-danger" 
            @click="deleteListing"
            :disabled="deletingListings.has(listingToDelete?.id)"
          >
            <span v-if="deletingListings.has(listingToDelete?.id)" class="flex items-center">
              <svg class="animate-spin -ml-1 mr-2 h-4 w-4 text-white" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
              </svg>
              Deleting...
            </span>
            <span v-else>Delete Listing</span>
          </button>
        </div>
      </div>
    </div>

    <div v-else-if="activeTab === 'rentals'">
      <h2 class="text-xl font-semibold text-gray-900 mb-6">My Rentals</h2>
      
      <div class="text-center py-12">
        <svg class="w-16 h-16 text-gray-400 mx-auto mb-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5H7a2 2 0 00-2 2v10a2 2 0 002 2h8a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2"></path>
        </svg>
        <h3 class="text-lg font-medium text-gray-900 mb-2">No rentals yet</h3>
        <p class="text-gray-600 mb-4">Items you've rented will appear here</p>
        <NuxtLink to="/search" class="btn-primary">
          Browse Items
        </NuxtLink>
      </div>
    </div>

    <div v-else-if="activeTab === 'ratings'">
      <h2 class="text-xl font-semibold text-gray-900 mb-6">User Ratings</h2>
      
      <!-- User Rating Component -->
      <UserRating :user-id="user?.id" />
    </div>

    <div v-else-if="activeTab === 'subscription'">
      <h2 class="text-xl font-semibold text-gray-900 mb-6">Subscription & Limits</h2>
      
      <div class="space-y-6">
        <!-- Current Plan Card -->
        <div class="card">
          <div class="flex items-center justify-between mb-4">
            <h3 class="text-lg font-medium text-gray-900">Current Plan</h3>
            <span v-if="subscription" class="px-3 py-1 text-sm font-medium rounded-full" :class="getSubscriptionStatusDisplay(subscription.subscription_status).class">
              {{ getSubscriptionStatusDisplay(subscription.subscription_status).text }}
            </span>
          </div>
          
          <div v-if="subscription" class="space-y-4">
            <div class="flex items-center justify-between">
              <span class="text-gray-600">Plan Type:</span>
              <span class="font-medium">{{ getRoleDisplayName(subscription.user_role) }}</span>
            </div>
            
            <div class="flex items-center justify-between">
              <span class="text-gray-600">Listings Used:</span>
              <span class="font-medium">{{ subscription.listing_usage_display }}</span>
            </div>
            
            <div v-if="subscription.user_role === 'free_user'" class="bg-blue-50 border border-blue-200 rounded-lg p-4">
              <div class="flex items-start">
                <svg class="w-5 h-5 text-blue-600 mt-0.5 mr-3 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path>
                </svg>
                <div>
                  <h4 class="text-sm font-medium text-blue-900 mb-1">Free Plan Limits</h4>
                  <p class="text-sm text-blue-700">You can create up to 2 free listings. Upgrade to Premium for unlimited listings and more features.</p>
                </div>
              </div>
            </div>
            
            <div v-if="!subscription.can_create_more_listings && subscription.user_role === 'free_user'" class="bg-red-50 border border-red-200 rounded-lg p-4">
              <div class="flex items-start">
                <svg class="w-5 h-5 text-red-600 mt-0.5 mr-3 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-2.5L13.732 4c-.77-.833-1.964-.833-2.732 0L4.082 16.5c-.77.833.192 2.5 1.732 2.5z"></path>
                </svg>
                <div>
                  <h4 class="text-sm font-medium text-red-900 mb-1">Listing Limit Reached</h4>
                  <p class="text-sm text-red-700">You've reached your free listing limit. Upgrade to Premium to create unlimited listings.</p>
                </div>
              </div>
            </div>
          </div>
          
          <div v-else class="text-center py-4">
            <div class="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600 mx-auto mb-2"></div>
            <p class="text-gray-600">Loading subscription info...</p>
          </div>
        </div>

        <!-- Plan Benefits -->
        <div class="card">
          <h3 class="text-lg font-medium text-gray-900 mb-4">Plan Benefits</h3>
          <div v-if="subscription" class="space-y-2">
            <div v-for="benefit in getRoleBenefits(subscription.user_role)" :key="benefit" class="flex items-center">
              <svg class="w-4 h-4 text-green-500 mr-2 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"></path>
              </svg>
              <span class="text-gray-700">{{ benefit }}</span>
            </div>
          </div>
        </div>

        <!-- Upgrade Options -->
        <div v-if="subscription && subscription.user_role === 'free_user'" class="card">
          <h3 class="text-lg font-medium text-gray-900 mb-4">Upgrade to Premium</h3>
          <div class="bg-gradient-to-r from-blue-50 to-indigo-50 border border-blue-200 rounded-lg p-6">
            <div class="flex items-center justify-between mb-4">
              <div>
                <h4 class="text-lg font-semibold text-gray-900">Premium Membership</h4>
                <p class="text-gray-600">Unlock unlimited listings and premium features</p>
              </div>
              <div class="text-right">
                <div class="text-2xl font-bold text-gray-900">$9.99</div>
                <div class="text-sm text-gray-600">per month</div>
              </div>
            </div>
            
            <div class="space-y-2 mb-6">
              <div class="flex items-center text-sm text-gray-700">
                <svg class="w-4 h-4 text-green-500 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"></path>
                </svg>
                Unlimited listings
              </div>
              <div class="flex items-center text-sm text-gray-700">
                <svg class="w-4 h-4 text-green-500 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"></path>
                </svg>
                Direct contact with renters
              </div>
              <div class="flex items-center text-sm text-gray-700">
                <svg class="w-4 h-4 text-green-500 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"></path>
                </svg>
                Priority listing placement
              </div>
              <div class="flex items-center text-sm text-gray-700">
                <svg class="w-4 h-4 text-green-500 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"></path>
                </svg>
                Advanced search filters
              </div>
            </div>
            
            <button class="w-full btn-primary">
              Upgrade to Premium
            </button>
          </div>
        </div>

        <!-- Subscription Management -->
        <div v-if="subscription && subscription.user_role === 'paid_user'" class="card">
          <h3 class="text-lg font-medium text-gray-900 mb-4">Subscription Management</h3>
          <div class="space-y-4">
            <div v-if="subscription.subscription_end_date" class="flex items-center justify-between">
              <span class="text-gray-600">Next billing date:</span>
              <span class="font-medium">{{ new Date(subscription.subscription_end_date).toLocaleDateString() }}</span>
            </div>
            
            <div class="flex gap-3">
              <button class="btn-secondary">
                Update Payment Method
              </button>
              <button class="btn-danger">
                Cancel Subscription
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>

    <div v-else-if="activeTab === 'settings'">
      <h2 class="text-xl font-semibold text-gray-900 mb-6">Account Settings</h2>
      
      <div class="space-y-6">
        <div class="card">
          <h3 class="text-lg font-medium text-gray-900 mb-4">Profile Information</h3>
          <div class="space-y-4">
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">Full Name</label>
              <input
                v-model="profileForm.full_name"
                type="text"
                class="input-field"
              />
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">Email</label>
              <input
                v-model="profileForm.email"
                type="email"
                class="input-field"
                disabled
              />
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">Phone Number</label>
              <input
                v-model="profileForm.phone"
                type="tel"
                class="input-field"
                placeholder="Optional"
              />
            </div>
            <button class="btn-primary">Save Changes</button>
          </div>
        </div>

        <div class="card">
          <h3 class="text-lg font-medium text-gray-900 mb-4">Notifications</h3>
          <div class="space-y-3">
            <label class="flex items-center">
              <input type="checkbox" class="rounded border-gray-300 text-blue-600 focus:ring-blue-500" />
              <span class="ml-2 text-sm text-gray-700">Email notifications for new rental requests</span>
            </label>
            <label class="flex items-center">
              <input type="checkbox" class="rounded border-gray-300 text-blue-600 focus:ring-blue-500" />
              <span class="ml-2 text-sm text-gray-700">SMS notifications for urgent updates</span>
            </label>
            <label class="flex items-center">
              <input type="checkbox" class="rounded border-gray-300 text-blue-600 focus:ring-blue-500" />
              <span class="ml-2 text-sm text-gray-700">Marketing emails</span>
            </label>
          </div>
        </div>
      </div>
    </div>

    <!-- Admin Tab -->
    <div v-else-if="activeTab === 'admin'">
      <div class="flex justify-between items-center mb-6">
        <h2 class="text-xl font-semibold text-gray-900">Admin Panel</h2>
        <NuxtLink to="/admin" class="btn-primary">
          Go to Full Admin Dashboard
        </NuxtLink>
      </div>
      
      <div class="grid md:grid-cols-2 gap-6">
        <!-- Quick Stats -->
        <div class="card">
          <h3 class="text-lg font-medium text-gray-900 mb-4">Platform Overview</h3>
          <div class="space-y-3">
            <div class="flex justify-between">
              <span class="text-gray-600">Your Role:</span>
              <span class="font-medium text-purple-600">Super Admin</span>
            </div>
            <div class="flex justify-between">
              <span class="text-gray-600">Admin Access:</span>
              <span class="font-medium text-green-600">Full Access</span>
            </div>
            <div class="flex justify-between">
              <span class="text-gray-600">Permissions:</span>
              <span class="font-medium text-blue-600">User Management</span>
            </div>
          </div>
        </div>

        <!-- Quick Actions -->
        <div class="card">
          <h3 class="text-lg font-medium text-gray-900 mb-4">Quick Actions</h3>
          <div class="space-y-3">
            <NuxtLink to="/admin" class="block w-full btn-secondary text-center">
              🔍 Search & Manage Users
            </NuxtLink>
            <button class="w-full btn-secondary" disabled>
              📊 View Analytics (Coming Soon)
            </button>
            <button class="w-full btn-secondary" disabled>
              ⚙️ System Settings (Coming Soon)
            </button>
          </div>
        </div>
      </div>

      <!-- Admin Features Info -->
      <div class="mt-6 card">
        <h3 class="text-lg font-medium text-gray-900 mb-4">Admin Features</h3>
        <div class="grid md:grid-cols-2 gap-4">
          <div>
            <h4 class="font-medium text-gray-900 mb-2">User Management</h4>
            <ul class="text-sm text-gray-600 space-y-1">
              <li>• Search users by email or name</li>
              <li>• Update user roles and subscriptions</li>
              <li>• Manage subscription dates</li>
              <li>• View user statistics</li>
            </ul>
          </div>
          <div>
            <h4 class="font-medium text-gray-900 mb-2">Platform Control</h4>
            <ul class="text-sm text-gray-600 space-y-1">
              <li>• Override subscription limits</li>
              <li>• Grant premium access manually</li>
              <li>• Monitor platform usage</li>
              <li>• Access all user data</li>
            </ul>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
// Protect this page - require authentication
definePageMeta({
  middleware: 'auth'
})

const supabase = useSupabaseClient()
const user = useSupabaseUser()
const activeTab = ref('listings')
const userListings = ref([])
const loadingListings = ref(false)
const userStats = ref(null)

// Use subscription composable
const { 
  userSubscription: subscription, 
  getRoleDisplayName, 
  getRoleBenefits, 
  getSubscriptionStatusDisplay 
} = useUserSubscription()

// Delete functionality
const showDeleteModal = ref(false)
const listingToDelete = ref(null)
const deletingListings = ref(new Set())

// Availability toggle functionality
const updatingAvailability = ref(new Set())

// Load user's listings with images
const loadUserListings = async () => {
  if (!user.value) return
  
  try {
    loadingListings.value = true
    const { data, error } = await supabase
      .from('listings')
      .select(`
        *,
        listing_images(
          id,
          image_url,
          is_primary
        )
      `)
      .eq('owner_id', user.value.id)
      .order('created_at', { ascending: false })
    
    if (error) throw error
    
    // Process listings to get primary image
    const processedListings = (data || []).map(listing => ({
      ...listing,
      primaryImage: listing.listing_images?.find(img => img.is_primary)?.image_url || 
                   listing.listing_images?.[0]?.image_url || null
    }))
    
    userListings.value = processedListings
  } catch (err) {
    console.error('Error loading listings:', err)
  } finally {
    loadingListings.value = false
  }
}

// Delete listing functionality
const confirmDelete = (listing) => {
  listingToDelete.value = listing
  showDeleteModal.value = true
}

const cancelDelete = () => {
  showDeleteModal.value = false
  listingToDelete.value = null
}

const deleteListing = async () => {
  if (!listingToDelete.value) return
  
  const listingId = listingToDelete.value.id
  
  try {
    // Add to deleting set to show loading state
    deletingListings.value.add(listingId)
    
    // First, delete all images associated with the listing
    const { data: images, error: imagesError } = await supabase
      .from('listing_images')
      .select('image_url')
      .eq('listing_id', listingId)
    
    if (imagesError) {
      console.error('Error fetching images:', imagesError)
    }
    
    // Delete images from storage
    if (images && images.length > 0) {
      for (const image of images) {
        const imagePath = image.image_url.split('/').pop()
        const { error: storageError } = await supabase.storage
          .from('listing-images')
          .remove([`${user.value.id}/${imagePath}`])
        
        if (storageError) {
          console.error('Error deleting image from storage:', storageError)
        }
      }
    }
    
    // Delete listing images from database
    const { error: deleteImagesError } = await supabase
      .from('listing_images')
      .delete()
      .eq('listing_id', listingId)
    
    if (deleteImagesError) {
      console.error('Error deleting listing images:', deleteImagesError)
    }
    
    // Delete the listing itself
    const { error: deleteListingError } = await supabase
      .from('listings')
      .delete()
      .eq('id', listingId)
      .eq('owner_id', user.value.id) // Extra security check
    
    if (deleteListingError) {
      throw deleteListingError
    }
    
    // Remove from local state
    userListings.value = userListings.value.filter(listing => listing.id !== listingId)
    
    // Close modal
    showDeleteModal.value = false
    listingToDelete.value = null
    
    // Show success message (you could add a toast notification here)
    console.log('Listing deleted successfully')
    
  } catch (error) {
    console.error('Error deleting listing:', error)
    alert('Failed to delete listing. Please try again.')
  } finally {
    // Remove from deleting set
    deletingListings.value.delete(listingId)
  }
}

// Fetch user rating statistics
const fetchUserStats = async () => {
  if (!user.value) return
  
  try {
    const { data, error } = await supabase
      .from('user_rating_stats')
      .select('*')
      .eq('rated_user_id', user.value.id)
      .single()

    if (error && error.code !== 'PGRST116') {
      throw error
    }

    userStats.value = data || { total_ratings: 0, average_rating: 0 }
  } catch (err) {
    console.error('Error fetching user stats:', err)
    userStats.value = { total_ratings: 0, average_rating: 0 }
  }
}

// Load listings when component mounts and user is available
watch(user, (newUser) => {
  if (newUser) {
    loadUserListings()
    fetchUserStats()
  }
}, { immediate: true })

const profileForm = ref({
  full_name: user.value?.user_metadata?.full_name || '',
  email: user.value?.email || '',
  phone: ''
})

const formatDate = (dateString) => {
  if (!dateString) return ''
  return new Date(dateString).toLocaleDateString()
}

const getStatusClass = (status) => {
  switch (status) {
    case 'active':
      return 'bg-green-100 text-green-800'
    case 'inactive':
      return 'bg-gray-100 text-gray-800'
    case 'draft':
      return 'bg-yellow-100 text-yellow-800'
    default:
      return 'bg-gray-100 text-gray-800'
  }
}

const getRentalStatusClass = (rentalStatus) => {
  switch (rentalStatus) {
    case 'available':
      return 'bg-green-100 text-green-800'
    case 'rented_out':
      return 'bg-red-100 text-red-800'
    case 'maintenance':
      return 'bg-yellow-100 text-yellow-800'
    default:
      return 'bg-gray-100 text-gray-800'
  }
}

const getRentalStatusText = (rentalStatus) => {
  switch (rentalStatus) {
    case 'available':
      return '✅ Available'
    case 'rented_out':
      return '🔒 Rented'
    case 'maintenance':
      return '🔧 Maintenance'
    default:
      return 'Unknown'
  }
}

// Toggle availability function
const toggleAvailability = async (listing, newStatus) => {
  const listingId = listing.id
  
  try {
    // Add to updating set to show loading state
    updatingAvailability.value.add(listingId)
    
    // Prepare update data
    const updateData = {
      rental_status: newStatus,
      updated_at: new Date().toISOString()
    }
    
    // Clear rental-related fields when marking as available
    if (newStatus === 'available') {
      updateData.renter_id = null
      updateData.rental_start_date = null
      updateData.rented_until = null
      updateData.rental_notes = null
    }
    
    // Update the listing in the database
    const { error } = await supabase
      .from('listings')
      .update(updateData)
      .eq('id', listingId)
      .eq('owner_id', user.value.id) // Extra security check
    
    if (error) {
      throw error
    }
    
    // Update local state
    const listingIndex = userListings.value.findIndex(l => l.id === listingId)
    if (listingIndex !== -1) {
      userListings.value[listingIndex] = {
        ...userListings.value[listingIndex],
        ...updateData
      }
    }
    
    // Show success feedback (you could add a toast notification here)
    console.log(`Listing availability updated to: ${newStatus}`)
    
  } catch (error) {
    console.error('Error updating availability:', error)
    alert('Failed to update availability. Please try again.')
  } finally {
    // Remove from updating set
    updatingAvailability.value.delete(listingId)
  }
}

useHead({
  title: 'Profile - Dare2Share'
})
</script>
