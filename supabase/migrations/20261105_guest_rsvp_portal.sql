-- Secure, token-based guest RSVP portal.
-- Guests receive a random 256-bit link token; only its SHA-256 hash is stored.
-- Public users can read only the event invitation summary and update RSVP status.
-- They cannot query the guest table or access other guest/event records.

create table if not exists public.guest_invitation_tokens (
  id uuid primary key default gen_random_uuid(),
  guest_id uuid not null references public.event_guests(id) on delete cascade,
  token_hash text not null unique check (token_hash ~ '^[a-f0-9]{64}$'),
  expires_at timestamptz not null default (now() + interval '30 days'),
  revoked_at timestamptz,
  created_at timestamptz not null default now()
);

create index if not exists guest_invitation_tokens_guest_idx
  on public.guest_invitation_tokens (guest_id);

alter table public.guest_invitation_tokens enable row level security;
revoke all on table public.guest_invitation_tokens from anon, authenticated;

create or replace function public.create_guest_invitation(p_guest_id uuid, p_token text)
returns void
language plpgsql
security definer
set search_path = public, extensions, pg_temp
as $$
declare
  v_event_id uuid;
begin
  if auth.uid() is null then
    raise exception 'Authentication required';
  end if;
  if p_token is null or p_token !~ '^[a-f0-9]{64}$' then
    raise exception 'Invalid invitation token format';
  end if;

  select g.event_id into v_event_id
  from public.event_guests g
  join public.events e on e.id = g.event_id
  where g.id = p_guest_id and e.owner_id = auth.uid();

  if v_event_id is null then
    raise exception 'Guest not found or access denied';
  end if;

  update public.guest_invitation_tokens
  set revoked_at = now()
  where guest_id = p_guest_id and revoked_at is null;

  insert into public.guest_invitation_tokens (guest_id, token_hash)
  values (p_guest_id, encode(digest(p_token, 'sha256'), 'hex'));
end;
$$;

create or replace function public.get_guest_invitation(p_token text)
returns table (
  guest_name text,
  event_title text,
  event_date date,
  event_location text,
  rsvp_status text
)
language sql
stable
security definer
set search_path = public, extensions, pg_temp
as $$
  select g.full_name, e.title, e.event_date, e.location, g.rsvp_status
  from public.guest_invitation_tokens i
  join public.event_guests g on g.id = i.guest_id
  join public.events e on e.id = g.event_id
  where p_token ~ '^[a-f0-9]{64}$'
    and i.token_hash = encode(digest(p_token, 'sha256'), 'hex')
    and i.revoked_at is null
    and i.expires_at > now()
  limit 1;
$$;

create or replace function public.respond_guest_invitation(p_token text, p_response text)
returns boolean
language plpgsql
security definer
set search_path = public, extensions, pg_temp
as $$
declare
  v_guest_id uuid;
begin
  if p_response is null or p_response not in ('confirmed', 'declined') then
    raise exception 'RSVP must be confirmed or declined';
  end if;
  if p_token is null or p_token !~ '^[a-f0-9]{64}$' then
    return false;
  end if;

  select i.guest_id into v_guest_id
  from public.guest_invitation_tokens i
  where i.token_hash = encode(digest(p_token, 'sha256'), 'hex')
    and i.revoked_at is null
    and i.expires_at > now()
  limit 1;

  if v_guest_id is null then
    return false;
  end if;

  update public.event_guests
  set rsvp_status = p_response
  where id = v_guest_id;

  return found;
end;
$$;

revoke all on function public.create_guest_invitation(uuid, text) from public, anon;
revoke all on function public.get_guest_invitation(text) from public;
revoke all on function public.respond_guest_invitation(text, text) from public;

grant execute on function public.create_guest_invitation(uuid, text) to authenticated;
grant execute on function public.get_guest_invitation(text) to anon, authenticated;
grant execute on function public.respond_guest_invitation(text, text) to anon, authenticated;

comment on table public.guest_invitation_tokens is
  'Stores only hashes of high-entropy RSVP link tokens; raw invitation tokens are never persisted.';
