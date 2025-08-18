// TypeScript types for subscription system
export type UserRole = 'super_user' | 'paid_user' | 'free_user'

export type SubscriptionStatus = 'active' | 'inactive' | 'trial' | 'expired'

export interface UserSubscriptionInfo {
  id: string
  user_role: UserRole
  subscription_status: SubscriptionStatus
  subscription_start_date?: string
  subscription_end_date?: string
  listing_count: number
  listing_limit: number
  can_create_more_listings: boolean
  listing_usage_display: string
}

export interface SubscriptionStatusDisplay {
  text: string
  class: string
}

export interface RoleBenefit {
  text: string
  included: boolean
}

export interface AdminUserInfo {
  id: string
  email: string
  full_name?: string
  phone?: string
  user_role: UserRole
  subscription_status: SubscriptionStatus
  subscription_start_date?: string
  subscription_end_date?: string
  listing_count: number
  created_at: string
  updated_at: string
}

export interface UserSearchResult {
  id: string
  email: string
  full_name?: string
  user_role: UserRole
  subscription_status: SubscriptionStatus
  listing_count: number
  created_at: string
}
