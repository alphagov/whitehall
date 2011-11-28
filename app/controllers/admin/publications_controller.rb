class Admin::PublicationsController < Admin::DocumentsController
  include Admin::DocumentsController::NationalApplicability

  private

  def document_class
    Publication
  end
end