class Admin::PublicationsController < Admin::DocumentsController
  private

  def document_class
    Publication
  end
end