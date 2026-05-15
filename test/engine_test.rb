# frozen_string_literal: true

require "test_helper"

class EngineTest < Minitest::Test
  def test_engine_exists_and_is_isolated
    assert_kind_of Class, RecordingStudioNavigation::Engine
    assert_equal RecordingStudioNavigation, RecordingStudioNavigation::Engine.railtie_namespace
  end

  def test_engine_view_uses_flatpack_components
    view_path = File.expand_path("../app/views/recording_studio_navigation/home/index.html.erb", __dir__)
    view_source = File.read(view_path)

    assert_includes view_source, "FlatPack::PageTitle::Component"
    assert_includes view_source, "FlatPack::Card::Component"
    assert_includes view_source, "Registry-backed"
  end
end
