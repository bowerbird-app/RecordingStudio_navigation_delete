# frozen_string_literal: true

module RecordingStudioNavigation
  module Authorization
    module_function

    def role_for(actor:, root:)
      return if actor.blank? || root.blank?
      return unless defined?(RecordingStudio::Access) && defined?(RecordingStudio::Recording)

      access_ids = RecordingStudio::Recording.where(
        root_recording_id: root.id,
        parent_recording_id: root.id,
        recordable_type: "RecordingStudio::Access",
        trashed_at: nil
      ).pluck(:recordable_id)

      return if access_ids.empty?

      accesses = RecordingStudio::Access.where(id: access_ids, actor: actor).to_a
      highest_access = accesses.max_by { |access| role_weight(access.role) }

      highest_access&.role&.to_sym
    rescue StandardError
      nil
    end

    def role_at_least?(actual_role, expected_role)
      role_weight(actual_role) >= role_weight(expected_role)
    end

    def role_weight(role)
      return -1 if role.blank?

      roles = if defined?(RecordingStudio::Access) && RecordingStudio::Access.respond_to?(:roles)
        RecordingStudio::Access.roles
      else
        {}
      end

      roles.fetch(role.to_s, -1)
    end
  end
end
