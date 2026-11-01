# Evebud

An event-planning workspace for managing events, tasks, guests, budgets and vendor shortlists.

## Tech stack
- React 18 + TypeScript
- Vite
- Supabase Auth and database
- Lucide React icons

## Run locally
1. Install Node.js 20+.
2. Run `npm install`.
3. Copy `.env.example` to `.env.local`.
4. Add your Supabase project URL and publishable/anon key.
5. Run `npm run dev`.

## Security notes
Never commit `.env.local`, passwords, service-role keys or other secrets. Use only the Supabase publishable/anon key in browser code. Enable and verify row-level security policies for every database table and storage bucket before production.

## Current feature scope
The supplied interface includes event workspaces, task tracking, guest RSVP management, expense tracking, vendor registration and shortlisting, and a checklist-style planning assistant. The checklist generator is currently deterministic rather than an LLM integration. The Discover screen is a placeholder, not a live maps integration.

## Before release
- Verify Supabase RLS and storage policies.
- Keep estimated costs separate from actual spending.
- Handle async errors and loading states consistently.
- Add tests for core user flows and calculations.
- Run `npm test` and `npm run build`.