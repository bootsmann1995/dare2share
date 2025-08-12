<template>
  <div>
    <label class="block text-sm font-medium text-gray-700 mb-2">Photos</label>
    
    <!-- Upload Area -->
    <div 
      @click="triggerFileInput"
      @dragover.prevent="isDragging = true"
      @dragleave.prevent="isDragging = false"
      @drop.prevent="handleDrop"
      :class="[
        'border-2 border-dashed rounded-lg p-6 text-center cursor-pointer transition-colors',
        isDragging ? 'border-blue-400 bg-blue-50' : 'border-gray-300 hover:border-gray-400'
      ]"
    >
      <svg class="w-12 h-12 text-gray-400 mx-auto mb-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6"></path>
      </svg>
      <p class="text-gray-600 mb-2">Click to upload photos or drag and drop</p>
      <p class="text-sm text-gray-500">PNG, JPG up to 5MB each (max 5 images)</p>
      
      <input 
        ref="fileInput"
        type="file" 
        multiple 
        accept="image/*" 
        class="hidden" 
        @change="handleFileSelect"
      />
    </div>

    <!-- Upload Progress -->
    <div v-if="uploading" class="mt-4">
      <div class="bg-blue-50 border border-blue-200 rounded-lg p-3">
        <div class="flex items-center">
          <div class="animate-spin rounded-full h-4 w-4 border-b-2 border-blue-600 mr-2"></div>
          <span class="text-sm text-blue-700">Uploading images... {{ uploadProgress }}%</span>
        </div>
        <div class="w-full bg-blue-200 rounded-full h-2 mt-2">
          <div class="bg-blue-600 h-2 rounded-full transition-all duration-300" :style="`width: ${uploadProgress}%`"></div>
        </div>
      </div>
    </div>

    <!-- Error Message -->
    <div v-if="error" class="mt-4 text-red-600 text-sm">
      {{ error }}
    </div>

    <!-- Preview Images -->
    <div v-if="images.length > 0" class="mt-4">
      <h4 class="text-sm font-medium text-gray-700 mb-2">Uploaded Images ({{ images.length }}/5)</h4>
      <div class="grid grid-cols-2 md:grid-cols-3 gap-4">
        <div 
          v-for="(image, index) in images" 
          :key="index"
          class="relative group"
        >
          <img 
            :src="image.url" 
            :alt="`Upload ${index + 1}`"
            class="w-full h-32 object-cover rounded-lg border border-gray-200"
          />
          
          <!-- Primary Image Badge -->
          <div 
            v-if="index === 0"
            class="absolute top-2 left-2 bg-blue-600 text-white text-xs px-2 py-1 rounded"
          >
            Primary
          </div>
          
          <!-- Delete Button -->
          <button
            @click="removeImage(index)"
            class="absolute top-2 right-2 bg-red-600 text-white rounded-full w-6 h-6 flex items-center justify-center opacity-0 group-hover:opacity-100 transition-opacity"
          >
            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>
            </svg>
          </button>
          
          <!-- Set as Primary Button -->
          <button
            v-if="index !== 0"
            @click="setPrimaryImage(index)"
            class="absolute bottom-2 left-2 bg-gray-800 bg-opacity-75 text-white text-xs px-2 py-1 rounded opacity-0 group-hover:opacity-100 transition-opacity"
          >
            Set as Primary
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
const props = defineProps({
  modelValue: {
    type: Array,
    default: () => []
  },
  maxImages: {
    type: Number,
    default: 5
  },
  maxFileSize: {
    type: Number,
    default: 5 * 1024 * 1024 // 5MB
  }
})

const emit = defineEmits(['update:modelValue'])

const supabase = useSupabaseClient()
const user = useSupabaseUser()

const fileInput = ref(null)
const uploading = ref(false)
const uploadProgress = ref(0)
const error = ref('')
const isDragging = ref(false)

// Use computed property to avoid reactive loops
const images = computed({
  get: () => props.modelValue || [],
  set: (newValue) => {
    emit('update:modelValue', newValue)
  }
})

const triggerFileInput = () => {
  fileInput.value?.click()
}

const handleFileSelect = (event) => {
  const files = Array.from(event.target.files)
  uploadFiles(files)
}

const handleDrop = (event) => {
  isDragging.value = false
  const files = Array.from(event.dataTransfer.files).filter(file => file.type.startsWith('image/'))
  uploadFiles(files)
}

const uploadFiles = async (files) => {
  if (!user.value) {
    error.value = 'You must be logged in to upload images'
    return
  }

  // Check if adding these files would exceed the limit
  if (images.value.length + files.length > props.maxImages) {
    error.value = `You can only upload up to ${props.maxImages} images`
    return
  }

  // Validate file sizes
  const oversizedFiles = files.filter(file => file.size > props.maxFileSize)
  if (oversizedFiles.length > 0) {
    error.value = `Some files are too large. Maximum size is ${Math.round(props.maxFileSize / 1024 / 1024)}MB`
    return
  }

  uploading.value = true
  uploadProgress.value = 0
  error.value = ''

  try {
    const uploadPromises = files.map(async (file, index) => {
      const fileExt = file.name.split('.').pop()
      const fileName = `${user.value.id}/${Date.now()}-${index}.${fileExt}`
      
      const { data, error: uploadError } = await supabase.storage
        .from('listing-images')
        .upload(fileName, file)

      if (uploadError) throw uploadError

      // Get public URL
      const { data: urlData } = supabase.storage
        .from('listing-images')
        .getPublicUrl(fileName)

      return {
        path: fileName,
        url: urlData.publicUrl,
        name: file.name
      }
    })

    // Upload files with progress tracking
    const uploadedImages = []
    for (let i = 0; i < uploadPromises.length; i++) {
      const result = await uploadPromises[i]
      uploadedImages.push(result)
      uploadProgress.value = Math.round(((i + 1) / uploadPromises.length) * 100)
    }

    // Add to images array
    images.value.push(...uploadedImages)

  } catch (err) {
    error.value = err.message || 'Failed to upload images'
  } finally {
    uploading.value = false
    uploadProgress.value = 0
  }
}

const removeImage = async (index) => {
  const image = images.value[index]
  
  try {
    // Delete from Supabase Storage
    const { error: deleteError } = await supabase.storage
      .from('listing-images')
      .remove([image.path])

    if (deleteError) {
      console.error('Error deleting image from storage:', deleteError)
    }

    // Remove from local array
    images.value.splice(index, 1)
  } catch (err) {
    console.error('Error removing image:', err)
    // Still remove from local array even if storage deletion fails
    images.value.splice(index, 1)
  }
}

const setPrimaryImage = (index) => {
  // Move the selected image to the first position
  const [selectedImage] = images.value.splice(index, 1)
  images.value.unshift(selectedImage)
}
</script>
