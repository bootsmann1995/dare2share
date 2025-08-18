-- Admin functions for user management
-- These functions can only be called by super_user role

-- Function to search users by email or name
CREATE OR REPLACE FUNCTION search_users(
  search_term TEXT DEFAULT '',
  limit_count INTEGER DEFAULT 20,
  offset_count INTEGER DEFAULT 0
)
RETURNS TABLE (
  id UUID,
  email TEXT,
  full_name TEXT,
  user_role TEXT,
  subscription_status TEXT,
  listing_count INTEGER,
  created_at TIMESTAMPTZ
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  -- Check if the calling user is a super_user
  IF NOT EXISTS (
    SELECT 1 FROM profiles 
    WHERE profiles.id = auth.uid() 
    AND profiles.user_role = 'super_user'
  ) THEN
    RAISE EXCEPTION 'Access denied. Admin privileges required.';
  END IF;

  RETURN QUERY
  SELECT 
    p.id,
    u.email::TEXT,
    p.full_name,
    p.user_role,
    p.subscription_status,
    p.listing_count,
    p.created_at
  FROM profiles p
  JOIN auth.users u ON p.id = u.id
  WHERE 
    (search_term = '' OR 
     u.email ILIKE '%' || search_term || '%' OR 
     p.full_name ILIKE '%' || search_term || '%')
  ORDER BY p.created_at DESC
  LIMIT limit_count
  OFFSET offset_count;
END;
$$;

-- Function to get detailed user information for admin
CREATE OR REPLACE FUNCTION get_user_admin_details(user_id UUID)
RETURNS TABLE (
  id UUID,
  email TEXT,
  full_name TEXT,
  phone TEXT,
  user_role TEXT,
  subscription_status TEXT,
  subscription_start_date TIMESTAMPTZ,
  subscription_end_date TIMESTAMPTZ,
  stripe_customer_id TEXT,
  stripe_subscription_id TEXT,
  listing_count INTEGER,
  created_at TIMESTAMPTZ,
  updated_at TIMESTAMPTZ
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  -- Check if the calling user is a super_user
  IF NOT EXISTS (
    SELECT 1 FROM profiles 
    WHERE profiles.id = auth.uid() 
    AND profiles.user_role = 'super_user'
  ) THEN
    RAISE EXCEPTION 'Access denied. Admin privileges required.';
  END IF;

  RETURN QUERY
  SELECT 
    p.id,
    u.email::TEXT,
    p.full_name,
    p.phone,
    p.user_role,
    p.subscription_status,
    p.subscription_start_date,
    p.subscription_end_date,
    p.stripe_customer_id,
    p.stripe_subscription_id,
    p.listing_count,
    p.created_at,
    p.updated_at
  FROM profiles p
  JOIN auth.users u ON p.id = u.id
  WHERE p.id = user_id;
END;
$$;

-- Function to update user subscription (admin only)
CREATE OR REPLACE FUNCTION admin_update_user_subscription(
  user_id UUID,
  new_role TEXT,
  new_status TEXT,
  new_start_date TIMESTAMPTZ DEFAULT NULL,
  new_end_date TIMESTAMPTZ DEFAULT NULL
)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  -- Check if the calling user is a super_user
  IF NOT EXISTS (
    SELECT 1 FROM profiles 
    WHERE profiles.id = auth.uid() 
    AND profiles.user_role = 'super_user'
  ) THEN
    RAISE EXCEPTION 'Access denied. Admin privileges required.';
  END IF;

  -- Validate role
  IF new_role NOT IN ('free_user', 'paid_user', 'super_user') THEN
    RAISE EXCEPTION 'Invalid user role. Must be free_user, paid_user, or super_user.';
  END IF;

  -- Validate status
  IF new_status NOT IN ('active', 'inactive', 'trial', 'expired') THEN
    RAISE EXCEPTION 'Invalid subscription status. Must be active, inactive, trial, or expired.';
  END IF;

  -- Update the user profile
  UPDATE profiles 
  SET 
    user_role = new_role,
    subscription_status = new_status,
    subscription_start_date = COALESCE(new_start_date, subscription_start_date),
    subscription_end_date = COALESCE(new_end_date, subscription_end_date),
    updated_at = NOW()
  WHERE id = user_id;

  -- Check if update was successful
  IF NOT FOUND THEN
    RAISE EXCEPTION 'User not found with ID: %', user_id;
  END IF;

  RETURN TRUE;
END;
$$;

-- Function to get admin dashboard stats
CREATE OR REPLACE FUNCTION get_admin_dashboard_stats()
RETURNS TABLE (
  total_users INTEGER,
  free_users INTEGER,
  paid_users INTEGER,
  super_users INTEGER,
  active_subscriptions INTEGER,
  total_listings INTEGER
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  -- Check if the calling user is a super_user
  IF NOT EXISTS (
    SELECT 1 FROM profiles 
    WHERE profiles.id = auth.uid() 
    AND profiles.user_role = 'super_user'
  ) THEN
    RAISE EXCEPTION 'Access denied. Admin privileges required.';
  END IF;

  RETURN QUERY
  SELECT 
    COUNT(*)::INTEGER as total_users,
    COUNT(CASE WHEN user_role = 'free_user' THEN 1 END)::INTEGER as free_users,
    COUNT(CASE WHEN user_role = 'paid_user' THEN 1 END)::INTEGER as paid_users,
    COUNT(CASE WHEN user_role = 'super_user' THEN 1 END)::INTEGER as super_users,
    COUNT(CASE WHEN subscription_status = 'active' THEN 1 END)::INTEGER as active_subscriptions,
    COALESCE(SUM(listing_count), 0)::INTEGER as total_listings
  FROM profiles;
END;
$$;
