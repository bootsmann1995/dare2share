<template>
  <div class="bg-white rounded-lg border border-gray-200 p-4">
    <div class="flex items-center justify-between mb-4">
      <h3 class="text-lg font-semibold text-gray-900">User Rating</h3>
      <div v-if="userStats" class="flex items-center">
        <div class="flex items-center mr-2">
          <StarRating :rating="userStats.average_rating" :readonly="true" :size="'sm'" />
        </div>
        <span class="text-sm text-gray-600">
          {{ userStats.average_rating.toFixed(1) }} ({{ userStats.total_ratings }} {{ userStats.total_ratings === 1 ? 'rating' : 'ratings' }})
        </span>
      </div>
    </div>

    <!-- Rating Form (only for authenticated users who haven't rated this user) -->
    <div v-if="canRate && !hasRated" class="mb-6">
      <h4 class="text-md font-medium text-gray-700 mb-3">Rate this user</h4>
      <form @submit.prevent="submitRating" class="space-y-4">
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-2">Rating *</label>
          <StarRating v-model="newRating.rating" :readonly="false" />
        </div>
        
        <div>
          <label for="comment" class="block text-sm font-medium text-gray-700 mb-2">Comment (optional)</label>
          <textarea
            id="comment"
            v-model="newRating.comment"
            rows="3"
            class="input-field"
            placeholder="Share your experience with this user..."
          ></textarea>
        </div>

        <div v-if="error" class="text-red-600 text-sm">
          {{ error }}
        </div>

        <div v-if="success" class="text-green-600 text-sm">
          {{ success }}
        </div>

        <div class="flex gap-3">
          <button
            type="submit"
            :disabled="!newRating.rating || submitting"
            class="btn-primary"
          >
            <span v-if="submitting">Submitting...</span>
            <span v-else>Submit Rating</span>
          </button>
          <button
            type="button"
            @click="cancelRating"
            class="btn-secondary"
          >
            Cancel
          </button>
        </div>
      </form>
    </div>

    <!-- User's existing rating (if they've already rated) -->
    <div v-else-if="canRate && hasRated && userRating" class="mb-6 bg-blue-50 border border-blue-200 rounded-lg p-4">
      <div class="flex items-center justify-between mb-2">
        <h4 class="text-md font-medium text-blue-900">Your Rating</h4>
        <button
          @click="editMode = !editMode"
          class="text-blue-600 hover:text-blue-800 text-sm"
        >
          {{ editMode ? 'Cancel' : 'Edit' }}
        </button>
      </div>
      
      <div v-if="!editMode">
        <div class="flex items-center mb-2">
          <StarRating :rating="userRating.rating" :readonly="true" :size="'sm'" />
          <span class="ml-2 text-sm text-blue-700">{{ userRating.rating }}/5</span>
        </div>
        <p v-if="userRating.comment" class="text-sm text-blue-800">{{ userRating.comment }}</p>
        <p class="text-xs text-blue-600 mt-2">Rated on {{ formatDate(userRating.created_at) }}</p>
      </div>

      <!-- Edit form -->
      <form v-else @submit.prevent="updateRating" class="space-y-3">
        <div>
          <StarRating v-model="editRating.rating" :readonly="false" />
        </div>
        <div>
          <textarea
            v-model="editRating.comment"
            rows="3"
            class="input-field text-sm"
            placeholder="Update your comment..."
          ></textarea>
        </div>
        <div class="flex gap-2">
          <button
            type="submit"
            :disabled="submitting"
            class="btn-primary text-sm"
          >
            Update
          </button>
          <button
            type="button"
            @click="deleteRating"
            :disabled="submitting"
            class="btn-danger text-sm"
          >
            Delete
          </button>
        </div>
      </form>
    </div>

    <!-- Recent ratings from other users -->
    <div v-if="recentRatings && recentRatings.length > 0">
      <h4 class="text-md font-medium text-gray-700 mb-3">Recent Reviews</h4>
      <div class="space-y-3 max-h-60 overflow-y-auto">
        <div
          v-for="rating in recentRatings"
          :key="rating.id"
          class="border-b border-gray-100 pb-3 last:border-b-0"
        >
          <div class="flex items-center justify-between mb-1">
            <div class="flex items-center">
              <StarRating :rating="rating.rating" :readonly="true" :size="'xs'" />
              <span class="ml-2 text-sm font-medium text-gray-700">{{ rating.rater_name || 'Anonymous' }}</span>
            </div>
            <span class="text-xs text-gray-500">{{ formatDate(rating.created_at) }}</span>
          </div>
          <p v-if="rating.comment" class="text-sm text-gray-600">{{ rating.comment }}</p>
        </div>
      </div>
    </div>

    <!-- No ratings message -->
    <div v-else-if="userStats && userStats.total_ratings === 0" class="text-center py-4">
      <p class="text-gray-500">No ratings yet</p>
    </div>
  </div>
</template>

<script setup>
const props = defineProps({
  userId: {
    type: String,
    required: true
  }
})

