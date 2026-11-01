-- Evebud marketplace foundation. Run once in Supabase SQL Editor.
create table if not exists public.vendor_profiles (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references auth.users(id) on delete cascade,
  business_name text not null,
  category text not null,
  city text not null,
  description text,
  phone text,
  email text,
  website text,
  starting_price numeric(14,2),
  price_unit text,
  service_area text,
  status text not null default 'pending' check (status in ('pending','published','rejected','paused')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index if not exists vendor_profiles_search_idx on public.vendor_profiles (status, city, category);
alter table public.vendor_profiles enable row level security;
drop policy if exists "Public can view published vendors" on public.vendor_profiles;
create policy "Public can view published vendors" on public.vendor_profiles for select using (status = 'published' or owner_id = auth.uid());
drop policy if exists "Vendors can create own profile" on public.vendor_profiles;
create policy "Vendors can create own profile" on public.vendor_profiles for insert with check (owner_id = auth.uid());
drop policy if exists "Vendors can update own profile" on public.vendor_profiles;
create policy "Vendors can update own profile" on public.vendor_profiles for update using (owner_id = auth.uid()) with check (owner_id = auth.uid());
alter table public.event_vendors add column if not exists vendor_profile_id uuid references public.vendor_profiles(id) on delete set null;
alter table public.event_vendors add column if not exists quoted_amount numeric(14,2);
alter table public.event_vendors add column if not exists booking_status text not null default 'shortlisted';
create index if not exists event_vendors_event_idx on public.event_vendors(event_id);
