# frozen_string_literal: true

module RecordingStudioNavigation
  class TreeLink
    def initialize(recordable_type:, href:, match: nil)
      @recordable_type = normalize_recordable_type(recordable_type)
      @href = href
      @match = match
    end

    def resolve(context)
      recording = find_recording(context)
      return if recording.blank?

      href = RecordingStudioNavigation.call(
        @href,
        context: context,
        recording: recording,
        recordable: recording.recordable
      )

      return if href.blank?

      {
        href: href,
        recording: recording,
        recordable: recording.recordable
      }
    end

    private

    def find_recording(context)
      context.recordings_for_root.find do |recording|
        next false unless recording.recordable_type == @recordable_type

        matches?(recording, context)
      end
    end

    def matches?(recording, context)
      case @match
      when nil
        true
      when Hash
        @match.all? do |attribute, expected_value|
          recording.recordable.respond_to?(attribute) &&
            recording.recordable.public_send(attribute) == expected_value
        end
      else
        RecordingStudioNavigation.call(
          @match,
          context: context,
          recording: recording,
          recordable: recording.recordable
        )
      end
    end

    def normalize_recordable_type(recordable_type)
      recordable_type.is_a?(Class) ? recordable_type.name : recordable_type.to_s
    end
  end
end
