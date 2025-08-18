-- User Subscription and Roles System
-- This adds role-based access control with listing limits

-- Add user role and subscription fields to profiles table
ALTER TABLE profiles 
ADD COLUMN IF NOT EXISTS user_role TEXT CHECK (user_role IN ('super_user', 'paid_user', 'free_user')) DEFAULT 'free_user',
ADD COLUMN IF NOT EXISTS subscription_status TEXT CHECK (subscription_status IN ('active', 'inactive', 'trial', 'expired')) DEFAULT 'inactive',
ADD COLUMN IF NOT EXISTS subscription_start_date TIMESTAMP WITH TIME ZONE,
ADD COLUMN IF NOT EXISTS subscription_end_date TIMESTAMP WITH TIME ZONE,
ADD COLUMN IF NOT EXISTS stripe_customer_id TEXT,
ADD COLUMN IF NOT EXISTS stripe_subscription_id TEXT,
ADD COLUMN IF NOT EXISTS listing_count INTEGER DEFAULT 0;

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_profiles_user_role ON profiles(user_role);
CREATE INDEX IF NOT EXISTS idx_profiles_subscription_status ON profiles(subscription_status);
CREATE INDEX IF NOT EXISTS idx_profiles_stripe_customer_id ON profiles(stripe_customer_id);

-- Create a function to get user listing limits based on role
CREATE OR REPLACE FUNCTION get_user_listing_limit(user_role TEXT)
RETURNS INTEGER AS $$
BEGIN
  CASE user_role
    WHEN 'super_user' THEN RETURN -1; -- Unlimited
    WHEN 'paid_user' THEN RETURN -1;  -- Unlimited
    WHEN 'free_user' THEN RETURN 2;   -- 2 free listings
    ELSE RETURN 0; -- No listings for unknown roles
  END CASE;
END;
$$ LANGUAGE plpgsql;

-- Create a function to check if user can create more listings
CREATE OR REPLACE FUNCTION can_create_listing(user_id UUID)
RETURNS BOOLEAN AS $$
DECLARE
  user_profile profiles%ROWTYPE;
  current_listing_count INTEGER;
  listing_limit INTEGER;
BEGIN
  -- Get user profile
  SELECT * INTO user_profile FROM profiles WHERE id = user_id;
  
  IF NOT FOUND THEN
    RETURN FALSE;
  END IF;
  
  -- Get current active listing count
  SELECT COUNT(*) INTO current_listing_count 
  FROM listings 
  WHERE owner_id = user_id AND status != 'deleted';
  
  -- Get listing limit for user role
  listing_limit := get_user_listing_limit(user_profile.user_role);
  
  -- If limit is -1, unlimited listings
  IF listing_limit = -1 THEN
    RETURN TRUE;
  END IF;
  
  -- Check if user is within limit
  RETURN current_listing_count < listing_limit;
END;
$$ LANGUAGE plpgsql;

-- Create a function to update listing count when listings are created/deleted
CREATE OR REPLACE FUNCTION update_user_listing_count()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    -- Increment listing count
    UPDATE profiles 
    SET listing_count = listing_count + 1 
    WHERE id = NEW.owner_id;
    RETURN NEW;
  ELSIF TG_OP = 'DELETE' THEN
    -- Decrement listing count
    UPDATE profiles 
    SET listing_count = GREATEST(listing_count - 1, 0) 
    WHERE id = OLD.owner_id;
    RETURN OLD;
  ELSIF TG_OP = 'UPDATE' THEN
    -- Handle status changes (e.g., soft delete)
    IF OLD.status != 'deleted' AND NEW.status = 'deleted' THEN
      UPDATE profiles 
      SET listing_count = GREATEST(listing_count - 1, 0) 
      WHERE id = NEW.owner_id;
    ELSIF OLD.status = 'deleted' AND NEW.status != 'deleted' THEN
      UPDATE profiles 
      SET listing_count = listing_count + 1 
      WHERE id = NEW.owner_id;
    END IF;
    RETURN NEW;
  END IF;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Create triggers to automatically update listing counts
DROP TRIGGER IF EXISTS trigger_update_listing_count ON listings;
CREATE TRIGGER trigger_update_listing_count
  AFTER INSERT OR UPDATE OR DELETE ON listings
  FOR EACH ROW EXECUTE FUNCTION update_user_listing_count();

-- Create a view for user subscription info
CREATE OR REPLACE VIEW user_subscription_info AS
SELECT 
  p.id,
  p.user_role,
  p.subscription_status,
  p.subscription_start_date,
  p.subscription_end_date,
  p.listing_count,
  get_user_listing_limit(p.user_role) as listing_limit,
  can_create_listing(p.id) as can_create_more_listings,
  CASE 
    WHEN p.user_role = 'super_user' THEN 'Unlimited'
    WHEN p.user_role = 'paid_user' THEN 'Unlimited'
    WHEN p.user_role = 'free_user' THEN CONCAT(p.listing_count, ' / 2')
    ELSE '0 / 0'
  END as listing_usage_display
FROM profiles p;

-- Function to initialize user profile with default role
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, user_role, subscription_status, listing_count)
  VALUES (NEW.id, 'free_user', 'inactive', 0);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger to create profile when user signs up
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION handle_new_user();

-- Row Level Security Policies
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- Users can only view and update their own profile
CREATE POLICY "Users can view own profile" ON profiles
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON profiles
  FOR UPDATE USING (auth.uid() = id);

-- Only authenticated users can view subscription info
GRANT SELECT ON user_subscription_info TO authenticated;

-- Grant permissions
GRANT EXECUTE ON FUNCTION get_user_listing_limit(TEXT) TO authenticated;
GRANT EXECUTE ON FUNCTION can_create_listing(UUID) TO authenticated;

-- Update existing users to have default role if they don't have one
UPDATE profiles 
SET user_role = 'free_user', 
    subscription_status = 'inactive', 
    listing_count = 0 
WHERE user_role IS NULL;

-- Update listing counts for existing users
UPDATE profiles 
SET listing_count = (
  SELECT COUNT(*) 
  FROM listings 
  WHERE owner_id = profiles.id AND status != 'deleted'
)
WHERE listing_count = 0;

COMMENT ON COLUMN profiles.user_role IS 'User subscription role: super_user (unlimited), paid_user (unlimited), free_user (2 listings)';
COMMENT ON COLUMN profiles.subscription_status IS 'Current subscription status';
COMMENT ON COLUMN profiles.listing_count IS 'Current number of active listings';
COMMENT ON FUNCTION get_user_listing_limit(TEXT) IS 'Returns listing limit for given user role (-1 for unlimited)';
COMMENT ON FUNCTION can_create_listing(UUID) IS 'Checks if user can create more listings based on their role and current count';
