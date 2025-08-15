-- User Ratings Schema
-- This script creates the user ratings system allowing users to rate each other

-- Create user_ratings table
CREATE TABLE IF NOT EXISTS user_ratings (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  rater_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  rated_user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
  comment TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  -- Ensure one rating per user pair
  UNIQUE(rater_id, rated_user_id),
  
  -- Prevent self-rating
  CHECK (rater_id != rated_user_id)
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_user_ratings_rated_user_id ON user_ratings(rated_user_id);
CREATE INDEX IF NOT EXISTS idx_user_ratings_rater_id ON user_ratings(rater_id);
CREATE INDEX IF NOT EXISTS idx_user_ratings_created_at ON user_ratings(created_at);

-- Enable Row Level Security
ALTER TABLE user_ratings ENABLE ROW LEVEL SECURITY;

-- RLS Policies for user_ratings
-- Allow users to read all ratings (for viewing ratings on profiles)
CREATE POLICY "Users can view all ratings" ON user_ratings
  FOR SELECT USING (auth.role() = 'authenticated');

-- Allow users to insert their own ratings
CREATE POLICY "Users can create ratings" ON user_ratings
  FOR INSERT WITH CHECK (auth.uid() = rater_id);

-- Allow users to update their own ratings
CREATE POLICY "Users can update their own ratings" ON user_ratings
  FOR UPDATE USING (auth.uid() = rater_id);

-- Allow users to delete their own ratings
CREATE POLICY "Users can delete their own ratings" ON user_ratings
  FOR DELETE USING (auth.uid() = rater_id);

-- Create a view for user rating statistics
CREATE OR REPLACE VIEW user_rating_stats AS
SELECT 
  rated_user_id,
  COUNT(*) as total_ratings,
  AVG(rating)::NUMERIC(3,2) as average_rating,
  COUNT(CASE WHEN rating = 5 THEN 1 END) as five_star_count,
  COUNT(CASE WHEN rating = 4 THEN 1 END) as four_star_count,
  COUNT(CASE WHEN rating = 3 THEN 1 END) as three_star_count,
  COUNT(CASE WHEN rating = 2 THEN 1 END) as two_star_count,
  COUNT(CASE WHEN rating = 1 THEN 1 END) as one_star_count
FROM user_ratings
GROUP BY rated_user_id;

-- Create a view for detailed ratings with rater info
CREATE OR REPLACE VIEW user_ratings_with_rater AS
SELECT 
  ur.id,
  ur.rater_id,
  ur.rated_user_id,
  ur.rating,
  ur.comment,
  ur.created_at,
  ur.updated_at,
  p.full_name as rater_name
FROM user_ratings ur
LEFT JOIN profiles p ON ur.rater_id = p.id;

-- Grant permissions on views
GRANT SELECT ON user_rating_stats TO authenticated;
GRANT SELECT ON user_ratings_with_rater TO authenticated;

-- Create function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_user_ratings_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for updated_at
CREATE TRIGGER update_user_ratings_updated_at
  BEFORE UPDATE ON user_ratings
  FOR EACH ROW
  EXECUTE FUNCTION update_user_ratings_updated_at();

-- Add rating stats to profiles view (update existing view)
CREATE OR REPLACE VIEW profiles_with_stats AS
SELECT 
  p.*,
  COALESCE(urs.total_ratings, 0) as total_ratings,
  COALESCE(urs.average_rating, 0) as average_rating
FROM profiles p
LEFT JOIN user_rating_stats urs ON p.id = urs.rated_user_id;

-- Grant permissions
GRANT SELECT ON profiles_with_stats TO authenticated;