const supabase = useSupabaseClient()
const user = useSupabaseUser()

const userStats = ref(null)
const recentRatings = ref([])
const userRating = ref(null)
const hasRated = ref(false)
const editMode = ref(false)

const newRating = ref({
  rating: 0,
  comment: ''
})

const editRating = ref({
  rating: 0,
  comment: ''
})

const submitting = ref(false)
const error = ref('')
const success = ref('')

// Check if current user can rate this user
const canRate = computed(() => {
  return user.value && user.value.id !== props.userId
})

// Fetch user rating statistics
const fetchUserStats = async () => {
  try {
    const { data, error: statsError } = await supabase
      .from('user_rating_stats')
      .select('*')
      .eq('rated_user_id', props.userId)
      .single()

    if (statsError && statsError.code !== 'PGRST116') {
      throw statsError
    }

    userStats.value = data || { total_ratings: 0, average_rating: 0 }
  } catch (err) {
    console.error('Error fetching user stats:', err)
  }
}

// Fetch recent ratings for this user
const fetchRecentRatings = async () => {
  try {
    const { data, error: ratingsError } = await supabase
      .from('user_ratings_with_rater')
      .select('*')
      .eq('rated_user_id', props.userId)
      .order('created_at', { ascending: false })
      .limit(5)

    if (ratingsError) {
      throw ratingsError
    }

    recentRatings.value = data || []
  } catch (err) {
    console.error('Error fetching recent ratings:', err)
  }
}

// Check if current user has already rated this user
const checkUserRating = async () => {
  if (!user.value) return

  try {
    const { data, error: ratingError } = await supabase
      .from('user_ratings')
      .select('*')
      .eq('rater_id', user.value.id)
      .eq('rated_user_id', props.userId)
      .single()

    if (ratingError && ratingError.code !== 'PGRST116') {
      throw ratingError
    }

    if (data) {
      userRating.value = data
      hasRated.value = true
      editRating.value = {
        rating: data.rating,
        comment: data.comment || ''
      }
    }
  } catch (err) {
    console.error('Error checking user rating:', err)
  }
}

// Submit new rating
const submitRating = async () => {
  if (!user.value || !newRating.value.rating) return

  try {
    submitting.value = true
    error.value = ''
    success.value = ''

    const { data, error: insertError } = await supabase
      .from('user_ratings')
      .insert({
        rater_id: user.value.id,
        rated_user_id: props.userId,
        rating: newRating.value.rating,
        comment: newRating.value.comment || null
      })
      .select()
      .single()

    if (insertError) {
      throw insertError
    }

    userRating.value = data
    hasRated.value = true
    success.value = 'Rating submitted successfully!'
    
    // Reset form
    newRating.value = { rating: 0, comment: '' }
    
    // Refresh data
    await Promise.all([fetchUserStats(), fetchRecentRatings()])

  } catch (err) {
    error.value = err.message || 'Failed to submit rating'
  } finally {
    submitting.value = false
  }
}

// Update existing rating
const updateRating = async () => {
  if (!userRating.value) return

  try {
    submitting.value = true
    error.value = ''

    const { data, error: updateError } = await supabase
      .from('user_ratings')
      .update({
        rating: editRating.value.rating,
        comment: editRating.value.comment || null
      })
      .eq('id', userRating.value.id)
      .select()
      .single()

    if (updateError) {
      throw updateError
    }

    userRating.value = data
    editMode.value = false
    success.value = 'Rating updated successfully!'
    
    // Refresh data
    await Promise.all([fetchUserStats(), fetchRecentRatings()])

  } catch (err) {
    error.value = err.message || 'Failed to update rating'
  } finally {
    submitting.value = false
  }
}

// Delete rating
const deleteRating = async () => {
  if (!userRating.value || !confirm('Are you sure you want to delete your rating?')) return

  try {
    submitting.value = true
    error.value = ''

    const { error: deleteError } = await supabase
      .from('user_ratings')
      .delete()
      .eq('id', userRating.value.id)

    if (deleteError) {
      throw deleteError
    }

    userRating.value = null
    hasRated.value = false
    editMode.value = false
    success.value = 'Rating deleted successfully!'
    
    // Refresh data
    await Promise.all([fetchUserStats(), fetchRecentRatings()])

  } catch (err) {
    error.value = err.message || 'Failed to delete rating'
  } finally {
    submitting.value = false
  }
}

const cancelRating = () => {
  newRating.value = { rating: 0, comment: '' }
  error.value = ''
  success.value = ''
}

const formatDate = (dateString) => {
  return new Date(dateString).toLocaleDateString('en-US', {
    year: 'numeric',
    month: 'short',
    day: 'numeric'
  })
}

// Load data on mount
onMounted(async () => {
  await Promise.all([
    fetchUserStats(),
    fetchRecentRatings(),
    checkUserRating()
  ])
})

// Watch for user changes
watch(user, () => {
  if (user.value) {
    checkUserRating()
  }
})
</script>
