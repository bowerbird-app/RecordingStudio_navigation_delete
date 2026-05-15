# frozen_string_literal: true

RecordingStudioNavigation.configure do |config|
  config.register do |registry|
    registry.register_item(
      :workspace_home,
      label: "Workspace overview",
      icon: :home,
      quick_link: true,
      description: "Open the current workspace home.",
      href: ->(context:) { context.helpers.workspace_path(context.root_recordable) }
    )

    registry.register_group(
      :workspace_primary,
      label: "Workspace",
      item_keys: %i[workspace_home]
    )

    registry.register_section(
      :primary_navigation,
      label: "Primary navigation",
      group_keys: %i[workspace_primary]
    )
  end
end
