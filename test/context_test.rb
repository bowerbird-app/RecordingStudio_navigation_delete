# frozen_string_literal: true

require "test_helper"

class ContextTest < Minitest::Test
  FakeRecording = Struct.new(:id, :recordable_type, :recordable, keyword_init: true)
  FakeRecordable = Struct.new(:name, :title, keyword_init: true)

  def setup
    @registry = RecordingStudioNavigation::Registry.new
  end

  def test_context_memoizes_resolution_and_visibility
    calls = 0
    @registry.register_item(
      :overview,
      label: "Overview",
      href: lambda do |context:|
        calls += 1
        "/roots/#{context.current_root}"
      end
    )

    context = RecordingStudioNavigation::Context.new(actor: nil, current_root: "root-1", registry: @registry)

    2.times { context.visible?(:overview) }
    2.times { context.resolve_item(:overview) }

    assert_equal 1, calls
  end

  def test_tree_link_resolves_against_recordings_for_current_root
    helper = Struct.new(:unused, keyword_init: true) do
      def workspace_recording_path(_workspace, recording)
        "/recordings/#{recording.id}"
      end
    end.new

    matching_recording = FakeRecording.new(
      id: "recording-1",
      recordable_type: "Page",
      recordable: FakeRecordable.new(title: "Style Guide")
    )
    other_recording = FakeRecording.new(
      id: "recording-2",
      recordable_type: "Page",
      recordable: FakeRecordable.new(title: "Client Brief")
    )

    tree_link = RecordingStudioNavigation::TreeLink.new(
      recordable_type: "Page",
      match: { title: "Style Guide" },
      href: ->(context:, recording:, **) { context.helpers.workspace_recording_path(nil, recording) }
    )

    @registry.register_item(:style_guide, label: "Style guide", resolver: tree_link)

    context = RecordingStudioNavigation::Context.new(actor: nil, current_root: nil, helpers: helper, registry: @registry)
    context.stub(:recordings_for_root, [other_recording, matching_recording]) do
      resolved_item = context.resolve_item(:style_guide)

      assert_equal "/recordings/recording-1", resolved_item.href
      assert context.visible?(:style_guide)
    end
  end

  def test_access_helpers_delegate_to_authorization_roles
    context = RecordingStudioNavigation::Context.new(actor: :actor, current_root: :root, registry: @registry)

    RecordingStudioNavigation::Authorization.stub(:role_for, :edit) do
      assert context.access_at_least?(:view)
      refute context.access_at_least?(:admin)
    end
  end
end
