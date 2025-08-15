<template>
  <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
    <!-- Search Header -->
    <div class="mb-8">
      <h1 class="text-3xl font-bold text-gray-900 mb-4">Find Items to Rent</h1>
      
      <!-- Search Bar -->
      <div class="flex gap-4 mb-6">
        <div class="flex-1">
          <input
            v-model="searchQuery"
            type="text"
            placeholder="Search for items (e.g., drill, camera, bike...)"
            class="input-field"
            @keyup.enter="performSearch"
          />
        </div>
        <button @click="performSearch" class="btn-primary">
          <svg class="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"></path>
          </svg>
          Search
        </button>
      </div>
      
      <!-- Filters -->
      <div class="flex flex-wrap items-center gap-4">
        <div class="flex items-center gap-2">
          <label class="text-sm font-medium text-gray-700">Category:</label>
          <select v-model="selectedCategory" class="input-field w-auto min-w-[140px]">
            <option value="">All Categories</option>
            <option value="tools">Tools & Equipment</option>
            <option value="electronics">Electronics</option>
            <option value="sports">Sports & Recreation</option>
            <option value="vehicles">Vehicles</option>
            <option value="home">Home & Garden</option>
            <option value="other">Other</option>
          </select>
        </div>
        
        <div class="flex items-center gap-2">
          <label class="text-sm font-medium text-gray-700">Price:</label>
          <select v-model="priceRange" class="input-field w-auto min-w-[120px]">
            <option value="">Any Price</option>
            <option value="0-10">$0 - $10/day</option>
            <option value="10-25">$10 - $25/day</option>
            <option value="25-50">$25 - $50/day</option>
            <option value="50+">$50+/day</option>
          </select>
        </div>
        
        <div class="flex items-center gap-2">
          <label class="text-sm font-medium text-gray-700">Location:</label>
          <input
            v-model="location"
            type="text"
            placeholder="Enter city or area"
            class="input-field w-auto min-w-[150px]"
          />
        </div>
        
        <!-- Clear Filters Button -->
        <button 
          v-if="hasActiveFilters"
          @click="clearFilters"
          class="btn-secondary text-sm"
        >
          <svg class="w-4 h-4 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>
          </svg>
          Clear Filters
        </button>
      </div>
    </div>

    <!-- Search Results -->
    <div v-if="loading" class="text-center py-8">
      <div class="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600 mx-auto"></div>
      <p class="mt-4 text-gray-600">Searching...</p>
    </div>

    <div v-else-if="searchResults.length === 0 && hasSearched" class="text-center py-8">
      <svg class="w-16 h-16 text-gray-400 mx-auto mb-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9.172 16.172a4 4 0 015.656 0M9 12h6m-6-4h6m2 5.291A7.962 7.962 0 0112 15c-2.34 0-4.29-1.009-5.824-2.562M15 9.75a3 3 0 11-6 0 3 3 0 016 0z"></path>
      </svg>
      <h3 class="text-lg font-medium text-gray-900 mb-2">No items found</h3>
      <p class="text-gray-600">Try adjusting your search terms or filters</p>
    </div>

    <div v-else class="grid md:grid-cols-2 lg:grid-cols-3 gap-6">
      <NuxtLink 
        v-for="listing in searchResults" 
        :key="listing.id" 
        :to="`/listings/${listing.id}`"
        class="card hover:shadow-lg transition-all hover:scale-[1.02] cursor-pointer block"
      >
        <!-- Listing Image -->
        <div class="h-48 rounded-lg mb-4 overflow-hidden">
          <img 
            v-if="listing.primaryImage" 
            :src="listing.primaryImage" 
            :alt="listing.title"
            class="w-full h-full object-cover transition-transform hover:scale-105"
          />
          <div v-else class="bg-gray-200 h-full rounded-lg flex items-center justify-center">
            <svg class="w-12 h-12 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z"></path>
            </svg>
          </div>
        </div>
        
        <div class="flex justify-between items-start mb-2">
          <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-blue-100 text-blue-800 capitalize">
            {{ listing.category }}
          </span>
          <span class="text-sm text-gray-500">{{ listing.location }}</span>
        </div>
        <h3 class="font-semibold text-lg mb-2">{{ listing.title }}</h3>
        <p class="text-gray-600 text-sm mb-3 line-clamp-2">{{ listing.description }}</p>
        <div class="flex justify-between items-center">
          <span class="text-xl font-bold text-blue-600">${{ listing.price_per_day }}/day</span>
          <span class="text-sm text-gray-500">by {{ listing.owner_name || 'Anonymous' }}</span>
        </div>
      </NuxtLink>
    </div>

    <!-- Loading More Indicator -->
    <div v-if="loadingMore" class="text-center py-8">
      <div class="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600 mx-auto mb-2"></div>
      <p class="text-gray-600">Loading more listings...</p>
    </div>
    
    <!-- No More Results -->
    <div v-else-if="hasSearched && searchResults.length > 0 && !hasMore" class="text-center py-8">
      <p class="text-gray-600">You've reached the end of the results</p>
    </div>
    
    <!-- Initial Loading State -->
    <div v-else-if="!hasSearched && loading" class="text-center py-12">
      <div class="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600 mx-auto mb-4"></div>
      <p class="text-gray-600">Loading listings...</p>
    </div>
  </div>
