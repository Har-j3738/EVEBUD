# Vendor directory privacy

The public marketplace previously selected directly from `vendor_profiles`, whose published-row policy also exposed phone and email fields.

This migration:
- Removes public row-level access to `vendor_profiles`.
- Restores authenticated owner-only reads for a vendor's own full profile.
- Adds `public_vendor_directory`, a read-only view exposing only listing-safe fields.
- Intentionally excludes phone, email and owner_id from the public view.

## Application follow-up required

The marketplace frontend must read `public_vendor_directory` rather than `vendor_profiles`. Vendor registration continues inserting into `vendor_profiles`; authenticated owners retain their own select policy.

Before applying to production:
1. Back up the database.
2. Test the migration on a staging Supabase project.
3. Test anonymous and signed-in directory reads.
4. Confirm an unrelated account cannot read a vendor's phone/email.
5. Confirm a vendor can still submit and read their own complete profile.

This migration has not been applied to Supabase.
