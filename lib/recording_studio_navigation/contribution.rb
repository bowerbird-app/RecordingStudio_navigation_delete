# frozen_string_literal: true

module RecordingStudioNavigation
  class Contribution
    VALID_POSITIONS = %i[append prepend].freeze

    attr_reader :entry_keys, :key, :position, :target_key, :target_type

    def initialize(key:, target_type:, target_key:, entry_keys:, position: :append, before: nil, after: nil, visible: nil)
      @key = key.to_sym
      @target_type = target_type.to_sym
      @target_key = target_key.to_sym
      @entry_keys = Array(entry_keys).flatten.compact.map(&:to_sym)
      @position = normalize_position(position)
      @before = before&.to_sym
      @after = after&.to_sym
      @visible = visible
    end

    def apply(keys)
      return keys if entry_keys.empty?

      result = keys.dup
      insertion_index = preferred_insertion_index(result)

      if insertion_index
        result.insert(insertion_index, *entry_keys)
      elsif position == :prepend
        result.unshift(*entry_keys)
      else
        result.concat(entry_keys)
      end

      result.uniq
    end

    def visible?(context)
      RecordingStudioNavigation.evaluate_condition(@visible, context: context)
    end

    private

    def normalize_position(position)
      normalized = position.to_sym
      return normalized if VALID_POSITIONS.include?(normalized)

      :append
    end

    def preferred_insertion_index(keys)
      if @before.present? && keys.include?(@before)
        keys.index(@before)
      elsif @after.present? && keys.include?(@after)
        keys.index(@after) + 1
      end
    end
  end
end
