class PublicationsController < DocumentsController
  def index
    @publications = Publication.published
  end

  private

  def document_class
    Publication
  end
end