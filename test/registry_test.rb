# frozen_string_literal: true

require "test_helper"

class RegistryTest < Minitest::Test
  def setup
    @registry = RecordingStudioNavigation::Registry.new
    @context = RecordingStudioNavigation::Context.new(actor: nil, current_root: nil, registry: @registry)
  end

  def test_sections_compose_groups_items_and_contributions
    @registry.register_item(:overview, label: "Overview", href: "/workspaces/1", quick_link: true)
    @registry.register_item(:library, label: "Library", href: "/workspaces/1/recordings/1")
    @registry.register_item(:access, label: "Access", href: "/workspaces/1/access", quick_link: true)
    @registry.register_group(:primary, label: "Primary", item_keys: %i[overview])
    @registry.register_group(:admin, label: "Admin", item_keys: [])
    @registry.register_section(:workspace, label: "Workspace", group_keys: %i[primary])
    @registry.contribute_to_group(key: :primary_library, group_key: :primary, item_keys: %i[library])
    @registry.contribute_to_group(key: :admin_access, group_key: :admin, item_keys: %i[access])
    @registry.contribute_to_section(key: :workspace_admin, section_key: :workspace, group_keys: %i[admin])

    sections = @registry.sections_for(@context)

    assert_equal ["Workspace"], sections.map(&:label)
    assert_equal ["Primary", "Admin"], sections.first.groups.map(&:label)
    assert_equal ["Overview", "Library"], sections.first.groups.first.items.map(&:label)
    assert_equal ["Access"], sections.first.groups.last.items.map(&:label)
  end

  def test_override_replaces_existing_item_definition_by_key
    @registry.register_item(:overview, label: "Overview", href: "/old")
    @registry.register_group(:primary, label: "Primary", item_keys: %i[overview])
    @registry.register_section(:workspace, label: "Workspace", group_keys: %i[primary])

    @registry.override_item(:overview, label: "Workspace overview", href: "/new")

    resolved_item = @registry.sections_for(@context).first.groups.first.items.first

    assert_equal "Workspace overview", resolved_item.label
    assert_equal "/new", resolved_item.href
  end

  def test_quick_links_require_explicit_opt_in_and_support_filtering
    @registry.register_item(:overview, label: "Overview", href: "/workspaces/1", quick_link: true)
    @registry.register_item(:library, label: "Library", href: "/workspaces/1/recordings/1")
    @registry.register_group(:primary, label: "Primary", item_keys: %i[overview library])
    @registry.register_section(:workspace, label: "Workspace", group_keys: %i[primary])

    assert_equal ["Overview"], @registry.quick_links(@context).map(&:label)
    assert_equal ["Overview"], @registry.quick_links(@context, query: "over").map(&:label)
    assert_empty @registry.quick_links(@context, query: "library")
  end

  def test_duplicate_registration_requires_override
    @registry.register_item(:overview, label: "Overview", href: "/workspaces/1")

    assert_raises(RecordingStudioNavigation::Registry::DuplicateKeyError) do
      @registry.register_item(:overview, label: "Duplicate", href: "/workspaces/2")
    end
  end

  def test_boolean_visibility_values_are_respected
    @registry.register_item(:hidden, label: "Hidden", href: "/hidden", visible: false)
    @registry.register_group(:primary, label: "Primary", item_keys: %i[hidden])
    @registry.register_section(:workspace, label: "Workspace", group_keys: %i[primary])

    assert_empty @registry.sections_for(@context)
  end

  def test_missing_item_reference_raises_consistently
    @registry.register_group(:primary, label: "Primary", item_keys: %i[missing])
    @registry.register_section(:workspace, label: "Workspace", group_keys: %i[primary])

    error = assert_raises(KeyError) do
      @registry.sections_for(@context)
    end

    assert_includes error.message, "Unknown navigation item"
  end
end
