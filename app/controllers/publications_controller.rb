class PublicationsController < DocumentsController
  def index
    @publications = Publication.published.includes(:document_identity)
  end

  def show
    @related_policies = Policy.published.related_to(@document)
  end

  private

  def document_class
    Publication
  end
end