class Admin::ConsultationResponsesController < Admin::EditionsController
  before_filter :build_edition_attachment, only: [:new, :edit]

  private

  def edition_class
    ConsultationResponse
  end

  def build_edition_attachment
    unless @edition.edition_attachments.any?(&:new_record?)
      edition_attachment = @edition.edition_attachments.build
      edition_attachment.build_attachment
    end
  end
end
