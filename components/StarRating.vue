<template>
  <div class="flex items-center">
    <button
      v-for="star in 5"
      :key="star"
      type="button"
      :disabled="readonly"
      @click="setRating(star)"
      @mouseover="!readonly && setHover(star)"
      @mouseleave="!readonly && setHover(0)"
      :class="[
        'focus:outline-none transition-colors',
        readonly ? 'cursor-default' : 'cursor-pointer hover:scale-110 transition-transform',
        getSizeClass()
      ]"
    >
      <svg
        :class="[
          'fill-current transition-colors',
          getStarColor(star)
        ]"
        viewBox="0 0 20 20"
      >
        <path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z" />
      </svg>
    </button>
    
    <!-- Rating text (optional) -->
    <span v-if="showText" :class="['ml-2 font-medium', getTextSizeClass()]">
      {{ displayRating }}/5
    </span>
  </div>
</template>

<script setup>
const props = defineProps({
  modelValue: {
    type: Number,
    default: 0
  },
  rating: {
    type: Number,
    default: 0
  },
  readonly: {
    type: Boolean,
    default: false
  },
  size: {
    type: String,
    default: 'md', // xs, sm, md, lg
    validator: (value) => ['xs', 'sm', 'md', 'lg'].includes(value)
  },
  showText: {
    type: Boolean,
    default: false
  }
})

const emit = defineEmits(['update:modelValue'])

const hoverRating = ref(0)

// Use rating prop for readonly mode, modelValue for interactive mode
const displayRating = computed(() => {
  if (props.readonly) {
    return props.rating
  }
  return hoverRating.value || props.modelValue
})

const setRating = (rating) => {
  if (!props.readonly) {
    emit('update:modelValue', rating)
  }
}

const setHover = (rating) => {
  if (!props.readonly) {
    hoverRating.value = rating
  }
}

const getStarColor = (star) => {
  const currentRating = displayRating.value
  if (star <= currentRating) {
    return 'text-yellow-400'
  }
  return 'text-gray-300'
}

const getSizeClass = () => {
  const sizes = {
    xs: 'w-3 h-3',
    sm: 'w-4 h-4',
    md: 'w-5 h-5',
    lg: 'w-6 h-6'
  }
  return sizes[props.size] || sizes.md
}

const getTextSizeClass = () => {
  const sizes = {
    xs: 'text-xs',
    sm: 'text-sm',
    md: 'text-base',
    lg: 'text-lg'
  }
  return sizes[props.size] || sizes.md
}
</script>
