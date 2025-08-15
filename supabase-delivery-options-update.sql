-- Update listings table to support better delivery/pickup options
-- This enhances the existing delivery_available field with more granular options

-- Add new columns for delivery options
ALTER TABLE listings 
ADD COLUMN IF NOT EXISTS delivery_method TEXT CHECK (delivery_method IN ('pickup_only', 'delivery_only', 'both')) DEFAULT 'pickup_only',
ADD COLUMN IF NOT EXISTS delivery_fee DECIMAL(10,2) DEFAULT 0,
ADD COLUMN IF NOT EXISTS delivery_radius INTEGER DEFAULT 0, -- in kilometers
ADD COLUMN IF NOT EXISTS pickup_instructions TEXT;

-- Update existing records to use the new delivery_method field
-- Convert existing delivery_available boolean to new delivery_method enum
UPDATE listings 
SET delivery_method = CASE 
  WHEN delivery_available = true THEN 'both'
  ELSE 'pickup_only'
END
WHERE delivery_method = 'pickup_only';

-- Add index for better performance on delivery method queries
CREATE INDEX IF NOT EXISTS idx_listings_delivery_method ON listings(delivery_method);

-- Drop and recreate the listings_with_owner view to include new delivery fields
DROP VIEW IF EXISTS listings_with_owner;

CREATE VIEW listings_with_owner AS
SELECT 
  l.*,
  p.full_name as owner_name,
  p.created_at as owner_member_since
FROM listings l
LEFT JOIN profiles p ON l.owner_id = p.id;

-- Grant necessary permissions
GRANT SELECT ON listings_with_owner TO authenticated;
