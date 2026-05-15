# frozen_string_literal: true

require "test_helper"

class ConfigurationTest < Minitest::Test
  def setup
    @configuration = RecordingStudioNavigation::Configuration.new
  end

  def test_register_yields_registry
    yielded_registry = nil

    @configuration.register do |registry|
      yielded_registry = registry
      registry.register_item(:workspace_home, label: "Home", href: "/workspaces/1")
    end

    assert_same @configuration.registry, yielded_registry
    assert_equal %i[workspace_home], @configuration.to_h.fetch(:items)
  end

  def test_reset_registry_clears_existing_definitions
    @configuration.registry.register_item(:workspace_home, label: "Home", href: "/workspaces/1")

    @configuration.reset_registry!

    assert_empty @configuration.registry.item_keys
  end
end
