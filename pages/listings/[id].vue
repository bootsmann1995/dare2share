<template>
  <div class="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
    <!-- Loading State -->
    <div v-if="loading" class="text-center py-12">
      <div class="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600 mx-auto"></div>
      <p class="mt-4 text-gray-600">Loading listing...</p>
    </div>

    <!-- Error State -->
    <div v-else-if="error" class="text-center py-12">
      <svg class="w-16 h-16 text-red-400 mx-auto mb-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-2.5L13.732 4c-.77-.833-1.964-.833-2.732 0L4.082 16.5c-.77.833.192 2.5 1.732 2.5z"></path>
      </svg>
      <h3 class="text-lg font-medium text-gray-900 mb-2">Listing not found</h3>
      <p class="text-gray-600 mb-4">{{ error }}</p>
      <NuxtLink to="/search" class="btn-primary">
        Browse Other Listings
      </NuxtLink>
    </div>

    <!-- Listing Content -->
    <div v-else-if="listing" class="grid lg:grid-cols-2 gap-8">
      <!-- Image Gallery -->
      <div>
        <div v-if="images.length > 0" class="space-y-4">
          <!-- Main Image -->
          <div class="aspect-w-4 aspect-h-3">
            <img 
              :src="selectedImage.image_url" 
              :alt="listing.title"
              class="w-full h-96 object-cover rounded-lg shadow-lg"
            />
          </div>
          
          <!-- Thumbnail Gallery -->
          <div v-if="images.length > 1" class="grid grid-cols-4 gap-2">
            <button
              v-for="(image, index) in images"
              :key="index"
              @click="selectedImage = image"
              :class="[
                'aspect-w-1 aspect-h-1 rounded-lg overflow-hidden border-2 transition-all',
                selectedImage.id === image.id 
                  ? 'border-blue-500 ring-2 ring-blue-200' 
                  : 'border-gray-200 hover:border-gray-300'
              ]"
            >
              <img 
                :src="image.image_url" 
                :alt="`${listing.title} ${index + 1}`"
                class="w-full h-20 object-cover"
              />
            </button>
          </div>
        </div>
        
        <!-- No Images Placeholder -->
        <div v-else class="bg-gray-200 h-96 rounded-lg flex items-center justify-center">
          <svg class="w-16 h-16 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z"></path>
          </svg>
        </div>
      </div>

      <!-- Listing Details -->
      <div class="space-y-6">
        <!-- Header -->
        <div>
          <div class="flex items-center justify-between mb-2">
            <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-blue-100 text-blue-800 capitalize">
              {{ listing.category }}
            </span>
            <span v-if="listing.status === 'active'" class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-green-100 text-green-800">
              Available
            </span>
          </div>
          
          <h1 class="text-3xl font-bold text-gray-900 mb-2">{{ listing.title }}</h1>
          
          <div class="flex items-center text-gray-600 mb-4">
            <svg class="w-5 h-5 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z"></path>
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 11a3 3 0 11-6 0 3 3 0 016 0z"></path>
            </svg>
            {{ listing.location }}
          </div>
        </div>

        <!-- Pricing -->
        <div class="bg-gray-50 rounded-lg p-6">
          <div class="flex items-baseline justify-between mb-4">
            <div>
              <span class="text-4xl font-bold text-blue-600">${{ listing.price_per_day }}</span>
              <span class="text-gray-600 ml-2">per day</span>
            </div>
          </div>
          
          <div v-if="listing.security_deposit > 0" class="text-sm text-gray-600 mb-2">
            Security deposit: ${{ listing.security_deposit }}
          </div>
          
          <div v-if="listing.min_rental_days > 1" class="text-sm text-gray-600 mb-4">
            Minimum rental: {{ listing.min_rental_days }} days
          </div>
          
          <div class="flex gap-2 mb-4">
            <span v-if="listing.available_now" class="inline-flex items-center px-2 py-1 rounded-full text-xs font-medium bg-green-100 text-green-800">
              <svg class="w-3 h-3 mr-1" fill="currentColor" viewBox="0 0 20 20">
                <path fill-rule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clip-rule="evenodd"></path>
              </svg>
              Available Now
            </span>
            
            <span v-if="listing.delivery_available" class="inline-flex items-center px-2 py-1 rounded-full text-xs font-medium bg-blue-100 text-blue-800">
              <svg class="w-3 h-3 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M20 7l-8-4-8 4m16 0l-8 4m8-4v10l-8 4m0-10L4 7m8 4v10M4 7v10l8 4"></path>
              </svg>
              Delivery Available
            </span>
          </div>
          
          <button 
            v-if="!isOwner"
            class="w-full btn-primary"
            @click="contactOwner"
          >
            Contact Owner
          </button>
          
          <div v-else class="text-center text-gray-600">
            <p class="text-sm">This is your listing</p>
            <NuxtLink to="/profile" class="text-blue-600 hover:text-blue-500 text-sm">
              Manage in Profile
            </NuxtLink>
          </div>
        </div>

        <!-- Owner Info -->
        <div class="border-t pt-6">
          <h3 class="text-lg font-semibold text-gray-900 mb-3">Listed by</h3>
          <div class="flex items-center">
            <div class="w-12 h-12 bg-gray-300 rounded-full flex items-center justify-center mr-3">
              <svg class="w-6 h-6 text-gray-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"></path>
              </svg>
            </div>
            <div>
              <p class="font-medium text-gray-900">{{ listing.owner_name || 'Anonymous' }}</p>
              <p class="text-sm text-gray-600">Member since {{ formatDate(listing.created_at) }}</p>
            </div>
          </div>
        </div>

        <!-- Description -->
        <div class="border-t pt-6">
          <h3 class="text-lg font-semibold text-gray-900 mb-3">Description</h3>
          <p class="text-gray-700 whitespace-pre-wrap">{{ listing.description }}</p>
          
          <div v-if="listing.additional_notes" class="mt-4 p-4 bg-yellow-50 border border-yellow-200 rounded-lg">
            <h4 class="font-medium text-yellow-800 mb-2">Additional Notes</h4>
            <p class="text-yellow-700 text-sm whitespace-pre-wrap">{{ listing.additional_notes }}</p>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
