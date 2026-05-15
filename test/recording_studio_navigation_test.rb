# frozen_string_literal: true

require "test_helper"

class RecordingStudioNavigationTest < Minitest::Test
  def setup
    RecordingStudioNavigation.reset!
  end

  def test_version_exists
    refute_nil RecordingStudioNavigation::VERSION
  end

  def test_module_registration_api_delegates_to_registry
    RecordingStudioNavigation.register_item(:workspace_home, label: "Home", href: "/workspaces/1")

    assert_equal %i[workspace_home], RecordingStudioNavigation.registry.item_keys
  end

  def test_public_registration_api_composes_sections_and_quick_links
    RecordingStudioNavigation.register_item(:workspace_home, label: "Home", href: "/workspaces/1", quick_link: true)
    RecordingStudioNavigation.register_group(:workspace_primary, label: "Workspace", item_keys: %i[workspace_home])
    RecordingStudioNavigation.register_section(:workspace_navigation, label: "Navigation", group_keys: %i[workspace_primary])

    context = RecordingStudioNavigation.context(actor: nil, current_root: nil)

    assert_equal ["Navigation"], context.sections.map(&:label)
    assert_equal ["Home"], context.quick_links.map(&:label)
  end

  def test_call_supports_keyword_and_context_only_callables
    keyword_result = RecordingStudioNavigation.call(->(context:) { context }, context: :value)
    positional_result = RecordingStudioNavigation.call(->(context) { context }, context: :value)

    assert_equal :value, keyword_result
    assert_equal :value, positional_result
  end
end
