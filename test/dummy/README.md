# Dummy App

This Rails app exists to validate `recording_studio_navigation` inside a real Recording Studio host application.

## What It Covers

- Devise authentication with two seeded users
- `Current.actor` wiring for Recording Studio access checks
- Two workspace roots with different content and different access levels
- A FlatPack sidebar rendered from the runtime navigation registry
- A top-nav quick-link search filtered by the current root and visible items

## Quick Start

```bash
cd test/dummy
bundle install
bin/rails db:setup
bin/dev
```

Then sign in with one of the demo users:

- `admin@admin.com` / `Password`
- `producer@admin.com` / `Password`

## Useful Routes

- `/` - redirects to the first accessible workspace
- `/workspaces/:id` - workspace overview and navigation demo
- `/workspaces/:workspace_id/recordings/:id` - generic page/folder detail screen
- `/workspaces/:workspace_id/access_overview` - root-level access summary
- `/recording_studio` - redirects to `/` while the mounted Recording Studio engine stays available under that prefix for non-root routes

## Why This App Exists

Use this app to verify that the same registry definitions can render different navigation trees for different roots and actors without introducing a second authorization system. If sidebar composition, root resolution, or quick-link filtering breaks here, the gem is not ready for a host app.
