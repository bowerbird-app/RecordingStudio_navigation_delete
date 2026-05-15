# frozen_string_literal: true

module RecordingStudioNavigation
  class NavigationItem
    attr_reader :description, :icon, :key, :keywords, :label, :metadata

    def initialize(
      key:,
      label:,
      href: nil,
      resolver: nil,
      icon: nil,
      description: nil,
      keywords: [],
      quick_link: false,
      searchable: nil,
      visible: nil,
      current: nil,
      metadata: {}
    )
      @key = key.to_sym
      @label = label
      @resolver = resolver || href
      @icon = icon
      @description = description
      @keywords = Array(keywords).flatten.compact
      @quick_link = quick_link
      @searchable = searchable
      @visible = visible
      @current = current
      @metadata = metadata
    end

    def resolve(context)
      resolved_target = resolve_target(context)
      return if resolved_target.blank?

      href = resolved_target.is_a?(Hash) ? resolved_target.fetch(:href, nil) : resolved_target
      return if href.blank?

      Registry::ResolvedItem.new(
        key: key,
        label: label,
        href: href,
        icon: icon,
        description: description,
        keywords: keywords,
        quick_link: quick_link?,
        searchable: searchable?,
        current: current?(context),
        metadata: metadata.merge(extract_metadata(resolved_target))
      )
    end

    def visible?(context)
      return false unless RecordingStudioNavigation.evaluate_condition(@visible, context: context)

      context.resolve_item(self).present?
    end

    def quick_link?
      !!@quick_link
    end

    def searchable?
      @searchable.nil? ? quick_link? : !!@searchable
    end

    private

    def current?(context)
      RecordingStudioNavigation.evaluate_condition(@current, context: context, default: false)
    end

    def resolve_target(context)
      if @resolver.respond_to?(:resolve)
        @resolver.resolve(context)
      elsif @resolver.respond_to?(:call)
        RecordingStudioNavigation.call(@resolver, context: context)
      else
        @resolver
      end
    end

    def extract_metadata(resolved_target)
      return {} unless resolved_target.is_a?(Hash)

      resolved_target.except(:href)
    end
  end
end
