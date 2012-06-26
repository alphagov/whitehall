class Admin::SpecialistGuidesController < Admin::EditionsController
  before_filter :build_edition_attachment, only: [:new, :edit]
  before_filter :build_image, only: [:new, :edit]

  private

  def edition_class
    SpecialistGuide
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
