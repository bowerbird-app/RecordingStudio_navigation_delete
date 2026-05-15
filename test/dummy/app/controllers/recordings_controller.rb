class RecordingsController < ApplicationController
  before_action :ensure_current_workspace!

  helper_method :recording_label, :recording_summary

  def show
    @resolved_item = tree_backed_navigation_items.find do |item|
      item.metadata[:recording].id == params[:id]
    end
    @recording = @resolved_item&.metadata&.fetch(:recording, nil)

    raise ActiveRecord::RecordNotFound if @recording.blank?
  end

  private

  def recording_label
    @recording.recordable_type.demodulize.underscore.humanize
  end

  def recording_summary
    recordable = @recording.recordable

    %i[name title email].each do |attribute|
      return recordable.public_send(attribute) if recordable.respond_to?(attribute) &&
        recordable.public_send(attribute).present?
    end

    "##{recordable.id}"
  end
end
