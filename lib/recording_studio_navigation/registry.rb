# frozen_string_literal: true

module RecordingStudioNavigation
  class Registry
    class DuplicateKeyError < StandardError; end

    ResolvedGroup = Struct.new(:key, :label, :items, :icon, :description, keyword_init: true)
    ResolvedItem = Struct.new(
      :key,
      :label,
      :href,
      :icon,
      :description,
      :keywords,
      :quick_link,
      :searchable,
      :current,
      :metadata,
      keyword_init: true
    ) do
      def quick_link?
        !!quick_link
      end

      def searchable?
        !!searchable
      end

      def current?
        !!current
      end

      def search_document
        [label, description, *Array(keywords)].join(" ").downcase
      end
    end
    ResolvedSection = Struct.new(:key, :label, :groups, :description, keyword_init: true)

    attr_reader :contributions, :groups, :items, :sections

    def initialize
      @items = {}
      @groups = {}
      @sections = {}
      @contributions = {}
    end

    def draw
      yield self if block_given?
      self
    end

    def register_item(key, replace: false, **attributes)
      store_definition(items, key, NavigationItem.new(key: key, **attributes), replace: replace)
    end

    def override_item(key, **attributes)
      register_item(key, replace: true, **attributes)
    end

    def register_group(key, replace: false, **attributes)
      store_definition(groups, key, NavigationGroup.new(key: key, **attributes), replace: replace)
    end

    def override_group(key, **attributes)
      register_group(key, replace: true, **attributes)
    end

    def register_section(key, replace: false, **attributes)
      store_definition(sections, key, NavigationSection.new(key: key, **attributes), replace: replace)
    end

    def override_section(key, **attributes)
      register_section(key, replace: true, **attributes)
    end

    def contribute_to_group(key:, group_key:, item_keys:, replace: false, **attributes)
      register_contribution(
        key: key,
        target_type: :group,
        target_key: group_key,
        entry_keys: item_keys,
        replace: replace,
        **attributes
      )
    end

    def contribute_to_section(key:, section_key:, group_keys:, replace: false, **attributes)
      register_contribution(
        key: key,
        target_type: :section,
        target_key: section_key,
        entry_keys: group_keys,
        replace: replace,
        **attributes
      )
    end

    def override_contribution(key:, **attributes)
      register_contribution(key: key, replace: true, **attributes)
    end

    def fetch_item(item_or_key)
      key = item_or_key.is_a?(NavigationItem) ? item_or_key.key : item_or_key.to_sym
      items.fetch(key)
    end

    def sections_for(context)
      sections.values.filter_map do |section|
        next unless section.visible?(context)

        build_section(section, context)
      end
    end

    def quick_links(context, query: nil, limit: nil)
      results = sections_for(context).flat_map(&:groups).flat_map(&:items).select do |item|
        item.quick_link? && item.searchable?
      end.uniq { |item| item.key }

      if query.present?
        needle = query.to_s.downcase.strip
        results = results.select { |item| item.search_document.include?(needle) }
      end

      limit.present? ? results.first(limit) : results
    end

    def item_keys
      items.keys
    end

    def group_keys
      groups.keys
    end

    def section_keys
      sections.keys
    end

    def contribution_keys
      contributions.keys
    end

    private

    def build_section(section, context)
      resolved_groups = group_keys_for(section, context).filter_map do |group_key|
        group = groups.fetch(group_key)
        next unless group.visible?(context)

        build_group(group, context)
      end

      return if resolved_groups.empty?

      ResolvedSection.new(
        key: section.key,
        label: section.label,
        groups: resolved_groups,
        description: section.description
      )
    end

    def build_group(group, context)
      resolved_items = item_keys_for(group, context).filter_map do |item_key|
        unless items.key?(item_key)
          raise KeyError, "Unknown navigation item #{item_key.inspect} referenced by group #{group.key.inspect}"
        end

        next unless context.visible?(item_key)

        context.resolve_item(item_key)
      end

      return if resolved_items.empty?

      ResolvedGroup.new(
        key: group.key,
        label: group.label,
        items: resolved_items,
        icon: group.icon,
        description: group.description
      )
    end

    def register_contribution(key:, replace:, **attributes)
      contribution = Contribution.new(key: key, **attributes)
      store_definition(contributions, key, contribution, replace: replace)
    end

    def group_keys_for(section, context)
      apply_contributions(section.group_keys, :section, section.key, context)
    end

    def item_keys_for(group, context)
      apply_contributions(group.item_keys, :group, group.key, context)
    end

    def apply_contributions(base_keys, target_type, target_key, context)
      matching_contributions = contributions.values.select do |contribution|
        contribution.target_type == target_type &&
          contribution.target_key == target_key &&
          contribution.visible?(context)
      end

      matching_contributions.reduce(base_keys.dup) do |keys, contribution|
        contribution.apply(keys)
      end
    end

    def store_definition(store, key, definition, replace:)
      normalized_key = key.to_sym

      if store.key?(normalized_key) && !replace
        raise DuplicateKeyError, "#{normalized_key} is already registered"
      end

      store[normalized_key] = definition
    end
  end
end
