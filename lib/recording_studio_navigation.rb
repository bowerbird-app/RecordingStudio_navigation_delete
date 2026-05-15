# frozen_string_literal: true

require "recording_studio_navigation/version"
require "recording_studio_navigation/registry"
require "recording_studio_navigation/configuration"
require "recording_studio_navigation/authorization"
require "recording_studio_navigation/context"
require "recording_studio_navigation/navigation_item"
require "recording_studio_navigation/navigation_group"
require "recording_studio_navigation/navigation_section"
require "recording_studio_navigation/contribution"
require "recording_studio_navigation/tree_link"
require "recording_studio_navigation/navigation_helper"
require "recording_studio_navigation/engine"

module RecordingStudioNavigation
  class << self
    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield(configuration) if block_given?
    end

    def reset!
      @configuration = Configuration.new
    end

    def registry
      configuration.registry
    end

    def register(&block)
      configuration.register(&block)
    end

    def register_item(...)
      registry.register_item(...)
    end

    def override_item(...)
      registry.override_item(...)
    end

    def register_group(...)
      registry.register_group(...)
    end

    def override_group(...)
      registry.override_group(...)
    end

    def register_section(...)
      registry.register_section(...)
    end

    def override_section(...)
      registry.override_section(...)
    end

    def contribute_to_group(...)
      registry.contribute_to_group(...)
    end

    def contribute_to_section(...)
      registry.contribute_to_section(...)
    end

    def override_contribution(...)
      registry.override_contribution(...)
    end

    def context(actor:, current_root:, helpers: nil, registry: self.registry)
      Context.new(actor: actor, current_root: current_root, helpers: helpers, registry: registry)
    end

    def call(callable, **kwargs)
      return callable unless callable.respond_to?(:call)

      parameters = callable.parameters

      if parameters.empty?
        callable.call
      elsif parameters.any? { |type, _name| %i[key keyreq keyrest].include?(type) }
        named_arguments = if parameters.any? { |type, _name| type == :keyrest }
          kwargs
        else
          parameter_names = parameters.filter_map { |type, name| name if %i[key keyreq].include?(type) }
          kwargs.slice(*parameter_names)
        end

        callable.call(**named_arguments)
      else
        positional_arguments = parameters.map do |_type, name|
          name ? kwargs[name] : kwargs[:context]
        end

        callable.call(*positional_arguments)
      end
    end

    def evaluate_condition(condition, context:, default: true)
      return default if condition.nil?

      if condition.respond_to?(:call)
        !!call(condition, context: context)
      else
        !!condition
      end
    end
  end
end
