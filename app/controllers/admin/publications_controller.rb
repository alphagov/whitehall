class Admin::PublicationsController < Admin::DocumentsController
  include Admin::DocumentsController::NationalApplicability

  before_filter :build_publication_metadatum, only: [:new]

  private

  def document_class
    Publication
  end

  def build_publication_metadatum
    @document.build_publication_metadatum
  end
end