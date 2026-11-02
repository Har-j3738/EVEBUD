# Evebud 🌸

**Your event, beautifully handled.**

Evebud is an event-management workspace designed to help organisers bring the moving parts of an event into one place. It provides a central space to create event workspaces, organise tasks, track estimated expenses, manage guests and RSVPs, and shortlist vendors.

> **Project status:** Evebud is a working development build. Some areas, including map-based discovery and live AI planning, are currently placeholders or planned integrations. See [Current functionality](#current-functionality-and-scope) for an honest breakdown.

## 1. Chosen vertical

**Event Management**

We chose event management because planning an event involves several connected activities—budgets, schedules, guests, vendors and follow-ups—that are often managed across separate tools or spreadsheets. Evebud brings these activities into one event-specific workspace so organisers can keep key information together and see what needs attention.

**Primary users**
- Individuals organising personal events such as birthdays, weddings and anniversaries.
- Organisers coordinating corporate events, conferences and celebrations.
- Event vendors who want to submit a business profile for marketplace review.

The organiser is the primary user; vendor registration supports the marketplace side of the platform.

## 2. Approach and solution logic

The solution is organised around an **event workspace**. An organiser signs in, creates an event and then manages its related information from dedicated sections.

- **Authentication:** Supabase email/password authentication provides account access.
- **Event management:** Each event stores details such as its name, type, date, expected guest count, budget, location and event vibe.
- **Tasks:** Organisers add tasks with a category, priority and optional due date, then mark tasks as complete or remove them.
- **Budget tracking:** Expenses are recorded with a category and estimated amount. The workspace shows the planned budget, tracked amount and remaining amount.
- **Guest management:** Organisers add guests and maintain each guest's RSVP state as pending, confirmed or declined.
- **Vendor marketplace:** Businesses can submit profiles for review. Only profiles with a published status appear in the marketplace. Organisers can search and filter published profiles, add vendors to an event shortlist and update their booking stage.
- **Profile:** Users can update their display name and upload a profile photo.
- **Planning assistance:** The current AI Studio creates a predefined event-planning starter checklist. Organisers can review the suggestions and add them to their task list.

The platform uses Supabase as its backend. Event-related records are associated with an event workspace, while account access is handled through Supabase Auth. Database access should be protected with appropriate Row Level Security policies.

## 3. How the solution works

1. **Sign up or sign in** using an email address and password.
2. **Create an event** and enter its basic details, including event type, date, guest count, budget, location and theme/vibe.
3. **Open the event workspace** to manage its tasks, guests, expenses and vendor shortlist.
4. **Break planning into tasks** by adding items, setting priorities and optional due dates, then tracking completion.
5. **Track expenses** by recording estimated costs and reviewing the budget summary.
6. **Manage guests** by adding guest details and updating RSVP status as responses arrive.
7. **Explore vendors** by searching published marketplace listings and saving relevant vendors to the selected event.
8. **Use the starter checklist** in AI Studio as a planning aid. Review the suggested items before adding them to the event's tasks.

The dashboard and notification panel provide quick access to event information, open tasks, pending RSVPs and the vendor shortlist.

## 4. Current functionality and scope

| Area | Current implementation |
|---|---|
| Authentication | Email/password sign-up and sign-in through Supabase Auth |
| Event workspaces | Create and view events associated with the signed-in account |
| Tasks | Add, complete and delete tasks; category, priority and optional due date |
| Budget | Add and remove estimated expenses; view budget totals |
| Guests | Add and remove guests; update RSVP status |
| Vendors | Submit vendor profiles for review; browse published profiles; shortlist and update booking stage |
| Profile | Update display name and upload avatar to Supabase Storage |
| Notifications | In-app panel showing open tasks, pending RSVPs and a link to the vendor shortlist |
| AI Studio | Predefined starter checklist; not connected to a live generative-AI model |
| Discover | Preview/placeholder for future map-based discovery; no live Google Maps search is currently connected |

## 5. Technology stack

- **Frontend:** React, TypeScript and Vite
- **UI:** CSS and Lucide icons
- **Backend services:** Supabase
- **Authentication:** Supabase Auth
- **Database:** Supabase Postgres
- **File storage:** Supabase Storage for profile photos
- **Design and prototyping:** Figma
- **Development assistance:** ChatGPT was used for brainstorming, planning, implementation support and debugging. It is not a runtime dependency of the application.

## 6. Setup and running locally

### Prerequisites

- Node.js 20 or later
- npm
- A Supabase project

### Installation

```bash
git clone https://github.com/Har-j3738/EVEBUD.git
cd EVEBUD
git checkout feat/evebud-v2-foundation
npm install
```

Create a local environment file from the example:

```bash
cp .env.example .env.local
```

Add the Supabase project URL and browser-safe anon/publishable key to `.env.local`:

```env
VITE_SUPABASE_URL=your_supabase_project_url
VITE_SUPABASE_PUBLISHABLE_KEY=your_supabase_publishable_key
# Legacy projects may continue using VITE_SUPABASE_ANON_KEY
```

Then start the development server:

```bash
npm run dev
```

To create a production build:

```bash
npm run build
```

### Supabase configuration

The application expects the Supabase database tables and policies used by the app, plus an `avatars` Storage bucket for profile-photo uploads. Apply the project's database setup in the Supabase SQL Editor where applicable, enable email/password authentication, and configure the appropriate local and deployed redirect URLs.

Never place a Supabase service-role key or other server-side secret in a `VITE_*` variable or commit it to the repository. The browser anon/publishable key is intended for client use only when database access is correctly restricted by Row Level Security.

## 7. Assumptions made

- Event organisers are the main users and manage their own event workspaces.
- Users have an internet connection and a modern browser.
- Users enter and maintain accurate event, expense, guest and RSVP information.
- Expense amounts are entered as estimates in Indian rupees (INR); the current tracker does not automatically import bank or payment data.
- Vendor profiles are not publicly listed immediately after submission; they must reach the published status before appearing in the marketplace.
- Vendor shortlisting and booking-stage updates are organiser-managed records; they do not represent a confirmed external booking or payment.
- The AI Studio checklist is a predefined set of suggestions, not output from a trained or live LLM.
- The Discover screen is a placeholder for future map and location discovery, not a working maps integration.
- Availability of authentication, database and storage features depends on correct Supabase project configuration and policies.

## 8. Future scope

- Connect a live generative-AI service for event-specific plans, timelines and budget suggestions.
- Integrate Google Maps/Places for location and venue discovery.
- Add reminders, calendar integration and invitation/RSVP workflows.
- Expand vendor communication, quotation and booking workflows.
- Add collaboration for co-organisers and role-based access.
- Improve reporting and analytics for event progress and spending.

## 9. Conclusion

Evebud brings core event-planning activities into a single workspace, helping organisers coordinate tasks, budgets, guests and vendor shortlists without switching between disconnected tools. The current build establishes the core workflow, while live AI planning, map discovery and deeper booking integrations remain future enhancements.
