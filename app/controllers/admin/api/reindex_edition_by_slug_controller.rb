class Admin::Api::ReindexEditionBySlugController < Admin::BaseController
skip_before_filter :verify_authenticity_token, only: [:create]

  def create
    documents_tagged_to_slug.map(&:update_in_search_index)
    render json: {
      result: 'ok',
      number_of_documents_with_slug_updated: documents_tagged_to_slug.count
    }
  end

private

  def slug
    params.fetch(:slug)
  end

  def document_types
    Document.pluck(:document_type).uniq
  end

  def documents_tagged_to_slug
    Edition.
      joins(:document).
      where(documents: { document_type: document_types }).
      where(documents: { slug: slug }).
      uniq
  end
end
