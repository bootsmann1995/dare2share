<template>
  <div>
    <!-- Hero Section -->
    <section class="bg-gradient-to-r from-blue-600 to-blue-800 text-white">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-24">
        <div class="text-center">
          <h1 class="text-4xl md:text-6xl font-bold mb-6">
            Share What You Dare
          </h1>
          <p class="text-xl md:text-2xl mb-8 text-blue-100">
            Rent out your belongings or find what you need from your neighbors
          </p>
          <div class="flex flex-col sm:flex-row gap-4 justify-center">
            <NuxtLink to="/search" class="bg-white text-blue-600 hover:bg-gray-100 font-bold py-3 px-8 rounded-lg text-lg transition-colors">
              Find Items
            </NuxtLink>
            <NuxtLink to="/listings/create" class="bg-blue-500 hover:bg-blue-400 text-white font-bold py-3 px-8 rounded-lg text-lg transition-colors">
              List Your Items
            </NuxtLink>
          </div>
        </div>
      </div>
    </section>

    <!-- Features Section -->
    <section class="py-16">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="text-center mb-12">
          <h2 class="text-3xl font-bold text-gray-900 mb-4">How It Works</h2>
          <p class="text-lg text-gray-600">Simple steps to start sharing</p>
        </div>
        
        <div class="grid md:grid-cols-3 gap-8">
          <div class="text-center">
            <div class="bg-blue-100 w-16 h-16 rounded-full flex items-center justify-center mx-auto mb-4">
              <svg class="w-8 h-8 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6"></path>
              </svg>
            </div>
            <h3 class="text-xl font-semibold mb-2">List Your Items</h3>
            <p class="text-gray-600">Upload photos and describe what you want to rent out</p>
          </div>
          
          <div class="text-center">
            <div class="bg-green-100 w-16 h-16 rounded-full flex items-center justify-center mx-auto mb-4">
              <svg class="w-8 h-8 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"></path>
              </svg>
            </div>
            <h3 class="text-xl font-semibold mb-2">Find & Connect</h3>
            <p class="text-gray-600">Search for items nearby and connect with owners</p>
          </div>
          
          <div class="text-center">
            <div class="bg-purple-100 w-16 h-16 rounded-full flex items-center justify-center mx-auto mb-4">
              <svg class="w-8 h-8 text-purple-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"></path>
              </svg>
            </div>
            <h3 class="text-xl font-semibold mb-2">Rent & Enjoy</h3>
            <p class="text-gray-600">Arrange pickup and enjoy using what you need</p>
          </div>
        </div>
      </div>
    </section>

    <!-- Recent Listings Preview -->
    <section class="bg-gray-100 py-16">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="text-center mb-12">
          <h2 class="text-3xl font-bold text-gray-900 mb-4">Recent Listings</h2>
          <p class="text-lg text-gray-600">See what's available in your area</p>
        </div>
        
        <div v-if="loading" class="grid md:grid-cols-3 gap-6 mb-8">
          <!-- Loading placeholders -->
          <div v-for="i in 3" :key="i" class="card animate-pulse">
            <div class="bg-gray-200 h-48 rounded-lg mb-4"></div>
            <div class="h-4 bg-gray-200 rounded mb-2"></div>
            <div class="h-4 bg-gray-200 rounded w-1/2 mb-2"></div>
            <div class="h-3 bg-gray-200 rounded w-3/4"></div>
          </div>
        </div>
        
        <div v-else-if="featuredListings.length > 0" class="grid md:grid-cols-3 gap-6 mb-8">
          <!-- Real listings -->
          <NuxtLink 
            v-for="listing in featuredListings" 
            :key="listing.id"
            :to="`/listings/${listing.id}`"
            class="card hover:shadow-lg transition-shadow cursor-pointer group"
          >
            <!-- Image -->
            <div class="relative h-48 rounded-lg mb-4 overflow-hidden">
              <img 
                v-if="listing.primary_image"
                :src="listing.primary_image" 
                :alt="listing.title"
                class="w-full h-full object-cover group-hover:scale-105 transition-transform duration-300"
              />
              <div v-else class="bg-gray-200 h-full flex items-center justify-center">
                <svg class="w-12 h-12 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z"></path>
                </svg>
              </div>
              <!-- Category badge -->
              <div class="absolute top-2 left-2 bg-blue-600 text-white text-xs px-2 py-1 rounded-full capitalize">
                {{ listing.category }}
              </div>
            </div>
            
            <!-- Content -->
            <h3 class="font-semibold text-lg mb-2 line-clamp-1 group-hover:text-blue-600 transition-colors">{{ listing.title }}</h3>
            <p class="text-gray-600 mb-2 font-semibold">${{ listing.price_per_day }}/day</p>
            <p class="text-sm text-gray-500 mb-2 line-clamp-2">{{ listing.description }}</p>
            
            <!-- Owner info - conditional based on auth status -->
            <div v-if="user" class="flex items-center text-sm text-gray-500">
              <svg class="w-4 h-4 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z"></path>
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 11a3 3 0 11-6 0 3 3 0 016 0z"></path>
              </svg>
              {{ listing.location }} • by {{ listing.owner_name || 'Anonymous' }}
            </div>
            <div v-else class="flex items-center text-sm text-gray-500">
              <svg class="w-4 h-4 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z"></path>
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 11a3 3 0 11-6 0 3 3 0 016 0z"></path>
              </svg>
              {{ listing.location }} • <NuxtLink to="/auth/login" class="text-blue-600 hover:underline">Login to see owner</NuxtLink>
            </div>
          </NuxtLink>
        </div>
        
        <div v-else class="text-center py-8">
          <p class="text-gray-500 mb-4">No listings available yet.</p>
          <NuxtLink to="/listings/create" class="btn-primary">
            Be the first to list an item!
          </NuxtLink>
        </div>
        
        <div class="text-center">
          <NuxtLink to="/search" class="btn-primary">
            View All Listings
          </NuxtLink>
        </div>
      </div>
    </section>
  </div>
</template>

<script setup>
const supabase = useSupabaseClient()
const user = useSupabaseUser()

// Reactive data
const featuredListings = ref([])
const loading = ref(true)

// Fetch featured listings on page load
const fetchFeaturedListings = async () => {
  try {
    loading.value = true
    
    // Fetch 6 random recent listings with images and owner info
    const { data, error } = await supabase
      .from('listings_with_owner')
      .select(`
        id,
        title,
        description,
        price_per_day,
        category,
        location,
        owner_name,
        primary_image:listing_images!listing_images_listing_id_fkey(
          image_url
        )
      `)
      .eq('status', 'active')
      .not('listing_images.image_url', 'is', null)
      .eq('listing_images.is_primary', true)
      .order('created_at', { ascending: false })
      .limit(6)
    
    if (error) {
      console.error('Error fetching featured listings:', error)
      return
    }
    
    // Transform the data to flatten primary image
    featuredListings.value = (data || []).map(listing => ({
      ...listing,
      primary_image: listing.primary_image?.[0]?.image_url || null
    }))
    
  } catch (err) {
    console.error('Error fetching featured listings:', err)
  } finally {
    loading.value = false
  }
}

// Fetch listings on page load
onMounted(() => {
  fetchFeaturedListings()
})

// Set page meta
useHead({
  title: 'Dare2Share - Rent Anything from Your Neighbors',
  meta: [
    { name: 'description', content: 'Platform for renting out your belongings to others. Find tools, equipment, and more from people in your community.' }
  ]
})
</script>

<style scoped>
.line-clamp-1 {
  display: -webkit-box;
  -webkit-line-clamp: 1;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.line-clamp-2 {
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}
</style>
