# RecordingStudioNavigation

`recording_studio_navigation` is a Rails engine gem for composing access-aware navigation in Recording Studio host apps.

## What it provides

- Runtime registration for navigation items, groups, sections, and contributions
- Deterministic key-based overrides for registered definitions
- Simple links and tree-backed links resolved against the current Recording Studio root
- A navigation context carrying the current actor, current root, memoized visibility, and memoized item resolution
- Quick-link querying over visible items with explicit quick-link opt-in
- FlatPack-friendly rendering primitives demonstrated in the dummy app

## Core concepts

### Items

Register items once. Groups reference item keys instead of re-defining links.

```ruby
RecordingStudioNavigation.register_item(
  :workspace_home,
  label: "Overview",
  quick_link: true,
  href: ->(context:) { context.helpers.workspace_path(context.root_recordable) }
)
```

### Tree-backed links

Resolve links from the current root without hard-coding a single record id:

```ruby
RecordingStudioNavigation.register_item(
  :workspace_library,
  label: "Library",
  resolver: RecordingStudioNavigation::TreeLink.new(
    recordable_type: "Folder",
    match: { name: "Library" },
    href: ->(context:, recording:, **) { context.helpers.workspace_recording_path(context.root_recordable, recording) }
  )
)
```

### Groups, sections, and contributions

```ruby
RecordingStudioNavigation.register_group(
  :workspace_primary,
  label: "Workspace",
  item_keys: %i[workspace_home]
)

RecordingStudioNavigation.register_section(
  :workspace_navigation,
  label: "Navigation",
  group_keys: %i[workspace_primary]
)

RecordingStudioNavigation.contribute_to_group(
  key: :workspace_reference_links,
  group_key: :workspace_primary,
  item_keys: %i[workspace_library]
)
```

### Context and authorization

The gem does not introduce a separate authorization system. Visibility blocks can read Recording Studio access records through the context:

```ruby
context = RecordingStudioNavigation.context(
  actor: Current.actor,
  current_root: current_root_recording,
  helpers: helpers
)

context.access_at_least?(:edit)
context.sections
context.quick_links(query: params[:q])
```

## Installation

1. Add the gem to your host app.
2. Run `rails generate recording_studio_navigation:install`.
3. Register your navigation in `config/initializers/recording_studio_navigation.rb`.
4. Render `RecordingStudioNavigation.context(...)` results in your FlatPack sidebar and top-nav search.

If your host app uses Tailwind CSS, the install generator also prints the required source lines.

## Dummy app

The dummy app demonstrates:

- two workspace roots,
- two users with different Recording Studio access,
- sidebar composition from the shared registry,
- quick-link search filtered by current root and visible items.

Run it from `test/dummy` with:

```bash
bundle install
bin/rails db:setup
bin/dev
```
