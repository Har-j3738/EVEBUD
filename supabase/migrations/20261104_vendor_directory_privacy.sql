-- Keep vendor contact details private while exposing a safe public directory.
-- Public listings deliberately omit phone, email and owner_id.

drop policy if exists "Public can view published vendors" on public.vendor_profiles;
drop policy if exists "Vendors can view own profile" on public.vendor_profiles;

create policy "Vendors can view own profile"
  on public.vendor_profiles
  for select
  to authenticated
  using (owner_id = auth.uid());

create or replace view public.public_vendor_directory
with (security_barrier = true)
as
select
  id,
  business_name,
  category,
  city,
  description,
  website,
  starting_price,
  price_unit,
  service_area,
  status,
  created_at
from public.vendor_profiles
where status = 'published';

grant select on public.public_vendor_directory to anon, authenticated;

comment on view public.public_vendor_directory is
  'Public marketplace-safe vendor fields only. Contact details and owner identity are intentionally excluded.';
