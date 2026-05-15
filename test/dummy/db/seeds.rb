# Create demo users
admin = User.find_or_create_by!(email: "admin@admin.com") do |user|
  user.password = "Password"
  user.password_confirmation = "Password"
end

producer = User.find_or_create_by!(email: "producer@admin.com") do |user|
  user.password = "Password"
  user.password_confirmation = "Password"
end

def ensure_workspace_tree(name:, folder_name:, page_titles:)
  workspace = Workspace.find_or_create_by!(name: name)
  root_recording = RecordingStudio::Recording.unscoped.find_or_create_by!(
    recordable: workspace,
    parent_recording_id: nil
  )

  folder = Folder.find_or_create_by!(name: folder_name)
  folder_recording = RecordingStudio::Recording.unscoped.find_or_create_by!(
    root_recording_id: root_recording.id,
    parent_recording_id: root_recording.id,
    recordable: folder
  )

  page_titles.each do |title|
    page = Page.find_or_create_by!(title: title)
    RecordingStudio::Recording.unscoped.find_or_create_by!(
      root_recording_id: root_recording.id,
      parent_recording_id: folder_recording.id,
      recordable: page
    )
  end

  [workspace, root_recording]
end

def ensure_access(actor:, role:, root_recording:)
  Current.actor = actor
  access = RecordingStudio::Access.find_or_create_by!(actor: actor, role: role)
  RecordingStudio::Recording.unscoped.find_or_create_by!(
    root_recording_id: root_recording.id,
    parent_recording_id: root_recording.id,
    recordable: access
  )
end

studio_workspace, studio_root = ensure_workspace_tree(
  name: "Studio North",
  folder_name: "Library",
  page_titles: ["Style Guide", "Mix Notes"]
)
client_workspace, client_root = ensure_workspace_tree(
  name: "Client Vault",
  folder_name: "Library",
  page_titles: ["Release Checklist", "Client Brief"]
)

ensure_access(actor: admin, role: :admin, root_recording: studio_root)
ensure_access(actor: admin, role: :view, root_recording: client_root)
ensure_access(actor: producer, role: :edit, root_recording: client_root)

puts "Seeded: admin@admin.com / Password (Studio North admin, Client Vault viewer)"
puts "Seeded: producer@admin.com / Password (Client Vault editor)"
puts "Seeded: Workspace '#{studio_workspace.name}' with root recording ##{studio_root.id}"
puts "Seeded: Workspace '#{client_workspace.name}' with root recording ##{client_root.id}"
