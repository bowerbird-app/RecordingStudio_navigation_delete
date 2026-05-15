class WorkspaceAccessesController < ApplicationController
  before_action :ensure_current_workspace!
  before_action :require_admin_workspace_access!

  def show
    access_ids = RecordingStudio::Recording.where(
      root_recording_id: current_root_recording.id,
      recordable_type: "RecordingStudio::Access",
      trashed_at: nil
    ).pluck(:recordable_id)

    @accesses = RecordingStudio::Access.where(id: access_ids).sort_by do |access|
      [
        -RecordingStudioNavigation::Authorization.role_weight(access.role),
        access.actor.respond_to?(:email) ? access.actor.email.to_s : access.actor_id.to_s
      ]
    end
  end
end
