# frozen_string_literal: true

module RecordingStudioNavigation
  class NavigationSection
    attr_reader :description, :group_keys, :key, :label

    def initialize(key:, label:, group_keys:, description: nil, visible: nil)
      @key = key.to_sym
      @label = label
      @group_keys = Array(group_keys).flatten.compact.map(&:to_sym)
      @description = description
      @visible = visible
    end

    def visible?(context)
      RecordingStudioNavigation.evaluate_condition(@visible, context: context)
    end
  end
end
