-- Add rental status functionality to listings
-- This allows marking items as currently rented out and unavailable

-- Add new columns for rental status
ALTER TABLE listings 
ADD COLUMN IF NOT EXISTS rental_status TEXT CHECK (rental_status IN ('available', 'rented_out', 'maintenance')) DEFAULT 'available',
ADD COLUMN IF NOT EXISTS rented_until DATE,
ADD COLUMN IF NOT EXISTS renter_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
ADD COLUMN IF NOT EXISTS rental_start_date DATE,
ADD COLUMN IF NOT EXISTS rental_notes TEXT;

-- Add index for better performance on rental status queries
CREATE INDEX IF NOT EXISTS idx_listings_rental_status ON listings(rental_status);
CREATE INDEX IF NOT EXISTS idx_listings_rented_until ON listings(rented_until);
CREATE INDEX IF NOT EXISTS idx_listings_renter_id ON listings(renter_id);

-- Update the existing status field to work with rental_status
-- Items can be active but rented out, or inactive entirely
COMMENT ON COLUMN listings.status IS 'Overall listing status: active, inactive, draft';
COMMENT ON COLUMN listings.rental_status IS 'Current rental availability: available, rented_out, maintenance';

-- Create a view for available listings (combines both status checks)
CREATE OR REPLACE VIEW available_listings AS
SELECT l.*
FROM listings l
WHERE l.status = 'active' 
  AND l.rental_status = 'available'
  AND (l.rented_until IS NULL OR l.rented_until < CURRENT_DATE);

-- Update the listings_with_owner view to include rental status
DROP VIEW IF EXISTS listings_with_owner;

CREATE VIEW listings_with_owner AS
SELECT 
  l.*,
  p.full_name as owner_name,
  p.created_at as owner_member_since,
  renter_p.full_name as renter_name
FROM listings l
LEFT JOIN profiles p ON l.owner_id = p.id
LEFT JOIN profiles renter_p ON l.renter_id = renter_p.id;

-- Create a function to automatically update rental status when rental period ends
CREATE OR REPLACE FUNCTION update_expired_rentals()
RETURNS void AS $$
BEGIN
  UPDATE listings 
  SET 
    rental_status = 'available',
    renter_id = NULL,
    rental_start_date = NULL,
    rental_notes = NULL,
    rented_until = NULL
  WHERE rental_status = 'rented_out' 
    AND rented_until IS NOT NULL 
    AND rented_until < CURRENT_DATE;
END;
$$ LANGUAGE plpgsql;

-- Grant necessary permissions
GRANT SELECT ON available_listings TO authenticated;
GRANT SELECT ON listings_with_owner TO authenticated;
GRANT EXECUTE ON FUNCTION update_expired_rentals() TO authenticated;

-- You can set up a cron job or call this function periodically to auto-update expired rentals
-- For now, it can be called manually or triggered by the application
