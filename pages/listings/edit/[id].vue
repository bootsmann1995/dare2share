<template>
  <div class="max-w-2xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
    <div class="mb-8">
      <h1 class="text-3xl font-bold text-gray-900 mb-2">Edit Your Listing</h1>
      <p class="text-gray-600">Update your item details and availability</p>
    </div>

    <!-- Loading state -->
    <div v-if="initialLoading" class="text-center py-8">
      <div class="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600 mx-auto"></div>
      <p class="text-gray-600 mt-2">Loading listing...</p>
    </div>

    <!-- Not found state -->
    <div v-else-if="notFound" class="text-center py-8">
      <h2 class="text-xl font-semibold text-gray-900 mb-2">Listing Not Found</h2>
      <p class="text-gray-600 mb-4">The listing you're trying to edit doesn't exist or you don't have permission to edit it.</p>
      <button @click="navigateTo('/profile')" class="btn-primary">
        Back to Profile
      </button>
    </div>

    <!-- Edit form -->
    <form v-else @submit.prevent="updateListing" class="space-y-6">
      <!-- Item Photos -->
      <div>
        <ImageUpload v-model="uploadedImages" :max-images="5" :existing-images="existingImages" />
      </div>

      <!-- Item Details -->
      <div class="grid md:grid-cols-2 gap-6">
        <div>
          <label for="title" class="block text-sm font-medium text-gray-700 mb-2">Item Title *</label>
          <input
            id="title"
            v-model="form.title"
            type="text"
            required
            class="input-field"
            placeholder="e.g., Professional Power Drill"
          />
        </div>

        <div>
          <label for="category" class="block text-sm font-medium text-gray-700 mb-2">Category *</label>
          <select id="category" v-model="form.category" required class="input-field">
            <option value="">Select a category</option>
            <option value="tools">Tools & Equipment</option>
            <option value="electronics">Electronics</option>
            <option value="sports">Sports & Recreation</option>
            <option value="vehicles">Vehicles</option>
            <option value="home">Home & Garden</option>
            <option value="other">Other</option>
          </select>
        </div>
      </div>

      <div>
        <label for="description" class="block text-sm font-medium text-gray-700 mb-2">Description *</label>
        <textarea
          id="description"
          v-model="form.description"
          rows="4"
          required
          class="input-field"
          placeholder="Describe your item, its condition, and any special instructions..."
        ></textarea>
      </div>

      <!-- Pricing & Availability -->
      <div class="grid md:grid-cols-3 gap-6">
        <div>
          <label for="price" class="block text-sm font-medium text-gray-700 mb-2">Price per Day *</label>
          <div class="relative">
            <span class="absolute left-3 top-2 text-gray-500">$</span>
            <input
              id="price"
              v-model="form.price_per_day"
              type="number"
              step="0.01"
              min="0"
              required
              class="input-field pl-8"
              placeholder="0.00"
            />
          </div>
        </div>

        <div>
          <label for="deposit" class="block text-sm font-medium text-gray-700 mb-2">Security Deposit</label>
          <div class="relative">
            <span class="absolute left-3 top-2 text-gray-500">$</span>
            <input
              id="deposit"
              v-model="form.security_deposit"
              type="number"
              step="0.01"
              min="0"
              class="input-field pl-8"
              placeholder="0.00"
            />
          </div>
        </div>

        <div>
          <label for="minRental" class="block text-sm font-medium text-gray-700 mb-2">Min Rental (days)</label>
          <input
            id="minRental"
            v-model="form.min_rental_days"
            type="number"
            min="1"
            class="input-field"
            placeholder="1"
          />
        </div>
      </div>

      <!-- Location -->
      <div>
        <label for="location" class="block text-sm font-medium text-gray-700 mb-2">Location *</label>
        <input
          id="location"
          v-model="form.location"
          type="text"
          required
          class="input-field"
          placeholder="City, neighborhood, or general area"
        />
      </div>

      <!-- Availability -->
      <div>
        <label class="block text-sm font-medium text-gray-700 mb-2">Availability</label>
        <div class="space-y-2">
          <label class="flex items-center">
            <input
              v-model="form.available_now"
              type="checkbox"
              class="rounded border-gray-300 text-blue-600 focus:ring-blue-500"
            />
            <span class="ml-2 text-sm text-gray-700">Available now</span>
          </label>
        </div>
      </div>

      <!-- Delivery & Pickup Options -->
      <div>
        <label class="block text-sm font-medium text-gray-700 mb-2">Delivery & Pickup Options *</label>
        <div class="space-y-3">
          <label class="flex items-center">
            <input 
              type="radio" 
              v-model="form.delivery_method" 
              value="pickup_only" 
              class="text-blue-600 focus:ring-blue-500" 
            />
            <span class="ml-2 text-sm text-gray-700">Pickup only - Renter picks up the item</span>
          </label>
          
          <label class="flex items-center">
            <input 
              type="radio" 
              v-model="form.delivery_method" 
              value="delivery_only" 
              class="text-blue-600 focus:ring-blue-500" 
            />
            <span class="ml-2 text-sm text-gray-700">Delivery only - I will deliver the item</span>
          </label>
          
          <label class="flex items-center">
            <input 
              type="radio" 
              v-model="form.delivery_method" 
              value="both" 
              class="text-blue-600 focus:ring-blue-500" 
            />
            <span class="ml-2 text-sm text-gray-700">Both options available - Flexible pickup or delivery</span>
          </label>
        </div>
        
        <!-- Delivery Details (shown when delivery is available) -->
        <div v-if="form.delivery_method === 'delivery_only' || form.delivery_method === 'both'" class="mt-4 p-4 bg-blue-50 border border-blue-200 rounded-lg">
          <h4 class="font-medium text-blue-900 mb-3">Delivery Details</h4>
          
          <div class="grid md:grid-cols-2 gap-4">
            <div>
              <label for="delivery_fee" class="block text-sm font-medium text-blue-700 mb-1">Delivery Fee</label>
              <div class="relative">
                <span class="absolute left-3 top-2 text-blue-500">$</span>
                <input
                  id="delivery_fee"
                  v-model="form.delivery_fee"
                  type="number"
                  step="0.01"
                  min="0"
                  class="input-field pl-8 text-sm"
                  placeholder="0.00"
                />
              </div>
              <p class="text-xs text-blue-600 mt-1">Leave as 0 for free delivery</p>
            </div>
            
            <div>
              <label for="delivery_radius" class="block text-sm font-medium text-blue-700 mb-1">Delivery Radius</label>
              <div class="relative">
                <input
                  id="delivery_radius"
                  v-model="form.delivery_radius"
                  type="number"
                  min="1"
                  class="input-field text-sm"
                  placeholder="10"
                />
                <span class="absolute right-3 top-2 text-blue-500 text-sm">km</span>
              </div>
              <p class="text-xs text-blue-600 mt-1">Maximum distance you'll deliver</p>
            </div>
          </div>
        </div>
        
        <!-- Pickup Instructions -->
        <div v-if="form.delivery_method === 'pickup_only' || form.delivery_method === 'both'" class="mt-4">
          <label for="pickup_instructions" class="block text-sm font-medium text-gray-700 mb-2">Pickup Instructions</label>
          <textarea
            id="pickup_instructions"
            v-model="form.pickup_instructions"
            rows="2"
            class="input-field text-sm"
            placeholder="e.g., Ring doorbell, available weekends, parking instructions..."
          ></textarea>
        </div>
      </div>

      <!-- Additional Notes -->
      <div>
        <label for="notes" class="block text-sm font-medium text-gray-700 mb-2">Additional Notes</label>
        <textarea
          id="notes"
          v-model="form.additional_notes"
          rows="3"
          class="input-field"
          placeholder="Any special requirements, pickup instructions, etc."
        ></textarea>
      </div>

      <!-- Status -->
      <div>
        <label for="status" class="block text-sm font-medium text-gray-700 mb-2">Listing Status</label>
        <select id="status" v-model="form.status" class="input-field">
          <option value="active">Active</option>
          <option value="inactive">Inactive</option>
          <option value="draft">Draft</option>
        </select>
        <p class="text-sm text-gray-500 mt-1">
          Active listings are visible to other users. Inactive listings are hidden but can be reactivated.
        </p>
      </div>

      <!-- Rental Status -->
      <div v-if="form.status === 'active'">
        <label class="block text-sm font-medium text-gray-700 mb-2">Rental Availability</label>
        <div class="space-y-3">
          <label class="flex items-center">
            <input 
              type="radio" 
              v-model="form.rental_status" 
              value="available" 
              class="text-green-600 focus:ring-green-500" 
            />
            <span class="ml-2 text-sm text-gray-700">✅ Available for rent</span>
          </label>
          
          <label class="flex items-center">
            <input 
              type="radio" 
              v-model="form.rental_status" 
              value="rented_out" 
              class="text-red-600 focus:ring-red-500" 
            />
            <span class="ml-2 text-sm text-gray-700">🔒 Currently rented out</span>
          </label>
          
          <label class="flex items-center">
            <input 
              type="radio" 
              v-model="form.rental_status" 
              value="maintenance" 
              class="text-yellow-600 focus:ring-yellow-500" 
            />
            <span class="ml-2 text-sm text-gray-700">🔧 Under maintenance</span>
          </label>
        </div>
        
        <!-- Rental Details (shown when rented out) -->
        <div v-if="form.rental_status === 'rented_out'" class="mt-4 p-4 bg-red-50 border border-red-200 rounded-lg">
          <h4 class="font-medium text-red-900 mb-3">Rental Details</h4>
          
          <div class="grid md:grid-cols-2 gap-4">
            <div>
              <label for="rental_start_date" class="block text-sm font-medium text-red-700 mb-1">Rental Start Date</label>
              <input
                id="rental_start_date"
                v-model="form.rental_start_date"
                type="date"
                class="input-field text-sm"
              />
            </div>
            
            <div>
              <label for="rented_until" class="block text-sm font-medium text-red-700 mb-1">Rented Until</label>
              <input
                id="rented_until"
                v-model="form.rented_until"
                type="date"
                class="input-field text-sm"
              />
            </div>
          </div>
          
          <div class="mt-4">
            <label for="rental_notes" class="block text-sm font-medium text-red-700 mb-1">Rental Notes (Optional)</label>
            <textarea
              id="rental_notes"
              v-model="form.rental_notes"
              rows="2"
              class="input-field text-sm"
              placeholder="e.g., Rented to John Doe, contact: 555-1234..."
            ></textarea>
          </div>
        </div>
        
        <!-- Maintenance Notes -->
        <div v-if="form.rental_status === 'maintenance'" class="mt-4 p-4 bg-yellow-50 border border-yellow-200 rounded-lg">
          <h4 class="font-medium text-yellow-900 mb-3">Maintenance Details</h4>
          
          <div>
            <label for="maintenance_notes" class="block text-sm font-medium text-yellow-700 mb-1">Maintenance Notes</label>
            <textarea
              id="maintenance_notes"
              v-model="form.rental_notes"
              rows="2"
              class="input-field text-sm"
              placeholder="e.g., Needs repair, cleaning, etc..."
            ></textarea>
          </div>
        </div>
      </div>

      <!-- Error/Success Messages -->
      <div v-if="error" class="text-red-600 text-sm">
        {{ error }}
      </div>

      <div v-if="success" class="text-green-600 text-sm">
        {{ success }}
      </div>

      <!-- Submit Button -->
      <div class="flex gap-4">
        <button
          type="submit"
          :disabled="loading"
          class="btn-primary flex-1"
        >
          <span v-if="loading">Updating...</span>
          <span v-else>Update Listing</span>
        </button>
        
        <button
          type="button"
          @click="navigateTo('/profile')"
          class="btn-secondary"
        >
          Cancel
        </button>
      </div>
    </form>
  </div>
