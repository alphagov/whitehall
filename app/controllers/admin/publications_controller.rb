class Admin::PublicationsController < Admin::EditionsController
  include Admin::EditionsController::NationalApplicability
  include Admin::EditionsController::Attachments

  before_filter :build_image, only: [:new, :edit]
  before_filter :build_html_version, only: [:new, :edit]

  private

  def edition_class
    Publication
  end

  def build_html_version
    @edition.build_html_version unless @edition.html_version.present?
  end
end
