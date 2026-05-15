class HomeController < ApplicationController
  def index
    if current_workspace.present?
      redirect_to workspace_path(current_workspace)
    else
      render :index
    end
  end
end
