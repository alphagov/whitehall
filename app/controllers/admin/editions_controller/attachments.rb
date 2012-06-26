module Admin::EditionsController::Attachments
  extend ActiveSupport::Concern

  included do
    before_filter :build_edition_attachment, only: [:new, :edit]
  end

  def build_edition_dependencies
    super
    build_edition_attachment
  end

  def build_edition_attachment
    unless @edition.edition_attachments.any?(&:new_record?)
      edition_attachment = @edition.edition_attachments.build
      edition_attachment.build_attachment
    end
  end
end
