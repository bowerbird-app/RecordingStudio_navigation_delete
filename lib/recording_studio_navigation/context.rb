# frozen_string_literal: true

module RecordingStudioNavigation
  class Context
    attr_reader :actor, :current_root, :helpers, :registry

    def initialize(actor:, current_root:, helpers: nil, registry: RecordingStudioNavigation.registry)
      @actor = actor
      @current_root = current_root
      @helpers = helpers
      @registry = registry
      @memoized_visibility = {}
      @memoized_resolution = {}
    end

    def role
      @role ||= Authorization.role_for(actor: actor, root: root_recording)
    end

    def access_at_least?(expected_role)
      Authorization.role_at_least?(role, expected_role)
    end

    def root_recording
      @root_recording ||= if current_root.blank?
        nil
      elsif recording?(current_root)
        current_root
      else
        find_root_recording_for(current_root)
      end
    end

    def root_recordable
      @root_recordable ||= root_recording&.recordable || current_root
    end

    def recordings_for_root
      @recordings_for_root ||= if root_recording.blank?
        []
      elsif !defined?(RecordingStudio::Recording)
        [root_recording]
      else
        descendants = RecordingStudio::Recording.includes(:recordable)
          .where(root_recording_id: root_recording.id, trashed_at: nil)
          .reorder(:created_at, :id)
          .to_a

        [root_recording, *descendants]
      end
    end

    def visible?(item_or_key)
      item = registry.fetch_item(item_or_key)
      @memoized_visibility.fetch(item.key) do
        @memoized_visibility[item.key] = item.visible?(self)
      end
    end

    def resolve_item(item_or_key)
      item = registry.fetch_item(item_or_key)
      @memoized_resolution.fetch(item.key) do
        @memoized_resolution[item.key] = item.resolve(self)
      end
    end

    def sections
      registry.sections_for(self)
    end

    def quick_links(query: nil, limit: nil)
      registry.quick_links(self, query: query, limit: limit)
    end

    private

    def recording?(value)
      defined?(RecordingStudio::Recording) && value.is_a?(RecordingStudio::Recording)
    end

    def find_root_recording_for(recordable)
      return unless defined?(RecordingStudio::Recording)

      RecordingStudio::Recording.includes(:recordable).find_by(
        recordable: recordable,
        parent_recording_id: nil,
        trashed_at: nil
      )
    rescue StandardError
      nil
    end
  end
end