</template>

<script setup>
const supabase = useSupabaseClient()
const route = useRoute()
const router = useRouter()

// Search state
const searchQuery = ref('')
const selectedCategory = ref('')
const priceRange = ref('')
const location = ref('')
const loading = ref(false)
const loadingMore = ref(false)
const hasSearched = ref(false)
const searchResults = ref([])
const hasMore = ref(true)
const currentPage = ref(0)
const pageSize = 12

// Computed property to check if any filters are active
const hasActiveFilters = computed(() => {
  return searchQuery.value || selectedCategory.value || priceRange.value || location.value
})

// Build search query with filters
const buildQuery = () => {
  let query = supabase
    .from('listings_with_owner')
    .select(`
      *,
      listing_images(
        id,
        image_url,
        is_primary
      )
    `)
    .eq('status', 'active')
  
  // Add search query filter (full-text search)
  if (searchQuery.value) {
    query = query.or(`title.ilike.%${searchQuery.value}%,description.ilike.%${searchQuery.value}%,location.ilike.%${searchQuery.value}%`)
  }
  
  // Add category filter
  if (selectedCategory.value) {
    query = query.eq('category', selectedCategory.value)
  }
  
  // Add location filter
  if (location.value) {
    query = query.ilike('location', `%${location.value}%`)
  }
  
  // Add price range filter
  if (priceRange.value) {
    const [min, max] = priceRange.value.split('-')
    if (max === undefined) {
      // Handle "50+" case
      query = query.gte('price_per_day', parseInt(min))
    } else {
      query = query.gte('price_per_day', parseInt(min)).lte('price_per_day', parseInt(max))
    }
  }
  
  return query
}

// Perform search with pagination
const performSearch = async (reset = true) => {
  try {
    if (reset) {
      loading.value = true
      currentPage.value = 0
      searchResults.value = []
      hasMore.value = true
    } else {
      loadingMore.value = true
    }
    
    hasSearched.value = true
    
    // Build and execute query
    const query = buildQuery()
    const { data, error } = await query
      .order('created_at', { ascending: false })
      .range(currentPage.value * pageSize, (currentPage.value + 1) * pageSize - 1)
    
    if (error) {
      throw error
    }
    
    // Process results to get primary image
    const processedResults = (data || []).map(listing => ({
      ...listing,
      primaryImage: listing.listing_images?.find(img => img.is_primary)?.image_url || 
                   listing.listing_images?.[0]?.image_url || null
    }))
    
    if (reset) {
      searchResults.value = processedResults
    } else {
      searchResults.value = [...searchResults.value, ...processedResults]
    }
    
    // Check if there are more results
    hasMore.value = processedResults.length === pageSize
    currentPage.value++
    
    // Update URL with search parameters
    updateURL()
    
  } catch (err) {
    console.error('Search error:', err)
  } finally {
    loading.value = false
    loadingMore.value = false
  }
}

// Load more results for infinite scroll
const loadMore = async () => {
  if (!hasMore.value || loadingMore.value) return
  await performSearch(false)
}

// Clear all filters and perform fresh search
const clearFilters = () => {
  searchQuery.value = ''
  selectedCategory.value = ''
  priceRange.value = ''
  location.value = ''
  // performSearch will be triggered automatically by the watchers
}

// Update URL with current search parameters
const updateURL = () => {
  const query = {}
  if (searchQuery.value) query.q = searchQuery.value
  if (selectedCategory.value) query.category = selectedCategory.value
  if (priceRange.value) query.price = priceRange.value
  if (location.value) query.location = location.value
  
  router.push({ query })
}

// Initialize search from URL parameters
const initializeFromURL = () => {
  searchQuery.value = route.query.q || ''
  selectedCategory.value = route.query.category || ''
  priceRange.value = route.query.price || ''
  location.value = route.query.location || ''
}

// Infinite scroll handler
const handleScroll = () => {
  const scrollTop = window.pageYOffset || document.documentElement.scrollTop
  const windowHeight = window.innerHeight
  const documentHeight = document.documentElement.scrollHeight
  
  // Load more when user is 200px from bottom
  if (scrollTop + windowHeight >= documentHeight - 200) {
    loadMore()
  }
}

// Initialize search on page load
onMounted(() => {
  initializeFromURL()
  performSearch() // Default search - load all listings
  
  // Add scroll listener for infinite scroll
  window.addEventListener('scroll', handleScroll)
})

// Clean up scroll listener
onUnmounted(() => {
  window.removeEventListener('scroll', handleScroll)
})

// Watch for URL changes (back/forward navigation)
watch(() => route.query, () => {
  initializeFromURL()
  performSearch()
}, { deep: true })

// Watch for ALL filter changes with debounce to reduce database requests
watch([selectedCategory, priceRange, location, searchQuery], debounce(() => {
  // Only trigger search if we've already done initial search
  if (hasSearched.value) {
    performSearch()
  }
}, 500), { deep: true })

// Simple debounce function
function debounce(func, wait) {
  let timeout
  return function executedFunction(...args) {
    const later = () => {
      clearTimeout(timeout)
      func(...args)
    }
    clearTimeout(timeout)
    timeout = setTimeout(later, wait)
  }
}

useHead({
  title: 'Search - Dare2Share'
})
</script>

<style scoped>
.line-clamp-2 {
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}
</style>
