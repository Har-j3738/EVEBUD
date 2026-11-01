# Evebud 2.0 🌸

**Your event, beautifully handled.** Evebud is an AI-assisted event planning workspace for creating events, organising budgets and tasks, discovering venues and vendors, and generating creative event concepts.

## Stack
- React + TypeScript + Vite
- Supabase Auth + Postgres with Row Level Security
- Google Maps Platform (Places + Maps) for nearby discovery (planned)
- Gemini API through a server-side endpoint for AI planning (planned)

## Local setup
1. Install Node.js 20+.
2. Copy `.env.example` to `.env.local` and fill in the Supabase project URL and anon/publishable key.
3. Run `npm install`.
4. Run `npm run dev` and open the local URL printed by Vite.

## Supabase setup
Run `supabase/schema.sql` in the Supabase SQL Editor. Enable email/password sign-in and configure the local redirect URL `http://localhost:5173`.

## Secrets and safety
- The Supabase anon/publishable key is intended for browser use when RLS is correctly configured.
- Never put a Supabase service-role key, Gemini key, or unrestricted server-side Google Maps key in frontend code or commit them to Git.
- AI suggestions are drafts. Vendor contact, bookings, invitations, payments and other external actions must require explicit user approval.

## Current milestone
The initial foundation includes sign-in/sign-up, personal event workspaces, cloud event creation/listing, a pastel responsive dashboard, and owner-scoped database policies. Google Places and Gemini are not wired yet. Test locally before merging the draft PR.
