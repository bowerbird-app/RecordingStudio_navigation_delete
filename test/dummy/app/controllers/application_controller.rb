class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  layout :application_layout

  before_action :authenticate_user!
  before_action :set_current_actor
  before_action :load_navigation_state

  helper_method(
    :available_workspaces,
    :current_root_recording,
    :current_workspace,
    :current_workspace_entry,
    :navigation_context,
    :quick_links,
    :visible_navigation_items,
    :tree_backed_navigation_items
  )

  private

  def application_layout
    devise_controller? ? "application" : "flat_pack_sidebar"
  end

  def set_current_actor
    Current.actor = current_user
  end

  def load_navigation_state
    @available_workspaces = load_available_workspaces
    @current_workspace_entry = select_current_workspace(@available_workspaces)
    @navigation_context = RecordingStudioNavigation.context(
      actor: current_user,
      current_root: @current_workspace_entry&.fetch(:root_recording, nil),
      helpers: helpers
    )
    @visible_navigation_items = if @navigation_context.root_recording.present?
      @navigation_context.sections.flat_map(&:groups).flat_map(&:items)
    else
      []
    end
    @tree_backed_navigation_items = @visible_navigation_items.select do |item|
      item.metadata[:recording].present?
    end.uniq { |item| item.metadata[:recording].id }
    @quick_links = if params[:q].present? && @navigation_context.root_recording.present?
      @navigation_context.quick_links(query: params[:q], limit: 8)
    else
      []
    end
  end

  def available_workspaces
    @available_workspaces
  end

  def current_workspace_entry
    @current_workspace_entry
  end

  def current_workspace
    current_workspace_entry&.fetch(:workspace, nil)
  end

  def current_root_recording
    current_workspace_entry&.fetch(:root_recording, nil)
  end

  def navigation_context
    @navigation_context
  end

  def quick_links
    @quick_links
  end

  def visible_navigation_items
    @visible_navigation_items
  end

  def tree_backed_navigation_items
    @tree_backed_navigation_items
  end

  def ensure_current_workspace!
    raise ActiveRecord::RecordNotFound if current_workspace.blank? || current_root_recording.blank?
  end

  def require_admin_workspace_access!
    raise ActiveRecord::RecordNotFound unless navigation_context.access_at_least?(:admin)
  end

  def workspace_parameter
    params[:workspace_id] || (controller_name == "workspaces" ? params[:id] : nil)
  end

  def select_current_workspace(workspaces)
    requested_workspace_id = workspace_parameter

    if requested_workspace_id.present?
      workspaces.find do |entry|
        entry.fetch(:workspace).id == requested_workspace_id
      end
    else
      workspaces.first
    end
  end

  def load_available_workspaces
    RecordingStudio::Recording.includes(:recordable)
      .where(parent_recording_id: nil, recordable_type: "Workspace", trashed_at: nil)
      .reorder(:created_at, :id)
      .filter_map do |root_recording|
        role = RecordingStudioNavigation::Authorization.role_for(actor: current_user, root: root_recording)
        next if role.blank? || root_recording.recordable.blank?

        {
          workspace: root_recording.recordable,
          root_recording: root_recording,
          role: role
        }
      end
  end
end
