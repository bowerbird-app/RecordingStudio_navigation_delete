# frozen_string_literal: true

module RecordingStudioNavigation
  class Configuration
    attr_reader :registry

    def initialize
      reset_registry!
    end

    def register(&block)
      registry.draw(&block)
    end

    def reset_registry!
      @registry = Registry.new
    end

    def to_h
      {
        items: registry.item_keys,
        groups: registry.group_keys,
        sections: registry.section_keys,
        contributions: registry.contribution_keys
      }
    end
  end
end
