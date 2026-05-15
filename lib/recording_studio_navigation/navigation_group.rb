# frozen_string_literal: true

module RecordingStudioNavigation
  class NavigationGroup
    attr_reader :description, :icon, :item_keys, :key, :label

    def initialize(key:, label:, item_keys:, icon: nil, description: nil, visible: nil)
      @key = key.to_sym
      @label = label
      @item_keys = Array(item_keys).flatten.compact.map(&:to_sym)
      @icon = icon
      @description = description
      @visible = visible
    end

    def visible?(context)
      RecordingStudioNavigation.evaluate_condition(@visible, context: context)
    end
  end
end
