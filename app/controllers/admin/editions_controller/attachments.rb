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
    @edition.build_empty_attachment
  end
end
