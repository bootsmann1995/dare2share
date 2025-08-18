-- Complete User Deletion Script for Dare2Share
-- This script safely deletes a user and ALL their related data
-- WARNING: This action is IRREVERSIBLE!

-- Function to completely delete a user and all related data
CREATE OR REPLACE FUNCTION admin_delete_user_completely(target_user_id UUID)
RETURNS BOOLEAN AS $$
DECLARE
  listing_record RECORD;
  image_record RECORD;
  deletion_count INTEGER := 0;
BEGIN
  -- Check if the calling user is a super_user
  IF NOT EXISTS (
    SELECT 1 FROM profiles 
    WHERE profiles.id = auth.uid() 
    AND profiles.user_role = 'super_user'
  ) THEN
    RAISE EXCEPTION 'Access denied. Admin privileges required.';
  END IF;

  -- Verify the target user exists
  IF NOT EXISTS (SELECT 1 FROM auth.users WHERE id = target_user_id) THEN
    RAISE EXCEPTION 'User with ID % not found.', target_user_id;
  END IF;

  -- Start transaction log
  RAISE NOTICE 'Starting deletion process for user: %', target_user_id;

  -- 1. Delete listing images from storage and database
  RAISE NOTICE 'Deleting listing images...';
  FOR listing_record IN 
    SELECT id FROM listings WHERE owner_id = target_user_id
  LOOP
    -- Delete images for this listing
    FOR image_record IN 
      SELECT id, image_url FROM listing_images WHERE listing_id = listing_record.id
    LOOP
      -- Note: Storage deletion should be handled by your application
      -- This only removes database records
      DELETE FROM listing_images WHERE id = image_record.id;
      deletion_count := deletion_count + 1;
    END LOOP;
  END LOOP;
  RAISE NOTICE 'Deleted % listing images', deletion_count;

  -- 2. Delete user ratings (both given and received)
  deletion_count := 0;
  DELETE FROM user_ratings WHERE rater_id = target_user_id OR rated_user_id = target_user_id;
  GET DIAGNOSTICS deletion_count = ROW_COUNT;
  RAISE NOTICE 'Deleted % user ratings', deletion_count;

  -- 3. Delete user listings
  deletion_count := 0;
  DELETE FROM listings WHERE owner_id = target_user_id;
  GET DIAGNOSTICS deletion_count = ROW_COUNT;
  RAISE NOTICE 'Deleted % listings', deletion_count;

  -- 4. Delete user profile
  deletion_count := 0;
  DELETE FROM profiles WHERE id = target_user_id;
  GET DIAGNOSTICS deletion_count = ROW_COUNT;
  RAISE NOTICE 'Deleted % profile record', deletion_count;

  -- 5. Delete from auth.users (this will cascade to any remaining references)
  deletion_count := 0;
  DELETE FROM auth.users WHERE id = target_user_id;
  GET DIAGNOSTICS deletion_count = ROW_COUNT;
  RAISE NOTICE 'Deleted % auth user record', deletion_count;

  RAISE NOTICE 'User deletion completed successfully for: %', target_user_id;
  RETURN TRUE;

EXCEPTION
  WHEN OTHERS THEN
    RAISE EXCEPTION 'Error during user deletion: %', SQLERRM;
    RETURN FALSE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to get user deletion preview (what will be deleted)
CREATE OR REPLACE FUNCTION admin_preview_user_deletion(target_user_id UUID)
RETURNS TABLE (
  data_type TEXT,
  count INTEGER,
  details TEXT
) AS $$
BEGIN
  -- Check if the calling user is a super_user
  IF NOT EXISTS (
    SELECT 1 FROM profiles 
    WHERE profiles.id = auth.uid() 
    AND profiles.user_role = 'super_user'
  ) THEN
    RAISE EXCEPTION 'Access denied. Admin privileges required.';
  END IF;

  -- Return what will be deleted
  RETURN QUERY
  SELECT 'User Profile'::TEXT, 1::INTEGER, 
         COALESCE('Name: ' || p.full_name || ', Email: ' || u.email, 'No profile data')::TEXT
  FROM auth.users u
  LEFT JOIN profiles p ON u.id = p.id
  WHERE u.id = target_user_id
  
  UNION ALL
  
  SELECT 'Listings'::TEXT, COUNT(*)::INTEGER, 
         'Listings owned by user'::TEXT
  FROM listings 
  WHERE owner_id = target_user_id
  
  UNION ALL
  
  SELECT 'Listing Images'::TEXT, COUNT(*)::INTEGER,
         'Images associated with user listings'::TEXT
  FROM listing_images li
  JOIN listings l ON li.listing_id = l.id
  WHERE l.owner_id = target_user_id
  
  UNION ALL
  
  SELECT 'Ratings Given'::TEXT, COUNT(*)::INTEGER,
         'Ratings given by this user'::TEXT
  FROM user_ratings
  WHERE rater_id = target_user_id
  
  UNION ALL
  
  SELECT 'Ratings Received'::TEXT, COUNT(*)::INTEGER,
         'Ratings received by this user'::TEXT
  FROM user_ratings
  WHERE rated_user_id = target_user_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Quick script to delete a specific user by email
-- Usage: Replace 'user@example.com' with the actual email
/*
DO $$
DECLARE
  user_id_to_delete UUID;
  user_email TEXT := 'user@example.com'; -- CHANGE THIS
BEGIN
  -- Find user ID by email
  SELECT id INTO user_id_to_delete 
  FROM auth.users 
  WHERE email = user_email;
  
  IF user_id_to_delete IS NULL THEN
    RAISE NOTICE 'User with email % not found', user_email;
  ELSE
    RAISE NOTICE 'Found user: % with ID: %', user_email, user_id_to_delete;
    
    -- Preview what will be deleted
    RAISE NOTICE 'Deletion preview:';
    PERFORM admin_preview_user_deletion(user_id_to_delete);
    
    -- Uncomment the line below to actually delete the user
    -- PERFORM admin_delete_user_completely(user_id_to_delete);
    
    RAISE NOTICE 'To actually delete, uncomment the deletion line in the script';
  END IF;
END $$;
*/

-- Manual deletion script template
-- Step 1: Find the user
-- SELECT id, email, created_at FROM auth.users WHERE email = 'user@example.com';

-- Step 2: Preview deletion
-- SELECT * FROM admin_preview_user_deletion('user-id-here');

-- Step 3: Delete user (IRREVERSIBLE!)
-- SELECT admin_delete_user_completely('user-id-here');
