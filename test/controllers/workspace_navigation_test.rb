# frozen_string_literal: true

ENV["RAILS_ENV"] = "test"
require_relative "../test_helper"
require_relative "../dummy/config/environment"

require "devise/test/integration_helpers"
require "rails/test_help"
require "securerandom"

class WorkspaceNavigationTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  TEST_PASSWORD = "DocsTestPassword!2026"

  setup do
    token = SecureRandom.hex(4)
    @hidden_style_guide_title = "Style Guide"
    @release_checklist_title = "Release Checklist"

    @admin = create_user("admin-#{token}@example.com")
    @producer = create_user("producer-#{token}@example.com")

    @studio_workspace, @studio_root = create_workspace_tree(
      name: "Studio North #{token}",
      page_titles: ["Style Guide", "Mix Notes #{token}"]
    )
    @client_workspace, @client_root = create_workspace_tree(
      name: "Client Vault #{token}",
      page_titles: [@hidden_style_guide_title, @release_checklist_title, "Client Brief #{token}"]
    )

    grant_access(actor: @admin, role: :admin, root_recording: @studio_root)
    grant_access(actor: @admin, role: :view, root_recording: @client_root)
    grant_access(actor: @producer, role: :edit, root_recording: @client_root)
  end

  test "admin sidebar and quick links reflect studio workspace items" do
    sign_in @admin

    get workspace_path(@studio_workspace), params: { q: "style" }

    assert_response :success
    assert_includes response.body, "Studio North"
    assert_includes response.body, "Library"
    assert_includes response.body, "Style guide"
    assert_includes response.body, "Access overview"
    refute_includes response.body, "Release checklist"
  end

  test "viewer sees client workspace links without edit or admin only items" do
    sign_in @admin

    get workspace_path(@client_workspace), params: { q: "release" }

    assert_response :success
    assert_includes response.body, "Client Vault"
    assert_includes response.body, "Release checklist"
    assert_includes response.body, "Library"
    refute_includes response.body, "Style guide"
    refute_includes response.body, "Access overview"
  end

  test "editor can navigate to tree backed page in accessible workspace" do
    sign_in @producer

    release_page = Page.find_by!(title: @release_checklist_title)
    release_recording = RecordingStudio::Recording.find_by!(
      root_recording_id: @client_root.id,
      recordable_type: "Page",
      recordable_id: release_page.id
    )

    get workspace_recording_path(@client_workspace, release_recording)

    assert_response :success
    assert_includes response.body, "Page: Release Checklist"
    refute_includes response.body, "Access overview"
  end

  test "non admin cannot open workspace access overview directly" do
    sign_in @producer

    get workspace_access_overview_path(@client_workspace)

    assert_response :not_found
  end

  test "tree backed pages not visible in navigation cannot be opened directly" do
    sign_in @admin

    hidden_recording = RecordingStudio::Recording.includes(:recordable)
      .where(root_recording_id: @client_root.id, recordable_type: "Page")
      .detect { |recording| recording.recordable.title == @hidden_style_guide_title }

    assert hidden_recording.present?
    get workspace_recording_path(@client_workspace, hidden_recording)

    assert_response :not_found
  end

  private

  def create_user(email)
    User.create!(
      email: email,
      password: TEST_PASSWORD,
      password_confirmation: TEST_PASSWORD
    )
  end

  def create_workspace_tree(name:, page_titles:)
    workspace = Workspace.create!(name: name)
    root_recording = RecordingStudio::Recording.create!(recordable: workspace)
    folder = Folder.create!(name: "Library")
    folder_recording = RecordingStudio::Recording.create!(
      root_recording_id: root_recording.id,
      parent_recording_id: root_recording.id,
      recordable: folder
    )

    page_titles.each do |title|
      page = Page.create!(title: title)
      RecordingStudio::Recording.create!(
        root_recording_id: root_recording.id,
        parent_recording_id: folder_recording.id,
        recordable: page
      )
    end

    [workspace, root_recording]
  end

  def grant_access(actor:, role:, root_recording:)
    Current.actor = actor
    access = RecordingStudio::Access.create!(actor: actor, role: role)
    RecordingStudio::Recording.create!(
      root_recording_id: root_recording.id,
      parent_recording_id: root_recording.id,
      recordable: access
    )
  end
end