</template>

<script setup>
// Protect this page - require authentication
definePageMeta({
  middleware: 'auth'
})

const route = useRoute()
const supabase = useSupabaseClient()
const user = useSupabaseUser()

const listingId = route.params.id

const form = ref({
  title: '',
  description: '',
  category: '',
  price_per_day: '',
  security_deposit: '',
  min_rental_days: 1,
  location: '',
  available_now: true,
  delivery_method: 'pickup_only',
  delivery_fee: 0,
  delivery_radius: 10,
  pickup_instructions: '',
  additional_notes: '',
  status: 'active',
  rental_status: 'available',
  rental_start_date: '',
  rented_until: '',
  rental_notes: ''
})

// Separate ref for uploaded images to prevent recursive updates
const uploadedImages = ref([])
const existingImages = ref([])

const initialLoading = ref(true)
const loading = ref(false)
const error = ref('')
const success = ref('')
const notFound = ref(false)

// Fetch existing listing data
const fetchListing = async () => {
  try {
    initialLoading.value = true
    error.value = ''

    // Fetch listing with images
    const { data: listing, error: listingError } = await supabase
      .from('listings')
      .select(`
        *,
        listing_images (
          id,
          image_url,
          is_primary
        )
      `)
      .eq('id', listingId)
      .eq('owner_id', user.value.id) // Ensure user owns this listing
      .single()

    if (listingError) {
      if (listingError.code === 'PGRST116') {
        notFound.value = true
        return
      }
      throw listingError
    }

    // Populate form with existing data
    form.value = {
      title: listing.title,
      description: listing.description,
      category: listing.category,
      price_per_day: listing.price_per_day,
      security_deposit: listing.security_deposit || '',
      min_rental_days: listing.min_rental_days,
      location: listing.location,
      available_now: listing.available_now,
      delivery_method: listing.delivery_method || 'pickup_only',
      delivery_fee: listing.delivery_fee || 0,
      delivery_radius: listing.delivery_radius || 10,
      pickup_instructions: listing.pickup_instructions || '',
      additional_notes: listing.additional_notes || '',
      status: listing.status,
      rental_status: listing.rental_status || 'available',
      rental_start_date: listing.rental_start_date || '',
      rented_until: listing.rented_until || '',
      rental_notes: listing.rental_notes || ''
    }

    // Set existing images for ImageUpload component
    if (listing.listing_images && listing.listing_images.length > 0) {
      existingImages.value = listing.listing_images.map(img => ({
        id: img.id,
        url: img.image_url,
        is_primary: img.is_primary
      }))
    }

  } catch (err) {
    console.error('Error fetching listing:', err)
    error.value = 'Failed to load listing data. Please try again.'
  } finally {
    initialLoading.value = false
  }
}

