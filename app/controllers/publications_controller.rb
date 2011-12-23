class PublicationsController < DocumentsController
  def index
    @publications = Publication.published.includes(:document_identity)
  end

  def show
    @related_policies = @document.published_related_policies
  end

  private

  def document_class
    Publication
  end
end