-- EVEBUD event collaboration foundation.
-- Adds owner-managed editor/viewer membership without changing existing records.
-- This migration is additive and must be reviewed before applying in Supabase.

create table if not exists public.event_members (
  id uuid primary key default gen_random_uuid(),
  event_id uuid not null references public.events(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  role text not null default 'editor' check (role in ('editor', 'viewer')),
  invited_by uuid not null references auth.users(id),
  created_at timestamptz not null default now(),
  unique (event_id, user_id)
);

create index if not exists event_members_user_event_idx
  on public.event_members (user_id, event_id);
create index if not exists event_members_event_role_idx
  on public.event_members (event_id, role);

alter table public.event_members enable row level security;

-- SECURITY DEFINER helpers avoid recursive RLS evaluation when policies on
-- events and event_members need to check one another.
create or replace function public.is_event_owner(p_event_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.events e
    where e.id = p_event_id
      and e.owner_id = auth.uid()
  );
$$;

create or replace function public.can_view_event(p_event_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.events e
    where e.id = p_event_id
      and (
        e.owner_id = auth.uid()
        or exists (
          select 1
          from public.event_members m
          where m.event_id = e.id
            and m.user_id = auth.uid()
        )
      )
  );
$$;

create or replace function public.can_manage_event(p_event_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.events e
    where e.id = p_event_id
      and (
        e.owner_id = auth.uid()
        or exists (
          select 1
          from public.event_members m
          where m.event_id = e.id
            and m.user_id = auth.uid()
            and m.role = 'editor'
        )
      )
  );
$$;

revoke all on function public.is_event_owner(uuid) from public, anon;
revoke all on function public.can_view_event(uuid) from public, anon;
revoke all on function public.can_manage_event(uuid) from public, anon;
grant execute on function public.is_event_owner(uuid) to authenticated;
grant execute on function public.can_view_event(uuid) to authenticated;
grant execute on function public.can_manage_event(uuid) to authenticated;

grant select, insert, update, delete on table public.event_members to authenticated;

drop policy if exists "Owners manage event members" on public.event_members;
drop policy if exists "Event members can view membership" on public.event_members;
drop policy if exists "Event owners add members" on public.event_members;
drop policy if exists "Event owners update members" on public.event_members;
drop policy if exists "Event owners remove members" on public.event_members;

create policy "Event members can view membership"
  on public.event_members for select to authenticated
  using (public.can_view_event(event_id));

create policy "Event owners add members"
  on public.event_members for insert to authenticated
  with check (
    public.is_event_owner(event_id)
    and invited_by = auth.uid()
    and user_id <> auth.uid()
  );

create policy "Event owners update members"
  on public.event_members for update to authenticated
  using (public.is_event_owner(event_id))
  with check (
    public.is_event_owner(event_id)
    and role in ('editor', 'viewer')
  );

create policy "Event owners remove members"
  on public.event_members for delete to authenticated
  using (public.is_event_owner(event_id));

-- Events are visible to members, but only the owner can change event-level
-- settings or transfer/delete the event.
drop policy if exists "owners manage own events" on public.events;
drop policy if exists "Event owners and members can view events" on public.events;
drop policy if exists "Event owners create events" on public.events;
drop policy if exists "Event owners update events" on public.events;
drop policy if exists "Event owners delete events" on public.events;

create policy "Event owners and members can view events"
  on public.events for select to authenticated
  using (owner_id = auth.uid() or public.can_view_event(id));

create policy "Event owners create events"
  on public.events for insert to authenticated
  with check (owner_id = auth.uid());

create policy "Event owners update events"
  on public.events for update to authenticated
  using (owner_id = auth.uid())
  with check (owner_id = auth.uid());

create policy "Event owners delete events"
  on public.events for delete to authenticated
  using (owner_id = auth.uid());

-- Event content: editors and owners can manage; viewers are read-only.
do $$
declare
  table_name text;
begin
  foreach table_name in array array[
    'event_tasks',
    'event_expenses',
    'event_vendors',
    'event_guests',
    'agent_runs'
  ]
  loop
    execute format('drop policy if exists %I on public.%I',
      'owners manage ' || replace(table_name, 'event_', 'event '), table_name);
    execute format('drop policy if exists %I on public.%I',
      'Event members view ' || table_name, table_name);
    execute format('drop policy if exists %I on public.%I',
      'Event editors insert ' || table_name, table_name);
    execute format('drop policy if exists %I on public.%I',
      'Event editors update ' || table_name, table_name);
    execute format('drop policy if exists %I on public.%I',
      'Event editors delete ' || table_name, table_name);

    execute format(
      'create policy %I on public.%I for select to authenticated using (public.can_view_event(event_id))',
      'Event members view ' || table_name, table_name
    );
    execute format(
      'create policy %I on public.%I for insert to authenticated with check (public.can_manage_event(event_id))',
      'Event editors insert ' || table_name, table_name
    );
    execute format(
      'create policy %I on public.%I for update to authenticated using (public.can_manage_event(event_id)) with check (public.can_manage_event(event_id))',
      'Event editors update ' || table_name, table_name
    );
    execute format(
      'create policy %I on public.%I for delete to authenticated using (public.can_manage_event(event_id))',
      'Event editors delete ' || table_name, table_name
    );
  end loop;
end $$;

-- Approval decisions remain owner-only. Editors may prepare approval requests,
-- but cannot approve or reject their own or another user's sensitive actions.
drop policy if exists "owners manage approvals" on public.action_approvals;
drop policy if exists "Event members view approvals" on public.action_approvals;
drop policy if exists "Event editors create approvals" on public.action_approvals;
drop policy if exists "Event owners decide approvals" on public.action_approvals;
drop policy if exists "Event owners delete approvals" on public.action_approvals;

create policy "Event members view approvals"
  on public.action_approvals for select to authenticated
  using (public.can_view_event(event_id));

create policy "Event editors create approvals"
  on public.action_approvals for insert to authenticated
  with check (public.can_manage_event(event_id) and status = 'pending');

create policy "Event owners decide approvals"
  on public.action_approvals for update to authenticated
  using (public.is_event_owner(event_id))
  with check (public.is_event_owner(event_id));

create policy "Event owners delete approvals"
  on public.action_approvals for delete to authenticated
  using (public.is_event_owner(event_id));

comment on table public.event_members is
  'Event-scoped collaboration membership. Owners invite users as editors or read-only viewers.';
