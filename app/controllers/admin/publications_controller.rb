class Admin::PublicationsController < Admin::EditionsController
  include Admin::EditionsController::NationalApplicability
  include Admin::EditionsController::Attachments

  before_filter :build_html_version, only: [:new, :edit]
  before_filter :build_image, only: [:new, :edit]

  private

  def edition_class
    Publication
  end
end
