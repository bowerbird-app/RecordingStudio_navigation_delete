# frozen_string_literal: true

RecordingStudioNavigation.configure do |config|
  config.register do |registry|
    registry.register_item(
      :workspace_home,
      label: "Overview",
      icon: :home,
      quick_link: true,
      description: "Open the current workspace overview.",
      href: ->(context:) { context.helpers.workspace_path(context.root_recordable) }
    )

    registry.register_item(
      :workspace_library,
      label: "Library",
      icon: :folder,
      quick_link: true,
      description: "Open the shared library folder for the current workspace.",
      resolver: RecordingStudioNavigation::TreeLink.new(
        recordable_type: "Folder",
        match: { name: "Library" },
        href: ->(context:, recording:, **) { context.helpers.workspace_recording_path(context.root_recordable, recording) }
      )
    )

    registry.register_item(
      :workspace_style_guide,
      label: "Style guide",
      icon: :eye,
      quick_link: true,
      description: "Open the current workspace style guide.",
      visible: ->(context:) { context.access_at_least?(:edit) },
      resolver: RecordingStudioNavigation::TreeLink.new(
        recordable_type: "Page",
        match: { title: "Style Guide" },
        href: ->(context:, recording:, **) { context.helpers.workspace_recording_path(context.root_recordable, recording) }
      )
    )

    registry.register_item(
      :workspace_release_checklist,
      label: "Release checklist",
      icon: :queue_list,
      quick_link: true,
      description: "Open the release checklist for the current workspace.",
      resolver: RecordingStudioNavigation::TreeLink.new(
        recordable_type: "Page",
        match: { title: "Release Checklist" },
        href: ->(context:, recording:, **) { context.helpers.workspace_recording_path(context.root_recordable, recording) }
      )
    )

    registry.register_item(
      :workspace_access_overview,
      label: "Access overview",
      icon: :settings,
      description: "Review who can access the current workspace.",
      visible: ->(context:) { context.access_at_least?(:admin) },
      href: ->(context:) { context.helpers.workspace_access_overview_path(context.root_recordable) }
    )

    registry.register_group(
      :workspace_primary,
      label: "Workspace",
      item_keys: %i[workspace_home]
    )

    registry.register_group(
      :workspace_admin,
      label: "Management",
      item_keys: []
    )

    registry.register_section(
      :workspace_navigation,
      label: "Navigation",
      group_keys: %i[workspace_primary]
    )

    registry.register_section(
      :workspace_management,
      label: "Access",
      group_keys: []
    )

    registry.contribute_to_group(
      key: :workspace_reference_links,
      group_key: :workspace_primary,
      item_keys: %i[workspace_library workspace_style_guide workspace_release_checklist]
    )

    registry.contribute_to_group(
      key: :workspace_admin_links,
      group_key: :workspace_admin,
      item_keys: %i[workspace_access_overview]
    )

    registry.contribute_to_section(
      key: :workspace_management_group,
      section_key: :workspace_management,
      group_keys: %i[workspace_admin],
      visible: ->(context:) { context.access_at_least?(:admin) }
    )
  end
end