const updateListing = async () => {
  try {
    loading.value = true
    error.value = ''
    success.value = ''

    // Validate required fields
    if (!form.value.title || !form.value.description || !form.value.category || !form.value.price_per_day || !form.value.location) {
      throw new Error('Please fill in all required fields')
    }

    // Validate price is a positive number
    if (parseFloat(form.value.price_per_day) <= 0) {
      throw new Error('Price per day must be greater than 0')
    }

    // Update listing in Supabase
    const { error: updateError } = await supabase
      .from('listings')
      .update({
        title: form.value.title,
        description: form.value.description,
        category: form.value.category,
        price_per_day: parseFloat(form.value.price_per_day),
        security_deposit: form.value.security_deposit ? parseFloat(form.value.security_deposit) : 0,
        min_rental_days: parseInt(form.value.min_rental_days) || 1,
        location: form.value.location,
        available_now: form.value.available_now,
        delivery_method: form.value.delivery_method,
        delivery_fee: (form.value.delivery_method === 'delivery_only' || form.value.delivery_method === 'both') ? parseFloat(form.value.delivery_fee) || 0 : 0,
        delivery_radius: (form.value.delivery_method === 'delivery_only' || form.value.delivery_method === 'both') ? parseInt(form.value.delivery_radius) || 10 : 0,
        pickup_instructions: (form.value.delivery_method === 'pickup_only' || form.value.delivery_method === 'both') ? form.value.pickup_instructions || null : null,
        additional_notes: form.value.additional_notes || null,
        status: form.value.status,
        rental_status: form.value.rental_status,
        rental_start_date: form.value.rental_start_date || null,
        rented_until: form.value.rented_until || null,
        rental_notes: form.value.rental_notes || null,
        updated_at: new Date().toISOString()
      })
      .eq('id', listingId)
      .eq('owner_id', user.value.id) // Ensure user owns this listing

    if (updateError) {
      throw updateError
    }

    // Handle image updates if any new images were uploaded
    if (uploadedImages.value && uploadedImages.value.length > 0) {
      const imagePromises = uploadedImages.value.map((imageObj, index) => {
        return supabase
          .from('listing_images')
          .insert({
            listing_id: listingId,
            image_url: imageObj.url,
            is_primary: existingImages.value.length === 0 && index === 0 // First new image is primary if no existing images
          })
      })
      
      const imageResults = await Promise.all(imagePromises)
      
      // Check for any image insertion errors
      for (const result of imageResults) {
        if (result.error) {
          console.error('Error saving image:', result.error)
        }
      }
    }

    success.value = 'Listing updated successfully!'
    
    // Redirect after success
    setTimeout(() => {
      navigateTo('/profile')
    }, 2000)

  } catch (err) {
    error.value = err.message || 'Failed to update listing. Please try again.'
  } finally {
    loading.value = false
  }
}

// Load listing data on mount
onMounted(() => {
  fetchListing()
})

useHead({
  title: 'Edit Listing - Dare2Share'
})
</script>
