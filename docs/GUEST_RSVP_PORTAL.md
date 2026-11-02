# Guest invitation and RSVP portal

This change adds private, per-guest RSVP links.

## Flow

1. An authenticated event organiser creates a guest in the existing guest list.
2. The organiser selects **Copy RSVP link** for that guest.
3. The browser generates a cryptographically random 256-bit token.
4. The token is sent to the authenticated `create_guest_invitation` RPC. Only its SHA-256 hash is stored.
5. The guest opens `/invite/<token>` without creating an Evebud account.
6. The public invitation RPC returns only that guest's name, event title/date/location and current RSVP state.
7. The guest can confirm or decline. The response RPC updates only the guest row bound to that token.

## Security properties

- Raw invitation tokens are not stored in Postgres.
- Tokens are random 256-bit values and expire after 30 days.
- Creating/replacing a link requires an authenticated event owner.
- Reissuing a link revokes previous active links for that guest.
- Anonymous access is limited to the two token-scoped RPCs; there is no anonymous SELECT policy on guest records or token rows.
- The public RPC does not return guest email, phone, dietary notes, or other guests.
- The response RPC accepts only `confirmed` or `declined`.

## Required rollout

The migration is `supabase/migrations/20261105_guest_rsvp_portal.sql`.

It has **not** been applied to the connected Supabase project. Before production use:

1. Back up the database and test on a staging Supabase project.
2. Confirm `pgcrypto` is installed and that `digest(text, text)` resolves in the configured extension schema.
3. Apply the migration.
4. Test owner-only invitation creation, invalid tokens, expired tokens, revoked tokens, and response updates using separate accounts/browser sessions.
5. Verify anonymous users cannot query `event_guests` or `guest_invitation_tokens` directly.
6. Configure Vercel's SPA fallback so `/invite/<token>` serves the React application.

## Operational limitations

- The current link is copied for the organiser to send manually. Email/WhatsApp delivery and consent tracking are not included.
- There is no built-in token rate limiting yet. Keep tokens high entropy, monitor abuse, and add an edge-function rate limit before broad public launch.
- A link is a bearer credential: anyone who receives it can respond for that guest. Treat it as private and revoke/reissue if it is shared accidentally.
- The guest portal currently displays only the event's title, date and location. It does not expose the full guest list or private event workspace.
