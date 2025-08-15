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
  existingImages: {
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

// Combine existing images with newly uploaded images
const allImages = computed(() => {
  return [...(props.existingImages || []), ...(props.modelValue || [])]
})

// Use computed property to avoid reactive loops
const images = computed({
  get: () => allImages.value,
  set: (newValue) => {
    // Only emit the newly uploaded images (not existing ones)
    const newlyUploaded = newValue.filter(img => !props.existingImages.some(existing => existing.url === img.url))
    emit('update:modelValue', newlyUploaded)
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
  if (allImages.value.length + files.length > props.maxImages) {
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

    // Add to newly uploaded images array
    const currentUploaded = props.modelValue || []
    emit('update:modelValue', [...currentUploaded, ...uploadedImages])

  } catch (err) {
    error.value = err.message || 'Failed to upload images'
  } finally {
    uploading.value = false
    uploadProgress.value = 0
  }
}

const removeImage = async (index) => {
  const image = allImages.value[index]
  const existingCount = props.existingImages.length
  
  try {
    if (index < existingCount) {
      // Removing an existing image - delete from database and storage
      if (image.id) {
        const { error: dbError } = await supabase
          .from('listing_images')
          .delete()
          .eq('id', image.id)
        
        if (dbError) {
          console.error('Error deleting image from database:', dbError)
        }
      }
      
      // Extract path from URL for storage deletion
      if (image.url) {
        const urlParts = image.url.split('/')
        const path = urlParts.slice(-2).join('/') // Get last two parts (user_id/filename)
        
        const { error: deleteError } = await supabase.storage
          .from('listing-images')
          .remove([path])

        if (deleteError) {
          console.error('Error deleting image from storage:', deleteError)
        }
      }
      
      // Remove from existing images (this will trigger a re-render)
      const updatedExisting = [...props.existingImages]
      updatedExisting.splice(index, 1)
      // Note: We can't directly modify props, so the parent component should handle this
      // For now, we'll just refresh the page or emit an event
      window.location.reload()
    } else {
      // Removing a newly uploaded image
      const newlyUploadedIndex = index - existingCount
      
      // Delete from Supabase Storage
      const { error: deleteError } = await supabase.storage
        .from('listing-images')
        .remove([image.path])

      if (deleteError) {
        console.error('Error deleting image from storage:', deleteError)
      }

      // Remove from newly uploaded array
      const currentUploaded = [...(props.modelValue || [])]
      currentUploaded.splice(newlyUploadedIndex, 1)
      emit('update:modelValue', currentUploaded)
    }
  } catch (err) {
    console.error('Error removing image:', err)
  }
}

const setPrimaryImage = async (index) => {
  const image = allImages.value[index]
  const existingCount = props.existingImages.length
  
  try {
    if (index < existingCount) {
      // Setting an existing image as primary
      if (image.id) {
        // First, remove primary flag from all existing images
        await supabase
          .from('listing_images')
          .update({ is_primary: false })
          .in('id', props.existingImages.map(img => img.id))
        
        // Set the selected image as primary
        await supabase
          .from('listing_images')
          .update({ is_primary: true })
          .eq('id', image.id)
        
        // Refresh the page to show updated primary status
        window.location.reload()
      }
    } else {
      // Setting a newly uploaded image as primary
      const newlyUploadedIndex = index - existingCount
      const currentUploaded = [...(props.modelValue || [])]
      const [selectedImage] = currentUploaded.splice(newlyUploadedIndex, 1)
      currentUploaded.unshift(selectedImage)
      emit('update:modelValue', currentUploaded)
    }
  } catch (err) {
    console.error('Error setting primary image:', err)
  }
}
</script>
