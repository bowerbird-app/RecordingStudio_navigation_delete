# frozen_string_literal: true

module RecordingStudioNavigation
  class Engine < ::Rails::Engine
    isolate_namespace RecordingStudioNavigation

    initializer "recording_studio_navigation.helpers" do
      ActiveSupport.on_load(:action_controller_base) do
        helper RecordingStudioNavigation::NavigationHelper
      end

      ActiveSupport.on_load(:action_view) do
        include RecordingStudioNavigation::NavigationHelper
      end
    end
  end
end