const route = useRoute()
const supabase = useSupabaseClient()
const user = useSupabaseUser()

const listing = ref(null)
const images = ref([])
const selectedImage = ref(null)
const loading = ref(true)
const error = ref('')

const isOwner = computed(() => {
  return user.value && listing.value && user.value.id === listing.value.owner_id
})

const loadListing = async () => {
  try {
    loading.value = true
    error.value = ''

    const listingId = route.params.id

    // Load listing with owner info
    const { data: listingData, error: listingError } = await supabase
      .from('listings_with_owner')
      .select('*')
      .eq('id', listingId)
      .eq('status', 'active')
      .single()

    if (listingError) {
      if (listingError.code === 'PGRST116') {
        throw new Error('Listing not found or no longer available')
      }
      throw listingError
    }

    listing.value = listingData

    // Load listing images
    const { data: imageData, error: imageError } = await supabase
      .from('listing_images')
      .select('*')
      .eq('listing_id', listingId)
      .order('is_primary', { ascending: false })
      .order('created_at', { ascending: true })

    if (imageError) {
      console.error('Error loading images:', imageError)
    } else {
      images.value = imageData || []
      selectedImage.value = images.value[0] || null
    }

  } catch (err) {
    error.value = err.message
    console.error('Error loading listing:', err)
  } finally {
    loading.value = false
  }
}

const contactOwner = () => {
  // For now, just show an alert. In a real app, this would open a messaging system
  alert('Contact feature coming soon! For now, you can reach out to the owner through the platform.')
}

const formatDate = (dateString) => {
  if (!dateString) return ''
  return new Date(dateString).toLocaleDateString('en-US', { 
    year: 'numeric', 
    month: 'long' 
  })
}

// Load listing when component mounts
onMounted(() => {
  loadListing()
})

// Update page title
useHead(() => ({
  title: listing.value ? `${listing.value.title} - Dare2Share` : 'Loading - Dare2Share'
}))
</script>
