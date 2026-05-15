Rails.application.routes.draw do
  devise_for :users

  get "/recording_studio", to: redirect("/"), as: nil
  mount RecordingStudio::Engine, at: "/recording_studio"

  resources :workspaces, only: %i[index show] do
    get :access_overview, to: "workspace_accesses#show"
    resources :recordings, only: :show
  end

  get "up" => "rails/health#show", as: :rails_health_check

  root "home#index"
end
