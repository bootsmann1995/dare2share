<template>
  <div class="max-w-2xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
    <div class="mb-8">
      <h1 class="text-3xl font-bold text-gray-900 mb-2">List Your Item</h1>
      <p class="text-gray-600">Share what you have and start earning money</p>
    </div>

    <form @submit.prevent="createListing" class="space-y-6">
      <!-- Item Photos -->
      <div>
        <ImageUpload v-model="uploadedImages" :max-images="5" />
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
            <input type="checkbox" v-model="form.available_now" class="rounded border-gray-300 text-blue-600 focus:ring-blue-500" />
            <span class="ml-2 text-sm text-gray-700">Available immediately</span>
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
          class="flex-1 btn-primary disabled:opacity-50"
        >
          <span v-if="loading">Creating Listing...</span>
          <span v-else>Create Listing</span>
        </button>
        
        <button
          type="button"
          @click="saveDraft"
          class="btn-secondary"
        >
          Save Draft
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

const supabase = useSupabaseClient()
const user = useSupabaseUser()

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
  additional_notes: ''
})

// Separate ref for uploaded images to prevent recursive updates
const uploadedImages = ref([])

const loading = ref(false)
const error = ref('')
const success = ref('')

const createListing = async () => {
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

    // Create listing in Supabase
    const { data, error: insertError } = await supabase
      .from('listings')
      .insert({
        owner_id: user.value.id,
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
        status: 'active'
      })
      .select()
      .single()

    if (insertError) {
      throw insertError
    }

    const listingId = data.id

    // Save image URLs to database if any images were uploaded
    if (uploadedImages.value && uploadedImages.value.length > 0) {
      const imagePromises = uploadedImages.value.map((imageObj, index) => {
        return supabase
          .from('listing_images')
          .insert({
            listing_id: listingId,
            image_url: imageObj.url, // Extract URL from image object
            is_primary: index === 0 // First image is primary
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

    success.value = 'Listing created successfully! Your item is now available for rent.'
    
    // Reset form
    form.value = {
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
      additional_notes: ''
    }
    
    // Reset uploaded images
    uploadedImages.value = []

    // Redirect after success
    setTimeout(() => {
      navigateTo('/profile')
    }, 2000)

  } catch (err) {
    error.value = err.message || 'Failed to create listing. Please try again.'
  } finally {
    loading.value = false
  }
}

const saveDraft = () => {
  // Save to localStorage as draft
  localStorage.setItem('listing_draft', JSON.stringify(form.value))
  success.value = 'Draft saved successfully!'
  setTimeout(() => {
    success.value = ''
  }, 3000)
}

// Load draft on mount
onMounted(() => {
  const draft = localStorage.getItem('listing_draft')
  if (draft) {
    form.value = JSON.parse(draft)
  }
})

useHead({
  title: 'Create Listing - Dare2Share'
})
</script>
