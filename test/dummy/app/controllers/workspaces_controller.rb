class WorkspacesController < ApplicationController
  before_action :ensure_current_workspace!

  def index
    redirect_to workspace_path(current_workspace)
  end

  def show
    @sections = navigation_context.sections
    @tree_backed_items = tree_backed_navigation_items
  end
end
