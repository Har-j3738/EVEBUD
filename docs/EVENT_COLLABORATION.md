# Event collaboration foundation

This migration adds event-scoped collaboration to Evebud's existing organiser-owned event model.

## What it adds

- An `event_members` table linking an existing event to an authenticated user.
- Two membership levels: `editor` (can manage event content) and `viewer` (read-only).
- Owner-only membership management.
- Member read access to the event and its tasks, expenses, vendors, guests and AI run records.
- Owner-only event settings and deletion.
- Owner-only approval decisions. Editors can submit pending approval requests but cannot approve them.

Existing event and related records are retained. Existing owner-only policies on the affected tables are replaced with membership-aware policies.

## Important: database migration is not automatic

The SQL file is:
`supabase/migrations/20261103_event_collaboration_foundation.sql`

It is committed for review only. It has **not** been applied to the connected Supabase project.

Before applying it to a live database:

1. Take and verify a database backup/restore point.
2. Test on a separate Supabase development project containing the current schema and vendor migration.
3. Confirm the project has the baseline policies named in `supabase/schema.sql`.
4. Apply the migration in Supabase SQL Editor.
5. Test with two separate accounts: event owner, editor, viewer, and an unrelated account.

## Current limitation

This is the database permission foundation, not the invitation experience. Evebud does not yet have a UI to invite members, accept invitations, or switch between member workspaces. Do not manually insert arbitrary users as members without a trusted invitation/identity-verification flow.

## Suggested verification matrix

| Action | Owner | Editor | Viewer | Unrelated user |
|---|---:|---:|---:|---:|
| Read event and event content | Yes | Yes | Yes | No |
| Create/update/delete tasks, expenses, guests and event vendors | Yes | Yes | No | No |
| Change event-level settings | Yes | No | No | No |
| Add/remove/change members | Yes | No | No | No |
| Create a pending approval request | Yes | Yes | No | No |
| Approve/reject an approval | Yes | No | No | No |
| Read event approvals | Yes | Yes | Yes | No |

The migration is additive apart from replacing the existing owner-only RLS policies with the equivalent owner-plus-membership rules. Review the SQL against the exact live schema before applying.
