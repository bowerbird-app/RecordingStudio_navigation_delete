# frozen_string_literal: true

module RecordingStudioNavigation
  module NavigationHelper
    def recording_studio_navigation_context(
      current_root:,
      actor: (defined?(Current) ? Current.try(:actor) : nil)
    )
      RecordingStudioNavigation.context(
        actor: actor,
        current_root: current_root,
        helpers: self
      )
    end
  end
end
